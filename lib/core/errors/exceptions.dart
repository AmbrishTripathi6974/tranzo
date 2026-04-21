enum AppErrorCode {
  unknown,
  invalidRecipientCode,
  invalidReceiver,
  hashMismatch,
  duplicateFile,
  insufficientStorage,
  insecureEndpoint,
  chunkTransferFailed,
}

class AppException implements Exception {
  const AppException(this.message, {this.code = AppErrorCode.unknown});

  final String message;
  final AppErrorCode code;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

final class SecurityException extends AppException {
  const SecurityException(super.message)
    : super(code: AppErrorCode.insecureEndpoint);
}
