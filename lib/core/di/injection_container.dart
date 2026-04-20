import 'package:get_it/get_it.dart';

import '../../features/transfer/data/repositories/transfer_repository_impl.dart';
import '../../features/transfer/data/services/network/transfer_api_service.dart';
import '../../features/transfer/data/services/storage/file_storage_service.dart';
import '../../features/transfer/data/transfer_engine/download/download_manager.dart';
import '../../features/transfer/data/transfer_engine/retry/retry_policy.dart';
import '../../features/transfer/data/transfer_engine/upload/upload_manager.dart';
import '../../features/transfer/domain/repositories/transfer_repository.dart';
import '../../features/transfer/domain/usecases/retry_transfer_usecase.dart';
import '../../features/transfer/domain/usecases/start_download_usecase.dart';
import '../../features/transfer/domain/usecases/start_upload_usecase.dart';
import '../../features/transfer/presentation/bloc/transfer_bloc.dart';
import '../constants/app_constants.dart';
import '../network/network_info.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  sl.registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new);

  // Transfer services and engine
  sl.registerLazySingleton<TransferApiService>(TransferApiServiceImpl.new);
  sl.registerLazySingleton<FileStorageService>(FileStorageServiceImpl.new);
  sl.registerLazySingleton<UploadManager>(UploadManager.new);
  sl.registerLazySingleton<DownloadManager>(DownloadManager.new);
  sl.registerLazySingleton<RetryPolicy>(
    () => const RetryPolicy(maxRetries: AppConstants.defaultMaxRetryCount),
  );

  // Repositories
  sl.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(
      apiService: sl<TransferApiService>(),
      storageService: sl<FileStorageService>(),
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
