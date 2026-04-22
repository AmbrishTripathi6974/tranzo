import 'package:equatable/equatable.dart';

enum SenderTrustStatus { unknown, trusted, blocked }

class IncomingTransferOffer extends Equatable {
  const IncomingTransferOffer({
    required this.transferId,
    required this.senderId,
    required this.receiverId,
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.fileHash,
    required this.storagePath,
    required this.createdAt,
    this.trustStatus = SenderTrustStatus.unknown,
    this.requiresApproval = true,
  });

  final String transferId;
  final String senderId;
  final String receiverId;
  final String fileId;
  final String fileName;
  final int fileSize;
  final String fileHash;
  final String storagePath;
  final DateTime createdAt;
  final SenderTrustStatus trustStatus;
  final bool requiresApproval;

  @override
  List<Object?> get props => <Object?>[
    transferId,
    senderId,
    receiverId,
    fileId,
    fileName,
    fileSize,
    fileHash,
    storagePath,
    createdAt,
    trustStatus,
    requiresApproval,
  ];
}
