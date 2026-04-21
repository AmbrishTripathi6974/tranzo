import '../entities/transfer_task.dart';
import '../entities/user_entity.dart';
import '../entities/transfer_entity.dart';
import '../entities/file_entity.dart';
import '../entities/selected_transfer_file.dart';
import '../entities/transfer_batch_progress.dart';
import '../entities/incoming_transfer_offer.dart';

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

  Stream<TransferBatchProgress> sendFilesInBatch({
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  });

  Stream<IncomingTransferOffer> listenIncomingTransfers({
    required String receiverId,
  });

  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
  });

  Future<void> rejectIncomingTransfer({required String transferId});
}
