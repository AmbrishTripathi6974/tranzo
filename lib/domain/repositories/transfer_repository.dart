import '../entities/transfer_task.dart';
import '../entities/user_entity.dart';
import '../entities/transfer_entity.dart';
import '../entities/file_entity.dart';

abstract interface class TransferRepository {
  // Legacy transfer-task API kept for existing wiring.
  Future<void> startUpload(TransferTask task);
  Future<void> startDownload(TransferTask task);
  Future<void> retryTransfer(String transferId);

  // New domain contracts for transfer lifecycle use cases.
  Future<TransferEntity> sendFiles({
    required UserEntity sender,
    required UserEntity receiver,
    required List<FileEntity> files,
  });

  Future<TransferEntity> receiveFiles(String transferId);

  Future<List<TransferEntity>> getTransferHistory(String userId);
}
