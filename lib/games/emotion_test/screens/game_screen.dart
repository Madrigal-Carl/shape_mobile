import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';

class GameScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const GameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final Random random = Random();
  late ConfettiController _confettiController;

  // Image animations
  late AnimationController _imageIdleScaleController;
  late Animation<double> _imageIdleScaleAnim;

  late AnimationController _imageBounceController;
  late Animation<double> _imageBounceAnim;

  late AnimationController _imageShakeController;
  late Animation<double>
  _imageShakeAnim; // value 0..1 used to compute tilt/offset

  // Choice shake controllers (one per choice key)
  final Map<String, AnimationController> _choiceShakeControllers = {};
  final List<String> allChoices = [
    "angry",
    "sad",
    "happy",
    "disgust",
    "scared",
  ];

  // Menu animations
  late AnimationController _menuAnimController;
  late Animation<double> _menuScaleAnim;

  bool showMenuPopup = false;
  bool showHowToPlay = false;
  bool showOverlay = false;

  int score = 0;
  int currentRound = 0;
  List<String> emotions = ["joy", "anger", "sadness", "disgusted", "fear"];
  Map<String, String> emotionMap = {
    "joy": "happy",
    "anger": "angry",
    "sadness": "sad",
    "disgusted": "disgust",
    "fear": "scared",
  };

  late List<String> rounds;
  String? currentEmotion;

  @override
  void initState() {
    super.initState();

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    // Menu popup
    _menuAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuScaleAnim = CurvedAnimation(
      parent: _menuAnimController,
      curve: Curves.easeOutBack,
    );

    // Image idle scale (gentle breathing)
    _imageIdleScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _imageIdleScaleAnim = Tween<double>(begin: 0.96, end: 1.02).animate(
      CurvedAnimation(
        parent: _imageIdleScaleController,
        curve: Curves.easeInOut,
      ),
    );

    // Image bounce for correct answer (quick pop)
    _imageBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _imageBounceAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_imageBounceController);

    // Image shake for wrong answer
    _imageShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _imageShakeAnim = CurvedAnimation(
      parent: _imageShakeController,
      curve: Curves.elasticIn,
    );

    // Choice shake controllers
    for (var choice in allChoices) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      );
      _choiceShakeControllers[choice] = ctrl;
    }

    _generateRounds();
    _loadNextEmotion();
  }

  void _generateRounds() {
    rounds = List.from(emotions)..shuffle();
  }

  void _loadNextEmotion() {
    if (currentRound >= rounds.length) {
      GameProgressPreference.saveProgress(
        studentId: widget.studentId,
        lessonId: widget.lessonId,
        gameId: widget.gameId,
        subgameName: 'emotion_test',
      );
      setState(() => showOverlay = true);
      return;
    }
    setState(() {
      currentEmotion = rounds[currentRound];
    });

    // Ensure visual state is neutral
    _imageBounceController.reset();
    _imageShakeController.reset();
  }

  void _checkAnswer(String choice) {
    if (currentEmotion == null) return;
    String correct = emotionMap[currentEmotion]!;

    if (choice == correct) {
      // correct
      setState(() {
        score += 10;
      });
      _confettiController.play();

      // bounce image
      _imageBounceController.forward(from: 0);

      // Advance to next round after bounce finishes
      Future.delayed(const Duration(milliseconds: 480), () {
        setState(() {
          currentRound++;
        });
        _loadNextEmotion();
      });
    } else {
      // wrong - penalize and play wrong animations
      setState(() {
        score = (score - 5).clamp(0, 999);
      });

      // Play the chosen button's shake animation
      final ctrl = _choiceShakeControllers[choice];
      ctrl?.forward(from: 0);

      // Play the image shake animation
      _imageShakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _menuAnimController.dispose();
    _imageIdleScaleController.dispose();
    _imageBounceController.dispose();
    _imageShakeController.dispose();
    for (var c in _choiceShakeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // Helper to compute a horizontal shake offset (px) from an animation value
  double _shakeOffset(
    double progress, {
    double magnitude = 10.0,
    int shakes = 4,
  }) {
    // progress goes 0..1; produce sin-based wiggle that eases out
    if (progress <= 0) return 0.0;
    final ease = (1 - progress); // decaying amplitude
    final value = sin(progress * shakes * pi * 2); // wiggles
    return value * magnitude * ease;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showMenuPopup) {
          setState(() => showMenuPopup = false);
        } else if (showHowToPlay) {
          setState(() => showHowToPlay = false);
        } else if (showOverlay) {
          return false;
        } else {
          setState(() => showMenuPopup = true);
          _menuAnimController.forward(from: 0);
        }
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/games/emotion_test/images/bg2.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Score and menu
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 40,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Image.asset(
                                "assets/games/emotion_test/images/scoreplaceholder.png",
                                height: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 28),
                                child: Text(
                                  "Score: $score",
                                  style: GoogleFonts.dynaPuff(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => showMenuPopup = true);
                              _menuAnimController.forward(from: 0);
                            },
                            child: Image.asset(
                              "assets/games/emotion_test/images/menu.png",
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title
                    Text(
                      "Emotion Check",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tap to tell what emotion it shows!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Emotion image (with layered animations)
                    if (currentEmotion != null)
                      Expanded(
                        flex: 1,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _imageIdleScaleController,
                            _imageBounceController,
                            _imageShakeController,
                          ]),
                          builder: (context, child) {
                            // compute combined scale: idle * bounce (bounce default 1)
                            final idleScale = _imageIdleScaleAnim.value;
                            final bounceScale =
                                (_imageBounceController.isAnimating ||
                                    _imageBounceController.value > 0)
                                ? _imageBounceAnim.value
                                : 1.0;
                            final scale = idleScale * bounceScale;

                            // compute shake offsets and tilt from _imageShakeAnim.value
                            final shakeProgress = _imageShakeAnim.value;
                            final dx = _shakeOffset(
                              shakeProgress,
                              magnitude: 10.0,
                              shakes: 5,
                            );
                            final tilt =
                                sin(shakeProgress * pi * 6) *
                                0.06; // small rotation in radians
                            final dy =
                                sin(shakeProgress * pi * 4) *
                                6.0 *
                                (1 - shakeProgress);

                            return Transform.translate(
                              offset: Offset(dx, dy),
                              child: Transform.rotate(
                                angle: tilt,
                                child: Transform.scale(
                                  scale: scale,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Image.asset(
                              "assets/games/emotion_test/images/$currentEmotion.png",
                              fit: BoxFit.contain,
                              height: 220,
                            ),
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(height: 20),

                    // Choices
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEmotionChoice("angry", "Angry"),
                              const SizedBox(width: 25),
                              _buildEmotionChoice("sad", "Sad"),
                              const SizedBox(width: 25),
                              _buildEmotionChoice("happy", "Happy"),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEmotionChoice("disgust", "Disgust"),
                              const SizedBox(width: 25),
                              _buildEmotionChoice("scared", "Scared"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 25,
                gravity: 0.4,
              ),
            ),

            // Popups & overlays
            if (showMenuPopup) _buildMenuPopup(),
            if (showHowToPlay) _buildHowToPlayPopup(),
            if (showOverlay) _buildEndOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionChoice(String emotion, String label) {
    final ctrl = _choiceShakeControllers[emotion]!;

    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, child) {
        final progress = ctrl.value; // 0..1
        final offsetX = _shakeOffset(progress, magnitude: 12.0, shakes: 4);
        final tilt = sin(progress * pi * 6) * 0.04; // radians
        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: Transform.rotate(angle: tilt, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _checkAnswer(emotion),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // if an image is missing, consider adding fallback
            Image.asset(
              "assets/games/emotion_test/images/$emotion.png",
              height: 60,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.dynaPuff(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuPopup() => AnimatedOpacity(
    opacity: 1,
    duration: const Duration(milliseconds: 300),
    child: Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: ScaleTransition(
          scale: _menuScaleAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => setState(() => showMenuPopup = false),
                child: Image.asset(
                  "assets/games/emotion_test/images/continue.png",
                  height: 70,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showMenuPopup = false;
                    showHowToPlay = true;
                  });
                },
                child: Image.asset(
                  "assets/games/emotion_test/images/htp.png",
                  height: 70,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "assets/games/emotion_test/images/quit.png",
                  height: 70,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildHowToPlayPopup() => AnimatedOpacity(
    opacity: 1,
    duration: const Duration(milliseconds: 300),
    child: Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: Image.asset(
                "assets/games/emotion_test/images/how.png",
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: MediaQuery.of(context).size.width * 0.15,
              top: MediaQuery.of(context).size.height * 0.36,
              child: GestureDetector(
                onTap: () => setState(() => showHowToPlay = false),
                child: Image.asset(
                  "assets/games/emotion_test/images/close.png",
                  height: 45,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildEndOverlay() => AnimatedOpacity(
    opacity: 1,
    duration: const Duration(milliseconds: 300),
    child: Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/games/emotion_test/images/complete.png",
              height: 300,
              width: 350,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 205),
                Text(
                  "Score: $score",
                  style: GoogleFonts.dynaPuff(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        "assets/games/emotion_test/images/home.png",
                        height: 60,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          score = 0;
                          currentRound = 0;
                          showOverlay = false;
                          _generateRounds();
                          _loadNextEmotion();
                        });
                      },
                      child: Image.asset(
                        "assets/games/emotion_test/images/restart.png",
                        height: 60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
