import '../entities/transfer_entity.dart';
import '../repositories/transfer_repository.dart';

class GetTransferHistory {
  const GetTransferHistory(this._repository);

  final TransferRepository _repository;

  Future<List<TransferEntity>> call(String userId) {
    return _repository.getTransferHistory(userId);
  }
}
