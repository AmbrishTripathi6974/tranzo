import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum TransferStatus {
  pending,
  uploading,
  downloading,
  completed,
  failed,
  cancelled,
  /// New pipeline: row created, not yet uploading to Storage.
  queued,
  /// Sender finished all chunks; receiver may download.
  uploaded,
}
