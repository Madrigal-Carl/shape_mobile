import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart'; // this will be your self care main.dart

class SelfCareEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const SelfCareEntry({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // Register subgame progress tracking
    GameProgressPreference.registerSubgames(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
      subgames: ['eat', 'brush_teeth', 'bath'],
    );

    // Return the root widget for the game
    return SelfCareRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
