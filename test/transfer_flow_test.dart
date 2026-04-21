import 'package:flutter_test/flutter_test.dart';
import 'package:tranzo/core/constants/app_constants.dart';
import 'package:tranzo/core/errors/exceptions.dart';
import 'package:tranzo/core/network/network_info.dart';
import 'package:tranzo/core/services/permission_service.dart';
import 'package:tranzo/domain/entities/file_entity.dart';
import 'package:tranzo/domain/entities/incoming_transfer_offer.dart';
import 'package:tranzo/domain/entities/profile_interaction_entity.dart';
import 'package:tranzo/domain/entities/selected_transfer_file.dart';
import 'package:tranzo/domain/entities/transfer_batch_progress.dart';
import 'package:tranzo/domain/entities/transfer_entity.dart';
import 'package:tranzo/domain/entities/transfer_lifecycle_signal.dart';
import 'package:tranzo/domain/entities/transfer_task.dart';
import 'package:tranzo/domain/entities/user_entity.dart';
import 'package:tranzo/domain/repositories/transfer_repository.dart';
import 'package:tranzo/domain/usecases/retry_transfer_usecase.dart';
import 'package:tranzo/domain/usecases/send_files_usecase.dart';
import 'package:tranzo/domain/usecases/start_download_usecase.dart';
import 'package:tranzo/domain/usecases/start_upload_usecase.dart';
import 'package:tranzo/domain/usecases/check_transfer_permissions_usecase.dart';
import 'package:tranzo/domain/usecases/check_storage_availability_usecase.dart';
import 'package:tranzo/domain/usecases/cancel_transfer_usecase.dart';
import 'package:tranzo/domain/usecases/evaluate_upload_policy_usecase.dart';
import 'package:tranzo/domain/usecases/prepare_batch_upload_ui_usecase.dart';
import 'package:tranzo/domain/usecases/prepare_incoming_transfer_usecase.dart';
import 'package:tranzo/domain/usecases/validate_transfer_batch_usecase.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_bloc.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_event.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_state.dart';
import 'package:tranzo/transfer_engine/chunking/chunk_manager.dart';

void main() {
  group('ChunkManager', () {
    test('splits file into expected chunk boundaries', () {
      const ChunkManager manager = ChunkManager(chunkSizeBytes: 4);
      final chunks = manager.split(totalBytes: 10);

      expect(chunks.length, 3);
      expect(chunks[0].startByte, 0);
      expect(chunks[0].endByteExclusive, 4);
      expect(chunks[2].startByte, 8);
      expect(chunks[2].endByteExclusive, 10);
    });
  });

  group('TransferBloc batch upload', () {
    test('emits per-file progress for batch stream', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository();
      final TransferBloc bloc = TransferBloc(
        startUpload: StartUploadUseCase(repository),
        startDownload: StartDownloadUseCase(repository),
        retryTransfer: RetryTransferUseCase(repository),
        cancelTransfer: CancelTransferUseCase(repository),
        sendFiles: SendFiles(repository),
        validateTransferBatch: ValidateTransferBatchUseCase(
          EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: false)),
        ),
        prepareIncomingTransfer: PrepareIncomingTransferUseCase(
          checkTransferPermissions: CheckTransferPermissionsUseCase(
            _FakePermissionService(),
          ),
          checkStorageAvailability: CheckStorageAvailability(repository),
        ),
        prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
          CheckTransferPermissionsUseCase(_FakePermissionService()),
        ),
      );
      final List<TransferState> states = <TransferState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(
        TransferBatchUploadRequested(
          senderId: 'sender_1',
          recipientCode: 'ABC123',
          files: const <SelectedTransferFile>[
            SelectedTransferFile(
              id: 'f1',
              fileName: 'a.txt',
              localPath: '/tmp/a.txt',
              sizeBytes: 100,
            ),
          ],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(states.last.status, TransferStatus.success);
      expect(states.last.batchProgressByFileId['f1']?.progress, 1);

      await sub.cancel();
      await bloc.close();
    });

    test('rejects file larger than 1GB', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository();
      final TransferBloc bloc = TransferBloc(
        startUpload: StartUploadUseCase(repository),
        startDownload: StartDownloadUseCase(repository),
        retryTransfer: RetryTransferUseCase(repository),
        cancelTransfer: CancelTransferUseCase(repository),
        sendFiles: SendFiles(repository),
        validateTransferBatch: ValidateTransferBatchUseCase(
          EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: false)),
        ),
        prepareIncomingTransfer: PrepareIncomingTransferUseCase(
          checkTransferPermissions: CheckTransferPermissionsUseCase(
            _FakePermissionService(),
          ),
          checkStorageAvailability: CheckStorageAvailability(repository),
        ),
        prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
          CheckTransferPermissionsUseCase(_FakePermissionService()),
        ),
      );

      bloc.add(
        TransferBatchUploadRequested(
          senderId: 'sender_1',
          recipientCode: 'ABC123',
          files: const <SelectedTransferFile>[
            SelectedTransferFile(
              id: 'f1',
              fileName: 'large.bin',
              localPath: '/tmp/large.bin',
              sizeBytes: AppConstants.maxTransferFileSizeBytes + 1,
            ),
          ],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, TransferStatus.error);
      expect(bloc.state.errorMessage, contains('1GB'));

      await bloc.close();
    });

    test('blocks incoming accept when storage is insufficient', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository(
        throwOnAccept: true,
      );
      final TransferBloc bloc = TransferBloc(
        startUpload: StartUploadUseCase(repository),
        startDownload: StartDownloadUseCase(repository),
        retryTransfer: RetryTransferUseCase(repository),
        cancelTransfer: CancelTransferUseCase(repository),
        sendFiles: SendFiles(repository),
        validateTransferBatch: ValidateTransferBatchUseCase(
          EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: false)),
        ),
        prepareIncomingTransfer: PrepareIncomingTransferUseCase(
          checkTransferPermissions: CheckTransferPermissionsUseCase(
            _FakePermissionService(storageGranted: false),
          ),
          checkStorageAvailability: CheckStorageAvailability(repository),
        ),
        prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
          CheckTransferPermissionsUseCase(
            _FakePermissionService(storageGranted: false),
          ),
        ),
      );

      bloc.add(
        IncomingTransferAccepted(
          IncomingTransferOffer(
            transferId: 't-1',
            senderId: 'u-1',
            receiverId: 'u-2',
            fileId: 'f-1',
            fileName: 'doc.pdf',
            fileSize: 1024,
            fileHash: 'hash',
            storagePath: 'path',
            createdAt: DateTime(2026, 1, 1),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, TransferStatus.error);
      expect(bloc.state.errorMessage, contains('Not enough storage'));
      await bloc.close();
    });

    test(
      'requires confirmation on mobile when batch total exceeds 50MB',
      () async {
        final _FakeTransferRepository repository = _FakeTransferRepository();
        final TransferBloc bloc = TransferBloc(
          startUpload: StartUploadUseCase(repository),
          startDownload: StartDownloadUseCase(repository),
          retryTransfer: RetryTransferUseCase(repository),
          cancelTransfer: CancelTransferUseCase(repository),
          sendFiles: SendFiles(repository),
          validateTransferBatch: ValidateTransferBatchUseCase(
            EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: true)),
          ),
          prepareIncomingTransfer: PrepareIncomingTransferUseCase(
            checkTransferPermissions: CheckTransferPermissionsUseCase(
              _FakePermissionService(),
            ),
            checkStorageAvailability: CheckStorageAvailability(repository),
          ),
          prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
            CheckTransferPermissionsUseCase(_FakePermissionService()),
          ),
        );

        bloc.add(
          TransferBatchUploadRequested(
            senderId: 'sender_1',
            recipientCode: 'ABC123',
            files: const <SelectedTransferFile>[
              SelectedTransferFile(
                id: 'f1',
                fileName: 'movie.mp4',
                localPath: '/tmp/movie.mp4',
                sizeBytes: 55 * 1024 * 1024,
              ),
            ],
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(bloc.state.pendingUploadConfirmation, isNotNull);
        await bloc.close();
      },
    );

    test(
      'does not start upload when user declines mobile-data confirmation',
      () async {
        final _FakeTransferRepository repository = _FakeTransferRepository();
        final TransferBloc bloc = TransferBloc(
          startUpload: StartUploadUseCase(repository),
          startDownload: StartDownloadUseCase(repository),
          retryTransfer: RetryTransferUseCase(repository),
          cancelTransfer: CancelTransferUseCase(repository),
          sendFiles: SendFiles(repository),
          validateTransferBatch: ValidateTransferBatchUseCase(
            EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: true)),
          ),
          prepareIncomingTransfer: PrepareIncomingTransferUseCase(
            checkTransferPermissions: CheckTransferPermissionsUseCase(
              _FakePermissionService(),
            ),
            checkStorageAvailability: CheckStorageAvailability(repository),
          ),
          prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
            CheckTransferPermissionsUseCase(_FakePermissionService()),
          ),
        );

        bloc.add(
          TransferBatchUploadRequested(
            senderId: 'sender_1',
            recipientCode: 'ABC123',
            files: const <SelectedTransferFile>[
              SelectedTransferFile(
                id: 'f1',
                fileName: 'movie.mp4',
                localPath: '/tmp/movie.mp4',
                sizeBytes: 55 * 1024 * 1024,
              ),
            ],
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const TransferBatchUploadCancelled());
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(repository.sendBatchCallCount, 0);
        await bloc.close();
      },
    );

    test(
      'starts upload after user confirms mobile-data confirmation',
      () async {
        final _FakeTransferRepository repository = _FakeTransferRepository();
        final TransferBloc bloc = TransferBloc(
          startUpload: StartUploadUseCase(repository),
          startDownload: StartDownloadUseCase(repository),
          retryTransfer: RetryTransferUseCase(repository),
          cancelTransfer: CancelTransferUseCase(repository),
          sendFiles: SendFiles(repository),
          validateTransferBatch: ValidateTransferBatchUseCase(
            EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: true)),
          ),
          prepareIncomingTransfer: PrepareIncomingTransferUseCase(
            checkTransferPermissions: CheckTransferPermissionsUseCase(
              _FakePermissionService(),
            ),
            checkStorageAvailability: CheckStorageAvailability(repository),
          ),
          prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
            CheckTransferPermissionsUseCase(_FakePermissionService()),
          ),
        );

        bloc.add(
          TransferBatchUploadRequested(
            senderId: 'sender_1',
            recipientCode: 'ABC123',
            files: const <SelectedTransferFile>[
              SelectedTransferFile(
                id: 'f1',
                fileName: 'movie.mp4',
                localPath: '/tmp/movie.mp4',
                sizeBytes: 55 * 1024 * 1024,
              ),
            ],
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const TransferBatchUploadConfirmed());
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(repository.sendBatchCallCount, 1);
        expect(bloc.state.status, TransferStatus.success);
        await bloc.close();
      },
    );

    test(
      'continues incoming transfer when storage permission denied',
      () async {
        final _FakeTransferRepository repository = _FakeTransferRepository();
        final TransferBloc bloc = TransferBloc(
          startUpload: StartUploadUseCase(repository),
          startDownload: StartDownloadUseCase(repository),
          retryTransfer: RetryTransferUseCase(repository),
          cancelTransfer: CancelTransferUseCase(repository),
          sendFiles: SendFiles(repository),
          validateTransferBatch: ValidateTransferBatchUseCase(
            EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: false)),
          ),
          prepareIncomingTransfer: PrepareIncomingTransferUseCase(
            checkTransferPermissions: CheckTransferPermissionsUseCase(
              _FakePermissionService(storageGranted: false),
            ),
            checkStorageAvailability: CheckStorageAvailability(repository),
          ),
          prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
            CheckTransferPermissionsUseCase(
              _FakePermissionService(storageGranted: false),
            ),
          ),
        );

        bloc.add(
          IncomingTransferAccepted(
            IncomingTransferOffer(
              transferId: 't-1',
              senderId: 'u-1',
              receiverId: 'u-2',
              fileId: 'f-1',
              fileName: 'doc.pdf',
              fileSize: 1024,
              fileHash: 'hash',
              storagePath: 'path',
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(repository.lastPersistPermanently, isFalse);
        expect(bloc.state.uiWarningMessage, contains('temporarily'));
        await bloc.close();
      },
    );

    test(
      'shows in-app progress fallback when notification permission denied',
      () async {
        final _FakeTransferRepository repository = _FakeTransferRepository();
        final TransferBloc bloc = TransferBloc(
          startUpload: StartUploadUseCase(repository),
          startDownload: StartDownloadUseCase(repository),
          retryTransfer: RetryTransferUseCase(repository),
          cancelTransfer: CancelTransferUseCase(repository),
          sendFiles: SendFiles(repository),
          validateTransferBatch: ValidateTransferBatchUseCase(
            EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: false)),
          ),
          prepareIncomingTransfer: PrepareIncomingTransferUseCase(
            checkTransferPermissions: CheckTransferPermissionsUseCase(
              _FakePermissionService(notificationGranted: false),
            ),
            checkStorageAvailability: CheckStorageAvailability(repository),
          ),
          prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
            CheckTransferPermissionsUseCase(
              _FakePermissionService(notificationGranted: false),
            ),
          ),
        );

        bloc.add(
          TransferBatchUploadRequested(
            senderId: 'sender_1',
            recipientCode: 'ABC123',
            files: const <SelectedTransferFile>[
              SelectedTransferFile(
                id: 'f1',
                fileName: 'a.txt',
                localPath: '/tmp/a.txt',
                sizeBytes: 100,
              ),
            ],
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(bloc.state.showInAppProgress, isTrue);
        expect(
          bloc.state.uiWarningMessage,
          contains('Notification permission denied'),
        );
        await bloc.close();
      },
    );

    test('stores remote lifecycle signal as reconciliation hint', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository();
      final TransferBloc bloc = TransferBloc(
        startUpload: StartUploadUseCase(repository),
        startDownload: StartDownloadUseCase(repository),
        retryTransfer: RetryTransferUseCase(repository),
        cancelTransfer: CancelTransferUseCase(repository),
        sendFiles: SendFiles(repository),
        validateTransferBatch: ValidateTransferBatchUseCase(
          EvaluateUploadPolicyUseCase(_FakeNetworkInfo(isMobile: false)),
        ),
        prepareIncomingTransfer: PrepareIncomingTransferUseCase(
          checkTransferPermissions: CheckTransferPermissionsUseCase(
            _FakePermissionService(),
          ),
          checkStorageAvailability: CheckStorageAvailability(repository),
        ),
        prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
          CheckTransferPermissionsUseCase(_FakePermissionService()),
        ),
      );

      bloc.add(
        TransferLifecycleSignalReceived(
          TransferLifecycleSignalEntity(
            transferId: 't-remote',
            senderId: 'u-1',
            receiverId: 'u-2',
            event: TransferLifecycleEventType.transferCompleted,
            emittedAt: DateTime(2026, 1, 1),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        bloc.state.lifecycleSignalsByTransferId['t-remote']?.event,
        TransferLifecycleEventType.transferCompleted,
      );
      await bloc.close();
    });
  });
}

class _FakeTransferRepository implements TransferRepository {
  _FakeTransferRepository({this.throwOnAccept = false});

  final bool throwOnAccept;
  int sendBatchCallCount = 0;
  bool? lastPersistPermanently;

  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
    bool persistPermanently = true,
  }) async {
    lastPersistPermanently = persistPermanently;
    if (throwOnAccept) {
      throw const AppException(
        'Not enough storage space to receive this file.',
      );
    }
  }

  @override
  Future<List<TransferEntity>> getTransferHistory(String userId) async =>
      const <TransferEntity>[];

  @override
  Future<List<ProfileInteractionEntity>> getUserInteractions(
    String userId,
  ) async => const <ProfileInteractionEntity>[];

  @override
  Future<bool> hasAvailableStorage(int requiredBytes) async => true;

  @override
  Stream<IncomingTransferOffer> listenIncomingTransfers({
    required String receiverId,
  }) => const Stream<IncomingTransferOffer>.empty();

  @override
  Stream<TransferLifecycleSignalEntity> listenTransferSignals({
    required String userId,
  }) => const Stream<TransferLifecycleSignalEntity>.empty();

  @override
  Future<TransferEntity> receiveFiles(String transferId) {
    throw UnimplementedError();
  }

  @override
  Future<void> retryTransfer(String transferId) async {}

  @override
  Future<void> cancelTransfer(String transferId) async {}

  @override
  Future<void> resumeIncompleteTransfers({String? transferId}) async {}

  @override
  Future<void> rejectIncomingTransfer({required String transferId}) async {}

  @override
  Future<TransferEntity> sendFiles({
    required UserEntity sender,
    required UserEntity receiver,
    required List<FileEntity> files,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<TransferBatchProgress> sendFilesInBatch({
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  }) async* {
    sendBatchCallCount += 1;
    if (recipientCode == 'INVALID') {
      throw const AppException('Invalid recipient code.');
    }
    yield TransferBatchProgress(
      sessionId: 'batch_1',
      files: files
          .map(
            (f) => TransferFileProgress(
              fileId: f.id,
              fileName: f.fileName,
              progress: 0.5,
              status: TransferFileProgressStatus.uploading,
            ),
          )
          .toList(growable: false),
    );
    yield TransferBatchProgress(
      sessionId: 'batch_1',
      files: files
          .map(
            (f) => TransferFileProgress(
              fileId: f.id,
              fileName: f.fileName,
              progress: 1,
              status: TransferFileProgressStatus.completed,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> startDownload(TransferTask task) async {}

  @override
  Future<void> startUpload(TransferTask task) async {}
}

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo({required this.isMobile});

  final bool isMobile;

  @override
  Future<NetworkConnectionType> get connectionType async =>
      isMobile ? NetworkConnectionType.mobile : NetworkConnectionType.wifi;

  @override
  Stream<NetworkConnectionType> get onConnectionChanged =>
      const Stream<NetworkConnectionType>.empty();

  @override
  Future<bool> get isConnected async => true;
}

class _FakePermissionService implements PermissionService {
  _FakePermissionService({
    this.storageGranted = true,
    this.notificationGranted = true,
  });

  final bool storageGranted;
  final bool notificationGranted;

  @override
  Future<TransferPermissionSnapshot> checkTransferPermissions() async {
    return TransferPermissionSnapshot(
      storage: storageGranted
          ? PermissionState.granted
          : PermissionState.denied,
      notifications: notificationGranted
          ? PermissionState.granted
          : PermissionState.denied,
    );
  }
}
