import 'package:equatable/equatable.dart';

import '../../../domain/entities/incoming_transfer_offer.dart';
import '../../../domain/entities/transfer_batch_progress.dart';
import '../../../domain/entities/selected_transfer_file.dart';
import '../../../domain/entities/transfer_lifecycle_signal.dart';

enum TransferStatus { initial, loading, success, error }

class PendingUploadConfirmation extends Equatable {
  const PendingUploadConfirmation({
    required this.senderId,
    required this.recipientCode,
    required this.files,
    required this.totalBytes,
  });

  final String senderId;
  final String recipientCode;
  final List<SelectedTransferFile> files;
  final int totalBytes;

  @override
  List<Object?> get props => <Object?>[
    senderId,
    recipientCode,
    files,
    totalBytes,
  ];
}

class TransferState extends Equatable {
  const TransferState({
    this.status = TransferStatus.initial,
    this.progress = 0,
    this.activeTransferId,
    this.errorMessage,
    this.batchProgressByFileId = const <String, TransferFileProgress>{},
    this.batchSessionId,
    this.incomingTransfers = const <IncomingTransferOffer>[],
    this.pendingUploadConfirmation,
    this.uiWarningMessage,
    this.showInAppProgress = false,
    this.lifecycleSignalsByTransferId =
        const <String, TransferLifecycleSignalEntity>{},
    this.selectedUploadFiles = const <SelectedTransferFile>[],
    this.uploadDraftPickerBusy = false,
    this.uploadDraftSelectionNotice,
    this.uploadRecipientCodeDraft = '',
  });

  final TransferStatus status;
  final double progress;
  final String? activeTransferId;
  final String? errorMessage;
  final Map<String, TransferFileProgress> batchProgressByFileId;
  final String? batchSessionId;
  final List<IncomingTransferOffer> incomingTransfers;
  final PendingUploadConfirmation? pendingUploadConfirmation;
  final String? uiWarningMessage;
  final bool showInAppProgress;
  final Map<String, TransferLifecycleSignalEntity> lifecycleSignalsByTransferId;
  final List<SelectedTransferFile> selectedUploadFiles;
  final bool uploadDraftPickerBusy;
  final String? uploadDraftSelectionNotice;
  final String uploadRecipientCodeDraft;

  TransferState copyWith({
    TransferStatus? status,
    double? progress,
    String? activeTransferId,
    String? errorMessage,
    Map<String, TransferFileProgress>? batchProgressByFileId,
    String? batchSessionId,
    List<IncomingTransferOffer>? incomingTransfers,
    PendingUploadConfirmation? pendingUploadConfirmation,
    String? uiWarningMessage,
    bool? showInAppProgress,
    Map<String, TransferLifecycleSignalEntity>? lifecycleSignalsByTransferId,
    List<SelectedTransferFile>? selectedUploadFiles,
    bool? uploadDraftPickerBusy,
    String? uploadDraftSelectionNotice,
    String? uploadRecipientCodeDraft,
    bool clearActiveTransferId = false,
    bool clearErrorMessage = false,
    bool clearBatchProgress = false,
    bool clearPendingUploadConfirmation = false,
    bool clearUiWarningMessage = false,
    bool clearUploadDraftSelectionNotice = false,
  }) {
    return TransferState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      activeTransferId: clearActiveTransferId
          ? null
          : (activeTransferId ?? this.activeTransferId),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      batchProgressByFileId: clearBatchProgress
          ? const <String, TransferFileProgress>{}
          : (batchProgressByFileId ?? this.batchProgressByFileId),
      batchSessionId: clearBatchProgress
          ? null
          : (batchSessionId ?? this.batchSessionId),
      incomingTransfers: incomingTransfers ?? this.incomingTransfers,
      pendingUploadConfirmation: clearPendingUploadConfirmation
          ? null
          : (pendingUploadConfirmation ?? this.pendingUploadConfirmation),
      uiWarningMessage: clearUiWarningMessage
          ? null
          : (uiWarningMessage ?? this.uiWarningMessage),
      showInAppProgress: showInAppProgress ?? this.showInAppProgress,
      lifecycleSignalsByTransferId:
          lifecycleSignalsByTransferId ?? this.lifecycleSignalsByTransferId,
      selectedUploadFiles: selectedUploadFiles ?? this.selectedUploadFiles,
      uploadDraftPickerBusy:
          uploadDraftPickerBusy ?? this.uploadDraftPickerBusy,
      uploadDraftSelectionNotice: clearUploadDraftSelectionNotice
          ? null
          : (uploadDraftSelectionNotice ?? this.uploadDraftSelectionNotice),
      uploadRecipientCodeDraft:
          uploadRecipientCodeDraft ?? this.uploadRecipientCodeDraft,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    progress,
    activeTransferId,
    errorMessage,
    batchProgressByFileId,
    batchSessionId,
    incomingTransfers,
    pendingUploadConfirmation,
    uiWarningMessage,
    showInAppProgress,
    lifecycleSignalsByTransferId,
    selectedUploadFiles,
    uploadDraftPickerBusy,
    uploadDraftSelectionNotice,
    uploadRecipientCodeDraft,
  ];
}
