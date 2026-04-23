import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';

/// Worker for [Isolate.run]: only [path] is sent across isolates; file bytes are read here.
Future<String> _sha256HashFileWorker(String path) async {
  final Digest digest = await sha256.bind(File(path).openRead()).first;
  return digest.toString();
}

/// Worker for [Isolate.run]: [bytes] is copied into the worker (avoid huge buffers—see [Sha256Hasher]).
String _sha256HashBytesWorker(List<int> bytes) {
  return sha256.convert(bytes).toString();
}

final class Sha256Hasher {
  const Sha256Hasher();

  /// Spawn cost dominates for small buffers; huge buffers would duplicate RAM in the worker.
  static const int _minBytesForIsolateRun = 512 * 1024;
  static const int _maxBytesForIsolateRun = 12 * 1024 * 1024;

  /// SHA-256 of file at [filePath], computed in a short-lived worker isolate (path only on the wire).
  Future<String> hashFile(String filePath) async {
    return Isolate.run(() => _sha256HashFileWorker(filePath));
  }

  String hashBytes(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Like [hashBytes], but offloads to a worker when size is in [_minBytesForIsolateRun], [_maxBytesForIsolateRun].
  Future<String> hashBytesAsync(List<int> bytes) async {
    if (bytes.length >= _minBytesForIsolateRun &&
        bytes.length <= _maxBytesForIsolateRun) {
      return Isolate.run(() => _sha256HashBytesWorker(bytes));
    }
    return hashBytes(bytes);
  }
}
