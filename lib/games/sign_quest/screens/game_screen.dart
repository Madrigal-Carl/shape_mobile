import 'package:flutter/material.dart';
import '../widgets/play_button.dart';
import 'level_screen.dart';

class GameScreen extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const GameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  void _navigateToLevelScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => LevelScreen(
          lessonId: lessonId,
          studentId: studentId,
          gameId: gameId,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 🔹 Pure black fade transition
          return FadeTransition(opacity: animation, child: child);
        },
        opaque: true,
        barrierColor: Colors.black, // para solid black yung transition
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoHeight = size.height * 0.22;
    final playSize = size.width * 0.33;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Quit"),
            content: const Text("Do you want to exit the game?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Exit"),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/games/sign_quest/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/games/sign_quest/images/logo.png',
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Play button
                  PlayButton(
                    size: playSize,
                    onPressed: () => _navigateToLevelScreen(context),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
