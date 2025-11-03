import 'package:flutter/material.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/StudentActivityModel.dart';
import 'package:shape_mobile/services/preference_service.dart';
import 'package:toastification/toastification.dart';
import 'match_mania/entry.dart';
import 'count_quest/entry.dart';
import 'finger_addition/entry.dart';

class GameRegistry {
  static final Map<int, Widget Function(BuildContext, int, int, int)> _games = {
    // 5, 8, 20
    4: (context, lessonId, studentId, gameId) => MatchManiaEntry(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    ),
    12: (context, lessonId, studentId, gameId) => CountQuestEntry(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    ),
    8: (context, lessonId, studentId, gameId) => FingerAdditionEntry(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    ),
  };

  static List<int> get allGameIds => _games.keys.toList();

  /// Centralized game launcher
  static Future<void> launchGameById({
    required BuildContext context,
    required int gameId,
    required int lessonId,
  }) async {
    final db = AppDatabase.instance;

    // 🔹 Step 1: Get logged-in student ID
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

    // 🔹 Step 2: Verify that the game is linked to this lesson
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

    // 🔹 Step 3: Check student’s previous activity
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

    // 🔹 Step 4: Open the game
    final builder = _games[gameId];
    if (builder != null) {
      final gameWidget = builder(context, lessonId, studentId, gameId);
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
