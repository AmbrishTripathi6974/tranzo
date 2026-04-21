import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:workmanager/workmanager.dart';

const String kTransferRetryTaskName = 'tranzo_transfer_retry';
const String kTransferRetryTag = 'tranzo_transfer_retry_tag';

@pragma('vm:entry-point')
void transferRetryCallbackDispatcher() {
  Workmanager().executeTask((
    String task,
    Map<String, dynamic>? inputData,
  ) async {
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
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}

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

  Future<void> stopActiveTransfer();

  Future<void> scheduleRetry({
    required String transferId,
    required bool userInitiated,
    Duration initialDelay = Duration.zero,
  });
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
  Future<void> startActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) async {}

  @override
  Future<void> stopActiveTransfer() async {}

  @override
  Future<void> updateActiveTransfer({
    required String transferId,
    required String fileName,
    required int progressPercent,
  }) async {}
}

class AndroidBackgroundTransferRuntimeService
    implements BackgroundTransferRuntimeService {
  const AndroidBackgroundTransferRuntimeService();

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
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        enableVibration: false,
        playSound: false,
        showWhen: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
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

    final bool running = await FlutterForegroundTask.isRunningService;
    if (running) {
      await updateActiveTransfer(
        transferId: transferId,
        fileName: fileName,
        progressPercent: progressPercent,
      );
      return;
    }

    await FlutterForegroundTask.startService(
      serviceId: 2322,
      notificationTitle: 'Tranzo transfer',
      notificationText: '${_sanitizeFileName(fileName)} - $progressPercent%',
      callback: transferForegroundStartCallback,
    );
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

    final bool running = await FlutterForegroundTask.isRunningService;
    if (!running) {
      await startActiveTransfer(
        transferId: transferId,
        fileName: fileName,
        progressPercent: progressPercent,
      );
      return;
    }

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Tranzo transfer',
      notificationText: '${_sanitizeFileName(fileName)} - $progressPercent%',
    );
  }

  @override
  Future<void> stopActiveTransfer() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    final bool running = await FlutterForegroundTask.isRunningService;
    if (running) {
      await FlutterForegroundTask.stopService();
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

  String _sanitizeFileName(String fileName) {
    final String trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      return 'Unknown file';
    }
    return trimmed;
  }
}
