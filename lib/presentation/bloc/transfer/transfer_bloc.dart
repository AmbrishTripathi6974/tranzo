import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/incoming_transfer_offer.dart';
import '../../../domain/entities/selected_transfer_file.dart';
import '../../../domain/entities/transfer_lifecycle_signal.dart';
import '../../../domain/usecases/retry_transfer_usecase.dart';
import '../../../domain/usecases/send_files_usecase.dart';
import '../../../domain/usecases/start_download_usecase.dart';
import '../../../domain/usecases/start_upload_usecase.dart';
import '../../../domain/usecases/check_transfer_permissions_usecase.dart';
import '../../../domain/usecases/evaluate_upload_policy_usecase.dart';
import '../../../domain/usecases/check_storage_availability_usecase.dart';
import '../../../domain/entities/transfer_batch_progress.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc({
    required StartUploadUseCase startUpload,
    required StartDownloadUseCase startDownload,
    required RetryTransferUseCase retryTransfer,
    required SendFiles sendFiles,
    required CheckStorageAvailability checkStorageAvailability,
    required EvaluateUploadPolicyUseCase evaluateUploadPolicy,
    required CheckTransferPermissionsUseCase checkTransferPermissions,
  }) : _startUpload = startUpload,
       _startDownload = startDownload,
       _retryTransfer = retryTransfer,
       _sendFiles = sendFiles,
       _checkStorageAvailability = checkStorageAvailability,
       _evaluateUploadPolicy = evaluateUploadPolicy,
       _checkTransferPermissions = checkTransferPermissions,
       super(const TransferState()) {
    on<TransferUploadRequested>(_onUploadRequested);
    on<TransferDownloadRequested>(_onDownloadRequested);
    on<TransferRetryRequested>(_onRetryRequested);
    on<TransferBatchUploadRequested>(_onBatchUploadRequested);
    on<IncomingTransferListeningRequested>(_onIncomingListeningRequested);
    on<IncomingTransferReceived>(_onIncomingTransferReceived);
    on<IncomingTransferAccepted>(_onIncomingTransferAccepted);
    on<IncomingTransferRejected>(_onIncomingTransferRejected);
    on<TransferLifecycleListeningRequested>(_onLifecycleListeningRequested);
    on<TransferLifecycleSignalReceived>(_onLifecycleSignalReceived);
    on<TransferBatchUploadConfirmed>(_onBatchUploadConfirmed);
    on<TransferBatchUploadCancelled>(_onBatchUploadCancelled);
    on<TransferUiEffectConsumed>(_onUiEffectConsumed);
  }

  final StartUploadUseCase _startUpload;
  final StartDownloadUseCase _startDownload;
  final RetryTransferUseCase _retryTransfer;
  final SendFiles _sendFiles;
  final CheckStorageAvailability _checkStorageAvailability;
  final EvaluateUploadPolicyUseCase _evaluateUploadPolicy;
  final CheckTransferPermissionsUseCase _checkTransferPermissions;
  StreamSubscription<IncomingTransferOffer>? _incomingSubscription;
  StreamSubscription<TransferLifecycleSignalEntity>? _lifecycleSubscription;

  Future<void> _onUploadRequested(
    TransferUploadRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _runTransferAction(
      emit: emit,
      transferId: event.task.id,
      action: () => _startUpload(event.task),
    );
  }

  Future<void> _onDownloadRequested(
    TransferDownloadRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _runTransferAction(
      emit: emit,
      transferId: event.task.id,
      action: () => _startDownload(event.task),
    );
  }

  Future<void> _onRetryRequested(
    TransferRetryRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _runTransferAction(
      emit: emit,
      transferId: event.transferId,
      action: () => _retryTransfer(event.transferId),
    );
  }

  Future<void> _runTransferAction({
    required Emitter<TransferState> emit,
    required String transferId,
    required Future<void> Function() action,
  }) async {
    emit(
      state.copyWith(
        status: TransferStatus.loading,
        progress: 0,
        activeTransferId: transferId,
        clearErrorMessage: true,
      ),
    );
    try {
      await action();
      emit(
        state.copyWith(
          status: TransferStatus.success,
          progress: 1,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: _toDisplayError(error),
        ),
      );
    }
  }

  Future<void> _onBatchUploadRequested(
    TransferBatchUploadRequested event,
    Emitter<TransferState> emit,
  ) async {
    final bool oversized = event.files.any(
      (file) => file.sizeBytes > AppConstants.maxTransferFileSizeBytes,
    );
    if (oversized) {
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: 'File exceeds 1GB max size.',
        ),
      );
      return;
    }

    final UploadPolicyDecision uploadPolicy = await _evaluateUploadPolicy(
      event.files,
    );
    if (uploadPolicy.requiresMobileDataConfirmation) {
      emit(
        state.copyWith(
          pendingUploadConfirmation: PendingUploadConfirmation(
            senderId: event.senderId,
            recipientCode: event.recipientCode,
            files: event.files,
            totalBytes: uploadPolicy.totalBytes,
          ),
          clearErrorMessage: true,
        ),
      );
      return;
    }
    await _startBatchUpload(
      emit,
      senderId: event.senderId,
      recipientCode: event.recipientCode,
      files: event.files,
    );
  }

  Future<void> _onBatchUploadConfirmed(
    TransferBatchUploadConfirmed event,
    Emitter<TransferState> emit,
  ) async {
    final PendingUploadConfirmation? pending = state.pendingUploadConfirmation;
    if (pending == null) {
      return;
    }
    emit(state.copyWith(clearPendingUploadConfirmation: true));
    await _startBatchUpload(
      emit,
      senderId: pending.senderId,
      recipientCode: pending.recipientCode,
      files: pending.files,
    );
  }

  void _onBatchUploadCancelled(
    TransferBatchUploadCancelled event,
    Emitter<TransferState> emit,
  ) {
    emit(
      state.copyWith(
        clearPendingUploadConfirmation: true,
        status: TransferStatus.initial,
      ),
    );
  }

  void _onUiEffectConsumed(
    TransferUiEffectConsumed event,
    Emitter<TransferState> emit,
  ) {
    emit(
      state.copyWith(
        clearUiWarningMessage: true,
        clearPendingUploadConfirmation: true,
      ),
    );
  }

  Future<void> _startBatchUpload(
    Emitter<TransferState> emit, {
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  }) async {
    final TransferPermissionDecision permissionDecision =
        await _checkTransferPermissions();
    String? warningMessage;
    if (permissionDecision.notificationDenied) {
      warningMessage =
          'Notification permission denied. Transfer will continue with in-app progress.';
    }

    emit(
      state.copyWith(
        status: TransferStatus.loading,
        progress: 0,
        clearErrorMessage: true,
        clearBatchProgress: true,
        uiWarningMessage: warningMessage,
        showInAppProgress: permissionDecision.notificationDenied,
      ),
    );

    try {
      await emit.forEach<TransferBatchProgress>(
        _sendFiles.sendBatch(
          senderId: senderId,
          recipientCode: recipientCode,
          files: files,
        ),
        onData: (TransferBatchProgress progress) {
          final Map<String, TransferFileProgress> byId =
              <String, TransferFileProgress>{
                for (final TransferFileProgress item in progress.files)
                  item.fileId: item,
              };
          final double total = progress.files.isEmpty
              ? 0
              : progress.files
                        .map((TransferFileProgress e) => e.progress)
                        .reduce((double a, double b) => a + b) /
                    progress.files.length;
          return state.copyWith(
            status: total >= 1
                ? TransferStatus.success
                : TransferStatus.loading,
            progress: total,
            batchSessionId: progress.sessionId,
            batchProgressByFileId: byId,
            clearErrorMessage: true,
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: _toDisplayError(error),
        ),
      );
    }
  }

  Future<void> _onIncomingListeningRequested(
    IncomingTransferListeningRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _incomingSubscription?.cancel();
    _incomingSubscription = _sendFiles
        .listenIncoming(receiverId: event.receiverId)
        .listen((incoming) {
          add(IncomingTransferReceived(incoming));
        });
  }

  Future<void> _onLifecycleListeningRequested(
    TransferLifecycleListeningRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _lifecycleSubscription?.cancel();
    _lifecycleSubscription = _sendFiles
        .listenSignals(userId: event.userId)
        .listen((TransferLifecycleSignalEntity signal) {
          add(TransferLifecycleSignalReceived(signal));
        });
  }

  void _onLifecycleSignalReceived(
    TransferLifecycleSignalReceived event,
    Emitter<TransferState> emit,
  ) {
    final Map<String, TransferLifecycleSignalEntity> nextSignals =
        <String, TransferLifecycleSignalEntity>{
          ...state.lifecycleSignalsByTransferId,
          event.signal.transferId: event.signal,
        };
    final bool hasActiveLocalTransfer = state.activeTransferId != null;
    if (hasActiveLocalTransfer &&
        event.signal.event != TransferLifecycleEventType.transferCompleted &&
        event.signal.event != TransferLifecycleEventType.transferFailed) {
      emit(state.copyWith(lifecycleSignalsByTransferId: nextSignals));
      return;
    }
    emit(state.copyWith(lifecycleSignalsByTransferId: nextSignals));
  }

  void _onIncomingTransferReceived(
    IncomingTransferReceived event,
    Emitter<TransferState> emit,
  ) {
    final bool alreadyListed = state.incomingTransfers.any(
      (item) => item.transferId == event.transfer.transferId,
    );
    if (alreadyListed) {
      return;
    }
    emit(
      state.copyWith(
        incomingTransfers: <IncomingTransferOffer>[
          ...state.incomingTransfers,
          event.transfer,
        ],
      ),
    );
  }

  Future<void> _onIncomingTransferAccepted(
    IncomingTransferAccepted event,
    Emitter<TransferState> emit,
  ) async {
    emit(
      state.copyWith(status: TransferStatus.loading, clearErrorMessage: true),
    );
    try {
      final TransferPermissionDecision permissionDecision =
          await _checkTransferPermissions();
      final bool persistPermanently = permissionDecision.allowPersistentStorage;
      final bool hasStorage = await _checkStorageAvailability(
        event.transfer.fileSize,
      );
      if (!hasStorage) {
        throw Exception('Not enough storage space to receive this file.');
      }
      await _sendFiles.acceptIncoming(
        transfer: event.transfer,
        persistPermanently: persistPermanently,
      );
      emit(
        state.copyWith(
          status: TransferStatus.success,
          incomingTransfers: state.incomingTransfers
              .where((item) => item.transferId != event.transfer.transferId)
              .toList(growable: false),
          uiWarningMessage: permissionDecision.storageDenied
              ? 'Storage permission denied. File is available temporarily only.'
              : (permissionDecision.notificationDenied
                    ? 'Notification permission denied. Transfer progress is shown in-app.'
                    : null),
          showInAppProgress: permissionDecision.notificationDenied,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: _toDisplayError(error),
        ),
      );
    }
  }

  Future<void> _onIncomingTransferRejected(
    IncomingTransferRejected event,
    Emitter<TransferState> emit,
  ) async {
    try {
      await _sendFiles.rejectIncoming(transferId: event.transferId);
      emit(
        state.copyWith(
          incomingTransfers: state.incomingTransfers
              .where((item) => item.transferId != event.transferId)
              .toList(growable: false),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: _toDisplayError(error),
        ),
      );
    }
  }

  String _toDisplayError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  @override
  Future<void> close() async {
    await _incomingSubscription?.cancel();
    await _lifecycleSubscription?.cancel();
    return super.close();
  }
}
