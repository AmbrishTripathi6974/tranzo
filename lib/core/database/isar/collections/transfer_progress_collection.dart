import 'package:isar_community/isar.dart';

part 'transfer_progress_collection.g.dart';

/// Chunk-level progress for resumable uploads/downloads.
///
/// [direction] matches [TransferSessionDirection]: `0` = upload, `1` = download.
@Collection()
class TransferProgressCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String transferId;

  late String fileName;
  late int totalBytes;

  /// Ordinal of [TransferSessionDirection] (`upload` = 0, `download` = 1).
  late int direction;

  List<int> completedChunkIndexes = const <int>[];

  DateTime? updatedAt;
}
