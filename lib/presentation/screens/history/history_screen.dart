import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/history/history_bloc.dart';
import '../../bloc/history/history_event.dart';
import '../../bloc/history/history_state.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../widgets/transfer_list_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? userId = context.read<ProfileBloc>().state.user?.id;
      if (userId != null) {
        context.read<HistoryBloc>().add(LoadHistory(userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = context.select<ProfileBloc, String?>(
      (ProfileBloc bloc) => bloc.state.user?.id,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                return SegmentedButton<HistoryFilterType>(
                  segments: const <ButtonSegment<HistoryFilterType>>[
                    ButtonSegment<HistoryFilterType>(
                      value: HistoryFilterType.all,
                      label: Text('All'),
                    ),
                    ButtonSegment<HistoryFilterType>(
                      value: HistoryFilterType.sent,
                      label: Text('Sent'),
                    ),
                    ButtonSegment<HistoryFilterType>(
                      value: HistoryFilterType.received,
                      label: Text('Received'),
                    ),
                  ],
                  selected: <HistoryFilterType>{state.filterType},
                  onSelectionChanged: (Set<HistoryFilterType> selection) {
                    final HistoryFilterType selected = selection.first;
                    context.read<HistoryBloc>().add(FilterChanged(selected));
                  },
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                if (currentUserId == null) {
                  return const _MessageState(
                    icon: Icons.person_off_outlined,
                    message: 'User profile not loaded.',
                  );
                }

                switch (state.status) {
                  case HistoryStatus.initial:
                  case HistoryStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case HistoryStatus.error:
                    return _MessageState(
                      icon: Icons.error_outline,
                      message: state.errorMessage ?? 'Could not load history.',
                    );
                  case HistoryStatus.empty:
                    return const _MessageState(
                      icon: Icons.inbox_outlined,
                      message: 'No transfers found for this filter.',
                    );
                  case HistoryStatus.loaded:
                    return ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final transfer = state.items[index];
                        return TransferListItem(
                          transfer: transfer,
                          currentUserId: currentUserId,
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
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
