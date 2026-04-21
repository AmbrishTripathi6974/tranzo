import '../entities/profile_interaction_entity.dart';
import '../repositories/transfer_repository.dart';

class GetUserInteractions {
  const GetUserInteractions(this._repository);

  final TransferRepository _repository;

  Future<List<ProfileInteractionEntity>> call(String userId) {
    return _repository.getUserInteractions(userId);
  }
}
