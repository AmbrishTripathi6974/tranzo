import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tranzo/core/services/background_transfer_runtime_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'tranzo/transfer_progress_notification_test',
  );

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('showProgress does not invoke channel on unsupported platform', () async {
    bool called = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          called = true;
          return true;
        });

    final MethodChannelAndroidTransferProgressNotificationBridge bridge =
        MethodChannelAndroidTransferProgressNotificationBridge(
          channel: channel,
          isSupportedPlatform: () => false,
        );

    await bridge.showProgress(fileName: 'sample.bin', progressPercent: 50);
    expect(called, isFalse);
  });

  test('showProgress invokes channel with clamped payload', () async {
    MethodCall? lastCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          lastCall = call;
          return true;
        });

    final MethodChannelAndroidTransferProgressNotificationBridge bridge =
        MethodChannelAndroidTransferProgressNotificationBridge(
          channel: channel,
          isSupportedPlatform: () => true,
        );

    await bridge.showProgress(fileName: 'sample.bin', progressPercent: 150);

    expect(lastCall, isNotNull);
    expect(lastCall!.method, 'show_progress');
    expect(lastCall!.arguments, <String, dynamic>{
      'fileName': 'sample.bin',
      'progressPercent': 100,
    });
  });

  test('TransferProgressTracker keeps progress monotonic per transfer', () {
    final TransferProgressTracker tracker = TransferProgressTracker();

    expect(tracker.nextProgress('t1', 10), 10);
    expect(tracker.nextProgress('t1', 8), 10);
    expect(tracker.nextProgress('t1', 50), 50);
    expect(tracker.nextProgress('t1', 150), 100);
    expect(tracker.nextProgress('t1', 90), 100);
    expect(tracker.nextProgress('t2', 20), 20);
  });
}
