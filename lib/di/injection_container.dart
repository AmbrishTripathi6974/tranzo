import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';

import '../core/constants/app_constants.dart';
import '../core/database/isar/isar_database.dart';
import '../core/network/network_info.dart';
import '../core/services/auth_service.dart';
import '../core/services/permission_service.dart';
import '../core/services/realtime_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/supabase_client.dart';
import '../core/services/transfer_service.dart';
import '../data/datasources/local/transfer_local_data_source.dart';
import '../data/datasources/remote/transfer_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/transfer_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/transfer_repository.dart';
import '../domain/usecases/create_user_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/get_user_interactions_usecase.dart';
import '../domain/usecases/get_user_profile_usecase.dart';
import '../domain/usecases/get_transfer_history_usecase.dart';
import '../domain/usecases/check_transfer_permissions_usecase.dart';
import '../domain/usecases/check_storage_availability_usecase.dart';
import '../domain/usecases/evaluate_upload_policy_usecase.dart';
import '../domain/usecases/retry_transfer_usecase.dart';
import '../domain/usecases/send_files_usecase.dart';
import '../domain/usecases/start_download_usecase.dart';
import '../domain/usecases/start_upload_usecase.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/history/history_bloc.dart';
import '../presentation/bloc/profile/profile_bloc.dart';
import '../presentation/bloc/transfer/transfer_bloc.dart';
import '../transfer_engine/chunking/chunk_manager.dart';
import '../transfer_engine/download/download_manager.dart';
import '../transfer_engine/retry/retry_queue.dart';
import '../transfer_engine/state/transfer_state_manager.dart';
import '../transfer_engine/upload/upload_manager.dart';

final GetIt sl = GetIt.instance;

/// Opens Isar and registers it with GetIt. Call from [main] after
/// [configureDependencies]; omit in tests that do not exercise local DB code.
Future<void> registerIsarDatabase() async {
  if (sl.isRegistered<Isar>()) {
    return;
  }
  sl.registerSingleton<Isar>(await openTranzoIsar());
}

Future<void> configureDependencies() async {
  if (sl.isRegistered<TransferBloc>()) {
    return;
  }

  // Core
  sl.registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new);
  sl.registerLazySingleton<SupabaseClientHandle>(
    SupabaseClientHandle.fromEnvironment,
  );
  sl.registerLazySingleton<AuthService>(
    () => AuthService(sl<SupabaseClientHandle>().client),
  );
  sl.registerLazySingleton<TransferService>(
    () => TransferService(sl<SupabaseClientHandle>().client),
  );
  sl.registerLazySingleton<RealtimeService>(
    () => RealtimeService(sl<SupabaseClientHandle>().client),
  );
  sl.registerLazySingleton<StorageService>(StorageServiceImpl.new);
  sl.registerLazySingleton<PermissionService>(PermissionServiceImpl.new);

  // Transfer data sources
  sl.registerLazySingleton<TransferRemoteDataSource>(
    () => TransferRemoteDataSourceImpl(sl<TransferService>()),
  );
  sl.registerLazySingleton<TransferLocalDataSource>(
    () => TransferLocalDataSourceImpl(sl<Isar>()),
  );

  // Transfer engine (shared chunk / state / retry for resumable sessions)
  sl.registerLazySingleton<ChunkManager>(() => const ChunkManager());
  sl.registerLazySingleton<TransferStateManager>(TransferStateManager.new);
  sl.registerLazySingleton<RetryQueue>(
    () => RetryQueue(maxRetries: AppConstants.defaultMaxRetryCount),
  );
  sl.registerLazySingleton<UploadManager>(
    () => UploadManager(
      chunkManager: sl<ChunkManager>(),
      stateManager: sl<TransferStateManager>(),
      retryQueue: sl<RetryQueue>(),
    ),
  );
  sl.registerLazySingleton<DownloadManager>(
    () => DownloadManager(
      chunkManager: sl<ChunkManager>(),
      stateManager: sl<TransferStateManager>(),
      retryQueue: sl<RetryQueue>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authService: sl<AuthService>(), isar: sl<Isar>()),
  );
  sl.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(
      remoteDataSource: sl<TransferRemoteDataSource>(),
      localDataSource: sl<TransferLocalDataSource>(),
      transferService: sl<TransferService>(),
      realtimeService: sl<RealtimeService>(),
      isar: sl<Isar>(),
      uploadManager: sl<UploadManager>(),
      downloadManager: sl<DownloadManager>(),
      retryQueue: sl<RetryQueue>(),
      storageService: sl<StorageService>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<CreateUser>(() => CreateUser(sl<AuthRepository>()));
  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetTransferHistoryUseCase>(
    () => GetTransferHistoryUseCase(sl<TransferRepository>()),
  );
  sl.registerLazySingleton<GetUserProfile>(
    () => GetUserProfile(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetUserInteractions>(
    () => GetUserInteractions(sl<TransferRepository>()),
  );
  sl.registerLazySingleton<CheckStorageAvailability>(
    () => CheckStorageAvailability(sl<TransferRepository>()),
  );
  sl.registerLazySingleton<EvaluateUploadPolicyUseCase>(
    () => EvaluateUploadPolicyUseCase(sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<CheckTransferPermissionsUseCase>(
    () => CheckTransferPermissionsUseCase(sl<PermissionService>()),
  );
  sl.registerLazySingleton<StartUploadUseCase>(
    () => StartUploadUseCase(sl<TransferRepository>()),
  );
  sl.registerLazySingleton<StartDownloadUseCase>(
    () => StartDownloadUseCase(sl<TransferRepository>()),
  );
  sl.registerLazySingleton<RetryTransferUseCase>(
    () => RetryTransferUseCase(sl<TransferRepository>()),
  );
  sl.registerLazySingleton<SendFiles>(
    () => SendFiles(sl<TransferRepository>()),
  );

  // Blocs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      getCurrentUser: sl<GetCurrentUser>(),
      createUser: sl<CreateUser>(),
    ),
  );
  sl.registerFactory<HistoryBloc>(
    () => HistoryBloc(getTransferHistory: sl<GetTransferHistoryUseCase>()),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserProfile: sl<GetUserProfile>(),
      getUserInteractions: sl<GetUserInteractions>(),
    ),
  );
  sl.registerFactory<TransferBloc>(
    () => TransferBloc(
      startUpload: sl<StartUploadUseCase>(),
      startDownload: sl<StartDownloadUseCase>(),
      retryTransfer: sl<RetryTransferUseCase>(),
      sendFiles: sl<SendFiles>(),
      checkStorageAvailability: sl<CheckStorageAvailability>(),
      evaluateUploadPolicy: sl<EvaluateUploadPolicyUseCase>(),
      checkTransferPermissions: sl<CheckTransferPermissionsUseCase>(),
    ),
  );
}
