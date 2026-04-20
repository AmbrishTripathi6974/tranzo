import '../../domain/entities/transfer_task.dart';
import '../chunking/chunk_manager.dart';
import '../retry/retry_queue.dart';
import '../state/transfer_state_manager.dart';

/// Download-side orchestration hooks: chunk planning, local resume state, retry timing.
/// Byte transport and remote APIs belong in repository / services.
final class DownloadManager {
  DownloadManager({
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

  List<ChunkDescriptor> chunkPlanFor(TransferTask task) {
    return _chunks.split(totalBytes: task.totalBytes);
  }

  void registerSession(TransferResumeState state) {
    _state.putState(state);
  }

  List<ChunkDescriptor> pendingChunksFor(String transferId) {
    return _state.pendingChunks(
      transferId: transferId,
      chunkManager: _chunks,
    );
  }

  TransferResumeState? acknowledgeChunkComplete(String transferId, int chunkIndex) {
    return _state.markChunkComplete(transferId, chunkIndex);
  }

  Future<void> startResumableSession(TransferResumeState state) async {
    registerSession(state);
  }

  Future<void> resumeSession(String transferId) async {}

  Future<void> pauseSession(String transferId) async {}

  Future<void> downloadChunk({
    required String transferId,
    required ChunkDescriptor chunk,
  }) async {}

  Future<void> finalizeSession(String transferId) async {
    _state.removeState(transferId);
    _retries.clearId(transferId);
  }
}
