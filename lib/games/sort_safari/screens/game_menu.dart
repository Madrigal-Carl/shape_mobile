import 'package:flutter/material.dart';
import 'shape_game.dart';
import 'size_game.dart';
import 'color_game.dart';

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
              'assets/games/sort_safari/images/bg.png',
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
                      'assets/games/sort_safari/images/logo2.png',
                      width: size.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),

                    /// 🐾 Animals button
                    _categoryButton(
                      imagePath: 'assets/games/sort_safari/images/color.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ColorGameScreen(
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
                      imagePath: 'assets/games/sort_safari/images/size.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SizeGameScreen(
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
                      imagePath: 'assets/games/sort_safari/images/shape.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShapeGameScreen(
                              lessonId: lessonId,
                              studentId: studentId,
                              gameId: gameId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
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
              onPressed: () => Navigator.pop(context),
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
