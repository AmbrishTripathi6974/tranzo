import 'package:isar_community/isar.dart';

import '../../../../domain/entities/incoming_transfer_offer.dart';

part 'sender_trust_collection.g.dart';

@Collection()
class SenderTrustCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String senderId;

  @Enumerated(EnumType.ordinal)
  late SenderTrustStatus status;

  DateTime? trustedUntil;
  late DateTime updatedAt;
}
