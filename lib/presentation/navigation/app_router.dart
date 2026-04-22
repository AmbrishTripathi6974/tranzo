import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/transfer_home_page.dart';
import '../pages/upload_page.dart';
import '../pages/download_page.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
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
            pageBuilder: (context, state) =>
                _buildTabPage(state: state, child: const TransferHomePage()),
          ),
          GoRoute(
            path: '/transfer',
            pageBuilder: (context, state) =>
                _buildTabPage(state: state, child: const UploadPage()),
          ),
          GoRoute(
            path: '/inbox',
            pageBuilder: (context, state) =>
                _buildTabPage(state: state, child: const DownloadPage()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) =>
                _buildTabPage(state: state, child: const HistoryScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _buildTabPage(state: state, child: const ProfileScreen()),
          ),
        ],
      ),
    ],
  );

  static NoTransitionPage<void> _buildTabPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
}
