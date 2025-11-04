import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart';

class CastSpellEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const CastSpellEntry({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // Register the game’s subgames if any
    GameProgressPreference.registerSubgames(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
      subgames: ['animal_game', 'fruits_game', 'things_game', 'mixed_game'],
    );

    return CastSpellRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
