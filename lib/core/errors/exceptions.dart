enum AppErrorCode {
  unknown,
  invalidRecipientCode,
  invalidReceiver,
  hashMismatch,
  duplicateFile,
  insufficientStorage,
  insecureEndpoint,
  chunkTransferFailed,
  networkDisconnected,
  networkTimeout,
  networkUnstable,
  authExpired,
  permissionDenied,
  cancelledByUser,
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

final class TransferErrorUiMapper {
  const TransferErrorUiMapper._();

  static String toUserMessage(Object error) {
    if (error is AppException) {
      return _messageFromAppException(error);
    }
    return _messageFromUnknown(error.toString());
  }

  static String _messageFromAppException(AppException error) {
    final String explicit = error.message.trim();
    switch (error.code) {
      case AppErrorCode.networkDisconnected:
        return 'Connection issue detected. Transfer paused and will retry automatically.';
      case AppErrorCode.networkTimeout:
        return 'Network is slow right now. Transfer timed out and will retry automatically.';
      case AppErrorCode.networkUnstable:
        return 'Connection is unstable. Transfer paused and queued to retry.';
      case AppErrorCode.authExpired:
        return 'Your session expired. Please sign in again and retry the transfer.';
      case AppErrorCode.permissionDenied:
        return 'Transfer is not permitted for this account right now. Reopen the app and try again.';
      case AppErrorCode.cancelledByUser:
        return 'Transfer cancelled.';
      case AppErrorCode.invalidRecipientCode:
      case AppErrorCode.invalidReceiver:
      case AppErrorCode.hashMismatch:
      case AppErrorCode.duplicateFile:
      case AppErrorCode.insufficientStorage:
      case AppErrorCode.insecureEndpoint:
      case AppErrorCode.chunkTransferFailed:
      case AppErrorCode.unknown:
        if (_looksLikeTransportNoise(explicit)) {
          return _messageFromUnknown(explicit);
        }
        return explicit.isEmpty ? 'Transfer failed. Please try again.' : explicit;
    }
  }

  static String _messageFromUnknown(String raw) {
    final String normalized = raw.toLowerCase();
    if (_isDisconnected(normalized)) {
      return 'Connection issue detected. Transfer paused and will retry automatically.';
    }
    if (_isTimeout(normalized)) {
      return 'Network is slow right now. Transfer timed out and will retry automatically.';
    }
    if (_isAuthExpired(normalized)) {
      return 'Your session expired. Please sign in again and retry the transfer.';
    }
    if (_isPermissionDenied(normalized)) {
      return 'Transfer is not permitted for this account right now. Reopen the app and try again.';
    }
    if (_isCancelled(normalized)) {
      return 'Transfer cancelled.';
    }
    if (normalized.contains('insufficient storage')) {
      return 'Insufficient storage. Free up space and retry.';
    }
    return 'Transfer failed. Please try again.';
  }

  static bool _looksLikeTransportNoise(String raw) {
    final String normalized = raw.toLowerCase();
    return _isDisconnected(normalized) ||
        _isTimeout(normalized) ||
        normalized.contains('clientexception') ||
        normalized.contains('dioexception') ||
        normalized.contains('socketexception');
  }

  static bool _isDisconnected(String normalized) {
    return normalized.contains('software caused connection abort') ||
        normalized.contains('connection abort') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('network is unreachable') ||
        normalized.contains('connection refused') ||
        normalized.contains('connection reset') ||
        normalized.contains('socketexception') ||
        normalized.contains('connection error') ||
        normalized.contains('no address associated with hostname');
  }

  static bool _isTimeout(String normalized) {
    return normalized.contains('timed out') ||
        normalized.contains('timeout') ||
        normalized.contains('deadline exceeded');
  }

  static bool _isAuthExpired(String normalized) {
    return normalized.contains('jwt') ||
        normalized.contains('token') ||
        normalized.contains('session expired') ||
        normalized.contains('unauthorized') ||
        normalized.contains('401');
  }

  static bool _isPermissionDenied(String normalized) {
    return normalized.contains('permission denied') ||
        normalized.contains('row-level security') ||
        normalized.contains('storage policy blocked') ||
        normalized.contains('"code":"42501"') ||
        normalized.contains("code':'42501");
  }

  static bool _isCancelled(String normalized) {
    return normalized.contains('cancelled by user') ||
        normalized.contains('transfer cancelled by user');
  }
}
