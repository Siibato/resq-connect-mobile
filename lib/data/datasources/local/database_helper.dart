import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const _dbName = 'resconnect.db';
const _dbVersion = 2;
const _tableOfflineReports = 'offline_reports';
const _tableSmsOfflineReports = 'sms_offline_reports';

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

    // SMS offline reports table for no-internet mode
    await db.execute('''
      CREATE TABLE $_tableSmsOfflineReports (
        id TEXT PRIMARY KEY,
        citizen_id TEXT NOT NULL,
        citizen_name TEXT NOT NULL,
        type TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        description TEXT NOT NULL,
        sms_text TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'DRAFT',
        created_at TEXT NOT NULL,
        sent_at TEXT
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

  // --- SMS Offline Reports (for no-internet mode) ---

  Future<void> insertSmsOfflineReport(Map<String, dynamic> report) async {
    final db = await database;
    await db.insert(_tableSmsOfflineReports, report);
  }

  Future<List<Map<String, dynamic>>> getDraftSmsReports() async {
    final db = await database;
    return db.query(
      _tableSmsOfflineReports,
      where: 'status = ?',
      whereArgs: ['DRAFT'],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllSmsReports() async {
    final db = await database;
    return db.query(
      _tableSmsOfflineReports,
      orderBy: 'created_at DESC',
    );
  }

  Future<void> markSmsSent(String id) async {
    final db = await database;
    await db.update(
      _tableSmsOfflineReports,
      {
        'status': 'SENT',
        'sent_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSmsReport(String id) async {
    final db = await database;
    await db.delete(
      _tableSmsOfflineReports,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});
