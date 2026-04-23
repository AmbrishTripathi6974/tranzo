import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/network_info.dart';
import '../../di/injection_container.dart';
import '../../domain/entities/incoming_transfer_offer.dart';
import '../../domain/entities/transfer_lifecycle_signal.dart';
import '../bloc/transfer/transfer_bloc.dart';
import '../bloc/transfer/transfer_event.dart';
import '../bloc/transfer/transfer_state.dart';
import '../widgets/connectivity_ui.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late final ConnectivityUiController _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = ConnectivityUiController(networkInfo: sl<NetworkInfo>());
    _connectivity.initialize(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectivity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download')),
      body: BlocBuilder<TransferBloc, TransferState>(
        builder: (BuildContext context, TransferState state) {
          if (state.incomingTransfers.isEmpty) {
            return const Center(child: Text('No incoming transfers.'));
          }
          final bool showTopDownloadProgress =
              state.showInAppProgress ||
              (state.status == TransferStatus.loading &&
                  state.activeTransferId != null);
          return Column(
            children: <Widget>[
              if (_connectivity.isOffline || _connectivity.isReconnecting)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ConnectivityHintCard(
                    isOffline: _connectivity.isOffline,
                    isReconnecting: _connectivity.isReconnecting,
                    offlineTitle: 'You are offline',
                    offlineSubtitle:
                        'Incoming transfers are paused and will resume when connection is back.',
                    reconnectTitle: 'Back online, resuming downloads',
                    reconnectSubtitle:
                        'Waiting downloads are resuming automatically.',
                  ),
                ),
              if (showTopDownloadProgress)
                LinearProgressIndicator(
                  value: state.progress.clamp(0.0, 1.0),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  itemCount: state.incomingTransfers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final transfer = state.incomingTransfers[index];
                    final bool isActiveDownload =
                        state.status == TransferStatus.loading &&
                        state.activeTransferId == transfer.transferId;
                    final double progressValue = state.progress.clamp(0.0, 1.0);
                    final double? remoteProgress = transfer.cloudProgressPercent !=
                            null
                        ? (transfer.cloudProgressPercent! / 100.0).clamp(
                            0.0,
                            1.0,
                          )
                        : null;
                    final _DownloadStatusPresentation statusPresentation =
                        _statusPresentationForTransfer(
                      state: state,
                      transfer: transfer,
                      isActiveDownload: isActiveDownload,
                      isOffline: _connectivity.isOffline,
                      isReconnecting: _connectivity.isReconnecting,
                    );
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _fileIcon(transfer.fileName),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    transfer.fileName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusPresentation.backgroundColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    statusPresentation.label,
                                    style: Theme.of(context).textTheme.labelMedium
                                        ?.copyWith(
                                          color: statusPresentation.foregroundColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'From sender UID: ${_shortId(transfer.senderId)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatBytes(transfer.fileSize),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            if (isActiveDownload &&
                                !_connectivity.isOffline) ...<Widget>[
                              const SizedBox(height: 12),
                              LinearProgressIndicator(value: progressValue),
                              const SizedBox(height: 6),
                              Text(
                                '${(progressValue * 100).toStringAsFixed(0)}% receiving',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (!isActiveDownload &&
                                remoteProgress != null &&
                                transfer.usesTransfersV2) ...<Widget>[
                              const SizedBox(height: 12),
                              LinearProgressIndicator(value: remoteProgress),
                              const SizedBox(height: 6),
                              Text(
                                _v2RemoteProgressSubtitle(
                                  transfer: transfer,
                                  remoteProgress: remoteProgress,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(44),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    onPressed: isActiveDownload ||
                                            (transfer.usesTransfersV2 &&
                                                !<String>{
                                                  'uploaded',
                                                  'downloading',
                                                }.contains(
                                                  transfer.cloudStatus
                                                          ?.toLowerCase() ??
                                                      '',
                                                ))
                                        ? null
                                        : () async {
                                            if (_connectivity.isOffline) {
                                              showOfflineActionSnackBar(
                                                context,
                                                actionLabel: 'download',
                                              );
                                              return;
                                            }
                                            final TransferBloc transferBloc =
                                                context.read<TransferBloc>();
                                            if (transfer.requiresApproval) {
                                              bool trustSender = false;
                                              final bool? allow =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    builder: (
                                                      BuildContext dialogContext,
                                                    ) {
                                                      return StatefulBuilder(
                                                        builder: (
                                                          BuildContext context,
                                                          setState,
                                                        ) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                              'Allow transfer?',
                                                            ),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <Widget>[
                                                                Text(
                                                                  'Allow file from ${transfer.senderId}?',
                                                                ),
                                                                CheckboxListTile(
                                                                  value:
                                                                      trustSender,
                                                                  onChanged: (
                                                                    bool? value,
                                                                  ) {
                                                                    setState(() {
                                                                      trustSender =
                                                                          value ??
                                                                          false;
                                                                    });
                                                                  },
                                                                  title: const Text(
                                                                    'Trust this sender',
                                                                  ),
                                                                  controlAffinity:
                                                                      ListTileControlAffinity
                                                                          .leading,
                                                                  contentPadding:
                                                                      EdgeInsets.zero,
                                                                ),
                                                              ],
                                                            ),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                onPressed: () => Navigator.of(
                                                                  dialogContext,
                                                                ).pop(false),
                                                                child: const Text(
                                                                  'Cancel',
                                                                ),
                                                              ),
                                                              FilledButton(
                                                                onPressed: () => Navigator.of(
                                                                  dialogContext,
                                                                ).pop(true),
                                                                child: const Text(
                                                                  'Download',
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                              if (allow != true || !mounted) {
                                                if (allow == false) {
                                                  transferBloc.add(
                                                    IncomingTransferRejected(
                                                      transfer.transferId,
                                                    ),
                                                  );
                                                }
                                                return;
                                              }
                                              transferBloc.add(
                                                IncomingTransferAccepted(
                                                  transfer,
                                                  trustSender: trustSender,
                                                ),
                                              );
                                              return;
                                            }
                                            transferBloc.add(
                                              IncomingTransferAccepted(transfer),
                                            );
                                          },
                                    child: const Text('Download'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton.tonal(
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(44),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    onPressed: isActiveDownload
                                        ? null
                                        : () {
                                            context.read<TransferBloc>().add(
                                              IncomingTransferRejected(
                                                transfer.transferId,
                                              ),
                                            );
                                          },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _v2RemoteProgressSubtitle({
    required IncomingTransferOffer transfer,
    required double remoteProgress,
  }) {
    final String s = (transfer.cloudStatus ?? '').toLowerCase();
    final int pct = (remoteProgress * 100).round();
    if (s == 'uploading' && remoteProgress >= 1.0) {
      return 'Finishing upload on server…';
    }
    if (s == 'uploading') {
      return '$pct% · sender uploading';
    }
    if (s == 'downloading') {
      return '$pct% receiving';
    }
    return '$pct%';
  }

  _DownloadStatusPresentation _statusPresentationForTransfer({
    required TransferState state,
    required IncomingTransferOffer transfer,
    required bool isActiveDownload,
    required bool isOffline,
    required bool isReconnecting,
  }) {
    if (isOffline &&
        (isActiveDownload || _isTransferDownloadableOrActive(transfer))) {
      return _DownloadStatusPresentation(
        label: 'Paused (offline)',
        backgroundColor: Colors.orange.shade50,
        foregroundColor: Colors.orange.shade900,
      );
    }
    if (isReconnecting &&
        (isActiveDownload || _isTransferDownloadableOrActive(transfer))) {
      return _DownloadStatusPresentation(
        label: 'Resuming...',
        backgroundColor: Colors.green.shade50,
        foregroundColor: Colors.green.shade800,
      );
    }
    if (isActiveDownload) {
      return _DownloadStatusPresentation(
        label: 'Receiving…',
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      );
    }
    if (transfer.usesTransfersV2) {
      final String s = (transfer.cloudStatus ?? '').toLowerCase();
      final int? cloudPct = transfer.cloudProgressPercent;
      if (s == 'uploading' && cloudPct != null && cloudPct >= 100) {
        return _DownloadStatusPresentation(
          label: 'Finalizing upload…',
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        );
      }
      switch (s) {
        case 'queued':
          return _defaultDownloadStatus('Waiting…');
        case 'uploading':
          return _defaultDownloadStatus('Sender uploading…');
        case 'uploaded':
          return _defaultDownloadStatus('Ready to download');
        case 'downloading':
          return _defaultDownloadStatus('Receiving…');
        case 'completed':
          return _DownloadStatusPresentation(
            label: 'Done',
            backgroundColor: Colors.green.shade50,
            foregroundColor: Colors.green.shade800,
          );
        case 'failed':
          return _DownloadStatusPresentation(
            label: 'Failed',
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          );
        case 'cancelled':
          return _defaultDownloadStatus('Cancelled');
        default:
          break;
      }
    }
    final signal =
        state.lifecycleSignalsByTransferId[transfer.transferId];
    if (signal == null) {
      return _defaultDownloadStatus('Pending');
    }
    switch (signal.event) {
      case TransferLifecycleEventType.transferCompleted:
        return _DownloadStatusPresentation(
          label: 'Downloaded',
          backgroundColor: Colors.green.shade50,
          foregroundColor: Colors.green.shade800,
        );
      case TransferLifecycleEventType.transferFailed:
        return _DownloadStatusPresentation(
          label: 'Failed',
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        );
      case TransferLifecycleEventType.transferRejected:
        return _defaultDownloadStatus('Cancelled');
      case TransferLifecycleEventType.transferAccepted:
        return _defaultDownloadStatus('Pending');
      case TransferLifecycleEventType.transferStarted:
        return _defaultDownloadStatus('Pending');
    }
  }

  _DownloadStatusPresentation _defaultDownloadStatus(String label) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return _DownloadStatusPresentation(
      label: label,
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
    );
  }

  bool _isTransferDownloadableOrActive(IncomingTransferOffer transfer) {
    if (!transfer.usesTransfersV2) {
      return true;
    }
    final String cloud = (transfer.cloudStatus ?? '').toLowerCase();
    return cloud == 'uploaded' || cloud == 'downloading' || cloud == 'queued';
  }

  IconData _fileIcon(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    final String ext = dot >= 0
        ? fileName.substring(dot + 1).toLowerCase()
        : '';
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'heic':
        return Icons.image_outlined;
      case 'mp4':
      case 'mov':
      case 'mkv':
      case 'webm':
        return Icons.movie_outlined;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return Icons.audio_file_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_outlined;
      case 'apk':
        return Icons.android_rounded;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _shortId(String id) {
    if (id.length <= 14) {
      return id;
    }
    return '${id.substring(0, 6)}…${id.substring(id.length - 4)}';
  }

  String _formatBytes(int bytes) {
    const List<String> units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes <= 0) {
      return '0 B';
    }
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final String formatted = size >= 100
        ? size.toStringAsFixed(0)
        : size.toStringAsFixed(1);
    return '$formatted ${units[unitIndex]}';
  }
}

class _DownloadStatusPresentation {
  const _DownloadStatusPresentation({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
}

