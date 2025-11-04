// lib/games/objectify/main.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'games/game_menu.dart';

class ObjectifyRoot extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const ObjectifyRoot({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<ObjectifyRoot> createState() => _ObjectifyRootState();
}

class _ObjectifyRootState extends State<ObjectifyRoot>
    with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;
  bool isMuted = false;
  bool showHowToPlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMusic();
  }

  Future<void> _initMusic() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setSource(AssetSource('games/objectify/music/bgm.mp3'));
    await _audioPlayer.resume();
  }

  void _toggleMute() async {
    setState(() => isMuted = !isMuted);
    await _audioPlayer.setVolume(isMuted ? 0.0 : 1.0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed && !isMuted) {
      _audioPlayer.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
        if (shouldExit == true) Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 🎨 Background
            Positioned.fill(
              child: Image.asset(
                'assets/games/objectify/images/bg.png',
                fit: BoxFit.cover,
              ),
            ),

            // 🎮 Main Menu UI
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        'assets/games/objectify/images/logo.png',
                        width: size.width * 0.7,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 36),

                      _menuButton(
                        assetPath: 'assets/games/objectify/images/start.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameMenuScreen(
                                lessonId: widget.lessonId,
                                studentId: widget.studentId,
                                gameId: widget.gameId,
                              ),
                            ),
                          );
                        },
                        size: size,
                      ),
                      const SizedBox(height: 18),

                      _menuButton(
                        assetPath: 'assets/games/objectify/images/htp.png',
                        onTap: () => setState(() => showHowToPlay = true),
                        size: size,
                      ),
                      const SizedBox(height: 18),

                      _menuButton(
                        assetPath: 'assets/games/objectify/images/quit.png',
                        onTap: () async {
                          final shouldExit = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Quit"),
                              content: const Text(
                                "Do you want to exit the app?",
                              ),
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
                          if (shouldExit == true) Navigator.pop(context);
                        },
                        size: size,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // 🔊 Mute / Unmute Button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: _toggleMute,
              ),
            ),

            // 🪟 How To Play Popup
            if (showHowToPlay)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.asset(
                        'assets/games/objectify/images/how.png',
                        width: 330,
                        fit: BoxFit.contain,
                      ),
                      GestureDetector(
                        onTap: () => setState(() => showHowToPlay = false),
                        child: Image.asset(
                          'assets/games/objectify/images/x.png',
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required String assetPath,
    required VoidCallback onTap,
    required Size size,
  }) {
    return SizedBox(
      width: size.width * 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
