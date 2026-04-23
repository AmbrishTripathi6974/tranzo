import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/incoming_transfer_offer.dart';
import '../../domain/entities/transfer_lifecycle_signal.dart';
import '../bloc/transfer/transfer_bloc.dart';
import '../bloc/transfer/transfer_event.dart';
import '../bloc/transfer/transfer_state.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
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
                    final String statusLabel = _statusLabelForTransfer(
                      state: state,
                      transfer: transfer,
                      isActiveDownload: isActiveDownload,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'From ${_shortId(transfer.senderId)}',
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
                            if (isActiveDownload) ...<Widget>[
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

  String _statusLabelForTransfer({
    required TransferState state,
    required IncomingTransferOffer transfer,
    required bool isActiveDownload,
  }) {
    if (isActiveDownload) {
      return 'Receiving…';
    }
    if (transfer.usesTransfersV2) {
      final String s = (transfer.cloudStatus ?? '').toLowerCase();
      final int? cloudPct = transfer.cloudProgressPercent;
      if (s == 'uploading' && cloudPct != null && cloudPct >= 100) {
        return 'Finalizing upload…';
      }
      switch (s) {
        case 'queued':
          return 'Waiting…';
        case 'uploading':
          return 'Sender uploading…';
        case 'uploaded':
          return 'Ready to download';
        case 'downloading':
          return 'Receiving…';
        case 'completed':
          return 'Done';
        case 'failed':
          return 'Failed';
        case 'cancelled':
          return 'Cancelled';
        default:
          break;
      }
    }
    final signal =
        state.lifecycleSignalsByTransferId[transfer.transferId];
    if (signal == null) {
      return 'Pending';
    }
    switch (signal.event) {
      case TransferLifecycleEventType.transferCompleted:
        return 'Downloaded';
      case TransferLifecycleEventType.transferFailed:
        return 'Failed';
      case TransferLifecycleEventType.transferRejected:
        return 'Cancelled';
      case TransferLifecycleEventType.transferAccepted:
        return 'Pending';
      case TransferLifecycleEventType.transferStarted:
        return 'Pending';
    }
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
