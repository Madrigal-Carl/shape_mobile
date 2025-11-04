import 'package:flutter/material.dart';
import 'animal_game.dart';
import 'fruit_game.dart';
import 'thing_game.dart';
import 'mix_game.dart';

class GameMenuScreen extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const GameMenuScreen({
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
          /// 🖼️ Background
          Positioned.fill(
            child: Image.asset(
              'assets/games/objectify/images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 📋 Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 🧠 Logo
                    Image.asset(
                      'assets/games/objectify/images/logo2.png',
                      width: size.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),

                    /// 🐾 Animals button
                    _categoryButton(
                      imagePath:
                          'assets/games/objectify/images/category_animals.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimalGameScreen(
                              lessonId: lessonId,
                              studentId: studentId,
                              gameId: gameId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// 🍎 Fruits button
                    _categoryButton(
                      imagePath:
                          'assets/games/objectify/images/category_fruits.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FruitGameScreen(
                              lessonId: lessonId,
                              studentId: studentId,
                              gameId: gameId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// 🪑 Things button
                    _categoryButton(
                      imagePath:
                          'assets/games/objectify/images/category_things.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThingGameScreen(
                              lessonId: lessonId,
                              studentId: studentId,
                              gameId: gameId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// 🎲 Mixed button
                    _categoryButton(
                      imagePath:
                          'assets/games/objectify/images/category_mixed.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MixedGameScreen(
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

          /// 🔙 Back Button (Top-left)
          Positioned(
            top: 70,
            left: 30,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 40,
              ),
              // ✅ Go back to main.dart (home screen)
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🪵 Custom Button Widget
  Widget _categoryButton({
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        imagePath,
        width: 250,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
      ),
    );
  }
}
