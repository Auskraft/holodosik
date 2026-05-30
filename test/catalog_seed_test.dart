import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:holodosik/core/database/app_database.dart';
import 'package:holodosik/data/datasources/catalog_local_data_source.dart';
import 'package:holodosik/data/repositories/catalog_repository_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<String> loadAsset(String _) =>
      File('assets/data/ingredients.json').readAsString();

  test('сидинг импортирует справочник из ingredients.json', () async {
    final db = AppDatabase(path: inMemoryDatabasePath);
    final ds = CatalogLocalDataSource(db);
    final repo = CatalogRepositoryImpl(ds, assetLoader: loadAsset);

    expect(await ds.productCount(), 0);
    await repo.ensureSeeded();

    expect(await ds.productCount(), 992);
    final categories = await repo.categories();
    expect(categories.length, greaterThan(20));
    expect(categories.first.sortOrder, 0);

    // Повторный вызов не дублирует данные.
    await repo.ensureSeeded();
    expect(await ds.productCount(), 992);
  });
}
