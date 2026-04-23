import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../core/network/network_info.dart';
import '../di/injection_container.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/history/history_bloc.dart';
import 'bloc/profile/profile_bloc.dart';
import 'bloc/profile/profile_event.dart';
import 'bloc/profile/profile_state.dart';
import 'bloc/transfer/transfer_bloc.dart';
import 'bloc/transfer/transfer_event.dart';
import 'bloc/transfer/transfer_state.dart';
import 'navigation/app_router.dart';
import 'pages/auth_gate_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  static final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static bool _nativeSplashRemoved = false;
  static final DateTime _launchTimestamp = DateTime.now();
  static const Duration _minimumSplashDuration = Duration(milliseconds: 1200);

  static Future<void> _removeNativeSplashWhenReady() async {
    if (_nativeSplashRemoved) {
      return;
    }
    final Duration elapsed = DateTime.now().difference(_launchTimestamp);
    final Duration remaining = _minimumSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (_nativeSplashRemoved) {
      return;
    }
    _nativeSplashRemoved = true;
    FlutterNativeSplash.remove();
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription<NetworkConnectionType>? _networkSubscription;
  NetworkConnectionType? _previousConnectionType;

  @override
  void initState() {
    super.initState();
    _initializeConnectivityToasts();
  }

  Future<void> _initializeConnectivityToasts() async {
    final NetworkInfo networkInfo = sl<NetworkInfo>();
    _previousConnectionType = await networkInfo.connectionType;
    _networkSubscription = networkInfo.onConnectionChanged.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(NetworkConnectionType currentType) {
    final NetworkConnectionType? previousType = _previousConnectionType;
    _previousConnectionType = currentType;
    if (previousType == null || previousType == currentType) {
      return;
    }

    if (currentType == NetworkConnectionType.none) {
      _showConnectivityToast(message: 'You are offline', isBackOnline: false);
      return;
    }

    if (previousType == NetworkConnectionType.none) {
      _showConnectivityToast(
        message: 'You are back online',
        isBackOnline: true,
      );
    }
  }

  void _showConnectivityToast({
    required String message,
    required bool isBackOnline,
  }) {
    final IconData leadingIcon = isBackOnline
        ? Icons.wifi_outlined
        : Icons.wifi_off_outlined;
    final SnackBar snackBar = SnackBar(
      content: Row(
        children: <Widget>[
          Icon(leadingIcon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(message, style: const TextStyle(color: Colors.white)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: const Color(0xFF2D2D2D),
      duration: isBackOnline
          ? const Duration(seconds: 2)
          : const Duration(seconds: 4),
    );

    final ScaffoldMessengerState? messenger = App._messengerKey.currentState;
    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ScaffoldMessengerState? fallbackMessenger =
          App._messengerKey.currentState;
      fallbackMessenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    });
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

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
        child: MultiBlocListener(
          listeners: <BlocListener<dynamic, dynamic>>[
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (AuthState previous, AuthState current) {
                return previous.activeAction == AuthAction.bootstrap &&
                    current.activeAction != AuthAction.bootstrap;
              },
              listener: (BuildContext context, AuthState state) async {
                await App._removeNativeSplashWhenReady();
              },
            ),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (AuthState previous, AuthState current) {
                // Profile identity is local-first; request profile once auth is
                // no longer loading, even if auth ended in error.
                if (current.status == AuthStatus.loading) {
                  return false;
                }
                return previous.status != current.status ||
                    previous.user?.id != current.user?.id;
              },
              listener: (BuildContext context, AuthState state) {
                if (state.status == AuthStatus.success && state.user != null) {
                  context.read<ProfileBloc>().add(const ProfileRequested());
                }
              },
            ),
            BlocListener<ProfileBloc, ProfileState>(
              listenWhen: (ProfileState previous, ProfileState current) =>
                  previous.status != current.status ||
                  previous.user?.id != current.user?.id,
              listener: (BuildContext context, ProfileState profileState) {
                if (profileState.status != ProfileStatus.success ||
                    profileState.user == null) {
                  return;
                }
                context.read<TransferBloc>().add(
                  IncomingTransferListeningRequested(profileState.user!.id),
                );
                context.read<TransferBloc>().add(
                  TransferLifecycleListeningRequested(profileState.user!.id),
                );
              },
            ),
            BlocListener<TransferBloc, TransferState>(
              listenWhen: (TransferState previous, TransferState current) =>
                  previous.uiWarningMessage != current.uiWarningMessage &&
                  current.uiWarningMessage != null,
              listener: (BuildContext context, TransferState transferState) {
                final String? message = transferState.uiWarningMessage;
                if (message == null) {
                  return;
                }
                App._messengerKey.currentState
                  ?..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
                context.read<TransferBloc>().add(
                  const TransferUiEffectConsumed(),
                );
              },
            ),
          ],
          child: MaterialApp.router(
            scaffoldMessengerKey: App._messengerKey,
            title: 'Tranzo',
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            builder: (BuildContext context, Widget? child) {
              return BlocBuilder<AuthBloc, AuthState>(
                builder: (BuildContext context, AuthState authState) {
                  if (authState.status == AuthStatus.success &&
                      authState.user != null) {
                    return child ?? const SizedBox.shrink();
                  }
                  // Host auth UI in a Navigator so EditableText has an Overlay
                  // ancestor while the app is unauthenticated.
                  return Navigator(
                    onGenerateRoute: (RouteSettings _) {
                      return MaterialPageRoute<void>(
                        builder: (_) => const AuthGatePage(),
                      );
                    },
                  );
                },
              );
            },
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
      if (auth.status == AuthStatus.success &&
          auth.user != null &&
          profile.state.status == ProfileStatus.initial) {
        profile.add(const ProfileRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
