import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shape_mobile/models/StudentModel.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'package:shape_mobile/models/VideoModel.dart';
import 'package:shape_mobile/models/GameActivityModel.dart';
import 'package:shape_mobile/models/GameActivityLessonModel.dart';
import 'package:shape_mobile/models/StudentActivityModel.dart';
import 'package:shape_mobile/models/FeedModel.dart';
import 'package:shape_mobile/models/AwardModel.dart';
import 'package:shape_mobile/models/StudentAwardModel.dart';

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
  static const String gameActivitiesTable = 'game_activities';
  static const String gameActivityLessonsTable = 'game_activity_lessons';
  static const String studentActivitiesTable = 'student_activities';
  static const String feedsTable = 'feeds';
  static const String awardsTable = 'awards';
  static const String studentAwardsTable = 'student_awards';

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
        status TEXT DEFAULT 'inactive',
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

    // Game Activities Table
    await db.execute('''
      CREATE TABLE $gameActivitiesTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    // Game Activity Lessons Table
    await db.execute('''
      CREATE TABLE $gameActivityLessonsTable (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER,
        game_activity_id INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1,
        FOREIGN KEY (lesson_id) REFERENCES $lessonsTable (id) ON DELETE SET NULL,
        FOREIGN KEY (game_activity_id) REFERENCES $gameActivitiesTable (id) ON DELETE CASCADE
      )
    ''');

    // Student Activities Table
    await db.execute('''
      CREATE TABLE $studentActivitiesTable (
        id INTEGER PRIMARY KEY,
        student_id INTEGER NOT NULL,
        activity_lesson_id INTEGER NOT NULL,
        activity_lesson_type TEXT NOT NULL,
        status TEXT DEFAULT 'unfinished',
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1,
        FOREIGN KEY (student_id) REFERENCES $studentsTable (id) ON DELETE CASCADE
      )
    ''');

    // Feeds Table
    await db.execute('''
      CREATE TABLE $feedsTable (
        id INTEGER PRIMARY KEY,
        notifiable_id INTEGER,
        group_name TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1,
        FOREIGN KEY (notifiable_id) REFERENCES $studentsTable (id) ON DELETE SET NULL
      )
    ''');

    // Awards Table
    await db.execute('''
      CREATE TABLE $awardsTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        path TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    // Student Awards Table
    await db.execute('''
      CREATE TABLE $studentAwardsTable (
        id INTEGER PRIMARY KEY,
        school_year_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        award_id INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 1,
        UNIQUE (student_id, award_id, school_year_id),
        FOREIGN KEY (student_id) REFERENCES $studentsTable (id) ON DELETE CASCADE,
        FOREIGN KEY (award_id) REFERENCES $awardsTable (id) ON DELETE CASCADE
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

  // Insert Helpers
  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert(
      studentsTable,
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertLesson(Lesson lesson) async {
    final db = await database;
    await db.insert(
      lessonsTable,
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertVideo(Video video) async {
    final db = await database;
    await db.insert(
      videosTable,
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertGameActivity(GameActivity activity) async {
    final db = await database;
    await db.insert(
      gameActivitiesTable,
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertGameActivityLesson(GameActivityLesson link) async {
    final db = await database;
    await db.insert(
      gameActivityLessonsTable,
      link.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertStudentActivity(StudentActivity activity) async {
    final db = await database;
    await db.insert(
      studentActivitiesTable,
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFeed(Feed feed) async {
    final db = await database;
    await db.insert(
      feedsTable,
      feed.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAward(Award award) async {
    final db = await database;
    await db.insert(
      awardsTable,
      award.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertStudentAward(StudentAward studentAward) async {
    final db = await database;
    await db.insert(
      studentAwardsTable,
      studentAward.toMap(),
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

  Future<List<Award>> fetchAllAwards() async {
    final db = await database;
    final result = await db.query(awardsTable);
    return result.map((json) => Award.fromJson(json)).toList();
  }

  Future<Map<String, int>> fetchStudentSummary(int studentId) async {
    final db = await database;

    // Total lessons
    final totalLessonsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $lessonsTable',
    );
    final totalLessons = Sqflite.firstIntValue(totalLessonsResult) ?? 0;

    // Total activities for the student
    final totalActivitiesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $studentActivitiesTable WHERE student_id = ?',
      [studentId],
    );
    final totalActivities = Sqflite.firstIntValue(totalActivitiesResult) ?? 0;

    // Completed activities
    final completedActivitiesResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM $studentActivitiesTable WHERE student_id = ? AND status = 'finished'",
      [studentId],
    );
    final completedActivities =
        Sqflite.firstIntValue(completedActivitiesResult) ?? 0;

    // Completed lessons (all activities for a lesson are finished)
    final completedLessonsResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT lesson_id) as count
      FROM $studentActivitiesTable sa
      WHERE sa.student_id = ?
      AND NOT EXISTS (
        SELECT 1 
        FROM $studentActivitiesTable sa2
        WHERE sa2.lesson_id = sa.lesson_id
        AND sa2.student_id = sa.student_id
        AND sa2.status != 'finished'
      )
    ''',
      [studentId],
    );
    final completedLessons = Sqflite.firstIntValue(completedLessonsResult) ?? 0;

    return {
      'totalLessons': totalLessons,
      'totalActivities': totalActivities,
      'completedActivities': completedActivities,
      'completedLessons': completedLessons,
    };
  }

  Future<int> getUnreadNotificationCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $feedsTable WHERE is_read = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
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
