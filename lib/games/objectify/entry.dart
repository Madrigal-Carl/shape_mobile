import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart';

class ObjectifyEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const ObjectifyEntry({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // Register subgames (optional, you can customize)
    GameProgressPreference.registerSubgames(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
      subgames: ['animal_game', 'fruits_game', 'things_game', 'mixed_game'],
    );

    // Return your routed game’s root widget
    return ObjectifyRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
