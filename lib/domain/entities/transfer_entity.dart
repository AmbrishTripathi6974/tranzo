import 'package:equatable/equatable.dart';

import 'transfer_status.dart';

class TransferEntity extends Equatable {
  const TransferEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.fileName,
    required this.fileSize,
    this.senderUsername,
    this.receiverUsername,
    this.expiresAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final TransferStatus status;
  final DateTime createdAt;
  final String fileName;
  final int fileSize;
  final String? senderUsername;
  final String? receiverUsername;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    senderId,
    receiverId,
    status,
    createdAt,
    fileName,
    fileSize,
    senderUsername,
    receiverUsername,
    expiresAt,
  ];
}
