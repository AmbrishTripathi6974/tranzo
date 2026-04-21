import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetUserProfile {
  const GetUserProfile(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() {
    return _repository.getCurrentUser();
  }
}
