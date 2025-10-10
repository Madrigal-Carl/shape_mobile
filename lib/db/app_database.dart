import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shape_mobile/models/StudentModel.dart';

class AppDatabase {
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  static Database? _db;
  static const String _dbName = 'shape_mobile.db';
  static const int _dbVersion = 1;

  // Table name
  static const String studentsTable = 'students';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  /// Initialize DB and create tables if not exists
  Future<Database> initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    // openDatabase will call onCreate if DB didn't exist
    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create students table (mirror of your Laravel resource + sync columns)
    await db.execute('''
      CREATE TABLE $studentsTable (
        id INTEGER PRIMARY KEY,
        lrn TEXT NOT NULL UNIQUE,
        path TEXT,
        first_name TEXT NOT NULL,
        middle_name TEXT,
        last_name TEXT NOT NULL,
        sex TEXT,
        birth_date TEXT,
        disability_type TEXT,
        support_need TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement migration logic here when you bump DB version
  }

  /// Close DB
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  /// Insert or replace student
  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert(
      studentsTable,
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Development helper: delete database file completely
  Future<void> deleteDatabaseFile() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);
    await deleteDatabase(path);
    _db = null;
  }

  /// List of table names (ignores SQLite internal tables)
  Future<List<String>> getTables() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// Clear all user tables (used on logout)
  Future<void> clearAllTables() async {
    final db = await database;
    final tables = await getTables();

    for (final table in tables) {
      await db.delete(table);
    }

    print("🧹 All SQLite tables cleared.");
  }
}
