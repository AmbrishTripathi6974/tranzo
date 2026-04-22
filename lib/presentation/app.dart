import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/injection_container.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/history/history_bloc.dart';
import 'bloc/profile/profile_bloc.dart';
import 'bloc/profile/profile_event.dart';
import 'bloc/profile/profile_state.dart';
import 'bloc/transfer/transfer_bloc.dart';
import 'navigation/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthStarted()),
        ),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<HistoryBloc>(create: (_) => sl<HistoryBloc>()),
        BlocProvider<TransferBloc>(create: (_) => sl<TransferBloc>()),
      ],
      child: _ProfileBootstrap(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (AuthState previous, AuthState current) {
            // Profile identity is local-first; request profile once auth is no
            // longer loading, even if auth ended in error.
            if (current.status == AuthStatus.loading) {
              return false;
            }
            return previous.status != current.status ||
                previous.user?.id != current.user?.id;
          },
          listener: (BuildContext context, AuthState state) {
            context.read<ProfileBloc>().add(const ProfileRequested());
          },
          child: MaterialApp.router(
          title: 'Tranzo',
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F8FC),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE9EAF2)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD8DBEA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD8DBEA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF4F46E5),
                  width: 1.4,
                ),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: Color(0xFFE7E8FF),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
        ),
        ),
      ),
    );
  }
}

/// Ensures [ProfileRequested] runs when auth is already [AuthStatus.success]
/// before [BlocListener] subscribes — [Bloc] streams do not replay past states.
class _ProfileBootstrap extends StatefulWidget {
  const _ProfileBootstrap({required this.child});

  final Widget child;

  @override
  State<_ProfileBootstrap> createState() => _ProfileBootstrapState();
}

class _ProfileBootstrapState extends State<_ProfileBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final AuthState auth = context.read<AuthBloc>().state;
      final ProfileBloc profile = context.read<ProfileBloc>();
      if (auth.status != AuthStatus.loading &&
          profile.state.status == ProfileStatus.initial) {
        profile.add(const ProfileRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
