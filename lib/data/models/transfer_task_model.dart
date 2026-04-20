import '../../domain/entities/transfer_task.dart';

class TransferTaskModel extends TransferTask {
  const TransferTaskModel({
    required super.id,
    required super.fileName,
    required super.totalBytes,
  });

  factory TransferTaskModel.fromEntity(TransferTask task) {
    return TransferTaskModel(
      id: task.id,
      fileName: task.fileName,
      totalBytes: task.totalBytes,
    );
  }

  factory TransferTaskModel.fromJson(Map<String, dynamic> json) {
    return TransferTaskModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      totalBytes: json['totalBytes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fileName': fileName,
      'totalBytes': totalBytes,
    };
  }
}
