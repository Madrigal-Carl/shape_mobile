import 'package:flutter/material.dart';
import 'counting_game_screen.dart';
import 'medium_game_screen.dart';
import 'hard_game_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const LevelSelectionScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/games/count_quest/images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/games/count_quest/images/logo.png',
                    width: size.width * 0.7,
                  ),
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CountingGameScreen(
                            lessonId: lessonId,
                            studentId: studentId,
                            gameId: gameId,
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/games/count_quest/images/easy.png',
                      width: size.width * 0.7,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MediumGameScreen(
                            lessonId: lessonId,
                            studentId: studentId,
                            gameId: gameId,
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/games/count_quest/images/medium.png',
                      width: size.width * 0.7,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HardGameScreen(
                            lessonId: lessonId,
                            studentId: studentId,
                            gameId: gameId,
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/games/count_quest/images/hard.png',
                      width: size.width * 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
