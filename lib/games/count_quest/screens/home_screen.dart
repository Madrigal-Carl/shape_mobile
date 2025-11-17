import 'package:flutter/material.dart';
import '../main.dart'; // <-- IMPORTANT para makuha type ng CountQuestRootState
import 'level_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  final CountQuestRootState rootState; // <-- 🔥 get root controller

  const HomeScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
    required this.rootState,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _toggleSound() {
    widget.rootState.toggleMute(); // 🔥 control BGM
    setState(() {}); // refresh icon
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/games/count_quest/images/how.png'),
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
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
    final muted = widget.rootState.muteState; // <-- get state

    return WillPopScope(
      onWillPop: () async {
        _exitGame(context);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/games/count_quest/images/bg1.png',
                fit: BoxFit.cover,
              ),
            ),

            /// 🔊 SPEAKER BUTTON
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 15),
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(
                      muted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSound,
                  ),
                ),
              ),
            ),

            /// MAIN CONTENT
            SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 70),

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
                            builder: (_) => LevelSelectionScreen(
                              lessonId: widget.lessonId,
                              studentId: widget.studentId,
                              gameId: widget.gameId,
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

                    GestureDetector(
                      onTap: () => _showHowToPlay(context),
                      child: Image.asset(
                        'assets/games/count_quest/images/htp.png',
                        width: size.width * 0.6,
                      ),
                    ),

                    const SizedBox(height: 15),

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
