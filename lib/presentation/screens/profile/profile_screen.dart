import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
          switch (state.status) {
            case ProfileStatus.initial:
            case ProfileStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProfileStatus.error:
              return _MessageState(
                icon: Icons.error_outline,
                message: state.errorMessage ?? 'Could not load profile.',
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
                    child: ListTile(
                      title: Text(user.username),
                      subtitle: Text('Short code: ${user.shortCode}'),
                      leading: const Icon(Icons.person_outline),
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
    );
  }

  String _formatDate(DateTime dateTime) {
    final DateTime local = dateTime.toLocal();
    final String mm = local.month.toString().padLeft(2, '0');
    final String dd = local.day.toString().padLeft(2, '0');
    return '${local.year}-$mm-$dd';
  }
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
