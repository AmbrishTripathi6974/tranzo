import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';
import '../pages/transfer_home_page.dart';
import '../pages/upload_page.dart';
import '../screens/history/history_screen.dart';
import 'bottom_nav.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return BottomNav(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _buildTransitionPage(
              state: state,
              child: const TransferHomePage(),
            ),
          ),
          GoRoute(
            path: '/transfer',
            pageBuilder: (context, state) => _buildTransitionPage(
              state: state,
              child: const UploadPage(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => _buildTransitionPage(
              state: state,
              child: const HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _buildTransitionPage(
              state: state,
              child: const _ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  static CustomTransitionPage<void> _buildTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 300),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Tween<Offset> slideTween = Tween<Offset>(
          begin: const Offset(0.16, 0),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final String username = state.user?.username ?? 'Unknown';
            return Text('Username: $username');
          },
        ),
      ),
    );
  }
}
