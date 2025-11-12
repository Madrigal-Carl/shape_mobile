// lib/games/shape_trace/entry.dart
import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart';

class ShapeTraceEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const ShapeTraceEntry({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // Register this game’s progress
    GameProgressPreference.registerSubgames(
      studentId: studentId,
      lessonId: lessonId,
      gameId: gameId,
      subgames: ['shape_trace'],
    );

    return ShapeTraceRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
