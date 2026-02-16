import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const _dbName = 'resconnect.db';
const _dbVersion = 1;
const _tableOfflineReports = 'offline_reports';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableOfflineReports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        media_path TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insertOfflineReport(Map<String, dynamic> report) async {
    final db = await database;
    return db.insert(_tableOfflineReports, report);
  }

  Future<List<Map<String, dynamic>>> getPendingOfflineReports() async {
    final db = await database;
    return db.query(
      _tableOfflineReports,
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markReportSynced(int id) async {
    final db = await database;
    await db.update(
      _tableOfflineReports,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteOfflineReport(int id) async {
    final db = await database;
    await db.delete(
      _tableOfflineReports,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});
