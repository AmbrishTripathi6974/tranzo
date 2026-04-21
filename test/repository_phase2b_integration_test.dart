import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:tranzo/core/database/isar/collections/file_collection.dart';
import 'package:tranzo/core/database/isar/collections/queued_transfer_collection.dart';
import 'package:tranzo/core/database/isar/collections/transfer_collection.dart';
import 'package:tranzo/core/database/isar/collections/transfer_progress_collection.dart';
import 'package:tranzo/core/database/isar/collections/user_collection.dart';
import 'package:tranzo/core/network/network_info.dart';
import 'package:tranzo/core/security/sha256_hasher.dart';
import 'package:tranzo/core/services/background_transfer_runtime_service.dart';
import 'package:tranzo/core/services/realtime_service.dart';
import 'package:tranzo/core/services/storage_service.dart';
import 'package:tranzo/core/services/transfer_service.dart';
import 'package:tranzo/data/datasources/local/transfer_local_data_source.dart';
import 'package:tranzo/data/datasources/remote/transfer_remote_data_source.dart';
import 'package:tranzo/data/models/transfer_task_model.dart';
import 'package:tranzo/data/repositories/transfer_repository_impl.dart';
import 'package:tranzo/domain/entities/selected_transfer_file.dart';
import 'package:tranzo/domain/entities/transfer_batch_progress.dart';
import 'package:tranzo/transfer_engine/chunking/chunk_manager.dart';
import 'package:tranzo/transfer_engine/download/download_manager.dart';
import 'package:tranzo/transfer_engine/retry/retry_queue.dart';
import 'package:tranzo/transfer_engine/state/transfer_state_manager.dart';
import 'package:tranzo/transfer_engine/upload/upload_manager.dart';

import 'support/isar_test_runtime.dart';

Future<void> main() async {
  final bool isarRuntimeAvailable = await ensureIsarCoreForTests();

  group('Phase-2b repository integration', () {
    Directory? tempDir;
    Isar? isar;
    late TransferLocalDataSource localDataSource;
    late _FakeTransferService transferService;
    late _FakeRealtimeService realtimeService;
    late _FakeBackgroundRuntimeService runtimeService;
    late _FakeNetworkInfo networkInfo;
    late _FakeRemoteDataSource remoteDataSource;
    late TransferRepositoryImpl repository;
    late File sourceFile;
    final Sha256Hasher hasher = const Sha256Hasher();

    Future<void> buildRepository({
      required bool connected,
      Duration networkWaitTimeout = const Duration(minutes: 2),
      Duration networkWaitPollInterval = const Duration(milliseconds: 10),
    }) async {
      tempDir = await Directory.systemTemp.createTemp('tranzo_phase2b_');
      isar = await Isar.open(
        <CollectionSchema<dynamic>>[
          UserCollectionSchema,
          TransferCollectionSchema,
          FileCollectionSchema,
          TransferProgressCollectionSchema,
          QueuedTransferCollectionSchema,
        ],
        directory: tempDir!.path,
        name: 'phase2b',
      );
      localDataSource = TransferLocalDataSourceImpl(isar!);
      transferService = _FakeTransferService();
      realtimeService = _FakeRealtimeService();
      runtimeService = _FakeBackgroundRuntimeService();
      networkInfo = _FakeNetworkInfo(connected: connected);
      remoteDataSource = _FakeRemoteDataSource();
      sourceFile = File('${tempDir!.path}${Platform.pathSeparator}payload.bin');
      await sourceFile.writeAsBytes(
        List<int>.generate(3 * 1024 * 1024, (int i) => i % 251),
      );

      repository = TransferRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        transferService: transferService,
        realtimeService: realtimeService,
        isar: isar!,
        uploadManager: UploadManager(
          chunkManager: const ChunkManager(),
          stateManager: TransferStateManager(),
          retryQueue: RetryQueue(maxRetries: 1),
        ),
        downloadManager: DownloadManager(
          chunkManager: const ChunkManager(),
          stateManager: TransferStateManager(),
          retryQueue: RetryQueue(maxRetries: 1),
        ),
        retryQueue: RetryQueue(maxRetries: 1),
        storageService: const _FakeStorageService(),
        backgroundRuntimeService: runtimeService,
        networkInfo: networkInfo,
        sha256Hasher: hasher,
        networkWaitTimeout: networkWaitTimeout,
        networkWaitPollInterval: networkWaitPollInterval,
      );
    }

    tearDown(() async {
      await isar?.close(deleteFromDisk: true);
      if (tempDir != null && await tempDir!.exists()) {
        await tempDir!.delete(recursive: true);
      }
    });

    test(
      'cancel during chunk execution marks file as failed and cancels retry',
      () async {
      await buildRepository(connected: true);
      final List<TransferBatchProgress> emitted = <TransferBatchProgress>[];
      final Stream<TransferBatchProgress> stream = repository.sendFilesInBatch(
        senderId: 'sender-1',
        recipientCode: 'ABC123',
        files: <SelectedTransferFile>[
          SelectedTransferFile(
            id: 'file-1',
            fileName: 'payload.bin',
            localPath: sourceFile.path,
            sizeBytes: await sourceFile.length(),
          ),
        ],
      );

      final Future<void> consume = stream.forEach(emitted.add);
      final String transferId = await remoteDataSource.firstChunkTransferId.future;
      await repository.cancelTransfer(transferId);
      remoteDataSource.allowFirstChunk.complete();
      await consume;

      final TransferFileProgress fileProgress = emitted.last.files.single;
      expect(fileProgress.status, TransferFileProgressStatus.failed);
      expect(runtimeService.cancelledRetryIds, contains(transferId));
      },
      skip: isarRuntimeAvailable
          ? null
          : 'Isar native core unavailable (offline, skip env, or download failed). '
              'Run: dart run tool/ensure_isar_test_binary.dart',
    );

    test(
      'network wait timeout avoids chunk upload and reports failed progress',
      () async {
      await buildRepository(
        connected: false,
        networkWaitTimeout: const Duration(milliseconds: 40),
        networkWaitPollInterval: const Duration(milliseconds: 5),
      );
      final List<TransferBatchProgress> emitted = <TransferBatchProgress>[];
      await repository
          .sendFilesInBatch(
            senderId: 'sender-1',
            recipientCode: 'ABC123',
            files: <SelectedTransferFile>[
              SelectedTransferFile(
                id: 'file-2',
                fileName: 'payload.bin',
                localPath: sourceFile.path,
                sizeBytes: await sourceFile.length(),
              ),
            ],
          )
          .forEach(emitted.add);

      expect(remoteDataSource.uploadChunkCalls, 0);
      expect(emitted.last.files.single.status, TransferFileProgressStatus.failed);
      },
      skip: isarRuntimeAvailable
          ? null
          : 'Isar native core unavailable (offline, skip env, or download failed). '
              'Run: dart run tool/ensure_isar_test_binary.dart',
    );
  });
}

class _FakeTransferService implements TransferService {
  final List<String> updatedTransferIds = <String>[];

  @override
  Future<TransferSessionRecord> createTransferSession(
    TransferSessionPayload payload,
  ) async {
    final Map<String, dynamic> row = <String, dynamic>{
      'id': payload.transferId,
      'transfer_id': payload.transferId,
      'sender_id': payload.senderId,
      'receiver_id': payload.receiverId,
      'file_name': payload.fileName,
      'file_size': payload.fileSize,
      'file_hash': payload.fileHash,
      'storage_path': payload.storagePath,
      'status': payload.status,
      'created_at': payload.createdAt.toIso8601String(),
    };
    return TransferSessionRecord.fromRow(row);
  }

  @override
  Future<String?> resolveRecipientIdByCode(String rawCode) async => 'receiver-1';

  @override
  Future<void> updateTransferStatus({
    required String transferId,
    required String status,
  }) async {
    updatedTransferIds.add(transferId);
  }

  @override
  Future<List<TransferSessionRecord>> getIncomingTransfers(String receiverId) async =>
      const <TransferSessionRecord>[];

  @override
  Future<void> uploadTransferChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
    required Stream<List<int>> byteStream,
  }) async {}

  @override
  Future<Uint8List> downloadTransferChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
  }) async => Uint8List(0);
}

class _FakeRealtimeService implements RealtimeService {
  @override
  Future<void> sendTransferSignal({
    required TransferLifecycleSignal signal,
    String channelPrefix = 'transfer-signals',
  }) async {}

  @override
  Stream<TransferLifecycleSignal> listenTransferSignals({
    required String receiverId,
    String channelPrefix = 'transfer-signals',
  }) => const Stream<TransferLifecycleSignal>.empty();

  @override
  Future<void> sendRealtimeEvent({
    required String channelName,
    required String event,
    required Map<String, dynamic> payload,
  }) async {}

  @override
  Stream<Map<String, dynamic>> listenIncomingTransfers({
    required String receiverId,
    String channelName = 'incoming-transfers',
    String event = 'incoming_transfer',
  }) => const Stream<Map<String, dynamic>>.empty();
}

class _FakeRemoteDataSource implements TransferRemoteDataSource {
  int uploadChunkCalls = 0;
  final Completer<String> firstChunkTransferId = Completer<String>();
  final Completer<void> allowFirstChunk = Completer<void>();

  @override
  Future<void> upload(TransferTaskModel task) async {}

  @override
  Future<void> download(TransferTaskModel task) async {}

  @override
  Future<void> uploadChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
    required Stream<List<int>> byteStream,
  }) async {
    uploadChunkCalls += 1;
    await byteStream.drain<void>();
    if (uploadChunkCalls == 1) {
      firstChunkTransferId.complete(sessionId);
      await allowFirstChunk.future;
    }
  }

  @override
  Future<List<int>> downloadChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
  }) async => <int>[];
}

class _FakeBackgroundRuntimeService implements BackgroundTransferRuntimeService {
  final List<String> cancelledRetryIds = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> startActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) async {}

  @override
  Future<void> updateActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) async {}

  @override
  Future<void> stopActiveTransfer() async {}

  @override
  Future<void> scheduleRetry({
    required String transferId,
    required bool userInitiated,
    Duration initialDelay = Duration.zero,
  }) async {}

  @override
  Future<void> cancelRetry({required String transferId}) async {
    cancelledRetryIds.add(transferId);
  }
}

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo({required this.connected});

  bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Future<NetworkConnectionType> get connectionType async {
    return connected ? NetworkConnectionType.wifi : NetworkConnectionType.none;
  }

  @override
  Stream<NetworkConnectionType> get onConnectionChanged =>
      const Stream<NetworkConnectionType>.empty();
}

class _FakeStorageService implements StorageService {
  const _FakeStorageService();

  @override
  Future<bool> hasSpaceForBytes(int requiredBytes) async => true;
}
