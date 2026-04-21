import 'package:equatable/equatable.dart';

import '../../../domain/entities/selected_transfer_file.dart';
import '../../../domain/entities/incoming_transfer_offer.dart';
import '../../../domain/entities/transfer_task.dart';

sealed class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class TransferUploadRequested extends TransferEvent {
  const TransferUploadRequested(this.task);

  final TransferTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class TransferDownloadRequested extends TransferEvent {
  const TransferDownloadRequested(this.task);

  final TransferTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class TransferRetryRequested extends TransferEvent {
  const TransferRetryRequested(this.transferId);

  final String transferId;

  @override
  List<Object?> get props => <Object?>[transferId];
}

class TransferBatchUploadRequested extends TransferEvent {
  const TransferBatchUploadRequested({
    required this.senderId,
    required this.recipientCode,
    required this.files,
  });

  final String senderId;
  final String recipientCode;
  final List<SelectedTransferFile> files;

  @override
  List<Object?> get props => <Object?>[senderId, recipientCode, files];
}

class TransferBatchUploadConfirmed extends TransferEvent {
  const TransferBatchUploadConfirmed();
}

class TransferBatchUploadCancelled extends TransferEvent {
  const TransferBatchUploadCancelled();
}

class TransferUiEffectConsumed extends TransferEvent {
  const TransferUiEffectConsumed();
}

class IncomingTransferListeningRequested extends TransferEvent {
  const IncomingTransferListeningRequested(this.receiverId);

  final String receiverId;

  @override
  List<Object?> get props => <Object?>[receiverId];
}

class IncomingTransferReceived extends TransferEvent {
  const IncomingTransferReceived(this.transfer);

  final IncomingTransferOffer transfer;

  @override
  List<Object?> get props => <Object?>[transfer];
}

class IncomingTransferAccepted extends TransferEvent {
  const IncomingTransferAccepted(this.transfer);

  final IncomingTransferOffer transfer;

  @override
  List<Object?> get props => <Object?>[transfer];
}

class IncomingTransferRejected extends TransferEvent {
  const IncomingTransferRejected(this.transferId);

  final String transferId;

  @override
  List<Object?> get props => <Object?>[transferId];
}
