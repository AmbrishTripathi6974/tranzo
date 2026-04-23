import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/network/network_info.dart';

class ConnectivityUiController {
  ConnectivityUiController({
    required NetworkInfo networkInfo,
    this.reconnectHintDuration = const Duration(seconds: 8),
  }) : _networkInfo = networkInfo;

  final NetworkInfo _networkInfo;
  final Duration reconnectHintDuration;

  bool isOffline = false;
  bool isReconnecting = false;

  StreamSubscription<NetworkConnectionType>? _networkSubscription;
  Timer? _reconnectedTimer;
  VoidCallback? _onChanged;

  Future<void> initialize(VoidCallback onChanged) async {
    _onChanged = onChanged;
    final NetworkConnectionType initial = await _networkInfo.connectionType;
    isOffline = initial == NetworkConnectionType.none;
    _notifyChanged();

    _networkSubscription = _networkInfo.onConnectionChanged.listen((
      NetworkConnectionType nextType,
    ) {
      final bool nextOffline = nextType == NetworkConnectionType.none;
      if (nextOffline == isOffline) {
        return;
      }
      if (isOffline && !nextOffline) {
        _reconnectedTimer?.cancel();
        isOffline = false;
        isReconnecting = true;
        _notifyChanged();
        _reconnectedTimer = Timer(reconnectHintDuration, () {
          isReconnecting = false;
          _notifyChanged();
        });
        return;
      }

      isOffline = nextOffline;
      if (nextOffline) {
        _reconnectedTimer?.cancel();
        isReconnecting = false;
      }
      _notifyChanged();
    });
  }

  void dispose() {
    _networkSubscription?.cancel();
    _reconnectedTimer?.cancel();
    _onChanged = null;
  }

  void _notifyChanged() {
    _onChanged?.call();
  }
}

class ConnectivityHintCard extends StatelessWidget {
  const ConnectivityHintCard({
    super.key,
    required this.isOffline,
    required this.isReconnecting,
    required this.offlineTitle,
    required this.offlineSubtitle,
    required this.reconnectTitle,
    required this.reconnectSubtitle,
  });

  final bool isOffline;
  final bool isReconnecting;
  final String offlineTitle;
  final String offlineSubtitle;
  final String reconnectTitle;
  final String reconnectSubtitle;

  @override
  Widget build(BuildContext context) {
    if (!isOffline && !isReconnecting) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    final bool showOffline = isOffline;
    final IconData icon = showOffline ? Icons.wifi_off_outlined : Icons.wifi;
    final String title = showOffline ? offlineTitle : reconnectTitle;
    final String subtitle = showOffline ? offlineSubtitle : reconnectSubtitle;
    final Color bg = showOffline ? Colors.orange.shade50 : Colors.green.shade50;
    final Color fg = showOffline
        ? Colors.orange.shade900
        : Colors.green.shade800;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showOfflineActionSnackBar(
  BuildContext context, {
  required String actionLabel,
}) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('You are offline. Connect to internet to $actionLabel.'),
      ),
    );
}
