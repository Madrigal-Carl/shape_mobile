import 'package:flutter/material.dart';
import 'game_selection_screen.dart';
import '../overlay/how_to_play_overlay.dart';

class HomeScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const HomeScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showHowToPlay = false;

  void _toggleHowToPlay() {
    setState(() {
      _showHowToPlay = !_showHowToPlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget menuButton(
      String assetPath,
      VoidCallback onTap, {
      double width = 260,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Image.asset(assetPath, width: width, fit: BoxFit.contain),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldQuit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Quit'),
            content: const Text('Are you sure you want to quit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return shouldQuit ?? false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 🌄 Background
            Positioned.fill(
              child: Image.asset(
                'assets/games/match_mania/images/bg.png',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/games/match_mania/images/logo.png',
                      width: MediaQuery.of(context).size.width * 0.75,
                    ),
                    const SizedBox(height: 120),
                    menuButton('assets/games/match_mania/images/start.png', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameSelectionScreen(
                            lessonId: widget.lessonId,
                            studentId: widget.studentId,
                            gameId: widget.gameId,
                          ),
                        ),
                      );
                    }, width: 280),
                    const SizedBox(height: 15),
                    // 👇 When tapped, show overlay instead of navigating
                    menuButton(
                      'assets/games/match_mania/images/htp.png',
                      _toggleHowToPlay,
                      width: 280,
                    ),
                    const SizedBox(height: 15),
                    menuButton('assets/games/match_mania/images/quit.png', () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Quit'),
                          content: const Text('Are you sure you want to quit?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Navigator.of(context).maybePop();
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    }, width: 260),
                  ],
                ),
              ),
            ),

            // 🪟 Overlay shown when _showHowToPlay = true
            if (_showHowToPlay) HowToPlayOverlay(onClose: _toggleHowToPlay),
          ],
        ),
      ),
    );
  }
}
