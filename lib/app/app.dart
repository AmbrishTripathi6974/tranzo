import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection_container.dart';
import '../features/transfer/presentation/bloc/transfer_bloc.dart';
import '../features/transfer/presentation/bloc/transfer_event.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<TransferBloc>(
          create: (_) => sl<TransferBloc>()..add(const TransferStarted()),
        ),
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
