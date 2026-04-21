import '../../domain/entities/transfer_task.dart';
import '../chunking/chunk_manager.dart';
import '../retry/retry_queue.dart';
import '../state/transfer_state_manager.dart';

/// Upload-side orchestration hooks: chunk planning, local resume state, retry timing.
/// Byte transport and remote APIs belong in repository / services.
final class UploadManager {
  UploadManager({
    ChunkManager? chunkManager,
    TransferStateManager? stateManager,
    RetryQueue? retryQueue,
  }) : _chunks = chunkManager ?? const ChunkManager(),
       _state = stateManager ?? TransferStateManager(),
       _retries = retryQueue ?? RetryQueue();

  final ChunkManager _chunks;
  final TransferStateManager _state;
  final RetryQueue _retries;

  ChunkManager get chunkManager => _chunks;

  TransferStateManager get stateManager => _state;

  RetryQueue get retryQueue => _retries;

  /// Pure chunk layout for [task] (no IO).
  List<ChunkDescriptor> chunkPlanFor(TransferTask task) {
    return _chunks.split(totalBytes: task.totalBytes);
  }

  /// Registers or replaces in-memory resume state for an upload session.
  void registerSession(TransferResumeState state) {
    _state.putState(state);
  }

  /// Chunks still outstanding according to local progress.
  List<ChunkDescriptor> pendingChunksFor(String transferId) {
    return _state.pendingChunks(transferId: transferId, chunkManager: _chunks);
  }

  /// Marks a chunk finished locally (caller persists via data layer when wired).
  TransferResumeState? acknowledgeChunkComplete(
    String transferId,
    int chunkIndex,
  ) {
    return _state.markChunkComplete(transferId, chunkIndex);
  }

  /// Entry point for a resumable upload session (wire to remote + file IO later).
  Future<void> startResumableSession(TransferResumeState state) async {
    registerSession(state);
  }

  /// Resume using state already in [stateManager] or re-seeded by caller.
  Future<void> resumeSession(String transferId) async {}

  Future<void> pauseSession(String transferId) async {}

  /// Upload bytes for a single planned chunk (no network / file IO in this layer).
  Future<void> uploadChunk({
    required String transferId,
    required ChunkDescriptor chunk,
  }) async {}

  Future<void> finalizeSession(String transferId) async {
    _state.removeState(transferId);
    _retries.clearId(transferId);
  }
}
