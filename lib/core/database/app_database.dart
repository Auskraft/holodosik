import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Локальная БД. Использует глобальный [databaseFactory] — в приложении это
/// нативный sqflite, в тестах подменяется на ffi. Schema export и миграции
/// ведём с первой версии.
class AppDatabase {
  AppDatabase({this.fileName = 'holodos.db', this.path});

  final String fileName;

  /// Готовый путь к БД (для тестов — например, in-memory). Если null, путь
  /// строится из стандартной директории БД платформы.
  final String? path;

  Database? _db;

  static const int _version = 1;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dbPath = path ?? p.join(await databaseFactory.getDatabasesPath(), fileName);
    return databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_id TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_id TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    batch.execute('''
      CREATE TABLE stock_batches (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        location TEXT NOT NULL,
        qty_mode TEXT NOT NULL,
        qty_count INTEGER,
        qty_amount REAL,
        qty_per_pack REAL,
        qty_unit TEXT NOT NULL,
        purchase_date INTEGER,
        expiry_date INTEGER,
        opened_date INTEGER,
        note TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    batch.execute('''
      CREATE TABLE usage_events (
        id TEXT PRIMARY KEY,
        batch_id TEXT NOT NULL,
        amount_mode TEXT NOT NULL,
        amount_count INTEGER,
        amount_amount REAL,
        amount_per_pack REAL,
        amount_unit TEXT NOT NULL,
        reason TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY (batch_id) REFERENCES stock_batches (id)
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_products_category ON products (category_id)',
    );
    await batch.commit(noResult: true);
  }
}
