import 'package:flutter/material.dart';

import '../../domain/entities/transfer_entity.dart';
import '../../domain/entities/transfer_status.dart';

class TransferListItem extends StatelessWidget {
  const TransferListItem({
    required this.transfer,
    required this.currentUserId,
    super.key,
  });

  final TransferEntity transfer;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final bool isSent = transfer.senderId == currentUserId;
    final String username = isSent
        ? (transfer.receiverUsername ?? transfer.receiverId)
        : (transfer.senderUsername ?? transfer.senderId);

    return Card(
      child: ListTile(
        leading: Container(
          width: 10,
          height: 44,
          decoration: BoxDecoration(
            color: _statusColor(transfer.status),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(
          transfer.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${_formatBytes(transfer.fileSize)} • ${_formatDateTime(context, transfer.createdAt)}',
            ),
            Text(
              '${isSent ? 'To' : 'From'}: $username',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Text(
          transfer.status.name,
          style: TextStyle(
            color: _statusColor(transfer.status),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _statusColor(TransferStatus status) {
    switch (status) {
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
        return Colors.red;
      case TransferStatus.cancelled:
        return Colors.orange;
      case TransferStatus.pending:
      case TransferStatus.uploading:
      case TransferStatus.downloading:
        return Colors.blueGrey;
    }
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String date = localizations.formatShortDate(value);
    final String time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
      alwaysUse24HourFormat: true,
    );
    return '$date $time';
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
