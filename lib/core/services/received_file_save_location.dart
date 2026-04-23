import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves where received files should live so users can find them outside the app.
Future<Directory> resolvedReceivedFilesDirectory({
  required bool persistPermanently,
}) async {
  if (!persistPermanently) {
    return await getTemporaryDirectory();
  }
  final Directory? downloads = await getDownloadsDirectory();
  if (downloads != null) {
    final Directory dir = Directory(p.join(downloads.path, 'Tranzo'));
    await dir.create(recursive: true);
    return dir;
  }
  if (Platform.isAndroid) {
    try {
      final Directory? external = await getExternalStorageDirectory();
      if (external != null) {
        final Directory dir = Directory(p.join(external.path, 'Received'));
        await dir.create(recursive: true);
        return dir;
      }
    } catch (_) {
      // Fall through to app documents.
    }
  }
  final Directory docs = await getApplicationDocumentsDirectory();
  final Directory dir = Directory(p.join(docs.path, 'Received'));
  await dir.create(recursive: true);
  return dir;
}

/// Short text for success UI (not a full path on mobile sandboxes).
String describeReceivedSaveLocation(Directory directory) {
  final String path = directory.path;
  if (path.contains('Download')) {
    return 'Downloads/Tranzo';
  }
  if (Platform.isAndroid &&
      path.contains('Android${Platform.pathSeparator}data')) {
    return 'Files app → Tranzo → Received';
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return 'Tranzo → Received (Files / On My iPhone)';
  }
  return path;
}
