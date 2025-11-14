import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';

class BalloonPopRoot extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const BalloonPopRoot({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<BalloonPopRoot> createState() => _BalloonPopRootState();
}

class _BalloonPopRootState extends State<BalloonPopRoot>
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
      await _audioPlayer.setSource(
        AssetSource('games/balloon_pop/music/bgm.mp3'),
      );
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.resume();
      print('✅ Background music playing...');
    } catch (e) {
      print('❌ Error playing background music: $e');
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
    return _BalloonPopMainMenu(
      lessonId: widget.lessonId,
      studentId: widget.studentId,
      gameId: widget.gameId,
      isMuted: isMuted,
      onToggleMute: _toggleMute,
    );
  }
}

class _BalloonPopMainMenu extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;
  final bool isMuted;
  final VoidCallback onToggleMute;

  const _BalloonPopMainMenu({
    required this.lessonId,
    required this.studentId,
    required this.gameId,
    required this.isMuted,
    required this.onToggleMute,
  });

  @override
  State<_BalloonPopMainMenu> createState() => _BalloonPopMainMenuState();
}

class _BalloonPopMainMenuState extends State<_BalloonPopMainMenu>
    with TickerProviderStateMixin {
  bool showHowToPlay = false;
  late AnimationController _popupAnimController;
  late Animation<double> _popupScaleAnim;

  late AnimationController _logoController;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFloatAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // 🎞️ Popup animation
    _popupAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _popupScaleAnim = CurvedAnimation(
      parent: _popupAnimController,
      curve: Curves.easeOutBack,
    );

    // 🎬 Logo animation controller (looping bounce)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // 🔄 Logo scaling animation
    _logoScaleAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_logoController);

    // ⬆️⬇️ Floating effect (moves up and down)
    _logoFloatAnim = Tween<double>(
      begin: -10,
      end: 10,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_logoController);
  }

  @override
  void dispose() {
    _popupAnimController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Widget _woodButton({
    required String assetPath,
    required VoidCallback onTap,
    double width = 220,
  }) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.error, size: 40, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Quit"),
        content: const Text("Do you want to exit the game?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _resetPortraitOrientation();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            child: const Text("Exit"),
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
            /// 🌄 Background
            Positioned.fill(
              child: Image.asset(
                'assets/games/balloon_pop/images/bg.png',
                fit: BoxFit.cover,
              ),
            ),

            /// 🎈 Animated "Nagalaw" Logo
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _logoFloatAnim.value),
                  child: Transform.scale(
                    scale: _logoScaleAnim.value,
                    child: child,
                  ),
                );
              },
              child: Align(
                alignment: const Alignment(0, -0.75),
                child: Image.asset(
                  'assets/games/balloon_pop/images/logo.png',
                  width: size.width * 0.35,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 100),
                ),
              ),
            ),

            /// 🪵 Bottom Buttons
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _woodButton(
                      assetPath: 'assets/games/balloon_pop/images/htp.png',
                      onTap: () {
                        setState(() => showHowToPlay = true);
                        _popupAnimController.forward(from: 0);
                      },
                    ),
                    const SizedBox(width: 40),
                    _woodButton(
                      assetPath: 'assets/games/balloon_pop/images/start.png',
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
                    const SizedBox(width: 40),
                    _woodButton(
                      assetPath: 'assets/games/balloon_pop/images/quit.png',
                      onTap: () => _confirmExit(context),
                    ),
                  ],
                ),
              ),
            ),

            /// 🔇 Mute Button (top-right)
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Icon(
                  widget.isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: widget.onToggleMute,
              ),
            ),

            /// 🧠 How To Play Popup
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
                            'assets/games/balloon_pop/images/how.png',
                            width: 300,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: 10,
                            right: 20,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => showHowToPlay = false);
                              },
                              child: Image.asset(
                                'assets/games/balloon_pop/images/close.png',
                                height: 50,
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
}
