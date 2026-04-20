import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<UserEntity> createUser({
    required String shortCode,
    required String username,
  });

  Future<UserEntity?> getCurrentUser();
}
