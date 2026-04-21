import 'package:equatable/equatable.dart';

enum TransferLifecycleEventType {
  transferStarted,
  transferAccepted,
  transferCompleted,
  transferFailed,
}

class TransferLifecycleSignalEntity extends Equatable {
  const TransferLifecycleSignalEntity({
    required this.transferId,
    required this.senderId,
    required this.receiverId,
    required this.event,
    required this.emittedAt,
  });

  final String transferId;
  final String senderId;
  final String receiverId;
  final TransferLifecycleEventType event;
  final DateTime emittedAt;

  @override
  List<Object?> get props => <Object?>[
    transferId,
    senderId,
    receiverId,
    event,
    emittedAt,
  ];
}
