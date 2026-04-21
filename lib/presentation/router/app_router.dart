import 'package:go_router/go_router.dart';

import '../pages/download_page.dart';
import '../pages/transfer_home_page.dart';
import '../pages/upload_page.dart';
import '../screens/history/history_screen.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const TransferHomePage(),
      ),
      GoRoute(
        path: RouteNames.transfer,
        builder: (context, state) => const UploadPage(),
      ),
      GoRoute(
        path: RouteNames.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const DownloadPage(),
      ),
    ],
  );
}
