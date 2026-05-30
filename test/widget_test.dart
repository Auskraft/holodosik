import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:holodosik/app/app.dart';
import 'package:holodosik/domain/entities/stock.dart';
import 'package:holodosik/domain/repositories/stock_repository.dart';
import 'package:holodosik/features/inventory/bloc/inventory_cubit.dart';

/// Фейковый репозиторий: пустые запасы, без БД — тест проверяет UI, не данные.
class _FakeStockRepository implements StockRepository {
  @override
  Stream<List<StockEntry>> watchInventory() => Stream.value(const []);
  @override
  Future<void> addBatch(StockEntry entry) async {}
  @override
  Future<void> updateBatch(StockEntry entry) async {}
  @override
  Future<void> applyUsage(String batchId, UsageEvent event) async {}
  @override
  Future<void> discard(String batchId) async {}
  @override
  Future<List<StockEntry>> loadUsedUp() async => const [];
  @override
  Future<List<String>> loadCustomLocations() async => const [];
  @override
  Future<void> addLocation(String name) async {}
  @override
  Future<void> renameLocation(String from, String to) async {}
  @override
  Future<void> deleteLocation(String name) async {}
}

void main() {
  testWidgets('Главный экран показывает бренд и пустое состояние запасов',
      (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => InventoryCubit(_FakeStockRepository()),
        child: const HolodosikApp(),
      ),
    );
    // Проматываем внутренний сплеш (таймер 1600 мс) и ждём загрузки запасов.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Холодосик'), findsOneWidget);
    expect(find.text('Здесь пусто'), findsOneWidget);
  });
}
