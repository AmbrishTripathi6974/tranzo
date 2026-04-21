import '../../core/constants/app_constants.dart';
import '../../core/network/network_info.dart';
import '../entities/selected_transfer_file.dart';

class UploadPolicyDecision {
  const UploadPolicyDecision({
    required this.requiresMobileDataConfirmation,
    required this.totalBytes,
  });

  final bool requiresMobileDataConfirmation;
  final int totalBytes;
}

class EvaluateUploadPolicyUseCase {
  const EvaluateUploadPolicyUseCase(this._networkInfo);

  final NetworkInfo _networkInfo;

  Future<UploadPolicyDecision> call(List<SelectedTransferFile> files) async {
    final int totalBytes = files.fold<int>(
      0,
      (int sum, SelectedTransferFile file) => sum + file.sizeBytes,
    );
    final NetworkConnectionType connectionType =
        await _networkInfo.connectionType;
    final bool requiresConfirmation =
        connectionType == NetworkConnectionType.mobile &&
        totalBytes > AppConstants.mobileDataConfirmationThresholdBytes;
    return UploadPolicyDecision(
      requiresMobileDataConfirmation: requiresConfirmation,
      totalBytes: totalBytes,
    );
  }
}
