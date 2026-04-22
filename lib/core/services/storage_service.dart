import 'package:disk_space_plus/disk_space_plus.dart';

class LocalStorageSnapshot {
  const LocalStorageSnapshot({
    required this.freeBytes,
    required this.totalBytes,
  });

  final int freeBytes;
  final int totalBytes;

  int get usedBytes => totalBytes - freeBytes;
}

abstract interface class StorageService {
  Future<bool> hasSpaceForBytes(int requiredBytes);
  Future<LocalStorageSnapshot?> getLocalStorageSnapshot();
}

final class StorageServiceImpl implements StorageService {
  StorageServiceImpl({DiskSpacePlus? diskSpacePlus})
    : _diskSpacePlus = diskSpacePlus ?? DiskSpacePlus();

  final DiskSpacePlus _diskSpacePlus;

  @override
  Future<bool> hasSpaceForBytes(int requiredBytes) async {
    if (requiredBytes <= 0) {
      return true;
    }
    final LocalStorageSnapshot? snapshot = await getLocalStorageSnapshot();
    if (snapshot == null) {
      return false;
    }
    return requiredBytes <= snapshot.freeBytes;
  }

  @override
  Future<LocalStorageSnapshot?> getLocalStorageSnapshot() async {
    final double? freeDiskSpaceMb = await _diskSpacePlus.getFreeDiskSpace;
    final double? totalDiskSpaceMb = await _diskSpacePlus.getTotalDiskSpace;
    if (freeDiskSpaceMb == null || totalDiskSpaceMb == null) {
      return null;
    }
    const int bytesPerMb = 1024 * 1024;
    final int freeBytes = (freeDiskSpaceMb * bytesPerMb).floor();
    final int totalBytes = (totalDiskSpaceMb * bytesPerMb).floor();
    if (totalBytes <= 0 || freeBytes < 0 || freeBytes > totalBytes) {
      return null;
    }
    return LocalStorageSnapshot(freeBytes: freeBytes, totalBytes: totalBytes);
  }
}
