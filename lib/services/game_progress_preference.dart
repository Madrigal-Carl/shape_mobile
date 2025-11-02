import 'package:shared_preferences/shared_preferences.dart';
import 'package:shape_mobile/db/app_database.dart';

class GameProgressPreference {
  static const _prefix = 'game_progress_';

  /// Register all subgames for a given lesson, student, and game
  static Future<void> registerSubgames({
    required int studentId,
    required int lessonId,
    required int gameId,
    required List<String> subgames,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    for (final subgame in subgames) {
      final key = _key(studentId, lessonId, gameId, subgame);
      // Initialize only if not already existing
      if (!prefs.containsKey(key)) {
        await prefs.setString(key, 'unfinished');
      }
    }

    print('🗂️ Registered subgames for Game $gameId: $subgames');
  }

  /// Save progress for a specific subgame
  static Future<void> saveProgress({
    required int studentId,
    required int lessonId,
    required int gameId,
    required String subgameName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(studentId, lessonId, gameId, subgameName);

    await prefs.setString(key, 'finished');
    print('💾 Marked $subgameName as finished.');

    // After marking finished, check if all are completed
    await _checkAndMarkGameIfComplete(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
    );
  }

  /// Helper: key builder
  static String _key(
    int studentId,
    int lessonId,
    int gameId,
    String subgameName,
  ) {
    return '$_prefix${studentId}_${lessonId}_${gameId}_$subgameName';
  }

  /// Check if all subgames of a game are completed
  static Future<void> _checkAndMarkGameIfComplete({
    required int studentId,
    required int lessonId,
    required int gameId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Collect all keys for this (student, lesson, game)
    final allKeys = prefs.getKeys().where(
      (k) => k.startsWith('$_prefix${studentId}_${lessonId}_${gameId}_'),
    );

    if (allKeys.isEmpty) {
      print('⚠️ No subgames registered for game $gameId.');
      return;
    }

    // Check all statuses
    bool allFinished = true;
    for (final key in allKeys) {
      final status = prefs.getString(key);
      if (status != 'finished') {
        allFinished = false;
        break;
      }
    }

    print('🔍 Game $gameId → allFinished: $allFinished');

    if (allFinished) {
      final db = AppDatabase.instance;

      // 1️⃣ Fetch GameLesson link
      final link = await db.fetchGameLessonLink(lessonId, gameId);
      if (link == null) {
        print(
          '⚠️ No game lesson link found for lesson=$lessonId, game=$gameId',
        );
        return;
      }

      final activityLessonId = link['id'] as int;

      // 2️⃣ Fetch student activity
      final studentActivity = await db.fetchStudentGameActivity(
        studentId: studentId,
        activityLessonId: activityLessonId,
      );

      final database = await db.database;
      final now = DateTime.now().toIso8601String();

      // Update existing record
      await database.update(
        AppDatabase.studentActivitiesTable,
        {'status': 'finished', 'is_synced': 0, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [studentActivity!['id']],
      );
      print('🏁 Game $gameId marked finished (updated existing).');

      await clearGameProgress(
        studentId: studentId,
        lessonId: lessonId,
        gameId: gameId,
      );
      print('🧹 Cleared progress data for Game $gameId after completion.');
    }
  }

  /// Optional: clear a game’s progress (for testing)
  static Future<void> clearGameProgress({
    required int studentId,
    required int lessonId,
    required int gameId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
      (k) => k.startsWith('$_prefix${studentId}_${lessonId}_${gameId}_'),
    );
    for (final key in keys) {
      await prefs.remove(key);
    }
    print('🧹 Cleared progress for game $gameId');
  }
}
