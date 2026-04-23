import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:workmanager/workmanager.dart';

import '../../di/injection_container.dart';
import '../../domain/usecases/resume_incomplete_transfers_usecase.dart';
import 'supabase_client.dart';

const String kTransferRetryTaskName = 'tranzo_transfer_retry';
const String kTransferRetryTag = 'tranzo_transfer_retry_tag';
const int kTransferForegroundServiceId = 2322;

typedef TransferRetryExecutor =
    Future<void> Function(String transferId, bool userInitiated);

TransferRetryExecutor? _retryExecutor;

void registerTransferRetryExecutor(TransferRetryExecutor executor) {
  _retryExecutor = executor;
}

@pragma('vm:entry-point')
void transferRetryCallbackDispatcher() {
  Workmanager().executeTask((
    String task,
    Map<String, dynamic>? inputData,
  ) async {
    if (task != kTransferRetryTaskName) {
      return true;
    }
    final String transferId = inputData?['transferId'] as String? ?? '';
    final bool userInitiated = inputData?['userInitiated'] as bool? ?? false;
    if (transferId.isEmpty) {
      return true;
    }
    if (_retryExecutor != null) {
      await _retryExecutor!(transferId, userInitiated);
      return true;
    }
    WidgetsFlutterBinding.ensureInitialized();
    await TranzoSupabase.initializeFromEnvironment();
    await configureDependencies();
    await registerIsarDatabase();
    await sl<ResumeIncompleteTransfersUseCase>()(transferId: transferId);
    return true;
  });
}

@pragma('vm:entry-point')
void transferForegroundStartCallback() {
  FlutterForegroundTask.setTaskHandler(TransferForegroundTaskHandler());
}

class TransferForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) {
    // Intentionally no-op: notification must never trigger transfer actions.
  }

  @override
  void onNotificationPressed() {
    // Intentionally no-op: inbox/download button is the only download trigger.
  }

  @override
  void onNotificationDismissed() {}
}

abstract interface class BackgroundTransferRuntimeService {
  Future<void> initialize();

  Future<void> startActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  });

  Future<void> updateActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  });

  Future<void> stopActiveTransfer({String? transferId});

  Future<void> scheduleRetry({
    required String transferId,
    required bool userInitiated,
    Duration initialDelay = Duration.zero,
  });

  Future<void> cancelRetry({required String transferId});
}

class NoopBackgroundTransferRuntimeService
    implements BackgroundTransferRuntimeService {
  const NoopBackgroundTransferRuntimeService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleRetry({
    required String transferId,
    required bool userInitiated,
    Duration initialDelay = Duration.zero,
  }) async {}

  @override
  Future<void> cancelRetry({required String transferId}) async {}

  @override
  Future<void> startActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) async {}

  @override
  Future<void> stopActiveTransfer({String? transferId}) async {}

  @override
  Future<void> updateActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) async {}
}

class AndroidBackgroundTransferRuntimeService
    implements BackgroundTransferRuntimeService {
  AndroidBackgroundTransferRuntimeService({
    AndroidTransferProgressNotificationBridge? progressNotificationBridge,
  }) : _progressNotificationBridge =
           progressNotificationBridge ??
           MethodChannelAndroidTransferProgressNotificationBridge();

  final Set<String> _activeTransferIds = <String>{};
  _NotificationRenderState? _lastRenderedState;
  final TransferProgressTracker _progressTracker = TransferProgressTracker();
  final AndroidTransferProgressNotificationBridge _progressNotificationBridge;

  @override
  Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tranzo_transfer_channel',
        channelName: 'Transfer progress',
        channelDescription:
            'Shows active transfer progress and keeps transfers alive.',
        // Use low-priority + onlyAlertOnce to avoid re-alert spam while
        // progress updates continue on the same ongoing foreground notification.
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        enableVibration: false,
        playSound: false,
        showWhen: true,
        onlyAlertOnce: true,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowAutoRestart: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    await Workmanager().initialize(transferRetryCallbackDispatcher);
  }

  @override
  Future<void> startActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    _activeTransferIds.add(transferId);

    final bool running = await FlutterForegroundTask.isRunningService;
    if (running) {
      await updateActiveTransfer(
        transferId: transferId,
        fileName: fileName,
        progressPercent: progressPercent,
      );
      return;
    }

    final _NotificationRenderState state = _buildRenderState(
      transferId: transferId,
      fileName: fileName,
      progressPercent: progressPercent,
    );
    final dynamic startResult = await FlutterForegroundTask.startService(
      serviceId: kTransferForegroundServiceId,
      notificationTitle: 'Tranzo transfer',
      notificationText: state.notificationText,
      callback: transferForegroundStartCallback,
    );
    switch (startResult) {
      case ServiceRequestFailure(:final error):
        developer.log(
          'foreground_service_start_failed',
          name: 'transfer',
          error: error,
        );
      default:
        await _progressNotificationBridge.showProgress(
          fileName: state.fileName,
          progressPercent: state.progressPercent,
        );
        _lastRenderedState = state;
    }
  }

  @override
  Future<void> updateActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    _activeTransferIds.add(transferId);

    final bool running = await FlutterForegroundTask.isRunningService;
    if (!running) {
      await startActiveTransfer(
        transferId: transferId,
        fileName: fileName,
        progressPercent: progressPercent,
      );
      return;
    }

    final _NotificationRenderState state = _buildRenderState(
      transferId: transferId,
      fileName: fileName,
      progressPercent: progressPercent,
    );
    if (_lastRenderedState == state) {
      return;
    }

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Tranzo transfer',
      notificationText: state.notificationText,
    );
    await _progressNotificationBridge.showProgress(
      fileName: state.fileName,
      progressPercent: state.progressPercent,
    );
    _lastRenderedState = state;
  }

  @override
  Future<void> stopActiveTransfer({String? transferId}) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    if (transferId != null && transferId.isNotEmpty) {
      _activeTransferIds.remove(transferId);
      _progressTracker.remove(transferId);
    } else {
      _activeTransferIds.clear();
      _progressTracker.clear();
    }
    if (_activeTransferIds.isNotEmpty) {
      return;
    }

    final bool running = await FlutterForegroundTask.isRunningService;
    if (!running) {
      _lastRenderedState = null;
      return;
    }

    final dynamic stopResult = await FlutterForegroundTask.stopService();
    switch (stopResult) {
      case ServiceRequestSuccess():
        _lastRenderedState = null;
        return;
      case ServiceRequestFailure(:final error):
        developer.log(
          'foreground_service_stop_failed',
          name: 'transfer',
          error: error,
        );
      default:
        developer.log(
          'foreground_service_stop_unknown_result',
          name: 'transfer',
          error: stopResult,
        );
    }

    // Fallback path for transient failures from the platform channel.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final bool stillRunning = await FlutterForegroundTask.isRunningService;
    if (!stillRunning) {
      _lastRenderedState = null;
      return;
    }

    final dynamic secondStopResult = await FlutterForegroundTask.stopService();
    switch (secondStopResult) {
      case ServiceRequestFailure(:final error):
        developer.log(
          'foreground_service_stop_retry_failed',
          name: 'transfer',
          error: error,
        );
      default:
        _lastRenderedState = null;
        break;
    }
  }

  @override
  Future<void> scheduleRetry({
    required String transferId,
    required bool userInitiated,
    Duration initialDelay = Duration.zero,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    await Workmanager().registerOneOffTask(
      'transfer_retry_$transferId',
      kTransferRetryTaskName,
      tag: kTransferRetryTag,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: initialDelay,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
      inputData: <String, dynamic>{
        'transferId': transferId,
        'userInitiated': userInitiated,
      },
    );
  }

  @override
  Future<void> cancelRetry({required String transferId}) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    await Workmanager().cancelByUniqueName('transfer_retry_$transferId');
  }

  String _sanitizeFileName(String fileName) {
    final String trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      return 'Unknown file';
    }
    return trimmed;
  }

  _NotificationRenderState _buildRenderState({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) {
    final int monotonic = _progressTracker.nextProgress(
      transferId,
      progressPercent,
    );
    final String sanitizedFileName = _sanitizeFileName(fileName);
    return _NotificationRenderState(
      transferId: transferId,
      fileName: sanitizedFileName,
      progressPercent: monotonic,
      notificationText: '$sanitizedFileName - $monotonic%',
    );
  }
}

@visibleForTesting
class TransferProgressTracker {
  final Map<String, int> _maxRenderedProgressByTransferId = <String, int>{};

  int nextProgress(String transferId, int progressPercent) {
    final int clamped = progressPercent.clamp(0, 100);
    return _maxRenderedProgressByTransferId.update(
      transferId,
      (int previous) => clamped > previous ? clamped : previous,
      ifAbsent: () => clamped,
    );
  }

  void remove(String transferId) {
    _maxRenderedProgressByTransferId.remove(transferId);
  }

  void clear() {
    _maxRenderedProgressByTransferId.clear();
  }
}

@immutable
class _NotificationRenderState {
  const _NotificationRenderState({
    required this.transferId,
    required this.fileName,
    required this.progressPercent,
    required this.notificationText,
  });

  final String transferId;
  final String fileName;
  final int progressPercent;
  final String notificationText;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _NotificationRenderState &&
        other.transferId == transferId &&
        other.fileName == fileName &&
        other.progressPercent == progressPercent;
  }

  @override
  int get hashCode => Object.hash(transferId, fileName, progressPercent);
}

abstract interface class AndroidTransferProgressNotificationBridge {
  Future<void> showProgress({
    required String fileName,
    required int progressPercent,
  });
}

class MethodChannelAndroidTransferProgressNotificationBridge
    implements AndroidTransferProgressNotificationBridge {
  MethodChannelAndroidTransferProgressNotificationBridge({
    MethodChannel? channel,
    bool Function()? isSupportedPlatform,
  }) : _channel =
           channel ??
           const MethodChannel('tranzo/transfer_progress_notification'),
       _isSupportedPlatform =
           isSupportedPlatform ?? _defaultIsSupportedPlatform;

  final MethodChannel _channel;
  final bool Function() _isSupportedPlatform;

  @override
  Future<void> showProgress({
    required String fileName,
    required int progressPercent,
  }) async {
    if (!_isSupportedPlatform()) {
      return;
    }
    try {
      await _channel.invokeMethod<bool>('show_progress', <String, dynamic>{
        'fileName': fileName,
        'progressPercent': progressPercent.clamp(0, 100),
      });
    } on MissingPluginException {
      // Native bridge unavailable in this runtime; foreground text updates remain.
    } on PlatformException catch (error) {
      developer.log(
        'transfer_progress_native_notify_failed',
        name: 'transfer',
        error: error,
      );
    }
  }

  static bool _defaultIsSupportedPlatform() {
    return !kIsWeb && Platform.isAndroid;
  }
}
