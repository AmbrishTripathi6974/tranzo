import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRequestProfile());
  }

  void _maybeRequestProfile() {
    if (!mounted) {
      return;
    }
    final AuthState auth = context.read<AuthBloc>().state;
    if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
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
      profile.add(const ProfileRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocListener<AuthBloc, AuthState>(
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
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (BuildContext context, ProfileState state) {
          switch (state.status) {
            case ProfileStatus.initial:
            case ProfileStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProfileStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.error_outline, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ?? 'Could not load profile.',
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
              return ListView(
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
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Recipient code',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            user.shortCode.isEmpty ? '—' : user.shortCode,
                            style: Theme.of(context).textTheme.headlineSmall
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
                          title: Text(interaction.username),
                          subtitle: Text(
                            'Last interaction: '
                            '${_formatDate(interaction.lastInteractionDate)}',
                          ),
                        ),
                      ),
                    ),
                ],
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
