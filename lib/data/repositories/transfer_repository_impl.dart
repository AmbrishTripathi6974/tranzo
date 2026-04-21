import 'dart:io';

import '../../domain/entities/transfer_task.dart';
import '../../domain/entities/selected_transfer_file.dart';
import '../../domain/entities/transfer_batch_progress.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/entities/transfer_status.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../core/database/isar/collections/transfer_collection.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/transfer_service.dart';
import 'package:isar_community/isar.dart';
import '../../transfer_engine/download/download_manager.dart';
import '../../transfer_engine/retry/retry_queue.dart';
import '../../transfer_engine/chunking/chunk_manager.dart';
import '../../transfer_engine/upload/upload_manager.dart';
import '../../transfer_engine/state/transfer_state_manager.dart';
import '../datasources/local/transfer_local_data_source.dart';
import '../datasources/remote/transfer_remote_data_source.dart';
import '../models/transfer_task_model.dart';

class TransferRepositoryImpl implements TransferRepository {
  const TransferRepositoryImpl({
    required TransferRemoteDataSource remoteDataSource,
    required TransferLocalDataSource localDataSource,
    required TransferService transferService,
    required Isar isar,
    required UploadManager uploadManager,
    required DownloadManager downloadManager,
    required RetryQueue retryQueue,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _transferService = transferService,
       _isar = isar,
       _uploadManager = uploadManager,
       _downloadManager = downloadManager,
       _retryQueue = retryQueue;

  final TransferRemoteDataSource _remoteDataSource;
  final TransferLocalDataSource _localDataSource;
  final TransferService _transferService;
  final Isar _isar;
  final UploadManager _uploadManager;
  final DownloadManager _downloadManager;
  final RetryQueue _retryQueue;

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
    final Object _ = (
      _uploadManager,
      _downloadManager,
      _retryQueue,
      transferId,
    );
    throw UnimplementedError('Retry orchestration is not implemented yet.');
  }

  @override
  Future<TransferEntity> sendFiles({
    required UserEntity sender,
    required UserEntity receiver,
    required List<FileEntity> files,
  }) async {
    if (files.isEmpty) {
      throw const AppException('At least one file is required to send.');
    }

    final FileEntity primaryFile = files.first;
    final DateTime now = DateTime.now();
    final String transferId = primaryFile.transferId.isNotEmpty
        ? primaryFile.transferId
        : '${sender.id}_${now.microsecondsSinceEpoch}';
    final TransferSessionRecord remoteSession = await _transferService
        .createTransferSession(
          TransferSessionPayload(
            transferId: transferId,
            senderId: sender.id,
            receiverId: receiver.id,
            fileName: primaryFile.fileName,
            fileSize: primaryFile.size,
            fileHash: primaryFile.hash,
            status: TransferStatus.pending.name,
            storagePath: '',
            createdAt: now,
          ),
        );

    final transferEntity = TransferEntity(
      id: remoteSession.transferId,
      senderId: remoteSession.senderId,
      receiverId: remoteSession.receiverId,
      status: TransferStatus.pending,
      createdAt: now,
      expiresAt: null,
    );

    await _upsertLocalTransfer(
      transferEntity: transferEntity,
      fileName: primaryFile.fileName,
      fileSize: primaryFile.size,
      fileHash: primaryFile.hash,
      storagePath: '',
      intentScore: null,
      intentExpiry: null,
    );

    return transferEntity;
  }

  @override
  Future<TransferEntity> receiveFiles(String transferId) async {
    final TransferCollection? cached = await _isar.transferCollections
        .filter()
        .transferIdEqualTo(transferId)
        .findFirst();
    if (cached != null) {
      return _mapCollectionToEntity(cached);
    }

    throw const AppException(
      'Transfer is not available locally and remote fetch is not configured.',
    );
  }

  @override
  Future<List<TransferEntity>> getTransferHistory(String userId) async {
    final List<TransferCollection> localTransfers = await _isar
        .transferCollections
        .where()
        .findAll();
    localTransfers.sort(
      (TransferCollection a, TransferCollection b) =>
          b.createdAt.compareTo(a.createdAt),
    );
    return localTransfers
        .where(
          (TransferCollection transfer) =>
              transfer.senderId == userId || transfer.receiverId == userId,
        )
        .map(_mapCollectionToEntity)
        .toList(growable: false);
  }

  @override
  Stream<TransferBatchProgress> sendFilesInBatch({
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  }) async* {
    if (files.isEmpty) {
      throw const AppException('At least one file is required to send.');
    }

    final String? receiverId = await _transferService.resolveRecipientIdByCode(
      recipientCode,
    );
    if (receiverId == null) {
      throw const AppException('Invalid recipient code.');
    }

    final List<SelectedTransferFile> sortedFiles =
        List<SelectedTransferFile>.from(files)..sort(
          (SelectedTransferFile a, SelectedTransferFile b) =>
              a.sizeBytes.compareTo(b.sizeBytes),
        );
    for (final SelectedTransferFile file in sortedFiles) {
      if (file.sizeBytes > AppConstants.maxTransferFileSizeBytes) {
        throw AppException('File exceeds 1GB max size: ${file.fileName}');
      }
    }

    final String sessionId =
        '${senderId}_${DateTime.now().microsecondsSinceEpoch}';
    final List<TransferFileProgress> progress = sortedFiles
        .map(
          (SelectedTransferFile file) => TransferFileProgress(
            fileId: file.id,
            fileName: file.fileName,
            progress: 0,
            status: TransferFileProgressStatus.pending,
          ),
        )
        .toList(growable: false);

    yield TransferBatchProgress(sessionId: sessionId, files: progress);

    for (final SelectedTransferFile file in sortedFiles) {
      final TransferSessionRecord session = await _transferService
          .createTransferSession(
            TransferSessionPayload(
              transferId: sessionId,
              senderId: senderId,
              receiverId: receiverId,
              fileName: file.fileName,
              fileSize: file.sizeBytes,
              fileHash: '${file.fileName}_${file.sizeBytes}',
              status: TransferStatus.uploading.name,
              storagePath: '$sessionId/${file.id}',
              createdAt: DateTime.now(),
            ),
          );
      final TransferTask task = TransferTask(
        id: file.id,
        fileName: file.fileName,
        totalBytes: file.sizeBytes,
        localPath: file.localPath,
      );
      final List<ChunkDescriptor> chunks = _uploadManager.chunkPlanFor(task);
      _uploadManager.registerSession(
        TransferResumeState.fromTask(
          task,
          direction: TransferSessionDirection.upload,
        ),
      );
      final File source = File(file.localPath);

      _replaceProgress(
        progress,
        TransferFileProgress(
          fileId: file.id,
          fileName: file.fileName,
          progress: 0,
          status: TransferFileProgressStatus.uploading,
        ),
      );
      yield TransferBatchProgress(
        sessionId: sessionId,
        files: List<TransferFileProgress>.from(progress),
      );

      for (final ChunkDescriptor chunk in chunks) {
        final Stream<List<int>> bytes = source.openRead(
          chunk.startByte,
          chunk.endByteExclusive,
        );
        await _remoteDataSource.uploadChunk(
          sessionId: session.transferId,
          fileId: file.id,
          chunkIndex: chunk.index,
          byteStream: bytes,
        );
        _uploadManager.acknowledgeChunkComplete(file.id, chunk.index);

        final double fileProgress = (chunk.index + 1) / chunks.length;
        _replaceProgress(
          progress,
          TransferFileProgress(
            fileId: file.id,
            fileName: file.fileName,
            progress: fileProgress,
            status: TransferFileProgressStatus.uploading,
          ),
        );
        yield TransferBatchProgress(
          sessionId: sessionId,
          files: List<TransferFileProgress>.from(progress),
        );
      }

      _replaceProgress(
        progress,
        TransferFileProgress(
          fileId: file.id,
          fileName: file.fileName,
          progress: 1,
          status: TransferFileProgressStatus.completed,
        ),
      );
      yield TransferBatchProgress(
        sessionId: sessionId,
        files: List<TransferFileProgress>.from(progress),
      );
    }
  }

  Future<void> _upsertLocalTransfer({
    required TransferEntity transferEntity,
    required String fileName,
    required int fileSize,
    required String fileHash,
    required String storagePath,
    required double? intentScore,
    required DateTime? intentExpiry,
  }) async {
    await _isar.writeTxn(() async {
      final TransferCollection row = TransferCollection()
        ..transferId = transferEntity.id
        ..senderId = transferEntity.senderId
        ..receiverId = transferEntity.receiverId
        ..status = transferEntity.status
        ..createdAt = transferEntity.createdAt
        ..expiresAt = transferEntity.expiresAt
        ..fileName = fileName
        ..fileSize = fileSize
        ..fileHash = fileHash
        ..storagePath = storagePath
        ..intentScore = intentScore
        ..intentExpiry = intentExpiry;
      await _isar.transferCollections.put(row);
    });
  }

  TransferEntity _mapCollectionToEntity(TransferCollection collection) {
    return TransferEntity(
      id: collection.transferId,
      senderId: collection.senderId,
      receiverId: collection.receiverId,
      status: collection.status,
      createdAt: collection.createdAt,
      expiresAt: collection.expiresAt,
    );
  }

  void _replaceProgress(
    List<TransferFileProgress> progress,
    TransferFileProgress next,
  ) {
    final int index = progress.indexWhere(
      (TransferFileProgress item) => item.fileId == next.fileId,
    );
    if (index == -1) {
      return;
    }
    progress[index] = next;
  }
}
