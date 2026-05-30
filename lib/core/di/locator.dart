import 'package:get_it/get_it.dart';

import '../../data/repositories/in_memory_stock_repository.dart';
import '../../domain/repositories/stock_repository.dart';

final GetIt locator = GetIt.instance;

/// Регистрация зависимостей. Реализации меняются здесь, не трогая фичи.
void setupLocator() {
  locator.registerLazySingleton<StockRepository>(InMemoryStockRepository.new);
}
