import '../entities/transfer_task.dart';

abstract interface class TransferRepository {
  Future<void> startUpload(TransferTask task);
  Future<void> startDownload(TransferTask task);
  Future<void> retryTransfer(String transferId);
}
