import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gal/gal.dart';

/// Best-effort copy of still images and videos into the system photo library.
///
/// Other file types are left on disk only; [describeReceivedSaveLocation] covers UX.
Future<bool> tryExportReceivedMediaToPhotoLibrary(File file, String fileName) async {
  if (kIsWeb) {
    return false;
  }
  if (!Platform.isIOS && !Platform.isAndroid && !Platform.isMacOS) {
    return false;
  }
  final String ext = _extensionLower(fileName);
  final bool isVideo = _videoExtensions.contains(ext);
  final bool isImage = _imageExtensions.contains(ext);
  if (!isVideo && !isImage) {
    return false;
  }
  if (!await file.exists()) {
    return false;
  }
  try {
    final bool hasAlbumAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAlbumAccess) {
      final bool granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        return false;
      }
    }
    if (isVideo) {
      await Gal.putVideo(file.path, album: 'Tranzo');
    } else {
      await Gal.putImage(file.path, album: 'Tranzo');
    }
    return true;
  } catch (_) {
    return false;
  }
}

String _extensionLower(String fileName) {
  final int dot = fileName.lastIndexOf('.');
  if (dot < 0 || dot >= fileName.length - 1) {
    return '';
  }
  return fileName.substring(dot).toLowerCase();
}

const Set<String> _imageExtensions = <String>{
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
  '.heic',
  '.heif',
  '.bmp',
};

const Set<String> _videoExtensions = <String>{
  '.mp4',
  '.mov',
  '.m4v',
  '.webm',
  '.mkv',
  '.avi',
};
