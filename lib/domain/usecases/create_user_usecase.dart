import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CreateUser {
  const CreateUser(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String shortCode,
    required String username,
  }) {
    return _repository.createUser(shortCode: shortCode, username: username);
  }
}
