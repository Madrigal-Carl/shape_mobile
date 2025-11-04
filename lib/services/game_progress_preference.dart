import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shape_mobile/db/app_database.dart';

class GameProgressPreference {
  static const _prefix = 'game_progress_';

  /// Registers all subgames for a specific student, lesson, and game.
  static Future<void> registerSubgames({
    required int studentId,
    required int lessonId,
    required int gameId,
    required List<String> subgames,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _mainKey(studentId, lessonId, gameId);

    // Check if this key already exists
    if (prefs.containsKey(key)) {
      print('📂 Existing progress found for $key, using saved data.');
      await _listRegisteredSubgames(studentId, lessonId, gameId);
      return;
    }

    // Create new map for subgames
    final Map<String, String> progressMap = {
      for (final subgame in subgames) subgame: 'unfinished',
    };

    await prefs.setString(key, jsonEncode(progressMap));
    print('🗂️ Registered new subgames for Game $gameId: $subgames');

    await _listRegisteredSubgames(studentId, lessonId, gameId);
  }

  /// Save progress for a specific subgame
  static Future<void> saveProgress({
    required int studentId,
    required int lessonId,
    required int gameId,
    required String subgameName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _mainKey(studentId, lessonId, gameId);

    if (!prefs.containsKey(key)) {
      print('⚠️ No progress data found for $key — creating new entry.');
      await registerSubgames(
        studentId: studentId,
        lessonId: lessonId,
        gameId: gameId,
        subgames: [subgameName],
      );
    }

    // Decode, update subgame, and save
    final Map<String, dynamic> progressMap = jsonDecode(
      prefs.getString(key) ?? '{}',
    );
    progressMap[subgameName] = 'finished';
    await prefs.setString(key, jsonEncode(progressMap));

    print('💾 Updated $subgameName as finished in $key.');

    await _checkAndMarkGameIfComplete(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
    );
  }

  /// Helper: key builder (no subgame here)
  static String _mainKey(int studentId, int lessonId, int gameId) {
    return '$_prefix${studentId}_${lessonId}_${gameId}';
  }

  /// Check if all subgames for a game are completed
  static Future<void> _checkAndMarkGameIfComplete({
    required int studentId,
    required int lessonId,
    required int gameId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _mainKey(studentId, lessonId, gameId);

    if (!prefs.containsKey(key)) {
      print('⚠️ No progress found for $key');
      return;
    }

    final Map<String, dynamic> progressMap = jsonDecode(
      prefs.getString(key) ?? '{}',
    );

    final allFinished = progressMap.values.every(
      (status) => status == 'finished',
    );

    print('🔍 Checking completion for $key → allFinished: $allFinished');

    if (allFinished) {
      final db = AppDatabase.instance;

      final link = await db.fetchGameLessonLink(lessonId, gameId);
      if (link == null) {
        print(
          '⚠️ No game lesson link found for lesson=$lessonId, game=$gameId',
        );
        return;
      }

      final activityLessonId = link['id'] as int;
      final studentActivity = await db.fetchStudentGameActivity(
        studentId: studentId,
        activityLessonId: activityLessonId,
      );

      final database = await db.database;
      final now = DateTime.now().toIso8601String();

      await database.update(
        AppDatabase.studentActivitiesTable,
        {'status': 'finished', 'is_synced': 0, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [studentActivity!['id']],
      );

      print('🏁 Game $gameId marked as finished in the database.');
      await clearGameProgress(
        studentId: studentId,
        lessonId: lessonId,
        gameId: gameId,
      );
    }
  }

  /// Show all subgames and statuses
  static Future<void> _listRegisteredSubgames(
    int studentId,
    int lessonId,
    int gameId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _mainKey(studentId, lessonId, gameId);

    if (!prefs.containsKey(key)) {
      print('📭 No progress found for $key.');
      return;
    }

    final Map<String, dynamic> progressMap = jsonDecode(
      prefs.getString(key) ?? '{}',
    );

    print('📋 Progress for $key:');
    progressMap.forEach((subgame, status) {
      print('   • $subgame → $status');
    });
  }

  /// Clear all progress for this game
  static Future<void> clearGameProgress({
    required int studentId,
    required int lessonId,
    required int gameId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _mainKey(studentId, lessonId, gameId);
    await prefs.remove(key);
    print('🧹 Cleared all progress for $key');
  }
}
