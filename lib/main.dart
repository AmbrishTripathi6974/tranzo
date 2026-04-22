import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/services/background_transfer_runtime_service.dart';
import 'core/services/supabase_client.dart';
import 'di/injection_container.dart';
import 'domain/usecases/resume_incomplete_transfers_usecase.dart';
import 'presentation/app.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: '.env');
  await TranzoSupabase.initializeFromEnvironment();
  await configureDependencies();
  await registerIsarDatabase();
  registerTransferRetryExecutor((String transferId, bool userInitiated) async {
    await sl<ResumeIncompleteTransfersUseCase>()(transferId: transferId);
  });
  await sl<BackgroundTransferRuntimeService>().initialize();
  await sl<ResumeIncompleteTransfersUseCase>()();
  runApp(const App());
}
