import 'package:equatable/equatable.dart';

import '../../domain/entities/transfer_task.dart';
import '../chunking/chunk_manager.dart';

/// Whether local resume state refers to an upload or download session.
enum TransferSessionDirection { upload, download }

/// Serializable progress for resumable chunked transfers (persist via data layer).
final class TransferResumeState extends Equatable {
  const TransferResumeState({
    required this.transferId,
    required this.fileId,
    required this.fileName,
    required this.totalBytes,
    required this.totalChunks,
    required this.direction,
    required this.status,
    this.completedChunkIndexes = const <int>{},
    this.retryAttempt = 0,
    this.nextRetryAt,
    this.lastErrorCode,
    this.updatedAt,
  });

  final String transferId;
  final String fileId;
  final String fileName;
  final int totalBytes;
  final int totalChunks;
  final TransferSessionDirection direction;
  final String status;

  /// Zero-based chunk indices that finished successfully (transport layer sets).
  final Set<int> completedChunkIndexes;
  final int retryAttempt;
  final DateTime? nextRetryAt;
  final String? lastErrorCode;
  final DateTime? updatedAt;

  factory TransferResumeState.fromTask(
    TransferTask task, {
    required TransferSessionDirection direction,
  }) {
    return TransferResumeState(
      transferId: task.id,
      fileId: task.id,
      fileName: task.fileName,
      totalBytes: task.totalBytes,
      totalChunks: const ChunkManager()
          .split(totalBytes: task.totalBytes)
          .length,
      direction: direction,
      status: 'pending',
    );
  }

  factory TransferResumeState.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw =
        json['completedChunkIndexes'] as List<dynamic>? ?? const <dynamic>[];
    return TransferResumeState(
      transferId: json['transferId'] as String,
      fileId: json['fileId'] as String? ?? json['transferId'] as String,
      fileName: json['fileName'] as String,
      totalBytes: json['totalBytes'] as int,
      totalChunks: json['totalChunks'] as int? ?? 0,
      direction: TransferSessionDirection.values.firstWhere(
        (TransferSessionDirection e) => e.name == json['direction'] as String,
      ),
      status: json['status'] as String? ?? 'pending',
      completedChunkIndexes: Set<int>.from(raw.cast<int>()),
      retryAttempt: json['retryAttempt'] as int? ?? 0,
      nextRetryAt: json['nextRetryAt'] == null
          ? null
          : DateTime.parse(json['nextRetryAt'] as String),
      lastErrorCode: json['lastErrorCode'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final List<int> sorted = completedChunkIndexes.toList()..sort();
    return <String, dynamic>{
      'transferId': transferId,
      'fileId': fileId,
      'fileName': fileName,
      'totalBytes': totalBytes,
      'totalChunks': totalChunks,
      'direction': direction.name,
      'status': status,
      'completedChunkIndexes': sorted,
      'retryAttempt': retryAttempt,
      'nextRetryAt': nextRetryAt?.toIso8601String(),
      'lastErrorCode': lastErrorCode,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TransferResumeState copyWith({
    String? status,
    Set<int>? completedChunkIndexes,
    int? retryAttempt,
    DateTime? nextRetryAt,
    String? lastErrorCode,
    DateTime? updatedAt,
  }) {
    return TransferResumeState(
      transferId: transferId,
      fileId: fileId,
      fileName: fileName,
      totalBytes: totalBytes,
      totalChunks: totalChunks,
      direction: direction,
      status: status ?? this.status,
      completedChunkIndexes:
          completedChunkIndexes ?? this.completedChunkIndexes,
      retryAttempt: retryAttempt ?? this.retryAttempt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    transferId,
    fileId,
    fileName,
    totalBytes,
    totalChunks,
    direction,
    status,
    completedChunkIndexes,
    retryAttempt,
    nextRetryAt,
    lastErrorCode,
    updatedAt,
  ];
}

/// In-memory coordinator for resume metadata; pair with [TransferLocalDataSource]
/// when persistence is implemented.
final class TransferStateManager {
  final Map<String, TransferResumeState> _byId =
      <String, TransferResumeState>{};

  TransferResumeState? getState(String transferId) => _byId[transferId];

  void putState(TransferResumeState state) {
    _byId[state.transferId] = state.copyWith(updatedAt: DateTime.now());
  }

  TransferResumeState? markChunkComplete(String transferId, int chunkIndex) {
    final TransferResumeState? existing = _byId[transferId];
    if (existing == null) {
      return null;
    }
    final Set<int> next = Set<int>.from(existing.completedChunkIndexes)
      ..add(chunkIndex);
    final TransferResumeState updated = existing.copyWith(
      completedChunkIndexes: next,
      updatedAt: DateTime.now(),
    );
    _byId[transferId] = updated;
    return updated;
  }

  void removeState(String transferId) {
    _byId.remove(transferId);
  }

  /// Chunks not yet marked complete for this transfer.
  List<ChunkDescriptor> pendingChunks({
    required String transferId,
    required ChunkManager chunkManager,
  }) {
    final TransferResumeState? state = _byId[transferId];
    if (state == null) {
      return <ChunkDescriptor>[];
    }
    final List<ChunkDescriptor> all = chunkManager.split(
      totalBytes: state.totalBytes,
    );
    return all
        .where(
          (ChunkDescriptor c) => !state.completedChunkIndexes.contains(c.index),
        )
        .toList(growable: false);
  }
}
