import '../../domain/entities/transfer_task.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../transfer_engine/download/download_manager.dart';
import '../../transfer_engine/retry/retry_policy.dart';
import '../../transfer_engine/upload/upload_manager.dart';
import '../data_sources/local/transfer_local_data_source.dart';
import '../data_sources/remote/transfer_remote_data_source.dart';
import '../models/transfer_task_model.dart';

class TransferRepositoryImpl implements TransferRepository {
  const TransferRepositoryImpl({
    required TransferRemoteDataSource remoteDataSource,
    required TransferLocalDataSource localDataSource,
    required UploadManager uploadManager,
    required DownloadManager downloadManager,
    required RetryPolicy retryPolicy,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _uploadManager = uploadManager,
       _downloadManager = downloadManager,
       _retryPolicy = retryPolicy;

  final TransferRemoteDataSource _remoteDataSource;
  final TransferLocalDataSource _localDataSource;
  final UploadManager _uploadManager;
  final DownloadManager _downloadManager;
  final RetryPolicy _retryPolicy;

  @override
  Future<void> startUpload(TransferTask task) async {
    final TransferTaskModel model = TransferTaskModel.fromEntity(task);
    await _localDataSource.saveTransferMetadata(model);
    await _remoteDataSource.upload(model);
  }

  @override
  Future<void> startDownload(TransferTask task) async {
    final TransferTaskModel model = TransferTaskModel.fromEntity(task);
    await _remoteDataSource.download(model);
  }

  @override
  Future<void> retryTransfer(String transferId) async {
    // Intentionally kept as wiring-only scaffold.
    final Object _ = (_uploadManager, _downloadManager, _retryPolicy, transferId);
    throw UnimplementedError('Retry orchestration is not implemented yet.');
  }

  @override
  Future<TransferEntity> sendFiles({
    required UserEntity sender,
    required UserEntity receiver,
    required List<FileEntity> files,
  }) async {
    final Object _ = (sender, receiver, files);
    throw UnimplementedError('Send files is not implemented yet.');
  }

  @override
  Future<TransferEntity> receiveFiles(String transferId) async {
    final Object _ = transferId;
    throw UnimplementedError('Receive files is not implemented yet.');
  }

  @override
  Future<List<TransferEntity>> getTransferHistory(String userId) async {
    final Object _ = userId;
    throw UnimplementedError('Transfer history is not implemented yet.');
  }
}
