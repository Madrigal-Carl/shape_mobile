import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shape_mobile/models/StudentModel.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'package:shape_mobile/models/VideoModel.dart';

class AppDatabase {
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  static Database? _db;
  static const String _dbName = 'shape_mobile.db';
  static const int _dbVersion = 1;

  // Table name
  static const String studentsTable = 'students';
  static const String lessonsTable = 'lessons';
  static const String videosTable = 'videos';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  /// Initialize DB and create tables if not exists
  Future<Database> initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Students Table
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

    // Lessons Table
    await db.execute('''
      CREATE TABLE $lessonsTable (
        id INTEGER PRIMARY KEY,
        school_year_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    // Videos Table
    await db.execute('''
      CREATE TABLE $videosTable (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        url TEXT NOT NULL,
        title TEXT NOT NULL,
        thumbnail TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1,
        FOREIGN KEY (lesson_id) REFERENCES $lessonsTable (id) ON DELETE CASCADE
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

  // Insert student
  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert(
      studentsTable,
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert lesson
  Future<void> insertLesson(Lesson lesson) async {
    final db = await database;
    await db.insert(
      lessonsTable,
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert video
  Future<void> insertVideo(Video video) async {
    final db = await database;
    await db.insert(
      videosTable,
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Lesson?> fetchLatestLesson() async {
    final db = await database;
    final result = await db.query(
      lessonsTable,
      orderBy: "datetime(created_at) DESC",
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Lesson.fromJson(result.first);
    }
    return null;
  }

  Future<List<Video>> fetchVideosByLessonId(int lessonId) async {
    final db = await database;
    final result = await db.query(
      videosTable,
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return result.map((json) => Video.fromJson(json)).toList();
  }

  Future<List<Video>> fetchAllVideosSortedByLatest() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT v.*, l.title AS lesson_title
    FROM $videosTable v
    INNER JOIN $lessonsTable l ON v.lesson_id = l.id
    ORDER BY datetime(v.created_at) DESC
  ''');

    return result.map((json) => Video.fromJson(json)).toList();
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
