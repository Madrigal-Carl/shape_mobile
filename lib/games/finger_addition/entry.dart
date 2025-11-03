import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart';

class FingerAdditionEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const FingerAdditionEntry({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // Register subgames for progress tracking
    GameProgressPreference.registerSubgames(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
      subgames: ['addition'],
    );

    return FingerAdditionRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
