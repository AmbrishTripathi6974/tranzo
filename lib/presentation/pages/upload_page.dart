import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/selected_transfer_file.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';
import '../bloc/transfer/transfer_bloc.dart';
import '../bloc/transfer/transfer_event.dart';
import '../bloc/transfer/transfer_state.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController recipientController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _UploadForm(recipientController: recipientController),
      ),
    );
  }
}

class _UploadForm extends StatefulWidget {
  const _UploadForm({required this.recipientController});

  final TextEditingController recipientController;

  @override
  State<_UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<_UploadForm> {
  List<SelectedTransferFile> _selectedFiles = const <SelectedTransferFile>[];

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransferBloc, TransferState>(
      listenWhen: (previous, current) =>
          previous.pendingUploadConfirmation !=
              current.pendingUploadConfirmation ||
          previous.uiWarningMessage != current.uiWarningMessage,
      listener: (BuildContext context, TransferState state) async {
        if (state.uiWarningMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.uiWarningMessage!)));
          context.read<TransferBloc>().add(const TransferUiEffectConsumed());
          return;
        }

        final PendingUploadConfirmation? pending =
            state.pendingUploadConfirmation;
        if (pending == null) {
          return;
        }
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Mobile Data Warning'),
              content: const Text('This file may use mobile data. Continue?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('No'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
        if (!context.mounted) {
          return;
        }
        context.read<TransferBloc>().add(
          confirmed == true
              ? const TransferBatchUploadConfirmed()
              : const TransferBatchUploadCancelled(),
        );
      },
      child: BlocBuilder<TransferBloc, TransferState>(
        builder: (context, transferState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: widget.recipientController,
                decoration: const InputDecoration(
                  labelText: 'Recipient code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  FilledButton.tonal(
                    onPressed: _pickFiles,
                    child: const Text('Select files'),
                  ),
                  FilledButton(
                    onPressed: _selectedFiles.isEmpty
                        ? null
                        : () => _startUpload(context),
                    child: const Text('Start upload'),
                  ),
                ],
              ),
              if (transferState.errorMessage != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  transferState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (transferState.showInAppProgress) ...<Widget>[
                const SizedBox(height: 8),
                LinearProgressIndicator(value: transferState.progress),
              ],
              const SizedBox(height: 12),
              Text('Selected files (${_selectedFiles.length})'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    final SelectedTransferFile file = _selectedFiles[index];
                    final progress =
                        transferState.batchProgressByFileId[file.id];
                    return ListTile(
                      title: Text(file.fileName),
                      subtitle: Text('${file.sizeBytes} bytes'),
                      trailing: SizedBox(
                        width: 110,
                        child: Text(
                          progress == null
                              ? 'Pending'
                              : '${(progress.progress * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.end,
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

  Future<void> _pickFiles() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result == null) {
      return;
    }
    final List<SelectedTransferFile> files =
        result.files
            .where((PlatformFile file) => file.path != null)
            .map(
              (PlatformFile file) => SelectedTransferFile(
                id: file.identifier ?? '${file.name}_${file.size}',
                fileName: file.name,
                localPath: file.path!,
                sizeBytes: file.size,
              ),
            )
            .toList(growable: false)
          ..sort(
            (SelectedTransferFile a, SelectedTransferFile b) =>
                a.sizeBytes.compareTo(b.sizeBytes),
          );
    setState(() {
      _selectedFiles = files;
    });
  }

  void _startUpload(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState.status != ProfileStatus.success ||
        profileState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile is not ready yet.')),
      );
      return;
    }
    context.read<TransferBloc>().add(
      TransferBatchUploadRequested(
        senderId: profileState.user!.id,
        recipientCode: widget.recipientController.text,
        files: _selectedFiles,
      ),
    );
  }
}
