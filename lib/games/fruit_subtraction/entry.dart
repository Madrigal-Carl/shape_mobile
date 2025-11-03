import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart';

class FruitSubtractionEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const FruitSubtractionEntry({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // Register subgame for progress tracking
    GameProgressPreference.registerSubgames(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
      subgames: ['subtraction'],
    );

    return FruitSubtractionRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
