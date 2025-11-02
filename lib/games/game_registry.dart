import 'package:flutter/material.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/StudentActivityModel.dart';
import 'package:shape_mobile/services/preference_service.dart';
import 'package:toastification/toastification.dart';
import 'match_mania/entry.dart';

class GameRegistry {
  static final Map<int, WidgetBuilder> _games = {
    4: (context) => const MatchManiaEntry(),
  };

  static Widget? getGameById(BuildContext context, int id) {
    final builder = _games[id];
    return builder != null ? builder(context) : null;
  }

  static List<int> get allGameIds => _games.keys.toList();

  /// Centralized game launcher
  static Future<void> launchGameById({
    required BuildContext context,
    required int gameId,
    required int lessonId,
  }) async {
    final db = AppDatabase.instance;

    // 🔹 Step 1: Get logged-in student ID from cached preference
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

    // 🔹 Step 3: Check the student's existing activity
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

    // 🔹 Step 4: If allowed → open the game widget
    final gameWidget = getGameById(context, gameId);
    if (gameWidget != null) {
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
