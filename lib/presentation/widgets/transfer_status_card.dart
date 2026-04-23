import 'package:flutter/material.dart';

import '../bloc/transfer/transfer_state.dart';

class TransferStatusCard extends StatelessWidget {
  const TransferStatusCard({
    super.key,
    required this.status,
    this.detailMessage,
  });

  final TransferStatus status;
  final String? detailMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _StatusPresentation presentation = _presentationFor(
      status,
      theme.colorScheme,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: presentation.iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                presentation.icon,
                color: presentation.iconForeground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    presentation.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (detailMessage != null &&
                      detailMessage!.trim().isNotEmpty &&
                      (status == TransferStatus.error ||
                          status == TransferStatus.receiverDeclined)) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      detailMessage!.trim(),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status == TransferStatus.error
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPresentation {
  _StatusPresentation({
    required this.title,
    required this.icon,
    required this.iconBackground,
    required this.iconForeground,
  });

  final String title;
  final IconData icon;
  final Color iconBackground;
  final Color iconForeground;
}

_StatusPresentation _presentationFor(
  TransferStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case TransferStatus.initial:
      return _StatusPresentation(
        title: 'Ready to send',
        icon: Icons.outgoing_mail,
        iconBackground: colorScheme.primaryContainer,
        iconForeground: colorScheme.onPrimaryContainer,
      );
    case TransferStatus.loading:
      return _StatusPresentation(
        title: 'Transfer in progress…',
        icon: Icons.sync,
        iconBackground: colorScheme.secondaryContainer,
        iconForeground: colorScheme.onSecondaryContainer,
      );
    case TransferStatus.success:
      return _StatusPresentation(
        title: 'Last transfer finished',
        icon: Icons.check_circle_outline,
        iconBackground: Colors.green.shade50,
        iconForeground: Colors.green.shade800,
      );
    case TransferStatus.error:
      return _StatusPresentation(
        title: 'Something went wrong',
        icon: Icons.error_outline,
        iconBackground: Colors.red.shade50,
        iconForeground: Colors.red.shade800,
      );
    case TransferStatus.receiverDeclined:
      return _StatusPresentation(
        title: 'Receiver did not download',
        icon: Icons.info_outline,
        iconBackground: Colors.amber.shade50,
        iconForeground: Colors.amber.shade900,
      );
  }
}
