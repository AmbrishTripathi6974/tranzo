import 'package:isar_community/isar.dart';

part 'queued_transfer_collection.g.dart';

@Collection()
class QueuedTransferCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String queueKey;

  late String transferId;
  late String fileId;
  late DateTime queuedAt;
  late DateTime expiresAt;
  late String status;
  String? reason;
}
