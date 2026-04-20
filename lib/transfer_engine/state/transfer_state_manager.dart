import 'package:equatable/equatable.dart';

import '../../domain/entities/transfer_task.dart';
import '../chunking/chunk_manager.dart';

/// Whether local resume state refers to an upload or download session.
enum TransferSessionDirection {
  upload,
  download,
}

/// Serializable progress for resumable chunked transfers (persist via data layer).
final class TransferResumeState extends Equatable {
  const TransferResumeState({
    required this.transferId,
    required this.fileName,
    required this.totalBytes,
    required this.direction,
    this.completedChunkIndexes = const <int>{},
    this.updatedAt,
  });

  final String transferId;
  final String fileName;
  final int totalBytes;
  final TransferSessionDirection direction;

  /// Zero-based chunk indices that finished successfully (transport layer sets).
  final Set<int> completedChunkIndexes;
  final DateTime? updatedAt;

  factory TransferResumeState.fromTask(
    TransferTask task, {
    required TransferSessionDirection direction,
  }) {
    return TransferResumeState(
      transferId: task.id,
      fileName: task.fileName,
      totalBytes: task.totalBytes,
      direction: direction,
    );
  }

  factory TransferResumeState.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['completedChunkIndexes'] as List<dynamic>? ??
        const <dynamic>[];
    return TransferResumeState(
      transferId: json['transferId'] as String,
      fileName: json['fileName'] as String,
      totalBytes: json['totalBytes'] as int,
      direction: TransferSessionDirection.values.firstWhere(
        (TransferSessionDirection e) => e.name == json['direction'] as String,
      ),
      completedChunkIndexes: Set<int>.from(raw.cast<int>()),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final List<int> sorted = completedChunkIndexes.toList()..sort();
    return <String, dynamic>{
      'transferId': transferId,
      'fileName': fileName,
      'totalBytes': totalBytes,
      'direction': direction.name,
      'completedChunkIndexes': sorted,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TransferResumeState copyWith({
    Set<int>? completedChunkIndexes,
    DateTime? updatedAt,
  }) {
    return TransferResumeState(
      transferId: transferId,
      fileName: fileName,
      totalBytes: totalBytes,
      direction: direction,
      completedChunkIndexes:
          completedChunkIndexes ?? this.completedChunkIndexes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    transferId,
    fileName,
    totalBytes,
    direction,
    completedChunkIndexes,
    updatedAt,
  ];
}

/// In-memory coordinator for resume metadata; pair with [TransferLocalDataSource]
/// when persistence is implemented.
final class TransferStateManager {
  final Map<String, TransferResumeState> _byId = <String, TransferResumeState>{};

  TransferResumeState? getState(String transferId) => _byId[transferId];

  void putState(TransferResumeState state) {
    _byId[state.transferId] = state.copyWith(
      updatedAt: DateTime.now(),
    );
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
