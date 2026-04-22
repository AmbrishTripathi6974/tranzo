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

  /// [Supabase.initialize] starts [recoverSession] without awaiting it; a
  /// short retry window avoids null profile loads right after cold start.
  Future<UserSessionSnapshot?> _loadSessionSnapshotWithRetry() async {
    for (var attempt = 0; attempt < 4; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 160));
      }
      final UserSessionSnapshot? snapshot =
          await _authService.loadCurrentSessionProfile();
      if (snapshot != null) {
        return snapshot;
      }
    }
    return null;
  }

  @override
  Future<UserEntity> createUser({
    required String shortCode,
    required String username,
  }) async {
    final Object _ = shortCode;
    final result = await _authService.createAnonymousUserWithShortCode();
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
    });

    return userModel.toEntity();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final UserCollection? cached = await _isar.userCollections
        .where()
        .findFirst();
    if (cached != null) {
      final UserEntity fromCache = _entityFromCollection(cached);
      if (fromCache.shortCode.isNotEmpty) {
        return fromCache;
      }
      final UserSessionSnapshot? snapshot =
          await _loadSessionSnapshotWithRetry();
      if (snapshot != null &&
          snapshot.userId == cached.supabaseUserId &&
          snapshot.shortCode.isNotEmpty) {
        await _isar.writeTxn(() async {
          cached.shortCode = snapshot.shortCode;
          cached.displayName = snapshot.username;
          cached.updatedAt = DateTime.now();
          await _isar.userCollections.put(cached);
        });
        return UserEntity(
          id: snapshot.userId,
          shortCode: snapshot.shortCode,
          username: snapshot.username,
        );
      }
      return fromCache;
    }

    final UserSessionSnapshot? snapshot =
        await _loadSessionSnapshotWithRetry();
    if (snapshot == null) {
      return null;
    }

    await _isar.writeTxn(() async {
      final UserCollection userCollection = UserCollection()
        ..supabaseUserId = snapshot.userId
        ..displayName = snapshot.username
        ..shortCode = snapshot.shortCode
        ..updatedAt = DateTime.now();
      await _isar.userCollections.put(userCollection);
    });

    return UserEntity(
      id: snapshot.userId,
      shortCode: snapshot.shortCode,
      username: snapshot.username,
    );
  }

  UserEntity _entityFromCollection(UserCollection cached) {
    final UserModel userModel = UserModel(
      id: cached.supabaseUserId,
      shortCode: cached.shortCode ?? '',
      username: cached.displayName ?? '',
    );
    return userModel.toEntity();
  }
}
