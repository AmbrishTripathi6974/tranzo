import '../repositories/transfer_repository.dart';

class RetryTransferUseCase {
  const RetryTransferUseCase(this._repository);

  final TransferRepository _repository;

  Future<void> call(String transferId) => _repository.retryTransfer(transferId);
}
