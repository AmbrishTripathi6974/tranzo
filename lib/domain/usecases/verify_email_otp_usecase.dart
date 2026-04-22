import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  const VerifyEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String otpCode,
  }) {
    return _repository.verifyEmailOtp(email: email, otpCode: otpCode);
  }
}
