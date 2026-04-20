import 'package:isar_community/isar.dart';

import '../../../../domain/entities/transfer_status.dart';

part 'transfer_collection.g.dart';

/// Completed and in-flight transfers for local history and offline queue.
@Collection()
class TransferCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String transferId;

  late String senderId;
  late String receiverId;

  @Enumerated(EnumType.ordinal)
  late TransferStatus status;

  late DateTime createdAt;
  DateTime? expiresAt;

  String? fileName;
  int? fileSize;
  String? fileHash;
  String? storagePath;
  double? intentScore;
  DateTime? intentExpiry;
}
