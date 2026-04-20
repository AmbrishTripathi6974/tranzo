import '../../domain/entities/transfer_task.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../models/transfer_task_model.dart';
import '../services/network/transfer_api_service.dart';
import '../services/storage/file_storage_service.dart';
import '../transfer_engine/download/download_manager.dart';
import '../transfer_engine/retry/retry_policy.dart';
import '../transfer_engine/upload/upload_manager.dart';

class TransferRepositoryImpl implements TransferRepository {
  const TransferRepositoryImpl({
    required TransferApiService apiService,
    required FileStorageService storageService,
    required UploadManager uploadManager,
    required DownloadManager downloadManager,
    required RetryPolicy retryPolicy,
  }) : _apiService = apiService,
       _storageService = storageService,
       _uploadManager = uploadManager,
       _downloadManager = downloadManager,
       _retryPolicy = retryPolicy;

  final TransferApiService _apiService;
  final FileStorageService _storageService;
  final UploadManager _uploadManager;
  final DownloadManager _downloadManager;
  final RetryPolicy _retryPolicy;

  @override
  Future<void> startUpload(TransferTask task) async {
    final TransferTaskModel model = TransferTaskModel(
      id: task.id,
      fileName: task.fileName,
      totalBytes: task.totalBytes,
    );
    await _storageService.saveTransferMetadata(model);
    await _apiService.upload(model);
  }

  @override
  Future<void> startDownload(TransferTask task) async {
    final TransferTaskModel model = TransferTaskModel(
      id: task.id,
      fileName: task.fileName,
      totalBytes: task.totalBytes,
    );
    await _apiService.download(model);
  }

  @override
  Future<void> retryTransfer(String transferId) async {
    // Intentionally left as wiring-only scaffold for future retry orchestration.
    final Object _ = (_uploadManager, _downloadManager, _retryPolicy, transferId);
    throw UnimplementedError('Retry orchestration is not implemented yet.');
  }
}
