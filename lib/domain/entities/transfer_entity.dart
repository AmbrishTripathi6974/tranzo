import 'package:equatable/equatable.dart';

import 'transfer_status.dart';

class TransferEntity extends Equatable {
  const TransferEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final TransferStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    senderId,
    receiverId,
    status,
    createdAt,
    expiresAt,
  ];
}
