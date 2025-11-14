import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/game.dart';
import 'countdown_overlay.dart';
import '../match_a_pair_game.dart';
import '../components/card_component.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with WidgetsBindingObserver {
  late MatchAPairGame game;
  bool _showCountdown = true;
  bool _isRestarting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    game = MatchAPairGame(
      onQuitToMenu: () {
        Navigator.pushReplacementNamed(context, '/');
      },
      onCardsRegenerated: _onCardsRegenerated,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is in background
      game.stopBgm(); // <-- Use stop instead of pause
      game.pauseEngine();
      if (!game.overlays.isActive(MatchAPairGame.pauseMenuOverlay)) {
        game.overlays.add(MatchAPairGame.pauseMenuOverlay);
      }
    } else if (state == AppLifecycleState.resumed) {
      // App is back to foreground
      game.playBgm(); // <-- Start BGM again
      game.resumeEngine();
      game.overlays.remove(MatchAPairGame.pauseMenuOverlay);
    }
  }

  void _onCountdownFinish() {
    setState(() {
      _showCountdown = false;
      game.spawnCards();
      // Wait a short moment to ensure cards are rendered
      Future.delayed(const Duration(milliseconds: 100), () {
        // Show all cards face up
        for (final card in game.children.whereType<CardComponent>()) {
          card.showFront();
        }
        // After preview, flip all cards back
        Future.delayed(const Duration(milliseconds: 1500), () {
          for (final card in game.children.whereType<CardComponent>()) {
            card.showBack();
          }
        });
      });
      game.startGame();
      game.playBgm();
    });
  }

  void _onCardsRegenerated() {
    if (_isRestarting) {
      setState(() {
        _showCountdown = true;
      });
      _isRestarting = false;
    } else {
      // Show preview after regeneration
      Future.delayed(const Duration(milliseconds: 100), () {
        for (final card in game.children.whereType<CardComponent>()) {
          card.showFront();
        }
        Future.delayed(const Duration(milliseconds: 1500), () {
          for (final card in game.children.whereType<CardComponent>()) {
            card.showBack();
          }
        });
      });
    }
  }

  void restartGame() {
    _isRestarting = true;
    game.score = 0;
    game.stopBgm();
    game.spawnCards();
    game.startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              MatchAPairGame.pauseMenuOverlay: (context, game) => PauseMenu(
                game: game as MatchAPairGame,
                onRestart: restartGame,
              ),
              'ScoreOverlay': (context, game) =>
                  ScoreOverlay(game: game as MatchAPairGame),
              'ComboOverlay': (context, game) =>
                  ComboOverlay(game: game as MatchAPairGame),
            },
          ),
          if (_showCountdown) CountdownOverlay(onFinish: _onCountdownFinish),
        ],
      ),
    );
  }
}

class ScoreOverlay extends StatelessWidget {
  final MatchAPairGame game;
  const ScoreOverlay({required this.game, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scoreWidth = screenWidth * 0.75;
    final pauseWidth = screenWidth * 0.25;

    final isPauseMenuActive = game.overlays.isActive(
      MatchAPairGame.pauseMenuOverlay,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        children: [
          // Score image and score text (70%)
          SizedBox(
            width: scoreWidth,
            height: 180, // Adjust as needed
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/casual_games/match_a_pair/images/score.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Align(
                  alignment: const Alignment(0.5, 0), // Center of right half
                  child: ValueListenableBuilder<int>(
                    valueListenable: game.scoreNotifier,
                    builder: (context, score, _) {
                      return Text(
                        '$score',
                        style: const TextStyle(
                          fontFamily: 'DynaPuff',
                          fontSize: 36,
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Pause button (30%)
          SizedBox(
            width: pauseWidth,
            height: 80,
            child: Center(
              child: isPauseMenuActive
                  ? const SizedBox(
                      width: 56,
                      height: 56,
                    ) // Hide or disable button
                  : GestureDetector(
                      onTap: () {
                        FlameAudio.audioCache.clear('CLICK.wav');
                        FlameAudio.play('CLICK.wav', volume: 1.0);
                        game.pauseGame();
                      },
                      child: Image.asset(
                        'assets/casual_games/match_a_pair/images/pause_button.png',
                        width: 56,
                        height: 56,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class PauseMenu extends StatelessWidget {
  final MatchAPairGame game;
  final VoidCallback onRestart;

  const PauseMenu({required this.game, required this.onRestart, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/casual_games/match_a_pair/images/board.png',
            ),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _PauseMenuButton(
                text: 'Continue',
                onPressed: () {
                  FlameAudio.audioCache.clear('CLICK.wav');
                  FlameAudio.play('CLICK.wav', volume: 1.0);
                  game.resumeGame();
                },
              ),
              const SizedBox(height: 16),
              _PauseMenuButton(
                text: 'Restart',
                onPressed: () {
                  FlameAudio.audioCache.clear('CLICK.wav');
                  FlameAudio.play('CLICK.wav', volume: 1.0);
                  game.resumeGame();
                  onRestart(); // Use the callback to trigger countdown
                },
              ),
              const SizedBox(height: 16),
              _PauseMenuButton(
                text: 'Main Menu',
                onPressed: () {
                  FlameAudio.audioCache.clear('CLICK.wav');
                  FlameAudio.play('CLICK.wav', volume: 1.0);
                  game.quitToMenu();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseMenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _PauseMenuButton({
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

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

class ComboOverlay extends StatefulWidget {
  final MatchAPairGame game;
  const ComboOverlay({required this.game, Key? key}) : super(key: key);

  @override
  State<ComboOverlay> createState() => _ComboOverlayState();
}

class _ComboOverlayState extends State<ComboOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  int _lastCombo = 0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    widget.game.comboNotifier.addListener(_onComboChanged);
  }

  void _onComboChanged() {
    if (widget.game.comboNotifier.value >= 2) {
      setState(() {
        _lastCombo = widget.game.comboNotifier.value > 6
            ? 6
            : widget.game.comboNotifier.value;
      });
      _controller.forward(from: 0);

      // Hide the combo overlay after 1.5 seconds (adjust duration here)
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(milliseconds: 1500), () {
        setState(() {
          _lastCombo = 0;
        });
      });
    } else {
      setState(() {
        _lastCombo = 0;
      });
    }
  }

  @override
  void dispose() {
    widget.game.comboNotifier.removeListener(_onComboChanged);
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastCombo < 2) return const SizedBox.shrink();
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/casual_games/match_a_pair/images/combos/combo_${_lastCombo > 6 ? 6 : _lastCombo}.png',
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
