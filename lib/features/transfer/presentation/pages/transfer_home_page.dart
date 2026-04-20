import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_state.dart';
import '../widgets/transfer_status_card.dart';

class TransferHomePage extends StatelessWidget {
  const TransferHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tranzo Transfer Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BlocBuilder<TransferBloc, TransferState>(
              builder: (context, state) {
                return TransferStatusCard(status: state.status);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push(RouteNames.upload),
              child: const Text('Go to Upload'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => context.push(RouteNames.download),
              child: const Text('Go to Download'),
            ),
          ],
        ),
      ),
    );
  }
}
