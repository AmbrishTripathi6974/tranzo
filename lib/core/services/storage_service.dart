import 'package:disk_space_plus/disk_space_plus.dart';

abstract interface class StorageService {
  Future<bool> hasSpaceForBytes(int requiredBytes);
}

final class StorageServiceImpl implements StorageService {
  StorageServiceImpl({DiskSpacePlus? diskSpacePlus})
    : _diskSpacePlus = diskSpacePlus ?? DiskSpacePlus();

  final DiskSpacePlus _diskSpacePlus;

  @override
  Future<bool> hasSpaceForBytes(int requiredBytes) async {
    final double? freeDiskSpaceMb = await _diskSpacePlus.getFreeDiskSpace;
    if (freeDiskSpaceMb == null) {
      return false;
    }
    final double requiredMegabytes = requiredBytes / (1024 * 1024);
    return freeDiskSpaceMb >= requiredMegabytes;
  }
}
