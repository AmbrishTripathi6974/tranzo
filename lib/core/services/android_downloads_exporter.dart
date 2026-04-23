import 'dart:io';

import 'package:flutter/services.dart';

const MethodChannel _receivedFilesChannel = MethodChannel('tranzo/received_files');

/// Stores a file into Android shared Downloads/Tranzo through MediaStore.
///
/// Returns true when the insertion succeeds, false on unsupported platforms or
/// any failure.
Future<bool> tryStoreReceivedFileInAndroidDownloads(
  File sourceFile, {
  required String fileName,
}) async {
  if (!Platform.isAndroid) {
    return false;
  }
  if (!await sourceFile.exists()) {
    return false;
  }
  try {
    final bool? ok = await _receivedFilesChannel.invokeMethod<bool>(
      'store_in_downloads',
      <String, Object?>{
        'sourcePath': sourceFile.path,
        'fileName': fileName,
      },
    );
    return ok ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}
