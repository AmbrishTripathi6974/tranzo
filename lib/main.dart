import 'package:flutter/widgets.dart';

import 'core/services/background_transfer_runtime_service.dart';
import 'core/services/supabase_client.dart';
import 'di/injection_container.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TranzoSupabase.initializeFromEnvironment();
  await configureDependencies();
  await registerIsarDatabase();
  await sl<BackgroundTransferRuntimeService>().initialize();
  runApp(const App());
}
