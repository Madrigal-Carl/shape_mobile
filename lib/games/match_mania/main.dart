import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MatchManiaApp());
}

class MatchManiaApp extends StatefulWidget {
  const MatchManiaApp({super.key});

  @override
  State<MatchManiaApp> createState() => _MatchManiaAppState();
}

class _MatchManiaAppState extends State<MatchManiaApp>
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

    try {
      // set comfortable volume
      await _audioPlayer.setVolume(0.4);

      // ensure it loops properly
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      print('🎵 Attempting to play background music...');
      await _audioPlayer.play(AssetSource('music/bgm.mp3'));

      // fallback: ensure it restarts if somehow stops
      _audioPlayer.onPlayerComplete.listen((_) async {
        print('🔁 Music ended, restarting...');
        await _audioPlayer.play(AssetSource('music/bgm.mp3'));
      });

      print('✅ Music started successfully!');
    } catch (e) {
      print('❌ Error playing background music: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // pause when app is minimized, resume when reopened
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match Mania',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Default'),
      routes: {
        '/': (context) => const HomeScreen(),
        '/game': (context) => const GameScreenPlaceholder(),
      },
      initialRoute: '/',
    );
  }
}

// class HowToPlayScreenPlaceholder extends StatelessWidget {
//   const HowToPlayScreenPlaceholder({super.key});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         body: const Center(
//           child: Text('How to Play screen (implement later)'),
//         ),
//       );
// }

class GameScreenPlaceholder extends StatelessWidget {
  const GameScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Game')),
    body: const Center(child: Text('Game screen (implement later)')),
  );
}
