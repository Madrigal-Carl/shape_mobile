// lib/games/count_quest/main.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/home_screen.dart';

class CountQuestRoot extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const CountQuestRoot({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<CountQuestRoot> createState() => _CountQuestRootState();
}

class _CountQuestRootState extends State<CountQuestRoot>
    with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _initMusic();
  }

  Future<void> _initMusic() async {
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('games/count_quest/music/bgm.mp3'));
    } catch (e) {
      print('❌ Error playing background music: $e');
    }
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
    return HomeScreen(
      // lessonId: widget.lessonId,
      // studentId: widget.studentId,
      // gameId: widget.gameId,
    );
  }
}
