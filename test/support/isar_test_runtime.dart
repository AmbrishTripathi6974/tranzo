import 'dart:io';

import 'package:isar_community/isar.dart';

/// Prepares Isar native core for VM tests (`flutter test`) before any [Isar.open].
///
/// **Does not break the default suite when offline or without natives:** returns
/// `false` so callers can [skip] integration tests instead of failing everything.
///
/// Resolution order:
/// 1. [Platform.environment]`['TRANZO_SKIP_ISAR_INTEGRATION'] == '1'` → `false`
/// 2. [Isar.initializeIsarCore] with defaults (bare name + `dirname(Platform.script)`)
/// 3. [Isar.initializeIsarCore]`(download: true)` → fetches matching core for this ABI
///
/// **CI / dev:** run once (optional, speeds up CI if cached):
/// `dart run tool/ensure_isar_test_binary.dart`
///
/// **Parallel `flutter test`:** if multiple isolates download the same file, use
/// `flutter test -j 1` for the Isar integration file, or pre-seed the binary with the tool above.
Future<bool> ensureIsarCoreForTests() async {
  if (Platform.environment['TRANZO_SKIP_ISAR_INTEGRATION'] == '1') {
    return false;
  }
  try {
    await Isar.initializeIsarCore();
    return true;
  } catch (_) {
    // Continue to optional download.
  }
  try {
    await Isar.initializeIsarCore(download: true);
    return true;
  } catch (_) {
    return false;
  }
}
