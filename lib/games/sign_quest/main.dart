import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/game_screen.dart';

class SignQuestRoot extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const SignQuestRoot({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<SignQuestRoot> createState() => _SignQuestRootState();
}

class _SignQuestRootState extends State<SignQuestRoot>
    with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _initBgm();
  }

  Future<void> _initBgm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setSource(
        AssetSource('games/sign_quest/music/bgm.mp3'),
      ); // 🎵 your file path
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.resume();
      debugPrint('✅ BGM is playing...');
    } catch (e) {
      debugPrint('❌ Error playing BGM: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 🔄 Handle pause/resume when app goes background/foreground
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
    return GameScreen(
      lessonId: widget.lessonId,
      studentId: widget.studentId,
      gameId: widget.gameId,
    );
  }
}
