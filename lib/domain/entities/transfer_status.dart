import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum TransferStatus {
  pending,
  uploading,
  downloading,
  completed,
  failed,
  cancelled,
}
