import '../../core/services/permission_service.dart';

class TransferPermissionDecision {
  const TransferPermissionDecision({
    required this.allowPersistentStorage,
    required this.allowNotifications,
    required this.storageDenied,
    required this.notificationDenied,
  });

  final bool allowPersistentStorage;
  final bool allowNotifications;
  final bool storageDenied;
  final bool notificationDenied;
}

class CheckTransferPermissionsUseCase {
  const CheckTransferPermissionsUseCase(this._permissionService);

  final PermissionService _permissionService;

  Future<TransferPermissionDecision> call() async {
    final TransferPermissionSnapshot snapshot = await _permissionService
        .checkTransferPermissions();
    final bool storageGranted = snapshot.storage == PermissionState.granted;
    final bool notificationsGranted =
        snapshot.notifications == PermissionState.granted;
    return TransferPermissionDecision(
      allowPersistentStorage: storageGranted,
      allowNotifications: notificationsGranted,
      storageDenied: !storageGranted,
      notificationDenied: !notificationsGranted,
    );
  }
}
