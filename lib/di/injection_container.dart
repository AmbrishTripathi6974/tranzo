import 'package:get_it/get_it.dart';

import '../core/constants/app_constants.dart';
import '../core/network/network_info.dart';
import '../data/datasources/local/transfer_local_data_source.dart';
import '../data/datasources/remote/transfer_remote_data_source.dart';
import '../data/repositories/transfer_repository_impl.dart';
import '../domain/repositories/transfer_repository.dart';
import '../domain/usecases/retry_transfer_usecase.dart';
import '../domain/usecases/start_download_usecase.dart';
import '../domain/usecases/start_upload_usecase.dart';
import '../presentation/bloc/transfer_bloc.dart';
import '../transfer_engine/chunking/chunk_manager.dart';
import '../transfer_engine/download/download_manager.dart';
import '../transfer_engine/retry/retry_queue.dart';
import '../transfer_engine/state/transfer_state_manager.dart';
import '../transfer_engine/upload/upload_manager.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<TransferBloc>()) {
    return;
  }

  // Core
  sl.registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new);

  // Transfer data sources
  sl.registerLazySingleton<TransferRemoteDataSource>(
    TransferRemoteDataSourceImpl.new,
  );
  sl.registerLazySingleton<TransferLocalDataSource>(
    TransferLocalDataSourceImpl.new,
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
  sl.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(
      remoteDataSource: sl<TransferRemoteDataSource>(),
      localDataSource: sl<TransferLocalDataSource>(),
      uploadManager: sl<UploadManager>(),
      downloadManager: sl<DownloadManager>(),
      retryQueue: sl<RetryQueue>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<StartUploadUseCase>(
    () => StartUploadUseCase(sl<TransferRepository>()),
  );
  sl.registerLazySingleton<StartDownloadUseCase>(
    () => StartDownloadUseCase(sl<TransferRepository>()),
  );
  sl.registerLazySingleton<RetryTransferUseCase>(
    () => RetryTransferUseCase(sl<TransferRepository>()),
  );

  // Blocs
  sl.registerFactory<TransferBloc>(
    () => TransferBloc(
      startUpload: sl<StartUploadUseCase>(),
      startDownload: sl<StartDownloadUseCase>(),
      retryTransfer: sl<RetryTransferUseCase>(),
    ),
  );
}
