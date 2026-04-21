import 'dart:io';

import 'package:crypto/crypto.dart';
import '../../domain/entities/transfer_task.dart';
import '../../domain/entities/selected_transfer_file.dart';
import '../../domain/entities/transfer_batch_progress.dart';
import '../../domain/entities/incoming_transfer_offer.dart';
import '../../domain/entities/profile_interaction_entity.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/entities/transfer_status.dart';
import '../../domain/entities/file_status.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../core/database/isar/collections/transfer_collection.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/realtime_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/transfer_service.dart';
import '../../core/services/background_transfer_runtime_service.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
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
    required RealtimeService realtimeService,
    required Isar isar,
    required UploadManager uploadManager,
    required DownloadManager downloadManager,
    required RetryQueue retryQueue,
    required StorageService storageService,
    required BackgroundTransferRuntimeService backgroundRuntimeService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _transferService = transferService,
       _realtimeService = realtimeService,
       _isar = isar,
       _uploadManager = uploadManager,
       _downloadManager = downloadManager,
       _retryQueue = retryQueue,
       _storageService = storageService,
       _backgroundRuntimeService = backgroundRuntimeService;

  final TransferRemoteDataSource _remoteDataSource;
  final TransferLocalDataSource _localDataSource;
  final TransferService _transferService;
  final RealtimeService _realtimeService;
  final Isar _isar;
  final UploadManager _uploadManager;
  final DownloadManager _downloadManager;
  final RetryQueue _retryQueue;
  final StorageService _storageService;
  final BackgroundTransferRuntimeService _backgroundRuntimeService;

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
    await _backgroundRuntimeService.scheduleRetry(
      transferId: transferId,
      userInitiated: true,
    );
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
      fileName: primaryFile.fileName,
      fileSize: primaryFile.size,
      senderUsername: sender.username,
      receiverUsername: receiver.username,
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
      final bool hasSpace = await hasAvailableStorage(cached.fileSize ?? 0);
      if (!hasSpace) {
        throw const AppException(
          'Not enough storage space to receive this file.',
        );
      }
      return _mapCollectionToEntity(cached);
    }

    throw const AppException(
      'Transfer is not available locally and remote fetch is not configured.',
    );
  }

  @override
  Stream<IncomingTransferOffer> listenIncomingTransfers({
    required String receiverId,
  }) async* {
    final List<TransferSessionRecord> initial = await _transferService
        .getIncomingTransfers(receiverId);
    for (final TransferSessionRecord row in initial) {
      final IncomingTransferOffer? parsed = _mapRecordToIncomingOffer(row);
      if (parsed == null) {
        continue;
      }
      if (await _localDataSource.transferExists(parsed.transferId)) {
        continue;
      }
      await _localDataSource.upsertIncomingTransfer(
        transferId: parsed.transferId,
        senderId: parsed.senderId,
        receiverId: parsed.receiverId,
        senderUsername: null,
        receiverUsername: null,
        fileId: parsed.fileId,
        fileName: parsed.fileName,
        fileSize: parsed.fileSize,
        fileHash: parsed.fileHash,
        storagePath: parsed.storagePath,
        createdAt: parsed.createdAt,
        status: TransferStatus.pending,
      );
      yield parsed;
    }

    await for (final Map<String, dynamic> payload
        in _realtimeService.listenIncomingTransfers(receiverId: receiverId)) {
      final IncomingTransferOffer? offer = _mapPayloadToIncomingOffer(payload);
      if (offer == null) {
        continue;
      }
      final bool exists = await _localDataSource.transferExists(
        offer.transferId,
      );
      if (exists) {
        continue;
      }
      await _localDataSource.upsertIncomingTransfer(
        transferId: offer.transferId,
        senderId: offer.senderId,
        receiverId: offer.receiverId,
        senderUsername: null,
        receiverUsername: null,
        fileId: offer.fileId,
        fileName: offer.fileName,
        fileSize: offer.fileSize,
        fileHash: offer.fileHash,
        storagePath: offer.storagePath,
        createdAt: offer.createdAt,
        status: TransferStatus.pending,
      );
      yield offer;
    }
  }

  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
    bool persistPermanently = true,
  }) async {
    await _backgroundRuntimeService.startActiveTransfer(
      transferId: transfer.transferId,
      fileName: transfer.fileName,
      progressPercent: 0,
    );
    try {
      final bool hasSpace = await hasAvailableStorage(transfer.fileSize);
      if (!hasSpace) {
        throw const AppException(
          'Not enough storage space to receive this file.',
        );
      }

      if (await _localDataSource.fileHashExists(transfer.fileHash)) {
        await _localDataSource.updateTransferStatus(
          transfer.transferId,
          TransferStatus.completed,
        );
        await _localDataSource.updateFileStatusByTransferId(
          transfer.transferId,
          FileStatus.completed,
        );
        await _transferService.updateTransferStatus(
          transferId: transfer.transferId,
          status: TransferStatus.completed.name,
        );
        return;
      }

      await _localDataSource.updateTransferStatus(
        transfer.transferId,
        TransferStatus.downloading,
      );
      await _localDataSource.updateFileStatusByTransferId(
        transfer.transferId,
        FileStatus.uploading,
      );
      await _transferService.updateTransferStatus(
        transferId: transfer.transferId,
        status: TransferStatus.downloading.name,
      );

      final TransferTask task = TransferTask(
        id: transfer.transferId,
        fileName: transfer.fileName,
        totalBytes: transfer.fileSize,
      );
      final List<ChunkDescriptor> chunks = _downloadManager.chunkPlanFor(task);
      _downloadManager.registerSession(
        TransferResumeState.fromTask(
          task,
          direction: TransferSessionDirection.download,
        ),
      );

      final List<int> assembled = <int>[];
      try {
        for (final ChunkDescriptor chunk in chunks) {
          int attempt = 0;
          late List<int> bytes;
          while (true) {
            try {
              bytes = await _remoteDataSource.downloadChunk(
                sessionId: transfer.transferId,
                fileId: transfer.fileId,
                chunkIndex: chunk.index,
              );
              break;
            } catch (_) {
              if (!_retryQueue.canRetryAgain(attempt)) {
                rethrow;
              }
              _retryQueue.schedule(
                id: transfer.transferId,
                initiator: RetryInitiator.auto,
                attempt: attempt,
              );
              final Duration delay = _retryQueue.backoffAfterAttempt(attempt);
              attempt += 1;
              await Future<void>.delayed(delay);
            }
          }
          assembled.addAll(bytes);
          _downloadManager.acknowledgeChunkComplete(
            transfer.transferId,
            chunk.index,
          );
          await _backgroundRuntimeService.updateActiveTransfer(
            transferId: transfer.transferId,
            fileName: transfer.fileName,
            progressPercent: _progressPercent(chunk.index + 1, chunks.length),
          );
        }
      } catch (_) {
        await _backgroundRuntimeService.scheduleRetry(
          transferId: transfer.transferId,
          userInitiated: false,
        );
        rethrow;
      }

      final String digest = sha256.convert(assembled).toString();
      if (digest != transfer.fileHash) {
        await _localDataSource.updateTransferStatus(
          transfer.transferId,
          TransferStatus.failed,
        );
        await _localDataSource.updateFileStatusByTransferId(
          transfer.transferId,
          FileStatus.corrupted,
        );
        await _transferService.updateTransferStatus(
          transferId: transfer.transferId,
          status: TransferStatus.failed.name,
        );
        throw const AppException(
          'Received file is corrupted (SHA-256 mismatch).',
        );
      }

      final Directory appDir = persistPermanently
          ? await getApplicationDocumentsDirectory()
          : await getTemporaryDirectory();
      final File target = File(
        '${appDir.path}${Platform.pathSeparator}${transfer.fileName}',
      );
      await target.writeAsBytes(assembled, flush: true);

      await _localDataSource.updateTransferStatus(
        transfer.transferId,
        TransferStatus.completed,
      );
      await _localDataSource.updateFileStatusByTransferId(
        transfer.transferId,
        FileStatus.completed,
      );
      await _transferService.updateTransferStatus(
        transferId: transfer.transferId,
        status: TransferStatus.completed.name,
      );
      await _downloadManager.finalizeSession(transfer.transferId);
    } finally {
      await _backgroundRuntimeService.stopActiveTransfer();
    }
  }

  @override
  Future<void> rejectIncomingTransfer({required String transferId}) async {
    await _localDataSource.updateTransferStatus(
      transferId,
      TransferStatus.cancelled,
    );
    await _localDataSource.updateFileStatusByTransferId(
      transferId,
      FileStatus.failed,
    );
    await _transferService.updateTransferStatus(
      transferId: transferId,
      status: TransferStatus.cancelled.name,
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
  Future<List<ProfileInteractionEntity>> getUserInteractions(
    String userId,
  ) async {
    final List<TransferEntity> history = await getTransferHistory(userId);
    final Map<String, ProfileInteractionEntity> interactionsByUserId =
        <String, ProfileInteractionEntity>{};

    for (final TransferEntity transfer in history) {
      final bool isSender = transfer.senderId == userId;
      final String counterpartId = isSender
          ? transfer.receiverId
          : transfer.senderId;
      final String counterpartUsername = isSender
          ? (transfer.receiverUsername?.trim().isNotEmpty == true
                ? transfer.receiverUsername!
                : 'Unknown user')
          : (transfer.senderUsername?.trim().isNotEmpty == true
                ? transfer.senderUsername!
                : 'Unknown user');

      final ProfileInteractionEntity? existing =
          interactionsByUserId[counterpartId];
      if (existing == null ||
          transfer.createdAt.isAfter(existing.lastInteractionDate)) {
        interactionsByUserId[counterpartId] = ProfileInteractionEntity(
          userId: counterpartId,
          username: counterpartUsername,
          lastInteractionDate: transfer.createdAt,
        );
      }
    }

    final List<ProfileInteractionEntity> unique =
        interactionsByUserId.values.toList(growable: false)..sort(
          (ProfileInteractionEntity a, ProfileInteractionEntity b) =>
              b.lastInteractionDate.compareTo(a.lastInteractionDate),
        );
    return unique;
  }

  @override
  Future<bool> hasAvailableStorage(int requiredBytes) {
    return _storageService.hasSpaceForBytes(requiredBytes);
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

    await _backgroundRuntimeService.startActiveTransfer(
      transferId: sessionId,
      fileName: sortedFiles.first.fileName,
      progressPercent: 0,
    );

    try {
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
          await _backgroundRuntimeService.updateActiveTransfer(
            transferId: sessionId,
            fileName: file.fileName,
            progressPercent: _progressPercent(chunk.index + 1, chunks.length),
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
    } catch (_) {
      await _backgroundRuntimeService.scheduleRetry(
        transferId: sessionId,
        userInitiated: false,
      );
      rethrow;
    } finally {
      await _backgroundRuntimeService.stopActiveTransfer();
    }
  }

  int _progressPercent(int completed, int total) {
    if (total <= 0) {
      return 0;
    }
    final double normalized = completed / total;
    return (normalized * 100).clamp(0, 100).round();
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
        ..senderUsername = transferEntity.senderUsername
        ..receiverUsername = transferEntity.receiverUsername
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
      fileName: collection.fileName ?? 'Unknown file',
      fileSize: collection.fileSize ?? 0,
      senderUsername: collection.senderUsername,
      receiverUsername: collection.receiverUsername,
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

  IncomingTransferOffer? _mapRecordToIncomingOffer(
    TransferSessionRecord record,
  ) {
    return _mapPayloadToIncomingOffer(record.row);
  }

  IncomingTransferOffer? _mapPayloadToIncomingOffer(
    Map<String, dynamic> payload,
  ) {
    final String? transferId = payload['transfer_id'] as String?;
    final String? senderId = payload['sender_id'] as String?;
    final String? receiverId = payload['receiver_id'] as String?;
    final String? fileName = payload['file_name'] as String?;
    final int? fileSize = payload['file_size'] as int?;
    final String? fileHash = payload['file_hash'] as String?;
    if (transferId == null ||
        senderId == null ||
        receiverId == null ||
        fileName == null ||
        fileSize == null ||
        fileHash == null) {
      return null;
    }
    final String fileId =
        (payload['file_id'] as String?) ?? '$transferId-$fileName';
    final String storagePath =
        (payload['storage_path'] as String?) ?? '$transferId/$fileId';
    final String createdAtRaw =
        (payload['created_at'] as String?) ?? DateTime.now().toIso8601String();
    return IncomingTransferOffer(
      transferId: transferId,
      senderId: senderId,
      receiverId: receiverId,
      fileId: fileId,
      fileName: fileName,
      fileSize: fileSize,
      fileHash: fileHash,
      storagePath: storagePath,
      createdAt: DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
    );
  }
}
