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
    this.cloudProgressPercent,
    this.cloudStatus,
    this.usesTransfersV2 = false,
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
  final int? cloudProgressPercent;
  final String? cloudStatus;
  final bool usesTransfersV2;

  IncomingTransferOffer copyWith({
    String? transferId,
    String? senderId,
    String? receiverId,
    String? fileId,
    String? fileName,
    int? fileSize,
    String? fileHash,
    String? storagePath,
    DateTime? createdAt,
    SenderTrustStatus? trustStatus,
    bool? requiresApproval,
    int? cloudProgressPercent,
    String? cloudStatus,
    bool? usesTransfersV2,
  }) {
    return IncomingTransferOffer(
      transferId: transferId ?? this.transferId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileHash: fileHash ?? this.fileHash,
      storagePath: storagePath ?? this.storagePath,
      createdAt: createdAt ?? this.createdAt,
      trustStatus: trustStatus ?? this.trustStatus,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      cloudProgressPercent: cloudProgressPercent ?? this.cloudProgressPercent,
      cloudStatus: cloudStatus ?? this.cloudStatus,
      usesTransfersV2: usesTransfersV2 ?? this.usesTransfersV2,
    );
  }

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
    cloudProgressPercent,
    cloudStatus,
    usesTransfersV2,
  ];
}
