import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/injection_container.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/history/history_bloc.dart';
import 'bloc/profile/profile_bloc.dart';
import 'bloc/profile/profile_event.dart';
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
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>()..add(const ProfileRequested()),
        ),
        BlocProvider<HistoryBloc>(create: (_) => sl<HistoryBloc>()),
        BlocProvider<TransferBloc>(create: (_) => sl<TransferBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Tranzo',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
      ),
    );
  }
}
