import '../repositories/transfer_repository.dart';

class ResumeIncompleteTransfersUseCase {
  const ResumeIncompleteTransfersUseCase(this._repository);

  final TransferRepository _repository;

  Future<void> call({String? transferId}) =>
      _repository.resumeIncompleteTransfers(transferId: transferId);
}
