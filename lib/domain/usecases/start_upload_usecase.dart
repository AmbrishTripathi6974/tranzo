import '../entities/transfer_task.dart';
import '../repositories/transfer_repository.dart';

class StartUploadUseCase {
  const StartUploadUseCase(this._repository);

  final TransferRepository _repository;

  Future<void> call(TransferTask task) => _repository.startUpload(task);
}
