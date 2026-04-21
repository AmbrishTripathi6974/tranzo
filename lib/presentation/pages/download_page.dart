import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ProfileState profileState = context.read<ProfileBloc>().state;
      if (profileState.status == ProfileStatus.success &&
          profileState.user != null) {
        context.read<TransferBloc>().add(
          IncomingTransferListeningRequested(profileState.user!.id),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download')),
      body: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.user?.id != current.user?.id,
        listener: (BuildContext context, ProfileState profileState) {
          if (profileState.status == ProfileStatus.success &&
              profileState.user != null) {
            context.read<TransferBloc>().add(
              IncomingTransferListeningRequested(profileState.user!.id),
            );
          }
        },
        child: BlocBuilder<TransferBloc, TransferState>(
          builder: (BuildContext context, TransferState state) {
            if (state.incomingTransfers.isEmpty) {
              return const Center(child: Text('No incoming transfers.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.incomingTransfers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final transfer = state.incomingTransfers[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          transfer.fileName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text('From: ${transfer.senderId}'),
                        Text('${transfer.fileSize} bytes'),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            FilledButton(
                              onPressed: () {
                                context.read<TransferBloc>().add(
                                  IncomingTransferAccepted(transfer),
                                );
                              },
                              child: const Text('Accept'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: () {
                                context.read<TransferBloc>().add(
                                  IncomingTransferRejected(transfer.transferId),
                                );
                              },
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
