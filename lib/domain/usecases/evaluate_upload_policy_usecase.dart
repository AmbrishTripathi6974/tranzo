import '../../core/constants/app_constants.dart';
import '../../core/network/network_info.dart';
import '../entities/selected_transfer_file.dart';
import '../repositories/mobile_data_large_upload_consent_repository.dart';

class UploadPolicyDecision {
  const UploadPolicyDecision({
    required this.requiresMobileDataConfirmation,
    required this.totalBytes,
  });

  final bool requiresMobileDataConfirmation;
  final int totalBytes;
}

class EvaluateUploadPolicyUseCase {
  const EvaluateUploadPolicyUseCase(
    this._networkInfo,
    this._mobileDataConsent,
  );

  final NetworkInfo _networkInfo;
  final MobileDataLargeUploadConsentRepository _mobileDataConsent;

  Future<UploadPolicyDecision> call(List<SelectedTransferFile> files) async {
    final int totalBytes = files.fold<int>(
      0,
      (int sum, SelectedTransferFile file) => sum + file.sizeBytes,
    );
    final NetworkConnectionType connectionType =
        await _networkInfo.connectionType;
    bool requiresConfirmation =
        connectionType == NetworkConnectionType.mobile &&
        totalBytes > AppConstants.mobileDataConfirmationThresholdBytes;
    if (requiresConfirmation && await _mobileDataConsent.hasUserConsented()) {
      requiresConfirmation = false;
    }
    return UploadPolicyDecision(
      requiresMobileDataConfirmation: requiresConfirmation,
      totalBytes: totalBytes,
    );
  }
}
