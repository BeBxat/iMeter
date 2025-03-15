// # จัดการ SQLite

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'imeter_data.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meter_readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            voltage REAL,
            current REAL,
            power REAL
          )
        ''');
      },
    );
  }

  static Future<void> insertReading(double voltage, double current, double power) async {
    final db = await database;
    await db.insert('meter_readings', {
      'timestamp': DateTime.now().toIso8601String(),
      'voltage': voltage,
      'current': current,
      'power': power
    });
  }

  static Future<List<Map<String, dynamic>>> getLast30DaysData() async {
    final db = await database;
    return await db.query(
        'meter_readings',
        where: "timestamp >= datetime('now', '-30 days')",
        orderBy: "timestamp ASC"
    );
  }
}
