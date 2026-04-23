import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum PermissionState { granted, denied, permanentlyDenied }

class TransferPermissionSnapshot {
  const TransferPermissionSnapshot({
    required this.storage,
    required this.notifications,
  });

  final PermissionState storage;
  final PermissionState notifications;
}

abstract interface class PermissionService {
  Future<TransferPermissionSnapshot> checkTransferPermissions();
}

final class PermissionServiceImpl implements PermissionService {
  @override
  Future<TransferPermissionSnapshot> checkTransferPermissions() async {
    final PermissionState storageState = await _resolveStoragePermission();
    final PermissionState notificationState =
        await _resolveNotificationPermission();
    return TransferPermissionSnapshot(
      storage: storageState,
      notifications: notificationState,
    );
  }

  Future<PermissionState> _resolveStoragePermission() async {
    if (!Platform.isAndroid) {
      return PermissionState.granted;
    }

    final List<PermissionStatus> mediaStatuses =
        await <Permission>[
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request().then((Map<Permission, PermissionStatus> map) {
          return map.values.toList(growable: false);
        });

    if (mediaStatuses.any((PermissionStatus status) => status.isGranted)) {
      return PermissionState.granted;
    }
    if (mediaStatuses.any(
      (PermissionStatus status) => status.isPermanentlyDenied,
    )) {
      return PermissionState.permanentlyDenied;
    }
    return PermissionState.denied;
  }

  Future<PermissionState> _resolveNotificationPermission() async {
    final PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      return PermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return PermissionState.permanentlyDenied;
    }
    return PermissionState.denied;
  }
}
