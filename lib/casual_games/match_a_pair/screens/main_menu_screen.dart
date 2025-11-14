import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_audio/bgm.dart';
import 'gameplay_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _bgmStarted = false;

  late final AudioCache _audioCache;
  late final Bgm _myBgm;

  @override
  void initState() {
    super.initState();

    // 🔥 Use your custom folder
    _audioCache = AudioCache(prefix: 'assets/casual_games/match_a_pair/audio/');

    // 🔥 Create your custom BGM instance
    _myBgm = Bgm(audioCache: _audioCache);
    _myBgm.initialize();

    // Optional: Make FlameAudio.play() use your path too
    FlameAudio.audioCache = _audioCache;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bgmStarted) {
      _bgmStarted = true;
      _myBgm.stop();
      _myBgm.play('BGM.mp3', volume: 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/casual_games/match_a_pair/images/background.png',
            fit: BoxFit.cover,
          ),
          // Main menu content
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Image.asset(
                  'assets/casual_games/match_a_pair/images/title.png',
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              MenuButton(
                text: 'Start',
                onPressed: () {
                  // FlameAudio.bgm.stop();
                  FlameAudio.audioCache.clear('CLICK.wav');
                  FlameAudio.play('CLICK.wav', volume: 1.0);
                  FlameAudio.bgm.stop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GameplayScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              MenuButton(
                text: 'How to Play',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('How to Play'),
                      content: const Text(
                        'Find all matching pairs. Tap two cards to flip them. Match shapes to score!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            FlameAudio.audioCache.clear('CLICK.wav');
                            FlameAudio.play('CLICK.wav', volume: 1.0);
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              MenuButton(
                text: 'Quit',
                onPressed: () {
                  FlameAudio.audioCache.clear('CLICK.wav');
                  FlameAudio.play('CLICK.wav', volume: 1.0);
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const MenuButton({required this.text, required this.onPressed, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 220,
        height: 56,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/casual_games/match_a_pair/images/button.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'DynaPuff',
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black54,
                offset: Offset(1, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
