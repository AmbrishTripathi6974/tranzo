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
import '../transfer_engine/download/download_manager.dart';
import '../transfer_engine/retry/retry_policy.dart';
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

  // Transfer engine
  sl.registerLazySingleton<UploadManager>(UploadManager.new);
  sl.registerLazySingleton<DownloadManager>(DownloadManager.new);
  sl.registerLazySingleton<RetryPolicy>(
    () => const RetryPolicy(maxRetries: AppConstants.defaultMaxRetryCount),
  );

  // Repositories
  sl.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(
      remoteDataSource: sl<TransferRemoteDataSource>(),
      localDataSource: sl<TransferLocalDataSource>(),
      uploadManager: sl<UploadManager>(),
      downloadManager: sl<DownloadManager>(),
      retryPolicy: sl<RetryPolicy>(),
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
