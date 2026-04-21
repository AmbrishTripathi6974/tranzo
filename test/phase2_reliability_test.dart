import 'package:flutter_test/flutter_test.dart';
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
import 'package:tranzo/domain/usecases/cancel_transfer_usecase.dart';
import 'package:tranzo/domain/usecases/check_storage_availability_usecase.dart';
import 'package:tranzo/domain/usecases/check_transfer_permissions_usecase.dart';
import 'package:tranzo/domain/usecases/evaluate_upload_policy_usecase.dart';
import 'package:tranzo/domain/usecases/prepare_batch_upload_ui_usecase.dart';
import 'package:tranzo/domain/usecases/prepare_incoming_transfer_usecase.dart';
import 'package:tranzo/domain/usecases/resume_incomplete_transfers_usecase.dart';
import 'package:tranzo/domain/usecases/retry_transfer_usecase.dart';
import 'package:tranzo/domain/usecases/send_files_usecase.dart';
import 'package:tranzo/domain/usecases/start_download_usecase.dart';
import 'package:tranzo/domain/usecases/start_upload_usecase.dart';
import 'package:tranzo/domain/usecases/validate_transfer_batch_usecase.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_bloc.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_event.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_state.dart';

void main() {
  group('Phase 2 reliability regressions', () {
    test('resume usecase forwards transferId for isolated retry', () async {
      final _ReliabilityFakeTransferRepository repository =
          _ReliabilityFakeTransferRepository();
      final ResumeIncompleteTransfersUseCase useCase =
          ResumeIncompleteTransfersUseCase(repository);

      await useCase(transferId: 'target-transfer');

      expect(repository.resumeTransferIds, <String?>['target-transfer']);
    });

    test('resume usecase preserves global behavior when omitted', () async {
      final _ReliabilityFakeTransferRepository repository =
          _ReliabilityFakeTransferRepository();
      final ResumeIncompleteTransfersUseCase useCase =
          ResumeIncompleteTransfersUseCase(repository);

      await useCase();

      expect(repository.resumeTransferIds, <String?>[null]);
    });

    test('bloc forwards exact transferId on cancellation', () async {
      final _ReliabilityFakeTransferRepository repository =
          _ReliabilityFakeTransferRepository();
      final TransferBloc bloc = _buildBloc(repository);

      bloc.add(const TransferCancelRequested('tx-42'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.cancelledTransferIds, <String>['tx-42']);
      expect(bloc.state.status, TransferStatus.success);
      await bloc.close();
    });

    test('bloc surfaces network timeout style failures during batch upload', () async {
      final _ReliabilityFakeTransferRepository repository =
          _ReliabilityFakeTransferRepository()
            ..failBatchWith = const AppException(
              'Network unavailable for too long.',
              code: AppErrorCode.chunkTransferFailed,
            );
      final TransferBloc bloc = _buildBloc(repository);

      bloc.add(
        TransferBatchUploadRequested(
          senderId: 'sender-1',
          recipientCode: 'ABC123',
          files: const <SelectedTransferFile>[
            SelectedTransferFile(
              id: 'f1',
              fileName: 'doc.txt',
              localPath: '/tmp/doc.txt',
              sizeBytes: 100,
            ),
          ],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, TransferStatus.error);
      expect(bloc.state.errorMessage, contains('Network unavailable'));
      await bloc.close();
    });
  });
}

TransferBloc _buildBloc(_ReliabilityFakeTransferRepository repository) {
  return TransferBloc(
    startUpload: StartUploadUseCase(repository),
    startDownload: StartDownloadUseCase(repository),
    retryTransfer: RetryTransferUseCase(repository),
    cancelTransfer: CancelTransferUseCase(repository),
    sendFiles: SendFiles(repository),
    validateTransferBatch: ValidateTransferBatchUseCase(
      EvaluateUploadPolicyUseCase(_ReliabilityFakeNetworkInfo()),
    ),
    prepareIncomingTransfer: PrepareIncomingTransferUseCase(
      checkTransferPermissions: CheckTransferPermissionsUseCase(
        _ReliabilityFakePermissionService(),
      ),
      checkStorageAvailability: CheckStorageAvailability(repository),
    ),
    prepareBatchUploadUi: PrepareBatchUploadUiUseCase(
      CheckTransferPermissionsUseCase(_ReliabilityFakePermissionService()),
    ),
  );
}

class _ReliabilityFakeTransferRepository implements TransferRepository {
  final List<String?> resumeTransferIds = <String?>[];
  final List<String> cancelledTransferIds = <String>[];
  AppException? failBatchWith;

  @override
  Future<void> resumeIncompleteTransfers({String? transferId}) async {
    resumeTransferIds.add(transferId);
  }

  @override
  Future<void> cancelTransfer(String transferId) async {
    cancelledTransferIds.add(transferId);
  }

  @override
  Future<void> retryTransfer(String transferId) async {}

  @override
  Stream<TransferBatchProgress> sendFilesInBatch({
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  }) async* {
    if (failBatchWith != null) {
      throw failBatchWith!;
    }
    yield TransferBatchProgress(
      sessionId: 'session',
      files: files
          .map(
            (SelectedTransferFile file) => TransferFileProgress(
              fileId: file.id,
              fileName: file.fileName,
              progress: 1,
              status: TransferFileProgressStatus.completed,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
    bool persistPermanently = true,
  }) async {}

  @override
  Stream<IncomingTransferOffer> listenIncomingTransfers({
    required String receiverId,
  }) => const Stream<IncomingTransferOffer>.empty();

  @override
  Stream<TransferLifecycleSignalEntity> listenTransferSignals({
    required String userId,
  }) => const Stream<TransferLifecycleSignalEntity>.empty();

  @override
  Future<void> rejectIncomingTransfer({required String transferId}) async {}

  @override
  Future<void> startDownload(TransferTask task) async {}

  @override
  Future<void> startUpload(TransferTask task) async {}

  @override
  Future<TransferEntity> sendFiles({
    required UserEntity sender,
    required UserEntity receiver,
    required List<FileEntity> files,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TransferEntity> receiveFiles(String transferId) {
    throw UnimplementedError();
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
}

class _ReliabilityFakeNetworkInfo implements NetworkInfo {
  @override
  Future<NetworkConnectionType> get connectionType async =>
      NetworkConnectionType.wifi;

  @override
  Stream<NetworkConnectionType> get onConnectionChanged =>
      const Stream<NetworkConnectionType>.empty();

  @override
  Future<bool> get isConnected async => true;
}

class _ReliabilityFakePermissionService implements PermissionService {
  @override
  Future<TransferPermissionSnapshot> checkTransferPermissions() async {
    return const TransferPermissionSnapshot(
      storage: PermissionState.granted,
      notifications: PermissionState.granted,
    );
  }
}
