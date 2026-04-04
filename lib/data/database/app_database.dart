import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _database;

  Future<void> init() async {
    _database ??= await _open();
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'duobloom.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profiles (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            relationship_label TEXT NOT NULL,
            pairing_code TEXT NOT NULL,
            avatar_seed INTEGER NOT NULL,
            start_date TEXT NOT NULL,
            auth_method TEXT NOT NULL,
            email TEXT,
            phone TEXT,
            password_hash TEXT,
            google_email TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE habits (
            id TEXT PRIMARY KEY,
            profile_id TEXT NOT NULL,
            title TEXT NOT NULL,
            icon TEXT NOT NULL,
            target INTEGER NOT NULL,
            streak INTEGER NOT NULL,
            color_hex TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE habit_logs (
            id TEXT PRIMARY KEY,
            habit_id TEXT NOT NULL,
            log_date TEXT NOT NULL,
            completed INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE workouts (
            id TEXT PRIMARY KEY,
            profile_id TEXT NOT NULL,
            title TEXT NOT NULL,
            minutes INTEGER NOT NULL,
            intensity INTEGER NOT NULL,
            workout_date TEXT NOT NULL,
            note TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE journal_entries (
            id TEXT PRIMARY KEY,
            profile_id TEXT NOT NULL,
            entry_date TEXT NOT NULL,
            title TEXT NOT NULL,
            mood TEXT NOT NULL,
            body TEXT NOT NULL,
            highlight TEXT NOT NULL,
            media_path TEXT,
            drive_file_id TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE notes (
            id TEXT PRIMARY KEY,
            profile_id TEXT NOT NULL,
            note_type TEXT NOT NULL,
            body TEXT NOT NULL,
            created_at TEXT NOT NULL,
            pinned INTEGER NOT NULL,
            recipient_profile_id TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE cycle_entries (
            id TEXT PRIMARY KEY,
            profile_id TEXT NOT NULL,
            cycle_start TEXT NOT NULL,
            cycle_length INTEGER NOT NULL,
            period_length INTEGER NOT NULL,
            symptoms TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE media_assets (
            id TEXT PRIMARY KEY,
            profile_id TEXT NOT NULL,
            local_path TEXT NOT NULL,
            drive_file_id TEXT,
            journal_entry_id TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE app_meta (
            meta_key TEXT PRIMARY KEY,
            meta_value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<Map<String, List<Map<String, Object?>>>> exportAllTables() async {
    final db = await database;
    final tables = [
      'profiles',
      'habits',
      'habit_logs',
      'workouts',
      'journal_entries',
      'notes',
      'cycle_entries',
      'media_assets',
      'app_meta',
    ];

    final bundle = <String, List<Map<String, Object?>>>{};
    for (final table in tables) {
      bundle[table] = await db.query(table);
    }
    return bundle;
  }

  Future<void> restoreAllTables(Map<String, dynamic> payload) async {
    final db = await database;
    final tables = [
      'profiles',
      'habits',
      'habit_logs',
      'workouts',
      'journal_entries',
      'notes',
      'cycle_entries',
      'media_assets',
      'app_meta',
    ];

    await db.transaction((txn) async {
      for (final table in tables.reversed) {
        await txn.delete(table);
      }

      for (final table in tables) {
        final rawRows = (payload[table] as List<dynamic>? ?? const []);
        for (final raw in rawRows) {
          await txn.insert(
            table,
            Map<String, Object?>.from(raw as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }
}
