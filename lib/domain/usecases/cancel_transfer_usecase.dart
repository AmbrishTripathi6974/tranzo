import '../repositories/transfer_repository.dart';

class CancelTransferUseCase {
  const CancelTransferUseCase(this._repository);

  final TransferRepository _repository;

  Future<void> call(String transferId) =>
      _repository.cancelTransfer(transferId);
}
