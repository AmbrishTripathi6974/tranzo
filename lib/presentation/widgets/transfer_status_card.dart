import 'package:flutter/material.dart';

import '../bloc/transfer/transfer_state.dart';

class TransferStatusCard extends StatelessWidget {
  const TransferStatusCard({super.key, required this.status});

  final TransferStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const Icon(Icons.sync),
            const SizedBox(width: 12),
            Text('Transfer status: $status'),
          ],
        ),
      ),
    );
  }
}
