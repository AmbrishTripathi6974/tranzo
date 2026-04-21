import 'package:equatable/equatable.dart';

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
  ];
}
