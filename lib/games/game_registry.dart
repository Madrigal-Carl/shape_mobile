import 'package:flutter/material.dart';
import 'package:shape_mobile/services/preference_service.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/StudentActivityModel.dart';
import 'package:toastification/toastification.dart';

// Import all your game entry widgets
import 'match_mania/entry.dart';
import 'count_quest/entry.dart';
import 'finger_addition/entry.dart';
import 'fruit_subtraction/entry.dart';
import 'objectify/entry.dart';
import 'fruit_addition/entry.dart';
import 'finger_subtraction/entry.dart';
import 'sign_quest/entry.dart';
import 'cast_spell/entry.dart';
import 'number_quest/entry.dart';
import 'self_care/entry.dart';
import 'sort_safari/entry.dart';
import 'fairly_multiplication/entry.dart';
import 'animal_trace/entry.dart';
import 'shape_trace/entry.dart';
import 'count_to_100/entry.dart';
import 'emotion_test/entry.dart';
import 'tracing_time/entry.dart';
import 'balloon_pop/entry.dart';

class GameRegistry {
  /// Map of gameId → game entry (builder + thumbnail path)
  static final Map<int, _GameEntry> _games = {
    1: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => CountQuestEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/count_quest/count-quest-icon.png',
    ),
    2: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => FingerAdditionEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/finger_addition/finger-addition-icon.png',
    ),
    3: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => FruitSubtractionEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath:
          'assets/games/fruit_subtraction/fruit-subtraction-icon.png',
    ),
    4: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => ObjectifyEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/objectify/objectify-icon.png',
    ),
    5: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => FruitAdditionEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/fruit_addition/fruit-addition-icon.png',
    ),
    6: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => FingerSubtractionEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath:
          'assets/games/finger_subtraction/finger-subtraction-icon.png',
    ),
    7: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => SignQuestEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/sign_quest/sign-quest-icon.png',
    ),
    8: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => CastSpellEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/cast_spell/cast-spell-icon.png',
    ),
    9: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => NumberQuestEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/number_quest/number-quest-icon.png',
    ),
    10: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => SelfCareEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/self_care/care-for-yourself-icon.png',
    ),
    11: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => SortSafariEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/sort_safari/sort-safari-icon.png',
    ),
    12: _GameEntry(
      builder: (context, lessonId, studentId, gameId) =>
          FairlyMultiplicationEntry(
            lessonId: lessonId,
            studentId: studentId,
            gameId: gameId,
          ),
      thumbnailPath:
          'assets/games/fairly_multiplication/the-fairly-multiflication.png',
    ),
    13: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => AnimalTraceEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/animal_trace/animal-trace.png',
    ),
    14: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => ShapeTraceEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/shape_trace/shape-trace.png',
    ),
    15: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => CountTo100Entry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/count_to_100/count-to-100.png',
    ),
    16: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => MatchManiaEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/match_mania/math-mania-icon.png',
    ),
    17: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => EmotionTestEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/emotion_test/emotion-test.png',
    ),
    18: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => TracingTimeEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/tracing_time/tracing-time.png',
    ),
    19: _GameEntry(
      builder: (context, lessonId, studentId, gameId) => BalloonPopEntry(
        lessonId: lessonId,
        studentId: studentId,
        gameId: gameId,
      ),
      thumbnailPath: 'assets/games/balloon_pop/balloon-pop.png',
    ),
  };

  /// Get all registered game IDs
  static List<int> get allGameIds => _games.keys.toList();

  /// Get the game entry for a specific ID
  static _GameEntry? getGameEntry(int gameId) => _games[gameId];

  /// Launch a game by its ID
  static Future<void> launchGameById({
    required BuildContext context,
    required int gameId,
    required int lessonId,
  }) async {
    final db = AppDatabase.instance;
    final studentId = PreferenceService.studentId;

    if (studentId == null) {
      toastification.showError(
        context: context,
        title: 'Student not logged in.',
        autoCloseDuration: const Duration(seconds: 5),
        padding: const EdgeInsets.all(10),
      );
      return;
    }

    final link = await db.fetchGameLessonLink(lessonId, gameId);
    if (link == null) {
      toastification.showError(
        context: context,
        title: 'Game not linked to this lesson.',
        autoCloseDuration: const Duration(seconds: 5),
        padding: const EdgeInsets.all(10),
      );
      return;
    }

    final linkId = link['id'] as int;
    final studentActivityMap = await db.fetchStudentGameActivity(
      studentId: studentId,
      activityLessonId: linkId,
    );

    if (studentActivityMap != null) {
      final activity = StudentActivity.fromJson(studentActivityMap);
      if (activity.status == 'finished') {
        toastification.showError(
          context: context,
          title: 'You already finished this game.',
          autoCloseDuration: const Duration(seconds: 5),
          padding: const EdgeInsets.all(10),
        );
        return;
      }
    }

    final entry = _games[gameId];
    if (entry != null) {
      final gameWidget = entry.builder(context, lessonId, studentId, gameId);
      Navigator.push(context, MaterialPageRoute(builder: (_) => gameWidget));
    } else {
      toastification.showError(
        context: context,
        title: 'No game found for ID $gameId',
        autoCloseDuration: const Duration(seconds: 5),
        padding: const EdgeInsets.all(10),
      );
    }
  }
}

/// Internal class to store builder + thumbnail
class _GameEntry {
  final Widget Function(BuildContext, int, int, int) builder;
  final String thumbnailPath;

  _GameEntry({required this.builder, required this.thumbnailPath});
}
