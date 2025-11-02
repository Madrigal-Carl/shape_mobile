import 'package:flutter/material.dart';
import 'animal_match_screen.dart';
import 'matter_match_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const GameSelectionScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // 🔸 Helper for menu buttons
    Widget menuButton(
      String assetPath,
      VoidCallback onTap, {
      double width = 280,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Image.asset(assetPath, width: width, fit: BoxFit.contain),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 🖼️ Background image
          Positioned.fill(
            child: Image.asset(
              'assets/games/match_mania/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🌫️ Optional dark overlay for better contrast
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.05)),
          ),

          // 📦 Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 150), // slightly raised
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Logo
                    Image.asset(
                      'assets/games/match_mania/images/logo.png',
                      width: MediaQuery.of(context).size.width * 0.75,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 60),

                    // 🔸 Matter Match button
                    menuButton(
                      'assets/games/match_mania/images/matter.png',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatterMatchScreen(
                              lessonId: lessonId,
                              studentId: studentId,
                              gameId: gameId,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    // 🔸 Animal Match button
                    menuButton(
                      'assets/games/match_mania/images/animal.png',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnimalMatchScreen(
                              lessonId: lessonId,
                              studentId: studentId,
                              gameId: gameId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
