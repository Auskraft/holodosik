import 'package:get_it/get_it.dart';

import '../../data/datasources/catalog_local_data_source.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../data/repositories/in_memory_stock_repository.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../database/app_database.dart';

final GetIt locator = GetIt.instance;

/// Регистрация зависимостей. Реализации меняются здесь, не трогая фичи.
void setupLocator() {
  locator
    ..registerLazySingleton(AppDatabase.new)
    ..registerLazySingleton(() => CatalogLocalDataSource(locator()))
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(locator()),
    )
    ..registerLazySingleton<StockRepository>(InMemoryStockRepository.new);
}
