import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../entities/selected_transfer_file.dart';
import 'evaluate_upload_policy_usecase.dart';

class TransferBatchValidationDecision {
  const TransferBatchValidationDecision({
    required this.requiresMobileDataConfirmation,
    required this.totalBytes,
  });

  final bool requiresMobileDataConfirmation;
  final int totalBytes;
}

class ValidateTransferBatchUseCase {
  const ValidateTransferBatchUseCase(this._evaluateUploadPolicy);

  final EvaluateUploadPolicyUseCase _evaluateUploadPolicy;

  Future<TransferBatchValidationDecision> call(
    List<SelectedTransferFile> files,
  ) async {
    final bool oversized = files.any(
      (SelectedTransferFile file) =>
          file.sizeBytes > AppConstants.maxTransferFileSizeBytes,
    );
    if (oversized) {
      throw const AppException('File exceeds 1GB max size.');
    }
    final UploadPolicyDecision uploadPolicy = await _evaluateUploadPolicy(
      files,
    );
    return TransferBatchValidationDecision(
      requiresMobileDataConfirmation:
          uploadPolicy.requiresMobileDataConfirmation,
      totalBytes: uploadPolicy.totalBytes,
    );
  }
}
