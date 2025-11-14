import 'package:flutter/material.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'main.dart';

class EmotionTestEntry extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const EmotionTestEntry({
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
      subgames: ['emotion_test'],
    );

    return EmotionTestRoot(
      lessonId: lessonId,
      studentId: studentId,
      gameId: gameId,
    );
  }
}
