import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/selected_transfer_file.dart';
import '../../domain/entities/transfer_batch_progress.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../bloc/transfer/transfer_bloc.dart';
import '../bloc/transfer/transfer_event.dart';
import '../bloc/transfer/transfer_state.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send'), centerTitle: false),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double maxWidth = constraints.maxWidth >= 1000 ? 860 : 760;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _UploadForm(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UploadForm extends StatefulWidget {
  const _UploadForm();

  @override
  State<_UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<_UploadForm> {
  late final TextEditingController _recipientController;

  @override
  void initState() {
    super.initState();
    _recipientController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final String draft = context
          .read<TransferBloc>()
          .state
          .uploadRecipientCodeDraft;
      if (_recipientController.text != draft) {
        _recipientController.value = TextEditingValue(
          text: draft,
          selection: TextSelection.collapsed(offset: draft.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocListener<TransferBloc, TransferState>(
      listenWhen: (TransferState previous, TransferState current) =>
          previous.pendingUploadConfirmation !=
              current.pendingUploadConfirmation ||
          previous.uiWarningMessage != current.uiWarningMessage ||
          previous.uploadDraftSelectionNotice !=
              current.uploadDraftSelectionNotice,
      listener: (BuildContext context, TransferState state) async {
        if (state.uploadDraftSelectionNotice != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.uploadDraftSelectionNotice!)),
          );
          context.read<TransferBloc>().add(
            const TransferUploadDraftSelectionNoticeConsumed(),
          );
          return;
        }
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
            final ThemeData dialogTheme = Theme.of(dialogContext);
            final String approxSize = _formatApproxTransferSizeForDialog(
              pending.totalBytes,
            );
            return AlertDialog(
              icon: Icon(
                Icons.signal_cellular_alt,
                size: 36,
                color: dialogTheme.colorScheme.primary,
              ),
              title: const Text('Use mobile data for this upload?'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'You are not on Wi‑Fi. This upload is about $approxSize '
                      'and may count toward your mobile data plan.',
                      style: dialogTheme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    const _MobileDataConsentBullet(
                      icon: Icons.cloud_upload_outlined,
                      title: 'Send over current network',
                      subtitle:
                          'The transfer uses your active connection, which may '
                          'be metered or slower than Wi‑Fi.',
                    ),
                    const SizedBox(height: 14),
                    const _MobileDataConsentBullet(
                      icon: Icons.lock_outline,
                      title: 'Ask once on mobile data',
                      subtitle:
                          'If you allow, we remember your choice and will not '
                          'show this prompt again for uploads on cellular.',
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text("Don't allow"),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Allow'),
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
      child: BlocListener<TransferBloc, TransferState>(
        listenWhen: (TransferState previous, TransferState current) =>
            previous.uploadRecipientCodeDraft !=
            current.uploadRecipientCodeDraft,
        listener: (BuildContext context, TransferState state) {
          if (_recipientController.text != state.uploadRecipientCodeDraft) {
            final String text = state.uploadRecipientCodeDraft;
            _recipientController.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
          }
        },
        child: BlocBuilder<TransferBloc, TransferState>(
          builder: (BuildContext context, TransferState transferState) {
            final ProfileState profileState = context
                .watch<ProfileBloc>()
                .state;
            final bool localOnlyMode =
                profileState.status == ProfileStatus.success &&
                (profileState.user?.id.startsWith('local_') ?? false);
            final List<SelectedTransferFile> selected =
                transferState.selectedUploadFiles;
            final bool draftLocked =
                transferState.pendingUploadConfirmation != null;
            final bool pickerBusy = transferState.uploadDraftPickerBusy;
            final bool canEditSelection =
                transferState.status != TransferStatus.loading && !draftLocked;
            final bool canPick = canEditSelection && !pickerBusy;
            final bool canSend =
                canEditSelection &&
                !localOnlyMode &&
                selected.isNotEmpty &&
                transferState.uploadRecipientCodeDraft.trim().isNotEmpty;

            final Widget content = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (localOnlyMode) ...<Widget>[
                  Material(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.cloud_off_rounded,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Offline mode is active on this device. Cloud send '
                              'is unavailable until authentication reconnects. '
                              'Reopen the app when network/auth is available.',
                              style: TextStyle(
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.55,
                              ),
                              theme.colorScheme.surfaceContainerLow,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: theme.colorScheme.primary,
                                child: Icon(
                                  Icons.outbound_rounded,
                                  size: 28,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Send a transfer',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add files, confirm the recipient, then '
                                      'start the upload.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: TextField(
                          controller: _recipientController,
                          onChanged: (String value) {
                            context.read<TransferBloc>().add(
                              TransferUploadRecipientDraftChanged(value),
                            );
                          },
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Recipient code',
                            hintText: 'e.g. ABC123',
                            filled: true,
                            prefixIcon: const Icon(Icons.tag_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed: canPick
                                  ? () => _pickFiles(context)
                                  : null,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add files'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FilledButton.icon(
                              onPressed: canSend
                                  ? () => _startUpload(context, transferState)
                                  : null,
                              icon: const Icon(Icons.cloud_upload_rounded),
                              label: const Text('Start transfer'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            if (localOnlyMode) ...<Widget>[
                              const SizedBox(height: 8),
                              Text(
                                'Cloud pairing is disabled in offline/local mode.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (transferState.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Material(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline_rounded,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              transferState.errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (transferState.showInAppProgress) ...<Widget>[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: transferState.progress >= 1
                          ? null
                          : transferState.progress,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Text(
                      'Files',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (selected.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${selected.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: selected.isEmpty
                      ? _UploadEmptyState(theme: theme)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: selected.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (BuildContext context, int index) {
                            final SelectedTransferFile file = selected[index];
                            final TransferFileProgress? progress =
                                transferState.batchProgressByFileId[file.id];
                            return _TransferFileRow(
                              file: file,
                              progress: progress,
                              canRemove: canEditSelection,
                              onRemove: () {
                                context.read<TransferBloc>().add(
                                  TransferUploadDraftFileRemoved(file.localPath),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
            return content;
          },
        ),
      ),
    );
  }

  Future<void> _pickFiles(BuildContext context) async {
    final TransferBloc bloc = context.read<TransferBloc>();
    bloc.add(const TransferUploadDraftPickerBusy(true));
    try {
      final bool hasPermission = await _ensureMediaPermission(context);
      if (!hasPermission || !context.mounted) {
        return;
      }
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(allowMultiple: true);
      } on PlatformException catch (e) {
        if (e.code == 'already_active' && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait for the file picker to finish.'),
            ),
          );
        }
        return;
      }
      if (result == null || !context.mounted) {
        return;
      }
      final List<SelectedTransferFile> picked = result.files
          .where((PlatformFile file) => file.path != null)
          .map(
            (PlatformFile file) => SelectedTransferFile(
              id: file.identifier ?? '${file.name}_${file.size}',
              fileName: file.name,
              localPath: file.path!,
              sizeBytes: file.size,
            ),
          )
          .toList(growable: false);
      if (picked.isEmpty) {
        return;
      }
      bloc.add(TransferUploadDraftFilesAppended(picked));
    } finally {
      if (context.mounted) {
        bloc.add(const TransferUploadDraftPickerBusy(false));
      }
    }
  }

  Future<bool> _ensureMediaPermission(BuildContext context) async {
    final Map<Permission, PermissionStatus> mediaStatuses = await <Permission>[
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();
    final bool mediaGranted = mediaStatuses.values.any(
      (PermissionStatus status) => status.isGranted,
    );
    if (mediaGranted) {
      return true;
    }

    PermissionStatus storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
    }
    if (storageStatus.isGranted) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }
    final bool permanentlyDenied =
        storageStatus.isPermanentlyDenied ||
        mediaStatuses.values.any(
          (PermissionStatus status) => status.isPermanentlyDenied,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          permanentlyDenied
              ? 'Media access is disabled. Enable it in app settings to add files.'
              : 'Media access is required to add files.',
        ),
        action: permanentlyDenied
            ? SnackBarAction(label: 'Settings', onPressed: openAppSettings)
            : null,
      ),
    );
    return false;
  }

  void _startUpload(BuildContext context, TransferState transferState) {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState.status != ProfileStatus.success ||
        profileState.user == null) {
      context.read<ProfileBloc>().add(const ProfileRequested());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing profile... Please try again.')),
      );
      return;
    }
    context.read<TransferBloc>().add(
      TransferBatchUploadRequested(
        senderId: profileState.user!.id,
        recipientCode: transferState.uploadRecipientCodeDraft.trim(),
        files: transferState.selectedUploadFiles,
      ),
    );
  }
}

class _TransferFileRow extends StatelessWidget {
  const _TransferFileRow({
    required this.file,
    required this.progress,
    required this.canRemove,
    required this.onRemove,
  });

  final SelectedTransferFile file;
  final TransferFileProgress? progress;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double? progressValue = progress?.progress;
    final String statusLabel = progress == null
        ? 'Queued'
        : '${(progressValue! * 100).clamp(0, 100).toStringAsFixed(0)}%';

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  _fileIconForName(file.fileName),
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        file.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(file.sizeBytes),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 58),
                  child: Text(
                    statusLabel,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (canRemove)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Remove from transfer',
                    onPressed: onRemove,
                  ),
              ],
            ),
            if (progressValue != null && progressValue < 1) ...<Widget>[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: progressValue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UploadEmptyState extends StatelessWidget {
  const _UploadEmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_open_rounded,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No files yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap Add files to choose one or more items. You can add more in '
              'several steps before sending.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _fileIconForName(String fileName) {
  final String lower = fileName.toLowerCase();
  if (lower.endsWith('.pdf')) {
    return Icons.picture_as_pdf_outlined;
  }
  if (lower.endsWith('.zip') ||
      lower.endsWith('.rar') ||
      lower.endsWith('.7z')) {
    return Icons.folder_zip_outlined;
  }
  if (lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif')) {
    return Icons.image_outlined;
  }
  if (lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.mkv')) {
    return Icons.movie_outlined;
  }
  if (lower.endsWith('.mp3') ||
      lower.endsWith('.wav') ||
      lower.endsWith('.m4a')) {
    return Icons.audio_file_outlined;
  }
  return Icons.insert_drive_file_outlined;
}

String _formatFileSize(int bytes) {
  if (bytes <= 0) {
    return '—';
  }
  const int kb = 1024;
  const int mb = kb * 1024;
  const int gb = mb * 1024;
  if (bytes >= gb) {
    return '${(bytes / gb).toStringAsFixed(1)} GB';
  }
  if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  }
  if (bytes >= kb) {
    return '${(bytes / kb).round()} KB';
  }
  return '$bytes B';
}

String _formatApproxTransferSizeForDialog(int bytes) {
  if (bytes <= 0) {
    return 'an unknown amount of data';
  }
  const int kb = 1024;
  const int mb = kb * 1024;
  if (bytes >= mb) {
    final double mbValue = bytes / mb;
    return mbValue >= 10
        ? '${mbValue.round()} MB'
        : '${mbValue.toStringAsFixed(1)} MB';
  }
  if (bytes >= kb) {
    return '${(bytes / kb).round()} KB';
  }
  return '$bytes B';
}

class _MobileDataConsentBullet extends StatelessWidget {
  const _MobileDataConsentBullet({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
