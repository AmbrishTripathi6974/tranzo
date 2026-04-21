import 'package:equatable/equatable.dart';

import '../../../domain/entities/incoming_transfer_offer.dart';
import '../../../domain/entities/transfer_batch_progress.dart';

enum TransferStatus { initial, loading, success, error }

class TransferState extends Equatable {
  const TransferState({
    this.status = TransferStatus.initial,
    this.progress = 0,
    this.activeTransferId,
    this.errorMessage,
    this.batchProgressByFileId = const <String, TransferFileProgress>{},
    this.batchSessionId,
    this.incomingTransfers = const <IncomingTransferOffer>[],
  });

  final TransferStatus status;
  final double progress;
  final String? activeTransferId;
  final String? errorMessage;
  final Map<String, TransferFileProgress> batchProgressByFileId;
  final String? batchSessionId;
  final List<IncomingTransferOffer> incomingTransfers;

  TransferState copyWith({
    TransferStatus? status,
    double? progress,
    String? activeTransferId,
    String? errorMessage,
    Map<String, TransferFileProgress>? batchProgressByFileId,
    String? batchSessionId,
    List<IncomingTransferOffer>? incomingTransfers,
    bool clearActiveTransferId = false,
    bool clearErrorMessage = false,
    bool clearBatchProgress = false,
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
  ];
}
