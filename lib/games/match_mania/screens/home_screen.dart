import 'package:flutter/material.dart';
import 'game_selection_screen.dart';
import '../overlay/how_to_play_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.75,
                  ),
                  const SizedBox(height: 120),
                  menuButton('assets/images/start.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameSelectionScreen(),
                      ),
                    );
                  }, width: 280),
                  const SizedBox(height: 15),
                  // 👇 When tapped, show overlay instead of navigating
                  menuButton(
                    'assets/images/htp.png',
                    _toggleHowToPlay,
                    width: 280,
                  ),
                  const SizedBox(height: 15),
                  menuButton('assets/images/quit.png', () {
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
    );
  }
}
