import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'routine_together.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            partnerCode TEXT,
            connectedPartnerCode TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE habits(
            id TEXT PRIMARY KEY,
            userId TEXT,
            title TEXT,
            streak INTEGER,
            isDoneToday INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE workouts(
            id TEXT PRIMARY KEY,
            userId TEXT,
            type TEXT,
            durationMinutes INTEGER,
            timestamp TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE journals(
            id TEXT PRIMARY KEY,
            userId TEXT,
            date TEXT,
            title TEXT,
            content TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            userId TEXT,
            content TEXT,
            forPartner INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE period_cycles(
            id TEXT PRIMARY KEY,
            userId TEXT,
            lastPeriodStart TEXT,
            cycleLength INTEGER
          )
        ''');
      },
    );
  }

  Future<String> databasePath() async {
    final d = await db;
    return d.path;
  }
}
