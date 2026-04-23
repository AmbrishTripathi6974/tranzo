import 'dart:async';
import 'dart:developer' as developer;
import 'package:isar_community/isar.dart';

import '../../core/database/isar/collections/user_collection.dart';
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
  static const Duration _sessionLookupTimeout = Duration(seconds: 4);
  static const UserEntity _unauthenticatedUser = UserEntity(
    id: '',
    shortCode: '',
    username: '',
  );
  @override
  Future<void> sendEmailOtp({required String email}) {
    return _authService.sendEmailOtp(email: email);
  }

  @override
  Future<UserEntity> verifyEmailOtp({
    required String email,
    required String otpCode,
  }) async {
    final UserSessionSnapshot snapshot = await _authService.verifyEmailOtp(
      email: email,
      otpCode: otpCode,
    );
    final UserCollection fromSession = UserCollection()
      ..supabaseUserId = snapshot.userId
      ..email = snapshot.email
      ..displayName = snapshot.username
      ..shortCode = snapshot.shortCode
      ..updatedAt = DateTime.now();
    await _isar
        .writeTxn(() async {
          await _isar.userCollections.put(fromSession);
        })
        .timeout(_initTimeout);
    return _entityFromCollection(fromSession);
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    try {
      final UserCollection? cached = await _isar.userCollections
          .where()
          .findFirst()
          .timeout(_initTimeout);
      if (cached != null) {
        UserSessionSnapshot? remoteSnapshot;
        try {
          remoteSnapshot = await _authService
              .loadCurrentSessionProfile()
              .timeout(_sessionLookupTimeout);
        } on TimeoutException {
          // Hot restarts can race Supabase session hydration.
          remoteSnapshot = null;
        }
        if (remoteSnapshot != null) {
          final bool needsRefresh =
              cached.supabaseUserId != remoteSnapshot.userId ||
              (cached.email ?? '') != remoteSnapshot.email ||
              (cached.displayName ?? '') != remoteSnapshot.username ||
              (cached.shortCode ?? '') != remoteSnapshot.shortCode;
          if (needsRefresh) {
            await _isar
                .writeTxn(() async {
                  cached.supabaseUserId = remoteSnapshot!.userId;
                  cached.email = remoteSnapshot.email;
                  cached.displayName = remoteSnapshot.username;
                  cached.shortCode = remoteSnapshot.shortCode;
                  cached.updatedAt = DateTime.now();
                  await _isar.userCollections.put(cached);
                })
                .timeout(_initTimeout);
          }
        }
        final String? pinnedCode = await _authService.getPersistedRecipientCode(
          cached.supabaseUserId,
        );
        if ((cached.shortCode == null || cached.shortCode!.isEmpty) &&
            pinnedCode != null &&
            pinnedCode.isNotEmpty) {
          await _isar
              .writeTxn(() async {
                cached.shortCode = pinnedCode;
                cached.updatedAt = DateTime.now();
                await _isar.userCollections.put(cached);
              })
              .timeout(_initTimeout);
        } else if (cached.shortCode != null && cached.shortCode!.isNotEmpty) {
          await _authService.persistRecipientCode(
            cached.supabaseUserId,
            cached.shortCode!,
          );
        }
        final UserEntity localUser = _entityFromCollection(cached);
        developer.log(
          'user_loaded_from_local',
          name: 'auth',
          error: <String, Object?>{
            'userId': localUser.id,
            'shortCode': localUser.shortCode,
            'remoteSessionRecovered': remoteSnapshot != null,
          },
        );
        return localUser;
      }

      UserSessionSnapshot? snapshot;
      try {
        snapshot = await _authService.loadCurrentSessionProfile().timeout(
          _sessionLookupTimeout,
        );
      } on TimeoutException {
        // Do not block local-first init on session recovery delays.
        snapshot = null;
      }
      if (snapshot != null) {
        await _authService.persistRecipientCode(
          snapshot.userId,
          snapshot.shortCode,
        );
        final UserCollection fromSession = UserCollection()
          ..supabaseUserId = snapshot.userId
          ..email = snapshot.email
          ..displayName = snapshot.username
          ..shortCode = snapshot.shortCode
          ..updatedAt = DateTime.now();
        await _isar
            .writeTxn(() async {
              await _isar.userCollections.put(fromSession);
            })
            .timeout(_initTimeout);
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
      return _unauthenticatedUser;
    } on TimeoutException {
      throw TimeoutException('Current user initialization timed out.');
    }
  }

  UserEntity _entityFromCollection(UserCollection cached) {
    final String displayName = (cached.displayName ?? '').trim();
    final String email = (cached.email ?? '').trim();
    final UserModel userModel = UserModel(
      id: cached.supabaseUserId,
      shortCode: cached.shortCode ?? '',
      username: displayName.isNotEmpty
          ? displayName
          : (email.isNotEmpty ? email : cached.supabaseUserId),
    );
    return userModel.toEntity();
  }
}
