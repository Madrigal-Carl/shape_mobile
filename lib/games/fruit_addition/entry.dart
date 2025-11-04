// lib/games/fruit_addition/entry.dart
import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart';

class FruitAdditionEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const FruitAdditionEntry({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    GameProgressPreference.registerSubgames(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
      subgames: ['fruit_addition'],
    );

    // Return the game root widget
    return FruitAdditionRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
