import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/game_menu.dart';

class CastSpellRoot extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const CastSpellRoot({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<CastSpellRoot> createState() => _CastSpellRootState();
}

class _CastSpellRootState extends State<CastSpellRoot>
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
        AssetSource('games/cast_spell/music/bgm.mp3'),
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
      isMuted: isMuted,
      onToggleMute: _toggleMute,
      lessonId: widget.lessonId,
      studentId: widget.studentId,
      gameId: widget.gameId,
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

  Future<bool> _onWillPop() async {
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
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/games/cast_spell/images/bg.png',
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
                        'assets/games/cast_spell/images/logo.png',
                        width: size.width * 0.7,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 36),
                      _woodButton(
                        assetPath: 'assets/games/cast_spell/images/start.png',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameMenuScreen(
                              lessonId: widget.lessonId,
                              studentId: widget.studentId,
                              gameId: widget.gameId,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _woodButton(
                        assetPath: 'assets/games/cast_spell/images/htp.png',
                        onTap: () {
                          setState(() => showHowToPlay = true);
                          _popupAnimController.forward(from: 0);
                        },
                      ),
                      const SizedBox(height: 18),
                      _woodButton(
                        assetPath: 'assets/games/cast_spell/images/quit.png',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Quit"),
                              content: const Text(
                                "Do you want to exit the app?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                        '/home',
                                        (route) => false,
                                      ),
                                  child: const Text("Exit"),
                                ),
                              ],
                            ),
                          );
                        },
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
                          'assets/games/cast_spell/images/how.png',
                          width: 330,
                          fit: BoxFit.contain,
                        ),
                        GestureDetector(
                          onTap: () => setState(() => showHowToPlay = false),
                          child: Image.asset(
                            'assets/games/cast_spell/images/close.png',
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
