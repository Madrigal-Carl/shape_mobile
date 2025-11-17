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
  State<CountQuestRoot> createState() => CountQuestRootState(); // ✅ FIXED
}

class CountQuestRootState extends State<CountQuestRoot>
    with WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;
  bool isMuted = false;

  AudioPlayer get bgmPlayer => _audioPlayer;
  bool get muteState => isMuted;

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

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });

    _audioPlayer.setVolume(isMuted ? 0 : 1);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (!isMuted) _audioPlayer.resume();
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
      lessonId: widget.lessonId,
      studentId: widget.studentId,
      gameId: widget.gameId,
      rootState: this, // 🔥 pass root state
    );
  }
}
