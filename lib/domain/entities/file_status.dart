import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum FileStatus { pending, uploading, completed, failed, corrupted }
