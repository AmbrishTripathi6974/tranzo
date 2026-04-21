import '../repositories/transfer_repository.dart';

class CheckStorageAvailability {
  const CheckStorageAvailability(this._repository);

  final TransferRepository _repository;

  Future<bool> call(int requiredBytes) {
    return _repository.hasAvailableStorage(requiredBytes);
  }
}
