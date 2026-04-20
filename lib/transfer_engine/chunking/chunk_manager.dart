import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// Byte range for one piece of a resumable transfer (planning only; no IO).
final class ChunkDescriptor extends Equatable {
  const ChunkDescriptor({
    required this.index,
    required this.startByte,
    required this.lengthBytes,
  });

  final int index;
  final int startByte;
  final int lengthBytes;

  int get endByteExclusive => startByte + lengthBytes;

  @override
  List<Object?> get props => <Object?>[index, startByte, lengthBytes];
}

/// Pure chunk splitting for fixed-size segments (last chunk may be smaller).
final class ChunkManager {
  const ChunkManager({this.chunkSizeBytes = AppConstants.defaultChunkSizeBytes})
    : assert(chunkSizeBytes > 0, 'chunkSizeBytes must be positive');

  final int chunkSizeBytes;

  /// Returns an empty list when [totalBytes] is 0; otherwise contiguous ranges
  /// covering `[0, totalBytes)`.
  List<ChunkDescriptor> split({required int totalBytes}) {
    if (totalBytes <= 0) {
      return <ChunkDescriptor>[];
    }
    final List<ChunkDescriptor> chunks = <ChunkDescriptor>[];
    int start = 0;
    int index = 0;
    while (start < totalBytes) {
      final int remaining = totalBytes - start;
      final int len = remaining < chunkSizeBytes ? remaining : chunkSizeBytes;
      chunks.add(
        ChunkDescriptor(index: index, startByte: start, lengthBytes: len),
      );
      start += len;
      index++;
    }
    return chunks;
  }
}
