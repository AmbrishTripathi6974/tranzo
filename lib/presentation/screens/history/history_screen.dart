import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../domain/entities/transfer_entity.dart';
import '../../../domain/entities/transfer_lifecycle_signal.dart';
import '../../bloc/history/history_bloc.dart';
import '../../bloc/history/history_event.dart';
import '../../bloc/history/history_state.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_state.dart';
import '../../bloc/transfer/transfer_bloc.dart';
import '../../bloc/transfer/transfer_state.dart';
import '../../widgets/history_transfer_card.dart';
import '../../widgets/tranzo_skeleton.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _lastLoadMoreRequestAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _loadMoreThrottle = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfReady());
  }

  void _loadIfReady() {
    if (!mounted) {
      return;
    }
    final String? userId = context.read<ProfileBloc>().state.user?.id;
    if (userId != null) {
      context.read<HistoryBloc>().add(LoadHistory(userId));
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    final HistoryBloc bloc = context.read<HistoryBloc>();
    final String? userId =
        bloc.state.userId ?? context.read<ProfileBloc>().state.user?.id;
    if (userId == null) {
      return;
    }
    bloc.add(LoadHistory(userId));
    await bloc.stream.firstWhere(
      (HistoryState s) =>
          s.status == HistoryStatus.loaded ||
          s.status == HistoryStatus.empty ||
          s.status == HistoryStatus.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? currentUserId = context.select<ProfileBloc, String?>(
      (ProfileBloc bloc) => bloc.state.user?.id,
    );
    final double width = MediaQuery.sizeOf(context).width;
    final double horizontalPadding = width >= 1100
        ? (width - 860) / 2
        : width >= 900
        ? 28
        : 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FA),
      body: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (ProfileState previous, ProfileState current) {
              return previous.user?.id != current.user?.id &&
                  current.user?.id != null;
            },
            listener: (BuildContext context, ProfileState _) {
              _loadIfReady();
            },
          ),
          BlocListener<TransferBloc, TransferState>(
            listenWhen: (TransferState previous, TransferState current) {
              for (final MapEntry<String, TransferLifecycleSignalEntity> entry
                  in current.lifecycleSignalsByTransferId.entries) {
                final TransferLifecycleSignalEntity? prior =
                    previous.lifecycleSignalsByTransferId[entry.key];
                if (prior?.event == entry.value.event) {
                  continue;
                }
                switch (entry.value.event) {
                  case TransferLifecycleEventType.transferCompleted:
                  case TransferLifecycleEventType.transferFailed:
                  case TransferLifecycleEventType.transferRejected:
                    return true;
                  case TransferLifecycleEventType.transferStarted:
                  case TransferLifecycleEventType.transferAccepted:
                    break;
                }
              }
              return false;
            },
            listener: (BuildContext context, TransferState _) {
              final String? userId = context.read<ProfileBloc>().state.user?.id;
              if (userId != null) {
                context.read<HistoryBloc>().add(LoadHistory(userId));
              }
            },
          ),
          BlocListener<HistoryBloc, HistoryState>(
            listenWhen: (HistoryState previous, HistoryState current) {
              return previous.errorMessage != current.errorMessage &&
                  current.status == HistoryStatus.error &&
                  current.errorMessage != null;
            },
            listener: (BuildContext context, HistoryState state) {
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
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (BuildContext context, HistoryState state) {
              final bool showInitialSkeleton =
                  state.status == HistoryStatus.initial ||
                  (state.status == HistoryStatus.loading &&
                      state.allItems.isEmpty &&
                      state.items.isEmpty);
              return RefreshIndicator(
                color: theme.colorScheme.primary,
                onRefresh: () => _onRefresh(context),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollUpdateNotification &&
                        notification.metrics.extentAfter <= 360) {
                      final DateTime now = DateTime.now();
                      if (now.difference(_lastLoadMoreRequestAt) >=
                          _loadMoreThrottle) {
                        _lastLoadMoreRequestAt = now;
                        context.read<HistoryBloc>().add(const LoadMoreHistory());
                      }
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: _HistoryHeroHeader(
                          theme: theme,
                          historyState: state,
                          currentUserId: currentUserId,
                          statsLoading:
                              currentUserId != null && showInitialSkeleton,
                          onRefreshTap: () => _onRefresh(context),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            12,
                          ),
                          child: _FilterStrip(
                            selected: state.filterType,
                            onChanged: (HistoryFilterType next) {
                              context.read<HistoryBloc>().add(
                                FilterChanged(next),
                              );
                            },
                          ),
                        ),
                      ),
                      if (currentUserId == null)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyIllustration(
                            icon: Icons.person_outline_rounded,
                            title: 'Almost there',
                            subtitle:
                                'Your profile is still loading. Pull to refresh '
                                'in a moment.',
                            colors: <Color>[
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                              theme.colorScheme.tertiary.withValues(alpha: 0.12),
                            ],
                          ),
                        )
                      else
                        ..._buildHistoryBodySlivers(
                          context: context,
                          theme: theme,
                          state: state,
                          currentUserId: currentUserId,
                          horizontalPadding: horizontalPadding,
                          showInitialSkeleton: showInitialSkeleton,
                        ),
                    ],
                  ),
                ),
              );
          },
        ),
      ),
    );
  }

  List<Widget> _buildHistoryBodySlivers({
    required BuildContext context,
    required ThemeData theme,
    required HistoryState state,
    required String currentUserId,
    required double horizontalPadding,
    required bool showInitialSkeleton,
  }) {
    switch (state.status) {
      case HistoryStatus.initial:
      case HistoryStatus.loading:
        if (!showInitialSkeleton && state.items.isNotEmpty) {
          return _buildLoadedSlivers(
            context: context,
            theme: theme,
            state: state,
            currentUserId: currentUserId,
            horizontalPadding: horizontalPadding,
          );
        }
        return _historyLoadingSlivers(
          context: context,
          theme: theme,
          horizontalPadding: horizontalPadding,
        );
      case HistoryStatus.error:
        if (state.allItems.isNotEmpty) {
          return _buildLoadedSlivers(
            context: context,
            theme: theme,
            state: state,
            currentUserId: currentUserId,
            horizontalPadding: horizontalPadding,
          );
        }
        return <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyIllustration(
              icon: Icons.inbox_rounded,
              title: 'No transfers to show',
              subtitle: 'Pull down or tap retry to refresh your history.',
              colors: const <Color>[Color(0xFFE8EAF6), Color(0xFFE0F2FE)],
              action: FilledButton.icon(
                onPressed: () {
                  context.read<HistoryBloc>().add(LoadHistory(currentUserId));
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ),
          ),
        ];
      case HistoryStatus.empty:
        final bool hasAnyTransfer = state.allItems.isNotEmpty;
        return <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyIllustration(
              icon: hasAnyTransfer
                  ? Icons.filter_alt_off_rounded
                  : Icons.layers_outlined,
              title: hasAnyTransfer
                  ? 'Nothing in this view'
                  : 'No transfers yet',
              subtitle: hasAnyTransfer
                  ? 'Try another tab — your other transfers are still saved.'
                  : 'Files you send or receive will appear here with live '
                        'status and size.',
              colors: const <Color>[Color(0xFFE8EAF6), Color(0xFFE0F2FE)],
            ),
          ),
        ];
      case HistoryStatus.loaded:
        return _buildLoadedSlivers(
          context: context,
          theme: theme,
          state: state,
          currentUserId: currentUserId,
          horizontalPadding: horizontalPadding,
        );
    }
  }

  List<Widget> _buildLoadedSlivers({
    required BuildContext context,
    required ThemeData theme,
    required HistoryState state,
    required String currentUserId,
    required double horizontalPadding,
  }) {
    final List<_DaySection> sections = _groupByCalendarDay(context, state.items);
    if (sections.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyIllustration(
            icon: Icons.inbox_rounded,
            title: 'Nothing to show',
            subtitle: 'No items match this filter.',
            colors: const <Color>[Color(0xFFEDE9FE), Color(0xFFE0E7FF)],
          ),
        ),
      ];
    }
    final List<Widget> out = <Widget>[];
    for (final _DaySection section in sections) {
      out.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: <Color>[
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  section.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      out.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              final TransferEntity t = section.items[index];
              return HistoryTransferCard(
                transfer: t,
                currentUserId: currentUserId,
              );
            }, childCount: section.items.length),
          ),
        ),
      );
    }
    if (state.hasMore || state.isLoadingMore) {
      out.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Center(
              child: state.isLoadingMore
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : Text(
                      'Scroll for more',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      );
    } else {
      out.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
    }
    return out;
  }
}

List<Widget> _historyLoadingSlivers({
  required BuildContext context,
  required ThemeData theme,
  required double horizontalPadding,
}) {
  final PaintingEffect effect = TranzoSkeleton.effectOf(context);
  return <Widget>[
    SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          8,
        ),
        child: Skeletonizer(
          enabled: true,
          effect: effect,
          child: Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Today',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Skeletonizer.sliver(
      enabled: true,
      effect: effect,
      child: SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) =>
                const _HistoryTransferSkeletonCard(),
            childCount: 7,
          ),
        ),
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 24)),
  ];
}

class _HistoryTransferSkeletonCard extends StatelessWidget {
  const _HistoryTransferSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE9EAF2)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: <Color>[
                      scheme.primary.withValues(alpha: 0.35),
                      scheme.tertiary.withValues(alpha: 0.35),
                    ],
                  ),
                ),
                child: const Icon(Icons.insert_drive_file_rounded, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Quarterly-report-final-v2.pdf',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: <Widget>[
                        Text(
                          '12.4 MB',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '2h ago',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Done',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySection {
  _DaySection({required this.title, required this.items});

  final String title;
  final List<TransferEntity> items;
}

List<_DaySection> _groupByCalendarDay(
  BuildContext context,
  List<TransferEntity> items,
) {
  if (items.isEmpty) {
    return <_DaySection>[];
  }
  final MaterialLocalizations loc = MaterialLocalizations.of(context);
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  String labelFor(DateTime utc) {
    final DateTime local = utc.toLocal();
    final DateTime day = DateTime(local.year, local.month, local.day);
    if (day == today) {
      return 'Today';
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return loc.formatShortDate(local);
  }

  final List<TransferEntity> sorted = List<TransferEntity>.from(items)
    ..sort(
      (TransferEntity a, TransferEntity b) =>
          b.createdAt.compareTo(a.createdAt),
    );

  final LinkedHashMap<String, List<TransferEntity>> buckets =
      LinkedHashMap<String, List<TransferEntity>>();

  for (final TransferEntity t in sorted) {
    final String key = _dayKey(t.createdAt.toLocal());
    buckets.putIfAbsent(key, () => <TransferEntity>[]).add(t);
  }

  return buckets.values
      .map(
        (List<TransferEntity> bucket) =>
            _DaySection(title: labelFor(bucket.first.createdAt), items: bucket),
      )
      .toList(growable: false);
}

String _dayKey(DateTime local) {
  return '${local.year}-${local.month}-${local.day}';
}

class _HistoryHeroHeader extends StatelessWidget {
  const _HistoryHeroHeader({
    required this.theme,
    required this.historyState,
    required this.currentUserId,
    required this.statsLoading,
    required this.onRefreshTap,
  });

  final ThemeData theme;
  final HistoryState historyState;
  final String? currentUserId;
  final bool statsLoading;
  final Future<void> Function() onRefreshTap;

  @override
  Widget build(BuildContext context) {
    final int total;
    final int sent;
    final int received;
    if (statsLoading) {
      total = 24;
      sent = 14;
      received = 10;
    } else {
      total = historyState.allItems.length;
      int s = 0;
      int r = 0;
      if (currentUserId != null) {
        for (final TransferEntity t in historyState.allItems) {
          if (t.senderId == currentUserId) {
            s++;
          }
          if (t.receiverId == currentUserId) {
            r++;
          }
        }
      }
      sent = s;
      received = r;
    }

    final Widget statsSection = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 360;
        if (compact) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              SizedBox(
                width: (constraints.maxWidth - 10) / 2,
                child: _StatTile(
                  icon: Icons.layers_rounded,
                  label: 'Total',
                  value: total.toString(),
                  surface: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - 10) / 2,
                child: _StatTile(
                  icon: Icons.upload_rounded,
                  label: 'Sent',
                  value: sent.toString(),
                  surface: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - 10) / 2,
                child: _StatTile(
                  icon: Icons.download_rounded,
                  label: 'Received',
                  value: received.toString(),
                  surface: Colors.white.withValues(alpha: 0.16),
                ),
              ),
            ],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(
                icon: Icons.layers_rounded,
                label: 'Total',
                value: total.toString(),
                surface: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.upload_rounded,
                label: 'Sent',
                value: sent.toString(),
                surface: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.download_rounded,
                label: 'Received',
                value: received.toString(),
                surface: Colors.white.withValues(alpha: 0.16),
              ),
            ),
          ],
        );
      },
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFF4F46E5),
            Color(0xFF6D28D9),
            Color(0xFF2563EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x334F46E5),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Activity',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Every send & receive, one glance away.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => onRefreshTap(),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Skeletonizer(
                enabled: statsLoading,
                effect: TranzoSkeleton.effectOf(context),
                containersColor: Colors.white.withValues(alpha: 0.12),
                child: statsSection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.surface,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({required this.selected, required this.onChanged});

  final HistoryFilterType selected;
  final ValueChanged<HistoryFilterType> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E6EF)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _FilterChoice(
                icon: Icons.all_inclusive_rounded,
                label: 'All',
                selected: selected == HistoryFilterType.all,
                onTap: () => onChanged(HistoryFilterType.all),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _FilterChoice(
                icon: Icons.upload_file_rounded,
                label: 'Sent',
                selected: selected == HistoryFilterType.sent,
                onTap: () => onChanged(HistoryFilterType.sent),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _FilterChoice(
                icon: Icons.download_for_offline_rounded,
                label: 'Received',
                selected: selected == HistoryFilterType.received,
                onTap: () => onChanged(HistoryFilterType.received),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                size: 22,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(icon, size: 44, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (action != null) ...<Widget>[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}
