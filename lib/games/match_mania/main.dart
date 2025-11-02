// lib/games/match_mania/main.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/home_screen.dart';

class MatchManiaRoot extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const MatchManiaRoot({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<MatchManiaRoot> createState() => _MatchManiaRootState();
}

class _MatchManiaRootState extends State<MatchManiaRoot>
    with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMusic();
  }

  Future<void> _initMusic() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('games/match_mania/music/bgm.mp3'));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return HomeScreen(
      lessonId: widget.lessonId,
      studentId: widget.studentId,
      gameId: widget.gameId,
    );
  }
}
