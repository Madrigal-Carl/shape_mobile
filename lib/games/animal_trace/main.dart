import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';

class AnimalTraceRoot extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const AnimalTraceRoot({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<AnimalTraceRoot> createState() => _AnimalTraceRootState();
}

class _AnimalTraceRootState extends State<AnimalTraceRoot>
    with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _audioPlayer = AudioPlayer();
    _initializeBackgroundMusic();
  }

  Future<void> _initializeBackgroundMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setSource(
        AssetSource('games/animal_trace/music/bgm.mp3'),
      );
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.resume();
      debugPrint("✅ Background Music Playing");
    } catch (e) {
      debugPrint("❌ Error initializing music: $e");
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

  @override
  void initState() {
    super.initState();
    _popupAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _popupAnimController.dispose();
    super.dispose();
  }

  Widget _woodButton({required String assetPath, required VoidCallback onTap}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Image.asset(assetPath, fit: BoxFit.contain),
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
              Navigator.of(ctx).pop();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        _confirmExit(context);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/games/animal_trace/images/bg.png',
                fit: BoxFit.cover,
              ),
            ),

            /// Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        'assets/games/animal_trace/images/logo.png',
                        width: size.width * 0.7,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 36),
                      _woodButton(
                        assetPath: 'assets/games/animal_trace/images/start.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TracingGameScreen(
                                isMuted: widget.isMuted,
                                onToggleMute: widget.onToggleMute,
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
                        assetPath: 'assets/games/animal_trace/images/htp.png',
                        onTap: () {
                          setState(() => showHowToPlay = true);
                          _popupAnimController.forward(from: 0);
                        },
                      ),
                      const SizedBox(height: 18),
                      _woodButton(
                        assetPath: 'assets/games/animal_trace/images/quit.png',
                        onTap: () => _confirmExit(context),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            /// Sound Toggle Button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(
                  widget.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: widget.onToggleMute,
              ),
            ),

            /// HOW TO PLAY POPUP
            if (showHowToPlay)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _popupAnimController,
                      curve: Curves.easeOutBack,
                    ),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.asset(
                          'assets/games/animal_trace/images/how.png',
                          width: 330,
                          fit: BoxFit.contain,
                        ),
                        GestureDetector(
                          onTap: () => setState(() => showHowToPlay = false),
                          child: Image.asset(
                            'assets/games/animal_trace/images/x.png',
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
