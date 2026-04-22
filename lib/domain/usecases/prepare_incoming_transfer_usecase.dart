import '../../core/errors/exceptions.dart';
import '../entities/incoming_transfer_offer.dart';
import 'check_storage_availability_usecase.dart';
import 'check_transfer_permissions_usecase.dart';

class PreparedIncomingTransferDecision {
  const PreparedIncomingTransferDecision({
    required this.persistPermanently,
    this.uiWarningMessage,
    this.showInAppProgress = false,
  });

  final bool persistPermanently;
  final String? uiWarningMessage;
  final bool showInAppProgress;
}

class PrepareIncomingTransferUseCase {
  const PrepareIncomingTransferUseCase({
    required CheckTransferPermissionsUseCase checkTransferPermissions,
    required CheckStorageAvailability checkStorageAvailability,
  }) : _checkTransferPermissions = checkTransferPermissions,
       _checkStorageAvailability = checkStorageAvailability;

  final CheckTransferPermissionsUseCase _checkTransferPermissions;
  final CheckStorageAvailability _checkStorageAvailability;

  Future<PreparedIncomingTransferDecision> call(
    IncomingTransferOffer transfer,
  ) async {
    final TransferPermissionDecision permissionDecision =
        await _checkTransferPermissions();
    final bool hasStorage = await _checkStorageAvailability(transfer.fileSize);
    if (!hasStorage) {
      throw const AppException(
        'Insufficient storage. Free up space to receive this file.',
        code: AppErrorCode.insufficientStorage,
      );
    }
    return PreparedIncomingTransferDecision(
      persistPermanently: permissionDecision.allowPersistentStorage,
      uiWarningMessage: permissionDecision.storageDenied
          ? 'Storage permission denied. File is available temporarily only.'
          : (permissionDecision.notificationDenied
                ? 'Notification permission denied. Transfer progress is shown in-app.'
                : null),
      showInAppProgress: permissionDecision.notificationDenied,
    );
  }
}
