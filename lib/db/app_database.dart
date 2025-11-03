import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:shape_mobile/models/StudentModel.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'package:shape_mobile/models/VideoModel.dart';
import 'package:shape_mobile/models/GameActivityModel.dart';
import 'package:shape_mobile/models/GameActivityLessonModel.dart';
import 'package:shape_mobile/models/StudentActivityModel.dart';
import 'package:shape_mobile/models/FeedModel.dart';
import 'package:shape_mobile/models/AwardModel.dart';
import 'package:shape_mobile/models/StudentAwardModel.dart';
import 'package:shape_mobile/games/game_registry.dart';

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

  Future<Lesson?> fetchLatestLesson({int? studentId}) async {
    final db = await database;

    // 🧩 Make sure we have a studentId
    if (studentId == null) return null;

    // Query to get the latest lesson that is NOT fully completed
    final result = await db.rawQuery(
      '''
    SELECT l.*
    FROM $lessonsTable l
    LEFT JOIN (
      SELECT gal.lesson_id,
             COUNT(gal.id) AS total,
             SUM(CASE WHEN sa.status = 'finished' THEN 1 ELSE 0 END) AS completed
      FROM $gameActivityLessonsTable gal
      LEFT JOIN $studentActivitiesTable sa
        ON gal.id = sa.activity_lesson_id
       AND sa.student_id = ?
      GROUP BY gal.lesson_id
    ) AS prog ON prog.lesson_id = l.id
    WHERE (prog.completed IS NULL OR prog.completed < prog.total)
    ORDER BY datetime(l.created_at) DESC
    LIMIT 1
  ''',
      [studentId],
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

  Future<int> getUnreadNotificationCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $feedsTable WHERE is_read = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getLessonProgress(int lessonId, int studentId) async {
    final db = await database;

    // Count all activities linked to this lesson
    final totalResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as total
    FROM ${AppDatabase.gameActivityLessonsTable}
    WHERE lesson_id = ?
    ''',
      [lessonId],
    );

    final totalActivities = totalResult.first['total'] as int? ?? 0;
    if (totalActivities == 0) {
      print("⚠️ No activities found for lesson $lessonId");
      return 0.0;
    }

    // Count finished activities for this student and lesson
    final completedResult = await db.rawQuery(
      '''
    SELECT COUNT(*) as completed
    FROM ${AppDatabase.studentActivitiesTable} sa
    JOIN ${AppDatabase.gameActivityLessonsTable} gal
      ON sa.activity_lesson_id = gal.id
    WHERE gal.lesson_id = ?
      AND sa.student_id = ?
      AND sa.status = 'finished'
    ''',
      [lessonId, studentId],
    );

    final completedActivities = completedResult.first['completed'] as int? ?? 0;

    print(
      "📘 Lesson $lessonId | Student $studentId → $completedActivities / $totalActivities completed",
    );

    final progress = completedActivities / totalActivities;
    return progress.clamp(0.0, 1.0);
  }

  Future<List<Map<String, dynamic>>> fetchGamesWithLessonTitles(
    int studentId,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT 
      ga.*, 
      l.title AS lesson_title, 
      l.id AS lesson_id
    FROM $gameActivityLessonsTable gal
    INNER JOIN $gameActivitiesTable ga 
      ON gal.game_activity_id = ga.id
    INNER JOIN $lessonsTable l 
      ON gal.lesson_id = l.id
    INNER JOIN $studentActivitiesTable sa
      ON sa.activity_lesson_id = gal.id
    WHERE sa.student_id = ?
      AND sa.status = 'unfinished'
      AND sa.activity_lesson_type = 'App\\Models\\GameActivityLesson'
  ''',
      [studentId],
    );

    final registeredIds = GameRegistry.allGameIds.toSet();

    return result
        .where((row) => registeredIds.contains(row['id']))
        .map(
          (row) => {
            'game': GameActivity.fromJson(row),
            'lesson_title': row['lesson_title'],
            'lesson_id': row['lesson_id'],
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchGamesWithLessonTitlesByLessonId(
    int lessonId,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT 
      ga.*, 
      l.title AS lesson_title, 
      l.id AS lesson_id
    FROM $gameActivityLessonsTable gal
    INNER JOIN $gameActivitiesTable ga 
      ON gal.game_activity_id = ga.id
    INNER JOIN $lessonsTable l 
      ON gal.lesson_id = l.id
    WHERE gal.lesson_id = ?
  ''',
      [lessonId],
    );

    final registeredIds = GameRegistry.allGameIds.toSet();

    return result
        .where((row) => registeredIds.contains(row['id']))
        .map(
          (row) => {
            'game': GameActivity.fromJson(row),
            'lesson_title': row['lesson_title'],
            'lesson_id': row['lesson_id'],
          },
        )
        .toList();
  }

  /// Fetch the GameActivityLesson (linking record) by lesson and game ID
  Future<Map<String, dynamic>?> fetchGameLessonLink(
    int lessonId,
    int gameId,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT id FROM $gameActivityLessonsTable
      WHERE lesson_id = ? AND game_activity_id = ?
      LIMIT 1
    ''',
      [lessonId, gameId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Fetch a StudentActivity for this student + game lesson link
  Future<Map<String, dynamic>?> fetchStudentGameActivity({
    required int studentId,
    required int activityLessonId,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT * FROM $studentActivitiesTable
      WHERE student_id = ?
        AND activity_lesson_id = ?
        AND activity_lesson_type = 'App\\Models\\GameActivityLesson'
      LIMIT 1
    ''',
      [studentId, activityLessonId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // -----------------------
  // Delete Helpers
  // -----------------------

  Future<void> deleteStudent(int id) async {
    final db = await database;
    await db.delete(studentsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteLesson(int id) async {
    final db = await database;
    await db.delete(lessonsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteVideo(int id) async {
    final db = await database;

    // 1️⃣ Get the video to retrieve its local file path
    final result = await db.query(
      videosTable,
      columns: ['thumbnail', 'url'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final video = result.first;

      // Delete thumbnail file if exists
      final thumbnailPath = video['thumbnail'] as String?;
      if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
        final file = File(thumbnailPath);
        if (await file.exists()) await file.delete();
      }

      // Delete video file if exists
      final videoPath = video['url'] as String?;
      if (videoPath != null && videoPath.isNotEmpty) {
        final file = File(videoPath);
        if (await file.exists()) await file.delete();
      }
    }

    // 2️⃣ Delete the record from SQLite
    await db.delete(videosTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteGameActivity(int id) async {
    final db = await database;
    await db.delete(gameActivitiesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteGameActivityLesson(int id) async {
    final db = await database;
    await db.delete(gameActivityLessonsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteStudentActivity(int id) async {
    final db = await database;
    await db.delete(studentActivitiesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteFeed(int id) async {
    final db = await database;
    await db.delete(feedsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAward(int id) async {
    final db = await database;

    // 1️⃣ Get the award to retrieve its local file path
    final result = await db.query(
      awardsTable,
      columns: ['path'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final award = result.first;

      // Delete award file if exists
      final path = award['path'] as String?;
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }

    // 2️⃣ Delete the record from SQLite
    await db.delete(awardsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteStudentAward(int id) async {
    final db = await database;
    await db.delete(studentAwardsTable, where: 'id = ?', whereArgs: [id]);
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

  /// Development helper: delete database file completely
  Future<void> deleteDatabaseFile() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);
    await deleteDatabase(path);
    _db = null;
  }
}
