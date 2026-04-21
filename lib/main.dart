import 'package:flutter/widgets.dart';

import 'core/services/background_transfer_runtime_service.dart';
import 'di/injection_container.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await registerIsarDatabase();
  await sl<BackgroundTransferRuntimeService>().initialize();
  runApp(const App());
}
