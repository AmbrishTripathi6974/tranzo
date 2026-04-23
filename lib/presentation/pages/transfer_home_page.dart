import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/transfer/transfer_bloc.dart';
import '../bloc/transfer/transfer_state.dart';
import '../router/route_names.dart';
import '../widgets/transfer_status_card.dart';

class TransferHomePage extends StatelessWidget {
  const TransferHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tranzo')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxWidth = constraints.maxWidth >= 900 ? 760 : 680;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text(
                    'Fast and reliable file transfer',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Send files, track upload progress, and review history seamlessly.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<TransferBloc, TransferState>(
                    builder: (context, state) {
                      return TransferStatusCard(
                        status: state.status,
                        detailMessage: switch (state.status) {
                          TransferStatus.error =>
                            (state.errorMessage ?? state.uiWarningMessage),
                          TransferStatus.receiverDeclined =>
                            'They may have decided they did not need the file on '
                                'their device. This is not a send failure.',
                          _ => null,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.go(RouteNames.transfer),
                    icon: const Icon(Icons.upload_outlined),
                    label: const Text('Start New Transfer'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
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
    );
  }
}
