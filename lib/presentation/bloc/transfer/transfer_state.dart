import 'package:equatable/equatable.dart';

import '../../../domain/entities/incoming_transfer_offer.dart';
import '../../../domain/entities/transfer_batch_progress.dart';
import '../../../domain/entities/selected_transfer_file.dart';

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
    bool clearActiveTransferId = false,
    bool clearErrorMessage = false,
    bool clearBatchProgress = false,
    bool clearPendingUploadConfirmation = false,
    bool clearUiWarningMessage = false,
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
  ];
}
