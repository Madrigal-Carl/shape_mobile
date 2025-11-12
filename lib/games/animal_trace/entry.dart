// lib/games/animal_trace/entry.dart
import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart'; // imports AnimalTraceRoot (the main class you showed)

class AnimalTraceEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const AnimalTraceEntry({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // Register this game’s subgames or progress
    GameProgressPreference.registerSubgames(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
      subgames: ['animal_trace'],
    );

    return AnimalTraceRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
