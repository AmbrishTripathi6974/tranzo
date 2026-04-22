import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<void> sendEmailOtp({required String email});

  Future<UserEntity> verifyEmailOtp({
    required String email,
    required String otpCode,
  });

  Future<void> signOut();

  Future<UserEntity> getCurrentUser();
}
