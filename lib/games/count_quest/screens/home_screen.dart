import 'package:flutter/material.dart';
import 'dart:io';
import 'level_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The main popup image
            Image.asset(
              'assets/games/count_quest/images/how.png',
              fit: BoxFit.contain,
            ),

            // Close (X) button
            Positioned(
              top: 15,
              right: 15,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Image.asset(
                  'assets/games/count_quest/images/x.png',
                  width: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exitGame() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/games/count_quest/images/bg1.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Image.asset(
                    'assets/games/count_quest/images/logo.png',
                    width: size.width * 0.7,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  // START button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LevelSelectionScreen(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/games/count_quest/images/start.png',
                      width: size.width * 0.6,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // HOW TO PLAY button
                  GestureDetector(
                    onTap: () => _showHowToPlay(context),
                    child: Image.asset(
                      'assets/games/count_quest/images/htp.png',
                      width: size.width * 0.6,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // QUIT button
                  GestureDetector(
                    onTap: _exitGame,
                    child: Image.asset(
                      'assets/games/count_quest/images/quit.png',
                      width: size.width * 0.6,
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
