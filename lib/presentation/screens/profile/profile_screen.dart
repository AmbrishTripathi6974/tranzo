import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/storage_service.dart';
import '../../../di/injection_container.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../../widgets/tranzo_skeleton.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _didAutoRetryFromError = false;
  late final Future<LocalStorageSnapshot?> _storageSnapshotFuture;

  @override
  void initState() {
    super.initState();
    _storageSnapshotFuture = _loadStorageSnapshot();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRequestProfile());
  }

  Future<LocalStorageSnapshot?> _loadStorageSnapshot() {
    return sl<StorageService>().getLocalStorageSnapshot();
  }

  void _maybeRequestProfile() {
    if (!mounted) {
      return;
    }
    final ProfileBloc profile = context.read<ProfileBloc>();
    final ProfileState state = profile.state;
    if (state.status == ProfileStatus.loading) {
      return;
    }
    final bool needsRefresh =
        state.status == ProfileStatus.initial ||
        state.status == ProfileStatus.error ||
        (state.status == ProfileStatus.success &&
            (state.user == null || state.user!.shortCode.isEmpty));
    if (needsRefresh) {
      _didAutoRetryFromError = false;
      profile.add(const ProfileRequested());
    }
  }

  void _scheduleAutoRetryFromErrorIfNeeded() {
    if (_didAutoRetryFromError || !mounted) {
      return;
    }
    final AuthState auth = context.read<AuthBloc>().state;
    if (auth.status != AuthStatus.success || auth.user == null) {
      return;
    }
    _didAutoRetryFromError = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) {
        return;
      }
      final ProfileBloc profile = context.read<ProfileBloc>();
      if (profile.state.status == ProfileStatus.error) {
        profile.add(const ProfileRequested());
      }
    });
  }

  Future<void> _confirmSignOut() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) {
      return;
    }
    context.read<AuthBloc>().add(const AuthSignedOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (AuthState previous, AuthState current) {
              return current.status == AuthStatus.success &&
                  current.user != null &&
                  (previous.status != AuthStatus.success ||
                      previous.user?.id != current.user?.id);
            },
            listener: (BuildContext context, AuthState _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _maybeRequestProfile();
                }
              });
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (ProfileState previous, ProfileState current) {
              return previous.errorMessage != current.errorMessage &&
                  current.status == ProfileStatus.error &&
                  current.errorMessage != null;
            },
            listener: (BuildContext context, ProfileState state) {
              final String? message = state.errorMessage;
              if (message == null) {
                return;
              }
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (BuildContext context, ProfileState state) {
            if (state.status == ProfileStatus.loading ||
                state.status == ProfileStatus.success) {
              _didAutoRetryFromError = false;
            }
            switch (state.status) {
              case ProfileStatus.initial:
              case ProfileStatus.loading:
                return TranzoSkeleton.wrap(
                  context,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final double maxWidth = constraints.maxWidth >= 900
                          ? 760
                          : 680;
                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: <Widget>[
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          const Icon(Icons.person_outline),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Alex Morgan',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Recipient code',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'TRZ 8K2M',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontFamily: 'monospace',
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Local Storage',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 10),
                                      _StorageInfoLine(
                                        label: 'Used',
                                        value: '128 GB',
                                      ),
                                      const SizedBox(height: 6),
                                      _StorageInfoLine(
                                        label: 'Free',
                                        value: '64 GB',
                                      ),
                                      const SizedBox(height: 6),
                                      _StorageInfoLine(
                                        label: 'Total',
                                        value: '256 GB',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Recent Interactions',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.swap_horiz),
                                  title: const Text('Jordan Lee'),
                                  subtitle: Text(
                                    'Last interaction: '
                                    '${_formatDate(DateTime.now())}',
                                  ),
                                ),
                              ),
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.swap_horiz),
                                  title: const Text('Sam Rivera'),
                                  subtitle: Text(
                                    'Last interaction: '
                                    '${_formatDate(DateTime.now())}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              case ProfileStatus.error:
                _scheduleAutoRetryFromErrorIfNeeded();
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.person_off_outlined, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Profile is temporarily unavailable.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            context.read<ProfileBloc>().add(
                              const ProfileRequested(),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              case ProfileStatus.success:
                final user = state.user;
                if (user == null) {
                  return const _MessageState(
                    icon: Icons.person_off_outlined,
                    message: 'Profile not available.',
                  );
                }
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double maxWidth = constraints.maxWidth >= 900
                        ? 760
                        : 680;
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: <Widget>[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        const Icon(Icons.person_outline),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            user.username,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Recipient code',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    SelectableText(
                                      user.shortCode.isEmpty
                                          ? '—'
                                          : user.shortCode,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontFamily: 'monospace',
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FutureBuilder<LocalStorageSnapshot?>(
                              future: _storageSnapshotFuture,
                              builder:
                                  (
                                    BuildContext context,
                                    AsyncSnapshot<LocalStorageSnapshot?>
                                    snapshot,
                                  ) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return TranzoSkeleton.wrap(
                                        context,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Local Storage',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const SizedBox(height: 10),
                                                const _StorageInfoLine(
                                                  label: 'Used',
                                                  value: '—',
                                                ),
                                                const SizedBox(height: 6),
                                                const _StorageInfoLine(
                                                  label: 'Free',
                                                  value: '—',
                                                ),
                                                const SizedBox(height: 6),
                                                const _StorageInfoLine(
                                                  label: 'Total',
                                                  value: '—',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError ||
                                        snapshot.data == null) {
                                      return const Card(
                                        child: ListTile(
                                          leading: Icon(Icons.storage_outlined),
                                          title: Text('Local Storage'),
                                          subtitle: Text(
                                            'Could not load storage information.',
                                          ),
                                        ),
                                      );
                                    }
                                    final LocalStorageSnapshot storage =
                                        snapshot.data!;
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Local Storage',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                            const SizedBox(height: 10),
                                            _StorageInfoLine(
                                              label: 'Used',
                                              value: _formatBytes(
                                                storage.usedBytes,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            _StorageInfoLine(
                                              label: 'Free',
                                              value: _formatBytes(
                                                storage.freeBytes,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            _StorageInfoLine(
                                              label: 'Total',
                                              value: _formatBytes(
                                                storage.totalBytes,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Recent Interactions',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            if (state.interactions.isEmpty)
                              const _MessageState(
                                icon: Icons.history_toggle_off,
                                message: 'No recent interactions yet.',
                              )
                            else
                              ...state.interactions.map(
                                (interaction) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.swap_horiz),
                                    title: Text(interaction.displayLabel),
                                    subtitle: Text(
                                      'Last interaction: '
                                      '${_formatDate(interaction.lastInteractionDate)}',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

String _formatDate(DateTime dateTime) {
  final DateTime local = dateTime.toLocal();
  final String mm = local.month.toString().padLeft(2, '0');
  final String dd = local.day.toString().padLeft(2, '0');
  return '${local.year}-$mm-$dd';
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StorageInfoLine extends StatelessWidget {
  const _StorageInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) {
    return '0 B';
  }
  const List<String> units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
  double value = bytes.toDouble();
  int unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  final String display = value >= 10 || unitIndex == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '$display ${units[unitIndex]}';
}
