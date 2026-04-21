abstract final class AppConstants {
  static const int defaultChunkSizeBytes = 1024 * 1024;
  static const int defaultMaxRetryCount = 3;
  static const int maxTransferFileSizeBytes = 1024 * 1024 * 1024;
  static const int mobileDataConfirmationThresholdBytes = 50 * 1024 * 1024;
  static const Duration receiverOfflineQueueTtl = Duration(minutes: 10);
}
