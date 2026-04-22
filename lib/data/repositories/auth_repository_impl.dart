import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:isar_community/isar.dart';

import '../../core/database/isar/collections/user_collection.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/auth_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthService authService,
    required Isar isar,
  }) : _authService = authService,
       _isar = isar;

  final AuthService _authService;
  final Isar _isar;
  static const Duration _initTimeout = Duration(seconds: 5);
  static const Duration _sessionLookupTimeout = Duration(seconds: 1);
  static const String _localUserIdPrefix = 'local_';
  static const String _shortCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int _shortCodeLength = 6;
  static const int _shortCodeMaxAttempts = 12;

  @override
  Future<UserEntity> createUser({
    required String shortCode,
    required String username,
  }) async {
    final Object _ = shortCode;
    try {
      final result = await _authService
          .createAnonymousUserWithShortCode()
          .timeout(_initTimeout);
      final userModel = UserModel(
        id: result.userId,
        shortCode: result.shortCode,
        username: username,
      );

      await _isar.writeTxn(() async {
        final userCollection = UserCollection()
          ..supabaseUserId = userModel.id
          ..displayName = userModel.username
          ..shortCode = userModel.shortCode
          ..updatedAt = DateTime.now();
        await _isar.userCollections.put(userCollection);
      }).timeout(_initTimeout);

      return userModel.toEntity();
    } on TimeoutException {
      throw TimeoutException('User creation timed out.');
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    try {
      final UserCollection? cached = await _isar.userCollections
          .where()
          .findFirst()
          .timeout(_initTimeout);
      if (cached != null) {
        final String? pinnedCode = await _authService.getPersistedRecipientCode();
        if ((cached.shortCode == null || cached.shortCode!.isEmpty) &&
            pinnedCode != null &&
            pinnedCode.isNotEmpty) {
          await _isar.writeTxn(() async {
            cached.shortCode = pinnedCode;
            cached.updatedAt = DateTime.now();
            await _isar.userCollections.put(cached);
          }).timeout(_initTimeout);
        } else if (cached.shortCode != null && cached.shortCode!.isNotEmpty) {
          await _authService.persistRecipientCode(cached.shortCode!);
        }
        final UserEntity localUser = _entityFromCollection(cached);
        developer.log(
          'user_loaded_from_local',
          name: 'auth',
          error: <String, Object?>{
            'userId': localUser.id,
            'shortCode': localUser.shortCode,
          },
        );
        return localUser;
      }

      UserSessionSnapshot? snapshot;
      try {
        snapshot = await _authService
            .loadCurrentSessionProfile()
            .timeout(_sessionLookupTimeout);
      } on TimeoutException {
        // Do not block local-first init on session recovery delays.
        snapshot = null;
      }
      if (snapshot != null) {
        await _authService.persistRecipientCode(snapshot.shortCode);
        final UserCollection fromSession = UserCollection()
          ..supabaseUserId = snapshot.userId
          ..displayName = snapshot.username
          ..shortCode = snapshot.shortCode
          ..updatedAt = DateTime.now();
        await _isar.writeTxn(() async {
          await _isar.userCollections.put(fromSession);
        }).timeout(_initTimeout);
        final UserEntity remoteUser = _entityFromCollection(fromSession);
        developer.log(
          'user_loaded_from_remote_session',
          name: 'auth',
          error: <String, Object?>{
            'userId': remoteUser.id,
            'shortCode': remoteUser.shortCode,
          },
        );
        return remoteUser;
      }

      UserCollection userCollection;
      try {
        final created = await _authService
            .createAnonymousUserWithShortCode()
            .timeout(_initTimeout);
        userCollection = UserCollection()
          ..supabaseUserId = created.userId
          ..displayName = 'User'
          ..shortCode = created.shortCode
          ..updatedAt = DateTime.now();
        await _authService.persistRecipientCode(created.shortCode);
      } on AppException catch (e) {
        if (!_canUseLocalOnlyFallback(e)) {
          rethrow;
        }
        userCollection = await _createLocalOnlyUserCollection();
        developer.log(
          'user_created_local_only_fallback',
          name: 'auth',
          error: <String, Object?>{'reason': e.message},
        );
      }

      await _isar.writeTxn(() async {
        await _isar.userCollections.put(userCollection);
      }).timeout(_initTimeout);

      final UserEntity createdUser = _entityFromCollection(userCollection);
      developer.log(
        'user_created',
        name: 'auth',
        error: <String, Object?>{
          'userId': createdUser.id,
          'shortCode': createdUser.shortCode,
        },
      );
      return createdUser;
    } on TimeoutException {
      throw TimeoutException('Current user initialization timed out.');
    }
  }

  UserEntity _entityFromCollection(UserCollection cached) {
    final UserModel userModel = UserModel(
      id: cached.supabaseUserId,
      shortCode: cached.shortCode ?? '',
      username: cached.displayName ?? '',
    );
    return userModel.toEntity();
  }

  bool _canUseLocalOnlyFallback(AppException exception) {
    final String message = exception.message.toLowerCase();
    return message.contains('email rate limit') ||
        message.contains('over_email_send_rate_limit') ||
        message.contains('anonymous sign') ||
        message.contains('anonymous auth');
  }

  Future<UserCollection> _createLocalOnlyUserCollection() async {
    final String? pinned = await _authService.getPersistedRecipientCode();
    final Random random = Random.secure();
    String shortCode = pinned ?? await _generateUniqueLocalShortCode(random);
    if (pinned != null) {
      final List<UserCollection> users = await _isar.userCollections
          .where()
          .findAll()
          .timeout(_initTimeout);
      final bool exists = users.any((UserCollection user) {
        return (user.shortCode ?? '').toUpperCase() == pinned;
      });
      if (exists) {
        shortCode = await _generateUniqueLocalShortCode(random);
      }
    }
    await _authService.persistRecipientCode(shortCode);
    final String localId =
        '$_localUserIdPrefix${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(1 << 31)}';
    return UserCollection()
      ..supabaseUserId = localId
      ..displayName = 'User'
      ..shortCode = shortCode
      ..updatedAt = DateTime.now();
  }

  Future<String> _generateUniqueLocalShortCode(Random random) async {
    for (int attempt = 0; attempt < _shortCodeMaxAttempts; attempt++) {
      final String candidate = _randomShortCode(random);
      final List<UserCollection> users = await _isar.userCollections
          .where()
          .findAll()
          .timeout(_initTimeout);
      final bool exists = users.any((UserCollection user) {
        return (user.shortCode ?? '').toUpperCase() == candidate;
      });
      if (!exists) {
        return candidate;
      }
    }
    throw const AppException('Could not allocate a local short code.');
  }

  String _randomShortCode(Random random) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < _shortCodeLength; i++) {
      buffer.write(_shortCodeAlphabet[random.nextInt(_shortCodeAlphabet.length)]);
    }
    return buffer.toString();
  }
}
