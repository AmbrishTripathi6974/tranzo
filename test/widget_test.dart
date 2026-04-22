import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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
import 'package:tranzo/domain/repositories/mobile_data_large_upload_consent_repository.dart';
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
import 'package:tranzo/presentation/pages/transfer_home_page.dart';

void main() {
  testWidgets('Transfer home scaffold renders', (WidgetTester tester) async {
    final _FakeTransferRepository repository = _FakeTransferRepository();
    final _FakeMobileDataLargeUploadConsentRepository mobileDataConsent =
        _FakeMobileDataLargeUploadConsentRepository();
    final TransferBloc bloc = TransferBloc(
      startUpload: StartUploadUseCase(repository),
      startDownload: StartDownloadUseCase(repository),
      retryTransfer: RetryTransferUseCase(repository),
      cancelTransfer: CancelTransferUseCase(repository),
      sendFiles: SendFiles(repository),
      validateTransferBatch: ValidateTransferBatchUseCase(
        EvaluateUploadPolicyUseCase(_FakeNetworkInfo(), mobileDataConsent),
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
      mobileDataLargeUploadConsent: mobileDataConsent,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TransferBloc>.value(
          value: bloc,
          child: const TransferHomePage(),
        ),
      ),
    );

    expect(find.text('Tranzo'), findsOneWidget);
  });
}

class _FakeMobileDataLargeUploadConsentRepository
    implements MobileDataLargeUploadConsentRepository {
  _FakeMobileDataLargeUploadConsentRepository({bool initialConsented = false})
    : _consented = initialConsented;

  bool _consented;
  int setUserConsentedCallCount = 0;

  @override
  Future<bool> hasUserConsented() async => _consented;

  @override
  Future<void> setUserConsented(bool value) async {
    setUserConsentedCallCount++;
    _consented = value;
  }
}

class _FakeTransferRepository implements TransferRepository {
  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
    bool persistPermanently = true,
    bool trustSender = false,
  }) async {}

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
    yield const TransferBatchProgress(
      sessionId: 'session',
      files: <TransferFileProgress>[],
    );
  }

  @override
  Future<void> startDownload(TransferTask task) async {}

  @override
  Future<void> startUpload(TransferTask task) async {}
}

class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<NetworkConnectionType> get connectionType async =>
      NetworkConnectionType.wifi;

  @override
  Stream<NetworkConnectionType> get onConnectionChanged =>
      const Stream<NetworkConnectionType>.empty();

  @override
  Future<bool> get isConnected async => true;
}

class _FakePermissionService implements PermissionService {
  @override
  Future<TransferPermissionSnapshot> checkTransferPermissions() async {
    return const TransferPermissionSnapshot(
      storage: PermissionState.granted,
      notifications: PermissionState.granted,
    );
  }
}
