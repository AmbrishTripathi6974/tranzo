import 'check_transfer_permissions_usecase.dart';

class BatchUploadUiDecision {
  const BatchUploadUiDecision({
    this.warningMessage,
    required this.showInAppProgress,
  });

  final String? warningMessage;
  final bool showInAppProgress;
}

class PrepareBatchUploadUiUseCase {
  const PrepareBatchUploadUiUseCase(this._checkTransferPermissions);

  final CheckTransferPermissionsUseCase _checkTransferPermissions;

  Future<BatchUploadUiDecision> call() async {
    final TransferPermissionDecision permissionDecision =
        await _checkTransferPermissions();
    final String? warningMessage = permissionDecision.notificationDenied
        ? 'Notification permission denied. Transfer will continue with in-app progress.'
        : null;
    return BatchUploadUiDecision(
      warningMessage: warningMessage,
      showInAppProgress: permissionDecision.notificationDenied,
    );
  }
}
