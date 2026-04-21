// Pre-downloads Isar native core for VM tests (`flutter test`).
//
// Usage (from repo root):
//   dart run tool/ensure_isar_test_binary.dart
//
// Writes `libisar.dll` (Windows) next to the test entry script directory Isar
// expects, so `flutter test` can open the database without hitting the network
// on every run.
//
// Optional env:
//   TRANZO_SKIP_ISAR_INTEGRATION=1 — exits 0 without doing anything

import 'dart:io';

import 'package:isar_community/isar.dart';

Future<void> main() async {
  if (Platform.environment['TRANZO_SKIP_ISAR_INTEGRATION'] == '1') {
    return;
  }
  await Isar.initializeIsarCore(download: true);
  // ignore: avoid_print
  print('Isar core binary is ready for VM tests.');
}
