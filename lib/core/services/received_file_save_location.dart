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

  final List<Directory> candidates = <Directory>[];

  final Directory? downloads = await _tryGetDownloadsDirectory();
  if (downloads != null) {
    candidates.add(Directory(p.join(downloads.path, 'Tranzo')));
  }

  if (Platform.isAndroid) {
    for (final Directory shared in _androidSharedDownloadsCandidates()) {
      candidates.add(Directory(p.join(shared.path, 'Tranzo')));
    }

    final List<Directory>? typedExternalDirs =
        await _tryGetExternalStorageDirectories(type: StorageDirectory.downloads);
    if (typedExternalDirs != null) {
      for (final Directory dir in typedExternalDirs) {
        candidates.add(Directory(p.join(dir.path, 'Tranzo')));
      }
    }

    final Directory? external = await _tryGetExternalStorageDirectory();
    if (external != null) {
      candidates.add(Directory(p.join(external.path, 'Tranzo', 'Received')));
    }
  }

  final Directory docs = await getApplicationDocumentsDirectory();
  candidates.add(Directory(p.join(docs.path, 'Received')));

  for (final Directory candidate in candidates) {
    final Directory? ready = await _prepareWritableDirectory(candidate);
    if (ready != null) {
      return ready;
    }
  }

  throw const FileSystemException(
    'Unable to resolve writable directory for received files.',
  );
}

/// Short text for success UI (not a full path on mobile sandboxes).
String describeReceivedSaveLocation(Directory directory) {
  final String path = directory.path;
  if (path.toLowerCase().contains('download')) {
    return 'Downloads/Tranzo';
  }
  if (Platform.isAndroid &&
      path.contains('Android${Platform.pathSeparator}data')) {
    if (path.contains('${Platform.pathSeparator}Tranzo${Platform.pathSeparator}Received')) {
      return 'Files app -> Android/data/.../files/Tranzo/Received';
    }
    return 'Files app -> Android/data/.../files/Tranzo';
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return 'Tranzo -> Received (Files / On My iPhone)';
  }
  if (Platform.isAndroid &&
      (path.startsWith('/storage/emulated/0/Download') ||
          path.startsWith('/sdcard/Download'))) {
    return 'Downloads/Tranzo';
  }
  return path;
}

List<Directory> _androidSharedDownloadsCandidates() {
  if (!Platform.isAndroid) {
    return const <Directory>[];
  }
  return <Directory>[
    Directory('/storage/emulated/0/Download'),
    Directory('/sdcard/Download'),
  ];
}

Future<Directory?> _tryGetDownloadsDirectory() async {
  try {
    return await getDownloadsDirectory();
  } on UnsupportedError {
    return null;
  } on MissingPlatformDirectoryException {
    return null;
  }
}

Future<List<Directory>?> _tryGetExternalStorageDirectories({
  StorageDirectory? type,
}) async {
  try {
    return await getExternalStorageDirectories(type: type);
  } on UnsupportedError {
    return null;
  } on MissingPlatformDirectoryException {
    return null;
  }
}

Future<Directory?> _tryGetExternalStorageDirectory() async {
  try {
    return await getExternalStorageDirectory();
  } on UnsupportedError {
    return null;
  } on MissingPlatformDirectoryException {
    return null;
  }
}

Future<Directory?> _prepareWritableDirectory(Directory directory) async {
  try {
    await directory.create(recursive: true);
    final File probe = File(
      p.join(
        directory.path,
        '.tranzo-write-check-${DateTime.now().microsecondsSinceEpoch}.tmp',
      ),
    );
    await probe.writeAsString('ok', flush: true);
    if (await probe.exists()) {
      await probe.delete();
    }
    return directory;
  } on FileSystemException {
    return null;
  }
}
