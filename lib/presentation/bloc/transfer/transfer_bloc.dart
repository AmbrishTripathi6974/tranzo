import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/incoming_transfer_offer.dart';
import '../../../domain/entities/selected_transfer_file.dart';
import '../../../domain/entities/transfer_lifecycle_signal.dart';
import '../../../domain/usecases/retry_transfer_usecase.dart';
import '../../../domain/usecases/send_files_usecase.dart';
import '../../../domain/usecases/start_download_usecase.dart';
import '../../../domain/usecases/start_upload_usecase.dart';
import '../../../domain/usecases/cancel_transfer_usecase.dart';
import '../../../domain/usecases/prepare_batch_upload_ui_usecase.dart';
import '../../../domain/usecases/prepare_incoming_transfer_usecase.dart';
import '../../../domain/repositories/mobile_data_large_upload_consent_repository.dart';
import '../../../domain/usecases/validate_transfer_batch_usecase.dart';
import '../../../domain/entities/transfer_batch_progress.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc({
    required StartUploadUseCase startUpload,
    required StartDownloadUseCase startDownload,
    required RetryTransferUseCase retryTransfer,
    required CancelTransferUseCase cancelTransfer,
    required SendFiles sendFiles,
    required PrepareBatchUploadUiUseCase prepareBatchUploadUi,
    required ValidateTransferBatchUseCase validateTransferBatch,
    required PrepareIncomingTransferUseCase prepareIncomingTransfer,
    required MobileDataLargeUploadConsentRepository
    mobileDataLargeUploadConsent,
  }) : _startUpload = startUpload,
       _startDownload = startDownload,
       _retryTransfer = retryTransfer,
       _cancelTransfer = cancelTransfer,
       _sendFiles = sendFiles,
       _prepareBatchUploadUi = prepareBatchUploadUi,
       _validateTransferBatch = validateTransferBatch,
       _prepareIncomingTransfer = prepareIncomingTransfer,
       _mobileDataLargeUploadConsent = mobileDataLargeUploadConsent,
       super(const TransferState()) {
    on<TransferUploadRequested>(_onUploadRequested);
    on<TransferDownloadRequested>(_onDownloadRequested);
    on<TransferRetryRequested>(_onRetryRequested);
    on<TransferCancelRequested>(_onCancelRequested);
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
    on<TransferUploadDraftFilesAppended>(_onUploadDraftFilesAppended);
    on<TransferUploadDraftFileRemoved>(_onUploadDraftFileRemoved);
    on<TransferUploadDraftPickerBusy>(_onUploadDraftPickerBusy);
    on<TransferUploadDraftSelectionNoticeConsumed>(
      _onUploadDraftSelectionNoticeConsumed,
    );
    on<TransferUploadRecipientDraftChanged>(_onUploadRecipientDraftChanged);
  }

  final StartUploadUseCase _startUpload;
  final StartDownloadUseCase _startDownload;
  final RetryTransferUseCase _retryTransfer;
  final CancelTransferUseCase _cancelTransfer;
  final SendFiles _sendFiles;
  final PrepareBatchUploadUiUseCase _prepareBatchUploadUi;
  final ValidateTransferBatchUseCase _validateTransferBatch;
  final PrepareIncomingTransferUseCase _prepareIncomingTransfer;
  final MobileDataLargeUploadConsentRepository _mobileDataLargeUploadConsent;
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

  Future<void> _onCancelRequested(
    TransferCancelRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _runTransferAction(
      emit: emit,
      transferId: event.transferId,
      action: () => _cancelTransfer(event.transferId),
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
      final String displayError = _toDisplayError(error);
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: displayError,
          uiWarningMessage: displayError,
        ),
      );
    }
  }

  Future<void> _onBatchUploadRequested(
    TransferBatchUploadRequested event,
    Emitter<TransferState> emit,
  ) async {
    try {
      final TransferBatchValidationDecision validation =
          await _validateTransferBatch(event.files);
      if (validation.requiresMobileDataConfirmation) {
        emit(
          state.copyWith(
            pendingUploadConfirmation: PendingUploadConfirmation(
              senderId: event.senderId,
              recipientCode: event.recipientCode,
              files: event.files,
              totalBytes: validation.totalBytes,
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
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: _toDisplayError(error),
        ),
      );
    }
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
    await _mobileDataLargeUploadConsent.setUserConsented(true);
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

  void _onUploadDraftFilesAppended(
    TransferUploadDraftFilesAppended event,
    Emitter<TransferState> emit,
  ) {
    final List<SelectedTransferFile> picked = event.picked;
    final int countBefore = state.selectedUploadFiles.length;
    final Set<String> seenPaths = <String>{
      for (final SelectedTransferFile f in state.selectedUploadFiles)
        f.localPath,
    };
    final List<SelectedTransferFile> merged = List<SelectedTransferFile>.from(
      state.selectedUploadFiles,
    );
    for (final SelectedTransferFile file in picked) {
      if (seenPaths.add(file.localPath)) {
        merged.add(file);
      }
    }
    final bool duplicate = picked.isNotEmpty && merged.length == countBefore;
    emit(
      state.copyWith(
        selectedUploadFiles: merged,
        uploadDraftSelectionNotice: duplicate
            ? 'Those files are already in the list.'
            : null,
        clearUploadDraftSelectionNotice: !duplicate,
      ),
    );
  }

  void _onUploadDraftFileRemoved(
    TransferUploadDraftFileRemoved event,
    Emitter<TransferState> emit,
  ) {
    emit(
      state.copyWith(
        selectedUploadFiles: state.selectedUploadFiles
            .where((SelectedTransferFile f) => f.localPath != event.localPath)
            .toList(growable: false),
        clearUploadDraftSelectionNotice: true,
      ),
    );
  }

  void _onUploadDraftPickerBusy(
    TransferUploadDraftPickerBusy event,
    Emitter<TransferState> emit,
  ) {
    emit(state.copyWith(uploadDraftPickerBusy: event.busy));
  }

  void _onUploadDraftSelectionNoticeConsumed(
    TransferUploadDraftSelectionNoticeConsumed event,
    Emitter<TransferState> emit,
  ) {
    emit(state.copyWith(clearUploadDraftSelectionNotice: true));
  }

  void _onUploadRecipientDraftChanged(
    TransferUploadRecipientDraftChanged event,
    Emitter<TransferState> emit,
  ) {
    if (event.draft == state.uploadRecipientCodeDraft) {
      return;
    }
    emit(state.copyWith(uploadRecipientCodeDraft: event.draft));
  }

  Future<void> _startBatchUpload(
    Emitter<TransferState> emit, {
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  }) async {
    final BatchUploadUiDecision uiDecision = await _prepareBatchUploadUi();

    emit(
      state.copyWith(
        status: TransferStatus.loading,
        progress: 0,
        clearErrorMessage: true,
        clearBatchProgress: true,
        uiWarningMessage: uiDecision.warningMessage,
        showInAppProgress: uiDecision.showInAppProgress,
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
          final int totalFiles = progress.files.length;
          final int completedCount = progress.files
              .where(
                (TransferFileProgress item) =>
                    item.status == TransferFileProgressStatus.completed,
              )
              .length;
          final int failedCount = progress.files
              .where(
                (TransferFileProgress item) =>
                    item.status == TransferFileProgressStatus.failed,
              )
              .length;
          final double total = progress.files.isEmpty
              ? 0
              : progress.files
                        .map((TransferFileProgress e) => e.progress)
                        .reduce((double a, double b) => a + b) /
                    progress.files.length;
          final bool allFailed = totalFiles > 0 && failedCount == totalFiles;
          final bool allCompleted =
              totalFiles > 0 && completedCount == totalFiles;
          final bool hasPartialFailures =
              failedCount > 0 && !allFailed && completedCount > 0;
          String? firstFailureMessage;
          for (final TransferFileProgress item in progress.files) {
            if (item.status == TransferFileProgressStatus.failed &&
                item.errorMessage != null &&
                item.errorMessage!.trim().isNotEmpty) {
              firstFailureMessage = item.errorMessage;
              break;
            }
          }
          return state.copyWith(
            status: allFailed
                ? TransferStatus.error
                : (allCompleted
                      ? TransferStatus.success
                      : TransferStatus.loading),
            progress: total,
            batchSessionId: progress.sessionId,
            batchProgressByFileId: byId,
            errorMessage: allFailed
                ? (firstFailureMessage ??
                      'Transfer failed before upload could start. Check connection and cloud permissions, then retry.')
                : null,
            clearErrorMessage: !allFailed,
            uiWarningMessage: allFailed
                ? (firstFailureMessage ??
                      'Transfer failed before upload could start. Please fix the issue and tap Transfer again.')
                : (hasPartialFailures
                      ? 'Some files failed to upload. Review file statuses and retry.'
                      : null),
            clearUiWarningMessage: false,
            selectedUploadFiles: allCompleted
                ? const <SelectedTransferFile>[]
                : state.selectedUploadFiles,
            clearUploadDraftSelectionNotice: allCompleted,
            uploadRecipientCodeDraft: allCompleted
                ? ''
                : state.uploadRecipientCodeDraft,
          );
        },
      );
    } catch (error) {
      final String displayError = _toDisplayError(error);
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: displayError,
          uiWarningMessage: displayError,
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
    final TransferLifecycleSignalEntity? previousSignal =
        state.lifecycleSignalsByTransferId[event.signal.transferId];
    if (previousSignal != null &&
        previousSignal.event == event.signal.event &&
        !event.signal.emittedAt.isAfter(previousSignal.emittedAt)) {
      return;
    }
    final Map<String, TransferLifecycleSignalEntity> nextSignals =
        <String, TransferLifecycleSignalEntity>{
          ...state.lifecycleSignalsByTransferId,
          event.signal.transferId: event.signal,
        };
    final bool hasActiveLocalTransfer = state.activeTransferId != null;
    if (hasActiveLocalTransfer &&
        event.signal.event != TransferLifecycleEventType.transferCompleted &&
        event.signal.event != TransferLifecycleEventType.transferFailed &&
        event.signal.event != TransferLifecycleEventType.transferRejected) {
      emit(state.copyWith(lifecycleSignalsByTransferId: nextSignals));
      return;
    }
    if (event.signal.event == TransferLifecycleEventType.transferCompleted) {
      emit(
        state.copyWith(
          lifecycleSignalsByTransferId: nextSignals,
          status: TransferStatus.success,
          clearErrorMessage: true,
          clearUiWarningMessage: true,
        ),
      );
      return;
    }
    if (event.signal.event == TransferLifecycleEventType.transferRejected) {
      emit(
        state.copyWith(
          lifecycleSignalsByTransferId: nextSignals,
          status: TransferStatus.receiverDeclined,
          clearErrorMessage: true,
          clearUiWarningMessage: true,
        ),
      );
      return;
    }
    emit(state.copyWith(lifecycleSignalsByTransferId: nextSignals));
  }

  void _onIncomingTransferReceived(
    IncomingTransferReceived event,
    Emitter<TransferState> emit,
  ) {
    final int existingIndex = state.incomingTransfers.indexWhere(
      (IncomingTransferOffer item) =>
          item.transferId == event.transfer.transferId,
    );
    final List<IncomingTransferOffer> nextList =
        List<IncomingTransferOffer>.from(state.incomingTransfers);
    final bool isNewIncoming = existingIndex < 0;
    if (existingIndex >= 0) {
      nextList[existingIndex] = event.transfer;
    } else {
      nextList.add(event.transfer);
    }
    emit(
      state.copyWith(
        incomingTransfers: nextList,
        uiWarningMessage: isNewIncoming
            ? 'Incoming transfer from ${event.transfer.senderId}.'
            : null,
        clearUiWarningMessage: !isNewIncoming,
      ),
    );
  }

  Future<void> _onIncomingTransferAccepted(
    IncomingTransferAccepted event,
    Emitter<TransferState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TransferStatus.loading,
        activeTransferId: event.transfer.transferId,
        progress: 0,
        clearErrorMessage: true,
      ),
    );
    try {
      final PreparedIncomingTransferDecision decision =
          await _prepareIncomingTransfer(event.transfer);
      String? mergedNotice = decision.uiWarningMessage?.trim();
      if (mergedNotice != null && mergedNotice.isEmpty) {
        mergedNotice = null;
      }
      await _sendFiles.acceptIncoming(
        transfer: event.transfer,
        persistPermanently: decision.persistPermanently,
        trustSender: event.trustSender,
        onDownloadProgress: (double progress) {
          emit(
            state.copyWith(
              status: TransferStatus.loading,
              activeTransferId: event.transfer.transferId,
              progress: progress,
              clearErrorMessage: true,
            ),
          );
        },
        onReceivedFileSaved: (String summary) {
          mergedNotice = (mergedNotice == null || mergedNotice!.trim().isEmpty)
              ? summary
              : '${mergedNotice!.trim()}\n\n$summary';
        },
      );
      emit(
        state.copyWith(
          status: TransferStatus.success,
          progress: 1,
          clearActiveTransferId: true,
          incomingTransfers: state.incomingTransfers
              .where((item) => item.transferId != event.transfer.transferId)
              .toList(growable: false),
          uiWarningMessage: mergedNotice,
          showInAppProgress: decision.showInAppProgress,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: _toDisplayError(error),
          clearActiveTransferId: true,
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
          incomingTransfers: state.incomingTransfers
              .where((item) => item.transferId != event.transferId)
              .toList(growable: false),
          status: TransferStatus.error,
          errorMessage: _toDisplayError(error),
        ),
      );
    }
  }

  String _toDisplayError(Object error) {
    final String raw = error is AppException ? error.message : error.toString();
    final String normalized = raw.toLowerCase();
    final bool isRecipientCodePermissionIssue =
        (normalized.contains('"code":"42501"') ||
            normalized.contains("code':'42501") ||
            normalized.contains('permission denied')) &&
        normalized.contains('recipient_codes');
    if (isRecipientCodePermissionIssue) {
      return 'Cloud pairing is unavailable right now. Please reopen the app and try again.';
    }
    final bool isStoragePolicyBlocked =
        normalized.contains('storage policy blocked upload') ||
        (normalized.contains('row-level security policy') &&
            normalized.contains('storage'));
    if (isStoragePolicyBlocked) {
      return 'Cloud upload is not authorized for this account right now. Reopen the app (or sign in again) and retry.';
    }
    if (error is AppException) {
      return raw;
    }
    return raw;
  }

  @override
  Future<void> close() async {
    await _incomingSubscription?.cancel();
    await _lifecycleSubscription?.cancel();
    return super.close();
  }
}
