import 'package:isar_community/isar.dart';

import '../../../../domain/entities/file_status.dart';

part 'file_collection.g.dart';

/// Files attached to a transfer (names, hashes, per-file status).
@Collection()
class FileCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String fileId;

  @Index()
  late String transferId;

  late String fileName;
  late int size;
  late String hash;

  @Enumerated(EnumType.ordinal)
  late FileStatus status;
}
