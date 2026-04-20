import '../entities/transfer_entity.dart';
import '../repositories/transfer_repository.dart';

class ReceiveFiles {
  const ReceiveFiles(this._repository);

  final TransferRepository _repository;

  Future<TransferEntity> call(String transferId) {
    return _repository.receiveFiles(transferId);
  }
}
