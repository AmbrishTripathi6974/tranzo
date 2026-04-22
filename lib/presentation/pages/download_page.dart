import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          return Column(
            children: <Widget>[
              if (state.showInAppProgress)
                LinearProgressIndicator(value: state.progress),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.incomingTransfers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
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
                                  onPressed: () async {
                                    final TransferBloc transferBloc = context
                                        .read<TransferBloc>();
                                    if (transfer.requiresApproval) {
                                      bool trustSender = false;
                                      final bool?
                                      allow = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return StatefulBuilder(
                                            builder: (BuildContext context, setState) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Allow transfer?',
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      'Allow file from ${transfer.senderId}?',
                                                    ),
                                                    CheckboxListTile(
                                                      value: trustSender,
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          trustSender =
                                                              value ?? false;
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
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dialogContext,
                                                        ).pop(false),
                                                    child: const Text('Deny'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dialogContext,
                                                        ).pop(true),
                                                    child: const Text('Allow'),
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
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonal(
                                  onPressed: () {
                                    context.read<TransferBloc>().add(
                                      IncomingTransferRejected(
                                        transfer.transferId,
                                      ),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
