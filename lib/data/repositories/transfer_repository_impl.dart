import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;

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
import '../../domain/entities/transfer_lifecycle_signal.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../core/database/isar/collections/transfer_collection.dart';
import '../../core/database/isar/collections/queued_transfer_collection.dart';
import '../../core/database/isar/collections/sender_trust_collection.dart';
import '../../core/database/isar/collections/user_collection.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../core/security/sha256_hasher.dart';
import '../../core/services/realtime_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/transfer_service.dart';
import '../../core/services/background_transfer_runtime_service.dart';
import '../../core/services/android_downloads_exporter.dart';
import '../../core/services/received_file_save_location.dart';
import '../../core/services/received_gallery_exporter.dart';
import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../transfer_engine/download/download_manager.dart';
import '../../transfer_engine/retry/retry_queue.dart';
import '../../transfer_engine/chunking/chunk_manager.dart';
import '../../transfer_engine/upload/upload_manager.dart';
import '../../transfer_engine/state/transfer_state_manager.dart';
import '../datasources/local/transfer_local_data_source.dart';
import '../datasources/remote/transfer_remote_data_source.dart';
import '../models/transfer_task_model.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl({
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
    required NetworkInfo networkInfo,
    required Sha256Hasher sha256Hasher,
    Duration incomingPollInterval = const Duration(seconds: 3),
    Duration signalPollInterval = const Duration(seconds: 2),
    Duration pollingErrorBackoffMax = const Duration(seconds: 30),
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _transferService = transferService,
       _realtimeService = realtimeService,
       _isar = isar,
       _uploadManager = uploadManager,
       _downloadManager = downloadManager,
       _retryQueue = retryQueue,
       _storageService = storageService,
       _backgroundRuntimeService = backgroundRuntimeService,
       _networkInfo = networkInfo,
       _sha256Hasher = sha256Hasher,
       _incomingPollInterval = incomingPollInterval,
       _signalPollInterval = signalPollInterval,
       _pollingErrorBackoffMax = pollingErrorBackoffMax {
    _networkInfo.onConnectionChanged.listen((NetworkConnectionType type) {
      if (type != NetworkConnectionType.none) {
        _flushSignalQueue();
        unawaited(_replayOfflineQueuedTransfers());
      }
    });
  }

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
  final NetworkInfo _networkInfo;
  final Sha256Hasher _sha256Hasher;
  final Duration _incomingPollInterval;
  final Duration _signalPollInterval;
  final Duration _pollingErrorBackoffMax;
  final List<TransferLifecycleSignal> _pendingSignals =
      <TransferLifecycleSignal>[];
  final Set<String> _activeTransferLocks = <String>{};
  final Set<String> _cancelledTransferIds = <String>{};
  final Map<String, int> _backgroundRetryAttempts = <String, int>{};
  bool _isFlushingSignals = false;
  bool _isResumingTransfers = false;
  DateTime? _lastProgressSyncAt;
  static const int _maxIntegrityRetries = 3;
  static const String _offlineQueueStatusPending = 'pending';
  static const String _offlineQueueStatusExpired = 'expired';
  static const String _localUserIdPrefix = 'local_';
  static const String _insufficientStorageMessage =
      'Insufficient storage. Free up space to receive this file.';
  static const Duration _trustedSenderTtl = Duration(hours: 24);

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
    developer.log(
      'retry_requested_by_user',
      name: 'transfer',
      error: <String, Object?>{'transferId': transferId, 'userInitiated': true},
    );
    await resumeIncompleteTransfers(transferId: transferId);
  }

  @override
  Future<void> cancelTransfer(String transferId) async {
    _cancelledTransferIds.add(transferId);
    _activeTransferLocks.removeWhere(
      (String id) => id.startsWith('$transferId:'),
    );
    await _backgroundRuntimeService.cancelRetry(transferId: transferId);
    _clearRetryState(transferId);
    await _backgroundRuntimeService.stopActiveTransfer(transferId: transferId);
    await _localDataSource.updateTransferStatus(
      transferId,
      TransferStatus.cancelled,
    );
    await _localDataSource.clearTransferProgress(transferId);
    try {
      await _transferService.updateTransfersV2Status(
        transferUuid: transferId,
        status: TransferStatus.cancelled.name,
      );
    } catch (_) {
      try {
        await _transferService.updateTransferStatus(
          transferId: transferId,
          status: TransferStatus.cancelled.name,
        );
      } catch (_) {}
    }
    developer.log(
      'transfer_cancelled',
      name: 'transfer',
      error: <String, Object?>{'transferId': transferId},
    );
  }

  @override
  Future<void> resumeIncompleteTransfers({String? transferId}) async {
    if (_isResumingTransfers) {
      return;
    }
    _isResumingTransfers = true;
    final List<TransferResumeState> pending = await _localDataSource
        .getIncompleteTransferProgress();
    try {
      for (final TransferResumeState state in pending) {
        if (transferId != null && state.transferId != transferId) {
          continue;
        }
        if (_cancelledTransferIds.contains(state.transferId)) {
          continue;
        }
        final String lockId = '${state.transferId}:${state.fileId}';
        if (_activeTransferLocks.contains(lockId)) {
          continue;
        }
        _activeTransferLocks.add(lockId);
        try {
          if (state.direction == TransferSessionDirection.upload) {
            _uploadManager.registerSession(state.copyWith(status: 'uploading'));
          } else {
            _downloadManager.registerSession(
              state.copyWith(status: 'downloading'),
            );
          }
          developer.log(
            'transfer_resumed_from_local_state',
            name: 'transfer',
            error: <String, Object?>{
              'transferId': state.transferId,
              'fileId': state.fileId,
              'uploadedChunks': state.completedChunkIndexes.length,
              'totalChunks': state.totalChunks,
            },
          );
        } finally {
          _activeTransferLocks.remove(lockId);
        }
      }
    } finally {
      _isResumingTransfers = false;
    }
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
        throw const AppException(_insufficientStorageMessage);
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
  }) {
    final StreamController<IncomingTransferOffer> controller =
        StreamController<IncomingTransferOffer>();
    final Set<String> seenIncomingKeys = <String>{};
    bool disposed = false;
    StreamSubscription<TransferLifecycleSignal>? realtimeSubscription;
    StreamSubscription<Map<String, dynamic>>? transfersV2Subscription;

    TransferStatus statusFromCloud(String? raw) {
      switch ((raw ?? '').trim().toLowerCase()) {
        case 'queued':
          return TransferStatus.queued;
        case 'uploading':
          return TransferStatus.uploading;
        case 'uploaded':
          return TransferStatus.uploaded;
        case 'downloading':
          return TransferStatus.downloading;
        case 'completed':
          return TransferStatus.completed;
        case 'failed':
          return TransferStatus.failed;
        case 'cancelled':
          return TransferStatus.cancelled;
        default:
          return TransferStatus.pending;
      }
    }

    Future<void> emitIncoming(IncomingTransferOffer offer) async {
      if (offer.trustStatus == SenderTrustStatus.blocked) {
        await _rejectBlockedIncoming(offer);
        return;
      }
      if (offer.usesTransfersV2) {
        if (await _localTransferSuppressesIncomingV2(offer.transferId)) {
          return;
        }
      } else {
        final bool exists = await _localDataSource.fileExistsByFileId(
          offer.fileId,
        );
        if (exists) {
          return;
        }
      }
      final String dedupeKey = '${offer.transferId}:${offer.fileId}';
      if (!offer.usesTransfersV2) {
        if (!seenIncomingKeys.add(dedupeKey)) {
          return;
        }
      } else {
        seenIncomingKeys.add(dedupeKey);
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
        status: offer.usesTransfersV2
            ? statusFromCloud(offer.cloudStatus)
            : TransferStatus.pending,
      );
      if (!controller.isClosed) {
        controller.add(offer);
      }
    }

    Future<void> pollIncomingLoop() async {
      Duration nextDelay = Duration.zero;
      while (!disposed) {
        if (nextDelay > Duration.zero) {
          await Future<void>.delayed(nextDelay);
          if (disposed) {
            return;
          }
        }
        try {
          final List<TransferSessionRecord> rows = await _transferService
              .getIncomingTransfers(receiverId);
          for (final TransferSessionRecord row in rows) {
            final IncomingTransferOffer? parsed =
                await _mapRecordToIncomingOffer(row);
            if (parsed != null) {
              await emitIncoming(parsed);
            }
          }
          final List<TransfersV2Record> v2Rows = await _transferService
              .getIncomingTransfersV2(receiverId);
          for (final TransfersV2Record row in v2Rows) {
            await _syncLocalTransferRowFromV2Remote(
              row: row,
              viewerUserId: receiverId,
            );
            final IncomingTransferOffer? parsed =
                await _mapTransfersV2RecordToOffer(row);
            if (parsed != null) {
              await emitIncoming(parsed);
            }
          }
          nextDelay = _incomingPollInterval;
        } catch (_) {
          nextDelay = nextDelay == Duration.zero
              ? _incomingPollInterval
              : Duration(
                  milliseconds: (nextDelay.inMilliseconds * 2).clamp(
                    _incomingPollInterval.inMilliseconds,
                    _pollingErrorBackoffMax.inMilliseconds,
                  ),
                );
        }
      }
    }

    unawaited(pollIncomingLoop());
    try {
      realtimeSubscription = _realtimeService
          .listenTransferSignals(receiverId: receiverId)
          .listen((TransferLifecycleSignal signal) async {
            if (signal.event != TransferLifecycleEvent.transferStarted) {
              return;
            }
            final IncomingTransferOffer? offer =
                await _mapPayloadToIncomingOffer(signal.toPayload());
            if (offer != null) {
              await emitIncoming(offer);
            }
          });
    } catch (_) {
      // Polling loop remains the fallback source of truth.
    }

    try {
      transfersV2Subscription = _realtimeService
          .listenTransfersV2Postgres(userId: receiverId)
          .listen((Map<String, dynamic> row) async {
            try {
              final TransfersV2Record record = TransfersV2Record.fromRow(row);
              if (record.receiverId != receiverId) {
                return;
              }
              await _syncLocalTransferRowFromV2Remote(
                row: record,
                viewerUserId: receiverId,
              );
              final IncomingTransferOffer? parsed =
                  await _mapTransfersV2RecordToOffer(record);
              if (parsed != null) {
                await emitIncoming(parsed);
              }
            } catch (_) {
              // Ignore malformed realtime payloads.
            }
          });
    } catch (_) {
      // Postgres Realtime is optional; polling still updates offers.
    }

    controller.onCancel = () async {
      disposed = true;
      await realtimeSubscription?.cancel();
      await transfersV2Subscription?.cancel();
    };
    return controller.stream;
  }

  @override
  Stream<TransferLifecycleSignalEntity> listenTransferSignals({
    required String userId,
  }) {
    final StreamController<TransferLifecycleSignalEntity> controller =
        StreamController<TransferLifecycleSignalEntity>();
    final Map<String, String> polledStatusByTransferId = <String, String>{};
    final Set<String> emittedEventKeys = <String>{};
    bool signalsBaselineLoaded = false;
    bool disposed = false;
    StreamSubscription<TransferLifecycleSignal>? realtimeSubscription;

    void emitSignalEntity(TransferLifecycleSignalEntity entity) {
      final String key = '${entity.transferId}:${entity.event.name}';
      if (emittedEventKeys.contains(key)) {
        return;
      }
      emittedEventKeys.add(key);
      if (!controller.isClosed) {
        controller.add(entity);
      }
    }

    Future<void> pollSignalLoop() async {
      Duration nextDelay = Duration.zero;
      while (!disposed) {
        if (nextDelay > Duration.zero) {
          await Future<void>.delayed(nextDelay);
          if (disposed) {
            return;
          }
        }
        try {
          final List<TransferSessionRecord> rows = await _transferService
              .getParticipantTransfers(userId);
          for (final TransferSessionRecord row in rows) {
            final String status = (row.row['status'] as String? ?? '')
                .trim()
                .toLowerCase();
            if (status.isEmpty) {
              continue;
            }
            final String? previousStatus =
                polledStatusByTransferId[row.transferId];
            polledStatusByTransferId[row.transferId] = status;
            if (!signalsBaselineLoaded) {
              continue;
            }
            if (previousStatus == status) {
              continue;
            }
            final TransferLifecycleEventType? event = _statusToLifecycleEvent(
              status,
            );
            if (event == null) {
              continue;
            }
            emitSignalEntity(
              TransferLifecycleSignalEntity(
                transferId: row.transferId,
                senderId: row.senderId,
                receiverId: row.receiverId,
                event: event,
                emittedAt: DateTime.now(),
              ),
            );
          }
          final List<TransfersV2Record> v2Rows = await _transferService
              .getParticipantTransfersV2(userId);
          for (final TransfersV2Record row in v2Rows) {
            await _syncLocalTransferRowFromV2Remote(
              row: row,
              viewerUserId: userId,
            );
            final String status = row.status.trim().toLowerCase();
            if (status.isEmpty) {
              continue;
            }
            final String? previousV2 = polledStatusByTransferId[row.id];
            polledStatusByTransferId[row.id] = status;
            if (!signalsBaselineLoaded) {
              continue;
            }
            if (previousV2 == status) {
              continue;
            }
            final TransferLifecycleEventType? eventV2 =
                _statusToLifecycleEvent(status);
            if (eventV2 == null) {
              continue;
            }
            emitSignalEntity(
              TransferLifecycleSignalEntity(
                transferId: row.id,
                senderId: row.senderId,
                receiverId: row.receiverId,
                event: eventV2,
                emittedAt: DateTime.now(),
              ),
            );
          }
          if (!signalsBaselineLoaded) {
            _emitCompletedLifecycleCatchupForBaseline(
              legacyRows: rows,
              v2Rows: v2Rows,
              emit: emitSignalEntity,
            );
          }
          signalsBaselineLoaded = true;
          nextDelay = _signalPollInterval;
        } catch (_) {
          nextDelay = nextDelay == Duration.zero
              ? _signalPollInterval
              : Duration(
                  milliseconds: (nextDelay.inMilliseconds * 2).clamp(
                    _signalPollInterval.inMilliseconds,
                    _pollingErrorBackoffMax.inMilliseconds,
                  ),
                );
        }
      }
    }

    unawaited(pollSignalLoop());
    try {
      realtimeSubscription = _realtimeService
          .listenTransferSignals(receiverId: userId)
          .listen((TransferLifecycleSignal signal) {
            emitSignalEntity(
              TransferLifecycleSignalEntity(
                transferId: signal.transferId,
                senderId: signal.senderId,
                receiverId: signal.receiverId,
                event: _mapSignalEventToEntity(signal.event),
                emittedAt: signal.emittedAt,
              ),
            );
          });
    } catch (_) {
      // Polling loop remains the fallback source of truth.
    }

    controller.onCancel = () async {
      disposed = true;
      await realtimeSubscription?.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
    bool persistPermanently = true,
    bool trustSender = false,
    void Function(double progress)? onDownloadProgress,
    void Function(String summary)? onReceivedFileSaved,
  }) async {
    if (transfer.trustStatus == SenderTrustStatus.blocked) {
      await rejectIncomingTransfer(transferId: transfer.transferId);
      throw const AppException('This sender is blocked.');
    }
    if (trustSender) {
      await _upsertSenderTrustStatus(
        senderId: transfer.senderId,
        status: SenderTrustStatus.trusted,
        trustedFor: _trustedSenderTtl,
      );
    }
    final String lockId = '${transfer.transferId}:${transfer.fileId}';
    if (_activeTransferLocks.contains(lockId)) {
      return;
    }
    _activeTransferLocks.add(lockId);
    await _backgroundRuntimeService.startActiveTransfer(
      transferId: transfer.transferId,
      fileName: transfer.fileName,
      progressPercent: 0,
    );
    bool finalFileRenamedToTarget = false;
    Directory? downloadChunkStagingDir;
    try {
      final bool hasSpace = await hasAvailableStorage(transfer.fileSize);
      if (!hasSpace) {
        throw const AppException(
          _insufficientStorageMessage,
          code: AppErrorCode.insufficientStorage,
        );
      }

      if (!transfer.usesTransfersV2) {
        if (await _localDataSource.fileExistsByFileId(transfer.fileId) ||
            await _localDataSource.fileHashExists(transfer.fileHash)) {
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
      } else if (await _localTransferSuppressesIncomingV2(transfer.transferId)) {
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
      if (transfer.usesTransfersV2) {
        await _transferService.rpcBeginTransferDownload(
          transferUuid: transfer.transferId,
        );
      } else {
        await _transferService.updateTransferStatus(
          transferId: transfer.transferId,
          status: TransferStatus.downloading.name,
        );
      }
      await _emitOrQueueSignal(
        TransferLifecycleSignal(
          transferId: transfer.transferId,
          senderId: transfer.senderId,
          receiverId: transfer.receiverId,
          event: TransferLifecycleEvent.transferAccepted,
          emittedAt: DateTime.now(),
          fileId: transfer.fileId,
          fileName: transfer.fileName,
          fileSize: transfer.fileSize,
          fileHash: transfer.fileHash,
          storagePath: transfer.storagePath,
        ),
      );

      final TransferTask task = TransferTask(
        id: transfer.transferId,
        fileName: transfer.fileName,
        totalBytes: transfer.fileSize,
      );
      final TransferResumeState initialState =
          await _localDataSource.getTransferProgress(
            transfer.transferId,
            fileId: transfer.fileId,
          ) ??
          TransferResumeState(
            transferId: task.id,
            fileId: transfer.fileId,
            fileName: task.fileName,
            totalBytes: task.totalBytes,
            totalChunks: _downloadManager.chunkPlanFor(task).length,
            direction: TransferSessionDirection.download,
            status: TransferStatus.downloading.name,
          );
      _downloadManager.registerSession(initialState);

      void Function(double progress)? throttledDownloadProgress;
      if (onDownloadProgress != null) {
        DateTime? lastProgressEmit;
        throttledDownloadProgress = (double progress) {
          final DateTime now = DateTime.now();
          if (lastProgressEmit != null &&
              now.difference(lastProgressEmit!) <
                  const Duration(milliseconds: 80)) {
            return;
          }
          lastProgressEmit = now;
          onDownloadProgress(progress.clamp(0.0, 1.0));
        };
      }
      if (transfer.usesTransfersV2) {
        final Directory base = await getTemporaryDirectory();
        final Directory staging = Directory(
          p.join(base.path, 'tranzo_dl', transfer.transferId),
        );
        downloadChunkStagingDir = staging;
        await staging.create(recursive: true);
      }

      bool verified = false;
      List<int> assembled = <int>[];
      for (
        int integrityAttempt = 0;
        integrityAttempt < _maxIntegrityRetries;
        integrityAttempt++
      ) {
        assembled = await _downloadAllPendingChunks(
          transfer: transfer,
          chunkStagingPath: downloadChunkStagingDir?.path,
          onDownloadProgress: throttledDownloadProgress,
        );
        final String digest = await _sha256Hasher.hashBytesAsync(assembled);
        if (digest == transfer.fileHash) {
          verified = true;
          break;
        }
        await _localDataSource.clearTransferProgress(
          transfer.transferId,
          fileId: transfer.fileId,
        );
        _downloadManager.registerSession(
          TransferResumeState(
            transferId: task.id,
            fileId: transfer.fileId,
            fileName: task.fileName,
            totalBytes: task.totalBytes,
            totalChunks: _downloadManager.chunkPlanFor(task).length,
            direction: TransferSessionDirection.download,
            status: TransferStatus.downloading.name,
          ),
        );
      }
      if (!verified) {
        await _localDataSource.updateTransferStatus(
          transfer.transferId,
          TransferStatus.failed,
        );
        await _localDataSource.updateFileStatusByTransferId(
          transfer.transferId,
          FileStatus.corrupted,
        );
        if (transfer.usesTransfersV2) {
          await _transferService.rpcMarkTransferFailed(
            transferUuid: transfer.transferId,
            message: 'hash_mismatch',
          );
        } else {
          await _transferService.updateTransferStatus(
            transferId: transfer.transferId,
            status: TransferStatus.failed.name,
          );
        }
        await _emitOrQueueSignal(
          TransferLifecycleSignal(
            transferId: transfer.transferId,
            senderId: transfer.senderId,
            receiverId: transfer.receiverId,
            event: TransferLifecycleEvent.transferFailed,
            emittedAt: DateTime.now(),
            fileId: transfer.fileId,
            fileName: transfer.fileName,
            fileSize: transfer.fileSize,
            fileHash: transfer.fileHash,
            storagePath: transfer.storagePath,
          ),
        );
        throw const AppException(
          'Received file is corrupted (SHA-256 mismatch).',
          code: AppErrorCode.hashMismatch,
        );
      }

      final Directory appDir = await resolvedReceivedFilesDirectory(
        persistPermanently: persistPermanently,
      );
      final File target = await _resolveUniqueTargetFile(
        directoryPath: appDir.path,
        fileName: transfer.fileName,
      );
      final File tempTarget = File('${target.path}.part');
      if (await tempTarget.exists()) {
        await tempTarget.delete();
      }
      final bool hasSpaceForFinalWrite = await hasAvailableStorage(
        assembled.length,
      );
      if (!hasSpaceForFinalWrite) {
        throw const AppException(
          _insufficientStorageMessage,
          code: AppErrorCode.insufficientStorage,
        );
      }
      await tempTarget.writeAsBytes(assembled, flush: true);
      await tempTarget.rename(target.path);
      finalFileRenamedToTarget = true;

      if (persistPermanently) {
        final bool addedToDownloads = await tryStoreReceivedFileInAndroidDownloads(
          File(target.path),
          fileName: transfer.fileName,
        );
        final bool addedToGallery = await tryExportReceivedMediaToPhotoLibrary(
          File(target.path),
          transfer.fileName,
        );
        final String locationLabel = describeReceivedSaveLocation(appDir);
        final String summary = addedToGallery && addedToDownloads
            ? 'Saved to Downloads/Tranzo and also to your Photos library (album Tranzo).'
            : addedToGallery
            ? 'Also saved to your Photos library (album Tranzo). File copy: $locationLabel.'
            : addedToDownloads
            ? 'Saved to Downloads/Tranzo.'
            : 'Saved to $locationLabel.';
        onReceivedFileSaved?.call(summary);
      }

      if (transfer.usesTransfersV2) {
        await _transferService.rpcMarkTransferCompleted(
          transferUuid: transfer.transferId,
        );
      } else {
        await _transferService.updateTransferStatus(
          transferId: transfer.transferId,
          status: TransferStatus.completed.name,
        );
      }
      await _localDataSource.updateTransferStatus(
        transfer.transferId,
        TransferStatus.completed,
      );
      await _localDataSource.updateFileStatusByTransferId(
        transfer.transferId,
        FileStatus.completed,
      );
      await _emitOrQueueSignal(
        TransferLifecycleSignal(
          transferId: transfer.transferId,
          senderId: transfer.senderId,
          receiverId: transfer.receiverId,
          event: TransferLifecycleEvent.transferCompleted,
          emittedAt: DateTime.now(),
          fileId: transfer.fileId,
          fileName: transfer.fileName,
          fileSize: transfer.fileSize,
          fileHash: transfer.fileHash,
          storagePath: transfer.storagePath,
        ),
      );
      await _downloadManager.finalizeSession(transfer.transferId);
      await _localDataSource.clearTransferProgress(transfer.transferId);
      _clearRetryState(transfer.transferId);
      await _backgroundRuntimeService.cancelRetry(
        transferId: transfer.transferId,
      );
    } on AppException catch (error) {
      await _scheduleBackgroundRetryIfRecoverable(
        transferId: transfer.transferId,
        reason: error,
        userInitiated: false,
      );
      if (!finalFileRenamedToTarget) {
        await _localDataSource.updateTransferStatus(
          transfer.transferId,
          TransferStatus.failed,
        );
        await _localDataSource.updateFileStatusByTransferId(
          transfer.transferId,
          FileStatus.failed,
        );
        if (transfer.usesTransfersV2) {
          await _transferService.rpcMarkTransferFailed(
            transferUuid: transfer.transferId,
            message: error.message,
          );
        } else {
          await _transferService.updateTransferStatus(
            transferId: transfer.transferId,
            status: TransferStatus.failed.name,
          );
        }
      }
      rethrow;
    } catch (error) {
      await _scheduleBackgroundRetryIfRecoverable(
        transferId: transfer.transferId,
        reason: error,
        userInitiated: false,
      );
      if (!finalFileRenamedToTarget) {
        await _localDataSource.updateTransferStatus(
          transfer.transferId,
          TransferStatus.failed,
        );
        await _localDataSource.updateFileStatusByTransferId(
          transfer.transferId,
          FileStatus.failed,
        );
        if (transfer.usesTransfersV2) {
          await _transferService.rpcMarkTransferFailed(
            transferUuid: transfer.transferId,
            message: error.toString(),
          );
        } else {
          await _transferService.updateTransferStatus(
            transferId: transfer.transferId,
            status: TransferStatus.failed.name,
          );
        }
      }
      throw AppException(error.toString());
    } finally {
      await _backgroundRuntimeService.stopActiveTransfer(
        transferId: transfer.transferId,
      );
      _activeTransferLocks.remove(lockId);
      final Directory? stagingCleanup = downloadChunkStagingDir;
      if (stagingCleanup != null && await stagingCleanup.exists()) {
        try {
          await stagingCleanup.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> rejectIncomingTransfer({required String transferId}) async {
    final TransferCollection? transfer = await _isar.transferCollections
        .filter()
        .transferIdEqualTo(transferId)
        .findFirst();
    await _localDataSource.updateTransferStatus(
      transferId,
      TransferStatus.cancelled,
    );
    await _localDataSource.updateFileStatusByTransferId(
      transferId,
      FileStatus.failed,
    );
    bool cloudCancelUpdated = false;
    try {
      await _transferService.updateTransfersV2Status(
        transferUuid: transferId,
        status: TransferStatus.cancelled.name,
      );
      cloudCancelUpdated = true;
    } catch (_) {
      try {
        await _transferService.updateTransferStatus(
          transferId: transferId,
          status: TransferStatus.cancelled.name,
        );
        cloudCancelUpdated = true;
      } catch (_) {}
    }
    if (transfer != null) {
      await _emitOrQueueSignal(
        TransferLifecycleSignal(
          transferId: transferId,
          senderId: transfer.senderId,
          receiverId: transfer.receiverId,
          event: TransferLifecycleEvent.transferRejected,
          emittedAt: DateTime.now(),
          fileName: transfer.fileName,
          fileSize: transfer.fileSize,
          fileHash: transfer.fileHash,
          storagePath: transfer.storagePath,
        ),
      );
    }
    if (!cloudCancelUpdated) {
      throw const AppException(
        'Transfer was cancelled on this device, but the server could not be '
        'updated. It may reappear after reinstall until connectivity or '
        'permissions allow a sync.',
      );
    }
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
    final List<TransferEntity> localEntities = localTransfers
        .where(
          (TransferCollection transfer) =>
              transfer.senderId == userId || transfer.receiverId == userId,
        )
        .map(_mapCollectionToEntity)
        .toList(growable: false);

    final Map<String, TransferEntity> merged = <String, TransferEntity>{};

    try {
      final List<TransfersV2Record> cloudV2 = await _transferService
          .getParticipantTransfersV2(userId);
      for (final TransfersV2Record row in cloudV2) {
        final TransferEntity? cloud = _entityFromTransfersV2Record(row);
        if (cloud == null) {
          continue;
        }
        merged[cloud.id] = cloud;
      }
    } catch (_) {
      // Offline / RLS: fall back to local-only list below.
    }

    try {
      final List<TransferSessionRecord> legacy = await _transferService
          .getParticipantTransfers(userId);
      for (final TransferSessionRecord row in legacy) {
        final TransferEntity? cloud = _entityFromLegacyTransferSession(row);
        if (cloud == null || merged.containsKey(cloud.id)) {
          continue;
        }
        merged[cloud.id] = cloud;
      }
    } catch (_) {
      // Legacy table may be absent; ignore.
    }

    for (final TransferEntity local in localEntities) {
      final TransferEntity? cloud = merged[local.id];
      if (cloud == null) {
        merged[local.id] = local;
      } else {
        merged[local.id] = _mergeParticipantHistoryPreferCloud(
          cloud: cloud,
          local: local,
        );
      }
    }

    final List<TransferEntity> out = merged.values.toList()
      ..sort(
        (TransferEntity a, TransferEntity b) =>
            b.createdAt.compareTo(a.createdAt),
      );
    return out;
  }

  @override
  Future<List<ProfileInteractionEntity>> getUserInteractions(
    String userId,
  ) async {
    final List<TransferEntity> history = await getTransferHistory(userId);
    final List<UserCollection> cachedUsers = await _isar.userCollections
        .where()
        .findAll();
    final Map<String, String> emailByUserId = <String, String>{
      for (final UserCollection user in cachedUsers)
        if (user.email != null && user.email!.trim().isNotEmpty)
          user.supabaseUserId: user.email!.trim(),
    };
    final Map<String, ProfileInteractionEntity> interactionsByUserId =
        <String, ProfileInteractionEntity>{};

    for (final TransferEntity transfer in history) {
      final bool isSender = transfer.senderId == userId;
      final String counterpartId = isSender
          ? transfer.receiverId
          : transfer.senderId;
      final String? counterpartEmail = emailByUserId[counterpartId];
      final String? transferSideName = isSender
          ? transfer.receiverUsername?.trim()
          : transfer.senderUsername?.trim();
      final bool hasUsableName =
          transferSideName != null &&
          transferSideName.isNotEmpty &&
          transferSideName.toLowerCase() != 'user';
      final String counterpartLabel =
          counterpartEmail ??
          (hasUsableName ? transferSideName : counterpartId);

      final ProfileInteractionEntity? existing =
          interactionsByUserId[counterpartId];
      if (existing == null ||
          transfer.createdAt.isAfter(existing.lastInteractionDate)) {
        interactionsByUserId[counterpartId] = ProfileInteractionEntity(
          userId: counterpartId,
          displayLabel: counterpartLabel,
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
    if (senderId.startsWith(_localUserIdPrefix)) {
      throw const AppException(
        'Cloud pairing is unavailable because this device is in local-only mode. '
        'Sign in again or reopen the app when network/auth is available.',
        code: AppErrorCode.invalidRecipientCode,
      );
    }
    if (files.isEmpty) {
      throw const AppException('At least one file is required to send.');
    }

    final String authenticatedUserId = await _transferService
        .requireAuthenticatedUserId();
    final String effectiveSenderId;
    if (senderId != authenticatedUserId) {
      developer.log(
        'sender_id_corrected_from_session',
        name: 'transfer',
        error: <String, Object?>{
          'requestedSenderId': senderId,
          'authenticatedUserId': authenticatedUserId,
        },
      );
    }
    effectiveSenderId = authenticatedUserId;

    final String? receiverId = await _transferService.resolveRecipientIdByCode(
      recipientCode,
    );
    if (receiverId == null) {
      throw const AppException(
        'Invalid recipient code.',
        code: AppErrorCode.invalidRecipientCode,
      );
    }
    if (receiverId == effectiveSenderId) {
      throw const AppException(
        'Sender and receiver must be different users.',
        code: AppErrorCode.invalidReceiver,
      );
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
        '${effectiveSenderId}_${DateTime.now().microsecondsSinceEpoch}';
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
    _clearRetryState(sessionId);

    try {
      for (final SelectedTransferFile file in sortedFiles) {
        String? activeTransferId;
        String? activeFileHash;
        late String activeStoragePath;
        try {
          final String transferUuid = const Uuid().v4();
          final DateTime transferCreatedAt = DateTime.now();
          activeTransferId = transferUuid;
          _cancelledTransferIds.remove(transferUuid);
          final String fileHash = await _sha256Hasher.hashFile(file.localPath);
          activeFileHash = fileHash;
          final TransfersV2Record session = await _transferService
              .insertTransfersV2(
                transferUuid: transferUuid,
                senderId: effectiveSenderId,
                receiverId: receiverId,
                fileName: file.fileName,
                fileSize: file.sizeBytes,
                fileHash: fileHash,
                mimeType: null,
              );
          activeStoragePath = session.storageRoot;
          await _upsertLocalTransfer(
            transferEntity: TransferEntity(
              id: transferUuid,
              senderId: effectiveSenderId,
              receiverId: receiverId,
              status: TransferStatus.queued,
              createdAt: transferCreatedAt,
              fileName: file.fileName,
              fileSize: file.sizeBytes,
              senderUsername: null,
              receiverUsername: null,
              expiresAt: null,
            ),
            fileName: file.fileName,
            fileSize: file.sizeBytes,
            fileHash: fileHash,
            storagePath: activeStoragePath,
            intentScore: null,
            intentExpiry: null,
          );
          developer.log(
            'transfer_start',
            name: 'transfer',
            error: <String, Object?>{
              'transferId': transferUuid,
              'fileId': file.id,
              'fileName': file.fileName,
            },
          );
          await _emitOrQueueSignal(
            TransferLifecycleSignal(
              transferId: transferUuid,
              senderId: effectiveSenderId,
              receiverId: receiverId,
              event: TransferLifecycleEvent.transferStarted,
              emittedAt: DateTime.now(),
              fileId: 'v2-$transferUuid',
              fileName: file.fileName,
              fileSize: file.sizeBytes,
              fileHash: fileHash,
              storagePath: activeStoragePath,
            ),
          );
          await _transferService.updateTransfersV2Status(
            transferUuid: transferUuid,
            status: TransferStatus.uploading.name,
          );
          await _localDataSource.updateTransferStatus(
            transferUuid,
            TransferStatus.uploading,
          );
          final TransferTask task = TransferTask(
            id: transferUuid,
            fileName: file.fileName,
            totalBytes: file.sizeBytes,
            localPath: file.localPath,
          );
          final TransferResumeState initialState =
              await _localDataSource.getTransferProgress(
                transferUuid,
                fileId: file.id,
              ) ??
              TransferResumeState(
                transferId: task.id,
                fileId: file.id,
                fileName: task.fileName,
                totalBytes: task.totalBytes,
                totalChunks: _uploadManager.chunkPlanFor(task).length,
                direction: TransferSessionDirection.upload,
                status: TransferStatus.uploading.name,
              );
          _uploadManager.registerSession(initialState);
          final List<ChunkDescriptor> chunks = _uploadManager.pendingChunksFor(
            transferUuid,
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

          final int totalChunks = _uploadManager.chunkPlanFor(task).length;
          for (final ChunkDescriptor chunk in chunks) {
            if (_isTransferCancelled(transferUuid)) {
              throw const AppException(
                'Transfer cancelled by user.',
                code: AppErrorCode.unknown,
              );
            }
            if (!await _networkInfo.isConnected) {
              developer.log(
                'transfer_paused_network_lost',
                name: 'transfer',
                error: <String, Object?>{
                  'transferId': transferUuid,
                  'fileId': file.id,
                },
              );
              await _handleNoNetworkDuringTransfer(transferUuid);
            }
            final Stream<List<int>> bytes = source.openRead(
              chunk.startByte,
              chunk.endByteExclusive,
            );
            await _remoteDataSource.uploadTransfersV2Chunk(
              senderId: effectiveSenderId,
              transferUuid: transferUuid,
              chunkIndex: chunk.index,
              byteStream: bytes,
            );
            developer.log(
              'chunk_upload_success',
              name: 'transfer',
              error: <String, Object?>{
                'transferId': transferUuid,
                'fileId': file.id,
                'chunkIndex': chunk.index,
              },
            );
            await _transferService.rpcReportChunkUploaded(
              transferUuid: transferUuid,
              chunkIndex: chunk.index,
            );
            final TransferResumeState? updated = _uploadManager
                .acknowledgeChunkComplete(transferUuid, chunk.index);
            if (updated != null) {
              await _localDataSource.upsertTransferProgress(updated);
            }

            final double fileProgress = (chunk.index + 1) / totalChunks;
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
              progressPercent: _progressPercent(chunk.index + 1, totalChunks),
            );
            await _syncProgressThrottled(
              transferId: transferUuid,
              status: TransferStatus.uploading,
              writeLegacyTransferSessions: false,
            );
            yield TransferBatchProgress(
              sessionId: sessionId,
              files: List<TransferFileProgress>.from(progress),
            );
          }

          await _transferService.rpcMarkTransferUploaded(
            transferUuid: transferUuid,
          );
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
          await _localDataSource.updateTransferStatus(
            transferUuid,
            TransferStatus.uploaded,
          );
          await _localDataSource.clearTransferProgress(
            transferUuid,
            fileId: file.id,
          );
          _clearRetryState(transferUuid);
          await _backgroundRuntimeService.cancelRetry(
            transferId: transferUuid,
          );
        } catch (error) {
          final String reason = error.toString();
          if (activeTransferId != null) {
            await _scheduleBackgroundRetryIfRecoverable(
              transferId: activeTransferId,
              reason: error,
              userInitiated: false,
            );
            await _localDataSource.updateTransferStatus(
              activeTransferId,
              TransferStatus.failed,
            );
            try {
              await _transferService.rpcMarkTransferFailed(
                transferUuid: activeTransferId,
                message: reason,
              );
            } catch (_) {
              try {
                await _transferService.updateTransferStatus(
                  transferId: activeTransferId,
                  status: TransferStatus.failed.name,
                );
              } catch (_) {}
            }
            try {
              await _emitOrQueueSignal(
                TransferLifecycleSignal(
                  transferId: activeTransferId,
                  senderId: effectiveSenderId,
                  receiverId: receiverId,
                  event: TransferLifecycleEvent.transferFailed,
                  emittedAt: DateTime.now(),
                  fileId: file.id,
                  fileName: file.fileName,
                  fileSize: file.sizeBytes,
                  fileHash: activeFileHash,
                  storagePath: activeStoragePath,
                ),
              );
            } catch (_) {
              // Keep per-file isolation: signaling failures must not crash loop.
            }
          }
          _replaceProgress(
            progress,
            TransferFileProgress(
              fileId: file.id,
              fileName: file.fileName,
              progress: 0,
              status: TransferFileProgressStatus.failed,
              errorMessage: reason,
            ),
          );
          yield TransferBatchProgress(
            sessionId: sessionId,
            files: List<TransferFileProgress>.from(progress),
          );
          developer.log(
            'file_transfer_failed_isolated',
            name: 'transfer',
            error: <String, Object?>{
              'sessionId': sessionId,
              'fileId': file.id,
              'reason': reason,
            },
          );
          continue;
        }
      }
    } catch (_) {
      developer.log(
        'chunk_upload_failure',
        name: 'transfer',
        error: <String, Object?>{
          'transferId': sessionId,
          'errorCode': AppErrorCode.chunkTransferFailed.name,
        },
      );
      rethrow;
    } finally {
      await _backgroundRuntimeService.stopActiveTransfer(transferId: sessionId);
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

  TransferEntity? _entityFromTransfersV2Record(TransfersV2Record row) {
    final TransferStatus? status = _transferStatusFromTransfersV2CloudString(
      row.status,
    );
    if (status == null) {
      return null;
    }
    final DateTime createdAt =
        DateTime.tryParse(row.row['created_at'] as String? ?? '') ??
        DateTime.now();
    final String name = row.fileName.trim();
    return TransferEntity(
      id: row.id,
      senderId: row.senderId,
      receiverId: row.receiverId,
      status: status,
      createdAt: createdAt,
      fileName: name.isEmpty ? 'Unknown file' : name,
      fileSize: row.fileSize,
      senderUsername: null,
      receiverUsername: null,
      expiresAt: row.row['expires_at'] != null
          ? DateTime.tryParse(row.row['expires_at'] as String)
          : null,
    );
  }

  TransferEntity? _entityFromLegacyTransferSession(
    TransferSessionRecord record,
  ) {
    final TransferStatus status = _transferStatusFromLegacySessionRow(
      record.row['status'] as String?,
    );
    final DateTime createdAt =
        DateTime.tryParse(record.row['created_at'] as String? ?? '') ??
        DateTime.now();
    final String? fileName = record.row['file_name'] as String?;
    final int fileSize = record.row['file_size'] as int? ?? 0;
    return TransferEntity(
      id: record.transferId,
      senderId: record.senderId,
      receiverId: record.receiverId,
      status: status,
      createdAt: createdAt,
      fileName: (fileName == null || fileName.trim().isEmpty)
          ? 'Unknown file'
          : fileName,
      fileSize: fileSize,
      senderUsername: null,
      receiverUsername: null,
      expiresAt: record.row['expires_at'] != null
          ? DateTime.tryParse(record.row['expires_at'] as String)
          : null,
    );
  }

  TransferStatus _transferStatusFromLegacySessionRow(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'completed':
        return TransferStatus.completed;
      case 'failed':
        return TransferStatus.failed;
      case 'cancelled':
      case 'canceled':
        return TransferStatus.cancelled;
      case 'downloading':
        return TransferStatus.downloading;
      case 'uploading':
        return TransferStatus.uploading;
      case 'pending':
        return TransferStatus.pending;
      default:
        return TransferStatus.pending;
    }
  }

  TransferEntity _mergeParticipantHistoryPreferCloud({
    required TransferEntity cloud,
    required TransferEntity local,
  }) {
    final String cloudName = cloud.fileName.trim();
    final String localName = local.fileName.trim();
    return TransferEntity(
      id: cloud.id,
      senderId: cloud.senderId,
      receiverId: cloud.receiverId,
      status: cloud.status,
      createdAt: cloud.createdAt,
      fileName: cloudName.isEmpty || cloudName == 'Unknown file'
          ? (localName.isEmpty ? 'Unknown file' : local.fileName)
          : cloud.fileName,
      fileSize: cloud.fileSize != 0 ? cloud.fileSize : local.fileSize,
      senderUsername: cloud.senderUsername ?? local.senderUsername,
      receiverUsername: cloud.receiverUsername ?? local.receiverUsername,
      expiresAt: cloud.expiresAt ?? local.expiresAt,
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

  Future<IncomingTransferOffer?> _mapRecordToIncomingOffer(
    TransferSessionRecord record,
  ) async {
    return _mapPayloadToIncomingOffer(record.row);
  }

  Future<IncomingTransferOffer?> _mapPayloadToIncomingOffer(
    Map<String, dynamic> payload,
  ) async {
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
    final SenderTrustStatus trustStatus = await _resolveSenderTrustStatus(
      senderId,
    );
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
      trustStatus: trustStatus,
      requiresApproval: trustStatus == SenderTrustStatus.unknown,
    );
  }

  Future<void> _rejectBlockedIncoming(IncomingTransferOffer transfer) async {
    await _localDataSource.updateTransferStatus(
      transfer.transferId,
      TransferStatus.cancelled,
    );
    try {
      await _transferService.updateTransfersV2Status(
        transferUuid: transfer.transferId,
        status: TransferStatus.cancelled.name,
      );
    } catch (_) {
      try {
        await _transferService.updateTransferStatus(
          transferId: transfer.transferId,
          status: TransferStatus.cancelled.name,
        );
      } catch (_) {}
    }
    await _emitOrQueueSignal(
      TransferLifecycleSignal(
        transferId: transfer.transferId,
        senderId: transfer.senderId,
        receiverId: transfer.receiverId,
        event: TransferLifecycleEvent.transferRejected,
        emittedAt: DateTime.now(),
        fileId: transfer.fileId,
        fileName: transfer.fileName,
        fileSize: transfer.fileSize,
        fileHash: transfer.fileHash,
        storagePath: transfer.storagePath,
      ),
    );
  }

  Future<SenderTrustStatus> _resolveSenderTrustStatus(String senderId) async {
    final SenderTrustCollection? row = await _isar.senderTrustCollections
        .filter()
        .senderIdEqualTo(senderId)
        .findFirst();
    if (row == null) {
      return SenderTrustStatus.unknown;
    }
    final DateTime now = DateTime.now();
    if (row.status == SenderTrustStatus.trusted &&
        row.trustedUntil != null &&
        row.trustedUntil!.isBefore(now)) {
      await _isar.writeTxn(() async {
        await _isar.senderTrustCollections.delete(row.id);
      });
      return SenderTrustStatus.unknown;
    }
    return row.status;
  }

  Future<void> _upsertSenderTrustStatus({
    required String senderId,
    required SenderTrustStatus status,
    Duration? trustedFor,
  }) async {
    final DateTime now = DateTime.now();
    await _isar.writeTxn(() async {
      final SenderTrustCollection row = SenderTrustCollection()
        ..senderId = senderId
        ..status = status
        ..updatedAt = now
        ..trustedUntil = status == SenderTrustStatus.trusted
            ? now.add(trustedFor ?? _trustedSenderTtl)
            : null;
      await _isar.senderTrustCollections.putBySenderId(row);
    });
  }

  Future<void> _emitOrQueueSignal(TransferLifecycleSignal signal) async {
    final bool online = await _networkInfo.isConnected;
    if (!online) {
      _pendingSignals.add(signal);
      await _queueOfflineTransferSignal(signal);
      return;
    }
    try {
      await _realtimeService.sendTransferSignal(signal: signal);
      await _flushSignalQueue();
      await _markOfflineQueueDelivered(signal);
    } catch (_) {
      _pendingSignals.add(signal);
      await _queueOfflineTransferSignal(signal);
    }
  }

  Future<void> _flushSignalQueue() async {
    if (_isFlushingSignals || _pendingSignals.isEmpty) {
      return;
    }
    final bool online = await _networkInfo.isConnected;
    if (!online) {
      return;
    }
    _isFlushingSignals = true;
    try {
      final List<TransferLifecycleSignal> queued =
          List<TransferLifecycleSignal>.from(_pendingSignals);
      for (final TransferLifecycleSignal signal in queued) {
        try {
          await _realtimeService.sendTransferSignal(signal: signal);
          _pendingSignals.remove(signal);
        } catch (_) {
          break;
        }
      }
    } finally {
      _isFlushingSignals = false;
    }
  }

  Future<void> _syncProgressThrottled({
    required String transferId,
    required TransferStatus status,
    bool writeLegacyTransferSessions = true,
  }) async {
    if (!writeLegacyTransferSessions) {
      return;
    }
    final DateTime now = DateTime.now();
    if (_lastProgressSyncAt != null &&
        now.difference(_lastProgressSyncAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastProgressSyncAt = now;
    try {
      await _transferService.updateTransferStatus(
        transferId: transferId,
        status: status.name,
      );
    } catch (_) {
      // Local-first behavior: never block transfer on backend sync failures.
    }
  }

  TransferStatus? _transferStatusFromTransfersV2CloudString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'queued':
        return TransferStatus.queued;
      case 'uploading':
        return TransferStatus.uploading;
      case 'uploaded':
        return TransferStatus.uploaded;
      case 'downloading':
        return TransferStatus.downloading;
      case 'completed':
        return TransferStatus.completed;
      case 'failed':
        return TransferStatus.failed;
      case 'cancelled':
        return TransferStatus.cancelled;
      default:
        return null;
    }
  }

  /// Keeps local history rows aligned with `public.transfers` (sender was stuck
  /// on [TransferStatus.uploaded] / "Ready" after the receiver finished).
  Future<void> _syncLocalTransferRowFromV2Remote({
    required TransfersV2Record row,
    required String viewerUserId,
  }) async {
    final TransferStatus? remote = _transferStatusFromTransfersV2CloudString(
      row.status,
    );
    if (remote == null) {
      return;
    }

    final TransferCollection? local = await _isar.transferCollections
        .filter()
        .transferIdEqualTo(row.id)
        .findFirst();
    if (local == null) {
      return;
    }

    final TransferStatus cur = local.status;
    if (remote == TransferStatus.failed &&
        cur == TransferStatus.completed) {
      return;
    }
    const Set<TransferStatus> terminal = <TransferStatus>{
      TransferStatus.completed,
      TransferStatus.failed,
      TransferStatus.cancelled,
    };

    if (terminal.contains(remote)) {
      if (cur != remote) {
        await _localDataSource.updateTransferStatus(row.id, remote);
      }
      return;
    }

    if (terminal.contains(cur)) {
      return;
    }

    final bool viewerIsSender = row.senderId == viewerUserId;
    if (viewerIsSender &&
        remote == TransferStatus.downloading &&
        (cur == TransferStatus.uploaded || cur == TransferStatus.uploading)) {
      return;
    }

    if (remote == TransferStatus.uploaded &&
        cur == TransferStatus.downloading) {
      return;
    }

    if (cur != remote) {
      await _localDataSource.updateTransferStatus(row.id, remote);
    }
  }

  /// First successful participant poll only seeds [polledStatusByTransferId]
  /// and suppresses transition events. Emit one [transferCompleted] per row
  /// already completed in the cloud so the home card can hydrate (otherwise
  /// there is no `null → completed` transition on the next poll).
  void _emitCompletedLifecycleCatchupForBaseline({
    required List<TransferSessionRecord> legacyRows,
    required List<TransfersV2Record> v2Rows,
    required void Function(TransferLifecycleSignalEntity entity) emit,
  }) {
    for (final TransferSessionRecord row in legacyRows) {
      final String status = (row.row['status'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (status != 'completed') {
        continue;
      }
      emit(
        TransferLifecycleSignalEntity(
          transferId: row.transferId,
          senderId: row.senderId,
          receiverId: row.receiverId,
          event: TransferLifecycleEventType.transferCompleted,
          emittedAt: DateTime.now(),
        ),
      );
    }
    for (final TransfersV2Record row in v2Rows) {
      if (row.status.trim().toLowerCase() != 'completed') {
        continue;
      }
      emit(
        TransferLifecycleSignalEntity(
          transferId: row.id,
          senderId: row.senderId,
          receiverId: row.receiverId,
          event: TransferLifecycleEventType.transferCompleted,
          emittedAt: DateTime.now(),
        ),
      );
    }
  }

  TransferLifecycleEventType? _statusToLifecycleEvent(String status) {
    switch (status) {
      case 'uploaded':
        return TransferLifecycleEventType.transferAccepted;
      case 'downloading':
        return TransferLifecycleEventType.transferAccepted;
      case 'completed':
        return TransferLifecycleEventType.transferCompleted;
      case 'failed':
        return TransferLifecycleEventType.transferFailed;
      case 'cancelled':
        return TransferLifecycleEventType.transferRejected;
      default:
        return null;
    }
  }

  /// Hides v2 incoming offers after this device has reached a terminal outcome
  /// (received, user-dismissed, or failed) so polling does not resurrect them.
  Future<bool> _localTransferSuppressesIncomingV2(String transferId) async {
    final TransferCollection? row = await _isar.transferCollections
        .filter()
        .transferIdEqualTo(transferId)
        .findFirst();
    if (row == null) {
      return false;
    }
    return row.status == TransferStatus.completed ||
        row.status == TransferStatus.cancelled ||
        row.status == TransferStatus.failed;
  }

  Future<IncomingTransferOffer?> _mapTransfersV2RecordToOffer(
    TransfersV2Record record,
  ) async {
    final SenderTrustStatus trustStatus = await _resolveSenderTrustStatus(
      record.senderId,
    );
    final String fileId = 'v2-${record.id}';
    return IncomingTransferOffer(
      transferId: record.id,
      senderId: record.senderId,
      receiverId: record.receiverId,
      fileId: fileId,
      fileName: record.fileName,
      fileSize: record.fileSize,
      fileHash: record.fileHash,
      storagePath: record.storageRoot,
      createdAt: DateTime.tryParse(
            record.row['created_at'] as String? ?? '',
          ) ??
          DateTime.now(),
      trustStatus: trustStatus,
      requiresApproval: trustStatus == SenderTrustStatus.unknown,
      cloudProgressPercent: record.progress,
      cloudStatus: record.status,
      usesTransfersV2: true,
    );
  }

  TransferLifecycleEventType _mapSignalEventToEntity(
    TransferLifecycleEvent event,
  ) {
    switch (event) {
      case TransferLifecycleEvent.transferStarted:
        return TransferLifecycleEventType.transferStarted;
      case TransferLifecycleEvent.transferAccepted:
        return TransferLifecycleEventType.transferAccepted;
      case TransferLifecycleEvent.transferCompleted:
        return TransferLifecycleEventType.transferCompleted;
      case TransferLifecycleEvent.transferFailed:
        return TransferLifecycleEventType.transferFailed;
      case TransferLifecycleEvent.transferRejected:
        return TransferLifecycleEventType.transferRejected;
    }
  }

  Future<List<int>> _downloadAllPendingChunks({
    required IncomingTransferOffer transfer,
    String? chunkStagingPath,
    void Function(double progress)? onDownloadProgress,
  }) async {
    final TransferResumeState? state = _downloadManager.stateManager.getState(
      transfer.transferId,
    );
    final int totalChunks = state == null
        ? 0
        : _downloadManager.chunkManager
              .split(totalBytes: state.totalBytes)
              .length;
    final List<ChunkDescriptor> pending = _downloadManager.pendingChunksFor(
      transfer.transferId,
    );
    final Map<int, List<int>> chunksByIndex = <int, List<int>>{};
    for (final ChunkDescriptor chunk in pending) {
      final List<int> bytes = await _downloadChunkWithRetries(
        transfer: transfer,
        chunkIndex: chunk.index,
        chunkStagingPath: chunkStagingPath,
        onDownloadProgress: onDownloadProgress,
      );
      chunksByIndex[chunk.index] = bytes;
      final TransferResumeState? updated = _downloadManager
          .acknowledgeChunkComplete(transfer.transferId, chunk.index);
      if (updated != null) {
        await _localDataSource.upsertTransferProgress(updated);
      }
      await _backgroundRuntimeService.updateActiveTransfer(
        transferId: transfer.transferId,
        fileName: transfer.fileName,
        progressPercent: _progressPercent(chunk.index + 1, totalChunks),
      );
      if (transfer.usesTransfersV2) {
        await _transferService.rpcReportChunkDownloaded(
          transferUuid: transfer.transferId,
          chunkIndex: chunk.index,
        );
      }
      await _syncProgressThrottled(
        transferId: transfer.transferId,
        status: TransferStatus.downloading,
        writeLegacyTransferSessions: !transfer.usesTransfersV2,
      );
    }

    final TransferResumeState? finalState = await _localDataSource
        .getTransferProgress(transfer.transferId, fileId: transfer.fileId);
    final Set<int> completed = finalState?.completedChunkIndexes ?? <int>{};
    final List<ChunkDescriptor> all = _downloadManager.chunkManager.split(
      totalBytes: transfer.fileSize,
    );
    final List<int> assembled = <int>[];
    for (final ChunkDescriptor descriptor in all) {
      if (!completed.contains(descriptor.index)) {
        throw const AppException(
          'Incomplete chunk set during integrity verification.',
          code: AppErrorCode.chunkTransferFailed,
        );
      }
      assembled.addAll(
        chunksByIndex[descriptor.index] ??
            await _downloadChunkWithRetries(
              transfer: transfer,
              chunkIndex: descriptor.index,
              chunkStagingPath: chunkStagingPath,
              onDownloadProgress: onDownloadProgress,
            ),
      );
    }
    return assembled;
  }

  Future<List<int>> _downloadChunkWithRetries({
    required IncomingTransferOffer transfer,
    required int chunkIndex,
    String? chunkStagingPath,
    void Function(double progress)? onDownloadProgress,
  }) async {
    int attempt = 0;
    while (true) {
      final bool online = await _networkInfo.isConnected;
      if (!online) {
        developer.log(
          'transfer_paused_network_lost',
          name: 'transfer',
          error: <String, Object?>{'transferId': transfer.transferId},
        );
        await _handleNoNetworkDuringTransfer(transfer.transferId);
      }
      try {
        if (_isTransferCancelled(transfer.transferId)) {
          throw const AppException(
            'Transfer cancelled by user.',
            code: AppErrorCode.unknown,
          );
        }
        final List<int> chunk;
        if (transfer.usesTransfersV2) {
          if (chunkStagingPath == null || chunkStagingPath.isEmpty) {
            throw const AppException(
              'Missing download staging path.',
              code: AppErrorCode.chunkTransferFailed,
            );
          }
          final List<ChunkDescriptor> layout = _downloadManager.chunkManager
              .split(totalBytes: transfer.fileSize);
          if (chunkIndex < 0 || chunkIndex >= layout.length) {
            throw const AppException(
              'Invalid chunk index.',
              code: AppErrorCode.chunkTransferFailed,
            );
          }
          final ChunkDescriptor meta = layout[chunkIndex];
          final String chunkPath = p.join(
            chunkStagingPath,
            'c$chunkIndex.part',
          );
          final File chunkFile = File(chunkPath);
          if (await chunkFile.exists()) {
            await chunkFile.delete();
          }
          final String signedUrl =
              await _transferService.createSignedUrlForTransfersV2Chunk(
            senderId: transfer.senderId,
            transferUuid: transfer.transferId,
            chunkIndex: chunkIndex,
          );
          try {
            await _remoteDataSource.downloadFromSignedUrlToFile(
              signedUrl: signedUrl,
              destinationPath: chunkPath,
              onReceiveProgress: (int received, int total) {
                if (onDownloadProgress == null) {
                  return;
                }
                final int denom = transfer.fileSize;
                if (denom <= 0) {
                  return;
                }
                final int chunkTotal = total > 0 ? total : meta.lengthBytes;
                final int clampedReceived = received > chunkTotal
                    ? chunkTotal
                    : received;
                onDownloadProgress(
                  ((meta.startByte + clampedReceived) / denom).clamp(0.0, 1.0),
                );
              },
            );
          } on DioException catch (e) {
            throw AppException(
              e.message?.trim().isNotEmpty == true
                  ? e.message!.trim()
                  : 'Network download failed.',
              code: AppErrorCode.chunkTransferFailed,
            );
          }
          chunk = await chunkFile.readAsBytes();
          if (await chunkFile.exists()) {
            await chunkFile.delete();
          }
        } else {
          chunk = await _remoteDataSource.downloadChunk(
            sessionId: transfer.transferId,
            fileId: transfer.fileId,
            chunkIndex: chunkIndex,
          );
        }
        developer.log(
          'chunk_download_success',
          name: 'transfer',
          error: <String, Object?>{
            'transferId': transfer.transferId,
            'fileId': transfer.fileId,
            'chunkIndex': chunkIndex,
          },
        );
        return chunk;
      } catch (_) {
        developer.log(
          'chunk_download_failure',
          name: 'transfer',
          error: <String, Object?>{
            'transferId': transfer.transferId,
            'fileId': transfer.fileId,
            'chunkIndex': chunkIndex,
            'attempt': attempt,
          },
        );
        if (!_retryQueue.canRetryAgain(attempt)) {
          throw const AppException(
            'Chunk download failed after retries.',
            code: AppErrorCode.chunkTransferFailed,
          );
        }
        _retryQueue.schedule(
          id: transfer.transferId,
          initiator: RetryInitiator.auto,
          attempt: attempt,
        );
        final Duration delay = _retryQueue.backoffAfterAttempt(attempt);
        final TransferResumeState? current = await _localDataSource
            .getTransferProgress(transfer.transferId, fileId: transfer.fileId);
        if (current != null) {
          await _localDataSource.upsertTransferProgress(
            current.copyWith(
              retryAttempt: attempt + 1,
              nextRetryAt: DateTime.now().add(delay),
              lastErrorCode: AppErrorCode.chunkTransferFailed.name,
              status: TransferStatus.failed.name,
            ),
          );
        }
        attempt += 1;
        await Future<void>.delayed(delay);
      }
    }
  }

  bool _isTransferCancelled(String transferId) {
    return _cancelledTransferIds.contains(transferId);
  }

  Future<void> _handleNoNetworkDuringTransfer(String transferId) async {
    await _backgroundRuntimeService.stopActiveTransfer(transferId: transferId);
    throw const AppException(
      'Network unavailable. Transfer paused and queued for retry.',
      code: AppErrorCode.chunkTransferFailed,
    );
  }

  bool _isRecoverableTransferError(Object reason) {
    if (reason is! AppException) {
      return true;
    }
    return switch (reason.code) {
      AppErrorCode.chunkTransferFailed => true,
      AppErrorCode.unknown => true,
      AppErrorCode.hashMismatch => false,
      AppErrorCode.duplicateFile => false,
      AppErrorCode.insufficientStorage => false,
      AppErrorCode.insecureEndpoint => false,
      AppErrorCode.invalidRecipientCode => false,
      AppErrorCode.invalidReceiver => false,
    };
  }

  Future<void> _scheduleBackgroundRetryIfRecoverable({
    required String transferId,
    required Object reason,
    required bool userInitiated,
  }) async {
    if (!_isRecoverableTransferError(reason) ||
        _cancelledTransferIds.contains(transferId)) {
      return;
    }
    final int attempt = _backgroundRetryAttempts[transferId] ?? 0;
    if (!_retryQueue.canRetryAgain(attempt)) {
      developer.log(
        'transfer_retry_exhausted',
        name: 'transfer',
        error: <String, Object?>{
          'transferId': transferId,
          'attempt': attempt,
          'reason': reason.toString(),
        },
      );
      return;
    }
    final Duration delay = _retryQueue.backoffAfterAttempt(attempt);
    _backgroundRetryAttempts[transferId] = attempt + 1;
    await _backgroundRuntimeService.scheduleRetry(
      transferId: transferId,
      userInitiated: userInitiated,
      initialDelay: delay,
    );
    developer.log(
      'transfer_retry_scheduled',
      name: 'transfer',
      error: <String, Object?>{
        'transferId': transferId,
        'attempt': attempt + 1,
        'delayMs': delay.inMilliseconds,
        'userInitiated': userInitiated,
      },
    );
  }

  void _clearRetryState(String transferId) {
    _backgroundRetryAttempts.remove(transferId);
  }

  Future<void> _queueOfflineTransferSignal(
    TransferLifecycleSignal signal,
  ) async {
    if (signal.event != TransferLifecycleEvent.transferStarted) {
      return;
    }
    final String fileId = signal.fileId ?? signal.transferId;
    final DateTime now = DateTime.now();
    final QueuedTransferCollection row = QueuedTransferCollection()
      ..queueKey = '${signal.transferId}:$fileId'
      ..transferId = signal.transferId
      ..fileId = fileId
      ..queuedAt = now
      ..expiresAt = now.add(AppConstants.receiverOfflineQueueTtl)
      ..status = _offlineQueueStatusPending
      ..payloadJson = jsonEncode(signal.toPayload())
      ..attemptCount = 0
      ..priority = 0;
    await _isar.writeTxn(() async {
      await _isar.queuedTransferCollections.putByQueueKey(row);
    });
  }

  Future<void> _markOfflineQueueDelivered(
    TransferLifecycleSignal signal,
  ) async {
    final String fileId = signal.fileId ?? signal.transferId;
    await _isar.writeTxn(() async {
      await _isar.queuedTransferCollections.deleteByQueueKey(
        '${signal.transferId}:$fileId',
      );
    });
  }

  Future<void> _replayOfflineQueuedTransfers() async {
    final List<QueuedTransferCollection> queued = await _isar
        .queuedTransferCollections
        .where()
        .findAll();
    final DateTime now = DateTime.now();
    for (final QueuedTransferCollection row in queued) {
      if (row.expiresAt.isBefore(now)) {
        await _isar.writeTxn(() async {
          row.status = _offlineQueueStatusExpired;
          row.reason = 'receiver_offline_ttl_expired';
          await _isar.queuedTransferCollections.put(row);
        });
        await _localDataSource.updateTransferStatus(
          row.transferId,
          TransferStatus.failed,
        );
        continue;
      }
      developer.log(
        'offline_retry_pending_user_action',
        name: 'transfer',
        error: <String, Object?>{
          'transferId': row.transferId,
          'hasPayload': row.payloadJson != null,
          'attemptCount': row.attemptCount,
        },
      );
      if (row.payloadJson != null && row.payloadJson!.trim().isNotEmpty) {
        try {
          final Map<String, dynamic> decoded =
              jsonDecode(row.payloadJson!) as Map<String, dynamic>;
          final TransferLifecycleSignal? parsed =
              TransferLifecycleSignal.fromPayload(decoded);
          if (parsed != null) {
            await _emitOrQueueSignal(parsed);
          }
        } catch (error) {
          developer.log(
            'offline_queue_payload_decode_failed',
            name: 'transfer',
            error: <String, Object?>{
              'transferId': row.transferId,
              'message': error.toString(),
            },
          );
        }
      }
    }
  }

  Future<File> _resolveUniqueTargetFile({
    required String directoryPath,
    required String fileName,
  }) async {
    final int dot = fileName.lastIndexOf('.');
    final String base = dot > 0 ? fileName.substring(0, dot) : fileName;
    final String extension = dot > 0 ? fileName.substring(dot) : '';
    int copy = 0;
    while (true) {
      final String candidateName = copy == 0
          ? '$base$extension'
          : '$base ($copy)$extension';
      final File candidate = File(
        '$directoryPath${Platform.pathSeparator}$candidateName',
      );
      if (!await candidate.exists()) {
        return candidate;
      }
      copy += 1;
    }
  }

}
