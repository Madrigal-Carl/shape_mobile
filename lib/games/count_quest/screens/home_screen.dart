import 'package:flutter/material.dart';
import 'level_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const HomeScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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

  void _exitGame(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit'),
        content: const Text('Are you sure you want to quit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        _exitGame(context);
        return false;
      },
      child: Scaffold(
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
                            builder: (context) => LevelSelectionScreen(
                              lessonId: lessonId,
                              studentId: studentId,
                              gameId: gameId,
                            ),
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
                      onTap: () => _exitGame(context),
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
      ),
    );
  }
}
