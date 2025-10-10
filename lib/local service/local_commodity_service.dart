import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalCommodityService {
  static const String tableName = "commodities";
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "commodities.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            rate REAL NOT NULL,
            moisture REAL,
            condition TEXT,
            isSynced INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertCommodity(Commodity commodity, {bool synced = false}) async {
    final db = await database;
    await db.insert(
      tableName,
      {
        ...commodity.toJson(),
        'isSynced': synced ? 1 : (commodity.isSynced ? 1 : 0), // ensure correct mapping
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Commodity>> getAllCommodities() async {
    final db = await database;
    final result = await db.query(tableName);
    return result.map((e) => Commodity.fromJson({
      ...e,
      'isSynced': (e['isSynced'] as int) == 1, // convert 0/1 → bool
    })).toList();
  }

  Future<List<Commodity>> getUnsyncedCommodities() async {
    final db = await database;
    final result = await db.query(tableName, where: 'isSynced = ?', whereArgs: [0]);
    return result.map((e) => Commodity.fromJson({
      ...e,
      'isSynced': false,
    })).toList();
  }

  Future<void> updateSyncStatus(String id, bool synced) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': synced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCommodity(String id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
