import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/game_screen.dart';

class FruitSubtractionRoot extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const FruitSubtractionRoot({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<FruitSubtractionRoot> createState() => _FruitSubtractionRootState();
}

class _FruitSubtractionRootState extends State<FruitSubtractionRoot>
    with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _initMusic();
  }

  Future<void> _initMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(
        AssetSource('games/fruit_subtraction/music/bgm.mp3'),
      );
      print('🎵 Fruit Subtraction music started');
    } catch (e) {
      print('❌ Error playing music: $e');
    }
  }

  void _toggleMute() async {
    setState(() => isMuted = !isMuted);
    await _audioPlayer.setVolume(isMuted ? 0.0 : 1.0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
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
    return _MainMenuScreen(
      lessonId: widget.lessonId,
      studentId: widget.studentId,
      gameId: widget.gameId,
      isMuted: isMuted,
      onToggleMute: _toggleMute,
    );
  }
}

class _MainMenuScreen extends StatefulWidget {
  final bool isMuted;
  final VoidCallback onToggleMute;
  final int lessonId;
  final int studentId;
  final int gameId;

  const _MainMenuScreen({
    required this.isMuted,
    required this.onToggleMute,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<_MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<_MainMenuScreen>
    with SingleTickerProviderStateMixin {
  bool showHowToPlay = false;
  late AnimationController _popupAnimController;
  late Animation<double> _popupScaleAnim;

  @override
  void initState() {
    super.initState();
    _popupAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _popupScaleAnim = CurvedAnimation(
      parent: _popupAnimController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _popupAnimController.dispose();
    super.dispose();
  }

  Widget _woodButton({
    required String assetPath,
    required VoidCallback onTap,
    double width = 280,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = size.width * 0.6;

    return WillPopScope(
      onWillPop: () async {
        _confirmExit(context);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            /// 🌄 Background
            Positioned.fill(
              child: Image.asset(
                'assets/games/fruit_subtraction/images/bg.png',
                fit: BoxFit.cover,
              ),
            ),

            /// 📋 Menu
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        'assets/games/fruit_subtraction/images/logo.png',
                        width: size.width * 0.7,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 36),

                      _woodButton(
                        assetPath:
                            'assets/games/fruit_subtraction/images/start.png',
                        width: buttonWidth,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(
                                lessonId: widget.lessonId,
                                studentId: widget.studentId,
                                gameId: widget.gameId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),

                      _woodButton(
                        assetPath:
                            'assets/games/fruit_subtraction/images/htp.png',
                        width: buttonWidth,
                        onTap: () {
                          setState(() => showHowToPlay = true);
                          _popupAnimController.forward(from: 0);
                        },
                      ),
                      const SizedBox(height: 18),

                      _woodButton(
                        assetPath:
                            'assets/games/fruit_subtraction/images/quit.png',
                        width: buttonWidth,
                        onTap: () => _confirmExit(context),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔇 Mute
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(
                  widget.isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: widget.onToggleMute,
              ),
            ),

            /// 🧠 HOW TO PLAY POPUP
            if (showHowToPlay)
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: ScaleTransition(
                      scale: _popupScaleAnim,
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.asset(
                            'assets/games/fruit_subtraction/images/how.png',
                            width: 330,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: 1,
                            right: 20,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => showHowToPlay = false),
                              child: Image.asset(
                                'assets/games/fruit_subtraction/images/x.png',
                                height: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit'),
        content: const Text('Do you want to exit the game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
