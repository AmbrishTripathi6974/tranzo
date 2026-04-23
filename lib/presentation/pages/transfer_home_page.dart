import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/network_info.dart';
import '../../di/injection_container.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../domain/entities/transfer_status.dart' as domain;
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../bloc/history/history_state.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';
import '../bloc/transfer/transfer_bloc.dart';
import '../bloc/transfer/transfer_state.dart';
import '../router/route_names.dart';
import '../widgets/transfer_status_card.dart';
import '../widgets/tranzo_skeleton.dart';

class TransferHomePage extends StatefulWidget {
  const TransferHomePage({super.key});

  @override
  State<TransferHomePage> createState() => _TransferHomePageState();
}

class _TransferHomePageState extends State<TransferHomePage> {
  static const Duration _reconnectBannerDuration = Duration(seconds: 10);

  bool _postTransferSkeleton = false;
  Timer? _postTransferSkeletonTimer;
  Timer? _reconnectedTimer;
  StreamSubscription<NetworkConnectionType>? _networkSubscription;
  NetworkConnectionType _networkConnectionType = NetworkConnectionType.other;
  bool _recentlyReconnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistoryIfReady());
    _initConnectivityStatus();
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    _postTransferSkeletonTimer?.cancel();
    _reconnectedTimer?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivityStatus() async {
    final NetworkInfo networkInfo = sl<NetworkInfo>();
    final NetworkConnectionType initialType = await networkInfo.connectionType;
    if (mounted) {
      setState(() => _networkConnectionType = initialType);
    }
    _networkSubscription = networkInfo.onConnectionChanged.listen((
      NetworkConnectionType connectionType,
    ) {
      if (!mounted || _networkConnectionType == connectionType) {
        return;
      }
      final bool wasOffline = _networkConnectionType == NetworkConnectionType.none;
      final bool nowOnline = connectionType != NetworkConnectionType.none;
      if (wasOffline && nowOnline) {
        _reconnectedTimer?.cancel();
        setState(() {
          _networkConnectionType = connectionType;
          _recentlyReconnected = true;
        });
        _reconnectedTimer = Timer(_reconnectBannerDuration, () {
          if (!mounted) {
            return;
          }
          setState(() => _recentlyReconnected = false);
        });
        return;
      }

      setState(() {
        _networkConnectionType = connectionType;
        if (connectionType == NetworkConnectionType.none) {
          _reconnectedTimer?.cancel();
          _recentlyReconnected = false;
        }
      });
    });
  }

  void _schedulePostTransferSkeleton() {
    _postTransferSkeletonTimer?.cancel();
    setState(() => _postTransferSkeleton = true);
    _postTransferSkeletonTimer = Timer(const Duration(milliseconds: 420), () {
      if (mounted) {
        setState(() => _postTransferSkeleton = false);
      }
    });
  }

  void _loadHistoryIfReady() {
    if (!mounted) {
      return;
    }
    final String? userId = context.read<ProfileBloc>().state.user?.id;
    if (userId == null) {
      return;
    }
    context.read<HistoryBloc>().add(LoadHistory(userId));
  }

  TransferEntity? _latestTransfer(List<TransferEntity> items) {
    if (items.isEmpty) {
      return null;
    }
    final List<TransferEntity> sorted = List<TransferEntity>.from(items)
      ..sort(
        (TransferEntity a, TransferEntity b) =>
            b.createdAt.compareTo(a.createdAt),
      );
    return sorted.first;
  }

  String? _statusDetailMessage({
    required BuildContext context,
    required TransferState transferState,
    required HistoryState historyState,
    required String? currentUserId,
  }) {
    switch (transferState.status) {
      case TransferStatus.error:
        return null;
      case TransferStatus.receiverDeclined:
        return 'They may have decided they did not need the file '
            'on their device. This is not a send failure.';
      case TransferStatus.initial:
      case TransferStatus.loading:
      case TransferStatus.success:
        if (currentUserId == null) {
          return null;
        }
        final TransferEntity? latest = _latestTransfer(historyState.allItems);
        if (latest == null) {
          return null;
        }
        final bool isSender = latest.senderId == currentUserId;
        final String role = isSender ? 'Sender' : 'Receiver';
        final String fileName = latest.fileName.trim().isEmpty
            ? 'Unknown file'
            : latest.fileName.trim();
        final String statusLabel = switch (latest.status) {
          domain.TransferStatus.pending || domain.TransferStatus.queued =>
            'Queued',
          domain.TransferStatus.uploading => 'Sending',
          domain.TransferStatus.uploaded => isSender
              ? 'Sent, waiting for receiver'
              : 'Ready to receive',
          domain.TransferStatus.downloading => 'Receiving',
          domain.TransferStatus.completed => isSender ? 'Sent' : 'Received',
          domain.TransferStatus.failed => isSender ? 'Send failed' : 'Receive failed',
          domain.TransferStatus.cancelled => 'Cancelled',
        };
        final String age = _relativeTime(context, latest.createdAt);
        return '$role: $fileName · $age · $statusLabel';
    }
  }

  String? _networkDetailMessage() {
    if (_networkConnectionType == NetworkConnectionType.none) {
      return 'Transfer is queued and will continue when connection is back.';
    }
    if (_recentlyReconnected) {
      return 'Connection restored. Open Transfer to retry or continue queued uploads.';
    }
    return null;
  }

  String _relativeTime(BuildContext context, DateTime value) {
    final DateTime local = value.toLocal();
    final Duration diff = DateTime.now().difference(local);
    final DateTime today = DateTime.now();
    final DateTime localDay = DateTime(local.year, local.month, local.day);
    final DateTime todayDay = DateTime(today.year, today.month, today.day);
    if (diff.inSeconds < 45) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (localDay == todayDay.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    final MaterialLocalizations loc = MaterialLocalizations.of(context);
    return loc.formatShortDate(local);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tranzo')),
      body: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<TransferBloc, TransferState>(
            listenWhen: (TransferState previous, TransferState current) {
              return previous.status == TransferStatus.loading &&
                  current.status != TransferStatus.loading;
            },
            listener: (BuildContext context, TransferState _) {
              _schedulePostTransferSkeleton();
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (ProfileState previous, ProfileState current) {
              return previous.user?.id != current.user?.id &&
                  current.user?.id != null;
            },
            listener: (BuildContext context, ProfileState _) {
              _loadHistoryIfReady();
            },
          ),
          BlocListener<TransferBloc, TransferState>(
            listenWhen: (TransferState previous, TransferState current) {
              return previous.lifecycleSignalsByTransferId !=
                  current.lifecycleSignalsByTransferId;
            },
            listener: (BuildContext context, TransferState _) {
              _loadHistoryIfReady();
            },
          ),
        ],
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double maxWidth = constraints.maxWidth >= 900 ? 760 : 680;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  children: <Widget>[
                    Text(
                      'Fast and reliable file transfer',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Send files, track upload progress, and review history '
                      'seamlessly.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<TransferBloc, TransferState>(
                      builder: (BuildContext context, TransferState state) {
                        final HistoryState historyState =
                            context.watch<HistoryBloc>().state;
                        final String? currentUserId =
                            context.read<ProfileBloc>().state.user?.id;
                        final TransferEntity? latestTransfer =
                            _latestTransfer(historyState.allItems);
                        final bool historyDataLoading =
                            historyState.status == HistoryStatus.initial ||
                            (historyState.status == HistoryStatus.loading &&
                                historyState.allItems.isEmpty);
                        final bool showStatusSkeleton =
                            state.status == TransferStatus.loading ||
                            _postTransferSkeleton ||
                            historyDataLoading;
                        final String? transferDetailMessage = _statusDetailMessage(
                          context: context,
                          transferState: state,
                          historyState: historyState,
                          currentUserId: currentUserId,
                        );
                        final String? networkDetailMessage =
                            _networkDetailMessage();
                        final String? detailMessage =
                            networkDetailMessage ?? transferDetailMessage;
                        return TranzoSkeleton.wrap(
                          context,
                          enabled: showStatusSkeleton,
                          child: TransferStatusCard(
                            status: state.status,
                            isOffline:
                                _networkConnectionType ==
                                NetworkConnectionType.none,
                            isReconnected:
                                _recentlyReconnected &&
                                _networkConnectionType !=
                                    NetworkConnectionType.none,
                            detailMessage: showStatusSkeleton &&
                                    (detailMessage == null ||
                                        detailMessage.trim().isEmpty)
                                ? 'Syncing latest transfer activity and status'
                                : detailMessage,
                            onDetailTap: latestTransfer == null
                                ? null
                                : () => context.go(RouteNames.history),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => context.go(RouteNames.transfer),
                      icon: const Icon(Icons.upload_outlined),
                      label: const Text('Start New Transfer'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => context.go(RouteNames.history),
                      icon: const Icon(Icons.history),
                      label: const Text('View History'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
