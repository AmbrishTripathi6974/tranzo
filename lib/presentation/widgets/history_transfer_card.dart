import 'package:flutter/material.dart';

import '../../domain/entities/transfer_entity.dart';
import '../../domain/entities/transfer_status.dart';

/// Rich history row inspired by high-end transfer apps: direction, file type,
/// size chip, relative time, and a clear status capsule.
class HistoryTransferCard extends StatelessWidget {
  const HistoryTransferCard({
    required this.transfer,
    required this.currentUserId,
    super.key,
  });

  final TransferEntity transfer;
  final String currentUserId;

  static const Color _sentStart = Color(0xFF6366F1);
  static const Color _sentEnd = Color(0xFF8B5CF6);
  static const Color _recvStart = Color(0xFF0D9488);
  static const Color _recvEnd = Color(0xFF2DD4BF);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isSent = transfer.senderId == currentUserId;
    final String peerLabel = isSent
        ? (transfer.receiverUsername?.trim().isNotEmpty == true
              ? transfer.receiverUsername!
              : _shortId(transfer.receiverId))
        : (transfer.senderUsername?.trim().isNotEmpty == true
              ? transfer.senderUsername!
              : _shortId(transfer.senderId));

    final LinearGradient directionGradient = isSent
        ? const LinearGradient(
            colors: <Color>[_sentStart, _sentEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: <Color>[_recvStart, _recvEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE9EAF2)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _DirectionAvatar(
                gradient: directionGradient,
                fileIcon: _fileIcon(transfer.fileName),
                isSent: isSent,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      transfer.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        _SizeChip(text: _formatBytes(transfer.fileSize)),
                        _MutedChip(
                          icon: Icons.schedule_rounded,
                          text: _relativeTime(context, transfer.createdAt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Icon(
                          isSent
                              ? Icons.north_east_rounded
                              : Icons.south_west_rounded,
                          size: 16,
                          color: scheme.onSurfaceVariant.withValues(
                            alpha: 0.85,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isSent ? 'To $peerLabel' : 'From $peerLabel',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusCapsule(status: transfer.status),
            ],
          ),
        ),
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 10) {
      return id;
    }
    return '${id.substring(0, 4)}…${id.substring(id.length - 4)}';
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

  String _relativeTime(BuildContext context, DateTime value) {
    final DateTime local = value.toLocal();
    final Duration diff = DateTime.now().difference(local);
    if (diff.inSeconds < 45) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    final MaterialLocalizations loc = MaterialLocalizations.of(context);
    return loc.formatShortDate(local);
  }
}

class _DirectionAvatar extends StatelessWidget {
  const _DirectionAvatar({
    required this.gradient,
    required this.fileIcon,
    required this.isSent,
  });

  final LinearGradient gradient;
  final IconData fileIcon;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                      (isSent
                              ? HistoryTransferCard._sentEnd
                              : HistoryTransferCard._recvEnd)
                          .withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(child: Icon(fileIcon, color: Colors.white, size: 26)),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE9EAF2)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isSent ? Icons.upload_rounded : Icons.download_rounded,
                size: 12,
                color: isSent
                    ? HistoryTransferCard._sentStart
                    : HistoryTransferCard._recvStart,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MutedChip extends StatelessWidget {
  const _MutedChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusCapsule extends StatelessWidget {
  const _StatusCapsule({required this.status});

  final TransferStatus status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _StatusStyle capsule = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: capsule.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: capsule.border),
      ),
      child: Text(
        capsule.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: capsule.foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _StatusStyle _styleFor(TransferStatus s) {
    switch (s) {
      case TransferStatus.completed:
        return const _StatusStyle(
          label: 'Done',
          background: Color(0xFFE8F5E9),
          foreground: Color(0xFF1B5E20),
          border: Color(0xFFC8E6C9),
        );
      case TransferStatus.failed:
        return const _StatusStyle(
          label: 'Failed',
          background: Color(0xFFFFEBEE),
          foreground: Color(0xFFB71C1C),
          border: Color(0xFFFFCDD2),
        );
      case TransferStatus.cancelled:
        return const _StatusStyle(
          label: 'Cancelled',
          background: Color(0xFFFFF3E0),
          foreground: Color(0xFFE65100),
          border: Color(0xFFFFE0B2),
        );
      case TransferStatus.pending:
        return const _StatusStyle(
          label: 'Pending',
          background: Color(0xFFECEFF1),
          foreground: Color(0xFF455A64),
          border: Color(0xFFCFD8DC),
        );
      case TransferStatus.uploading:
        return const _StatusStyle(
          label: 'Sending',
          background: Color(0xFFE8EAF6),
          foreground: Color(0xFF283593),
          border: Color(0xFFC5CAE9),
        );
      case TransferStatus.downloading:
        return const _StatusStyle(
          label: 'Receiving',
          background: Color(0xFFE0F2F1),
          foreground: Color(0xFF00695C),
          border: Color(0xFFB2DFDB),
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color border;
}
