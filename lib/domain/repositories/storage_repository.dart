abstract interface class StorageRepository {
  Future<bool> hasSpaceForBytes(int requiredBytes);
}
