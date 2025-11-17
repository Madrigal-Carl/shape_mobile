import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'thing_game.dart';
import 'game_menu.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';

class FruitGameScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const FruitGameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<FruitGameScreen> createState() => _FruitGameScreenState();
}

class _FruitGameScreenState extends State<FruitGameScreen>
    with SingleTickerProviderStateMixin {
  final List<String> allFruits = [
    'apple',
    'banana',
    'orange',
    'grapes',
    'watermelon',
    'strawberry',
    'pineapple',
    'cherry',
    'lemon',
  ];

  late List<String> unusedFruits;
  late String currentFruit;
  List<String> currentChoices = [];

  String? droppedFruit;
  int score = 0;

  bool showMenu = false;
  bool showHowToPlay = false;
  bool showWinPopup = false;
  bool dragDisabled = false;

  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 15,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    unusedFruits = List.from(allFruits);
    _generateNewFruit();
  }

  void _generateNewFruit() {
    if (unusedFruits.isEmpty) {
      GameProgressPreference.saveProgress(
        studentId: widget.studentId,
        lessonId: widget.lessonId,
        gameId: widget.gameId,
        subgameName: 'fruits_game',
      );
      setState(() => showWinPopup = true);
      return;
    }

    final random = Random();
    setState(() {
      currentFruit = unusedFruits[random.nextInt(unusedFruits.length)];
      unusedFruits.remove(currentFruit);

      droppedFruit = null;

      final temp = List<String>.from(allFruits)..remove(currentFruit);
      temp.shuffle();

      currentChoices = [...temp.take(5), currentFruit]..shuffle();
    });
  }

  Future<void> _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('games/objectify/music/correct.m4a'));
  }

  /// --------------------------------------------------------
  /// ✅ FIXED ANSWER CHECKING (drag works after mistake)
  /// --------------------------------------------------------
  void _checkAnswer(String selectedFruit) {
    if (dragDisabled) return;

    if (selectedFruit == currentFruit) {
      setState(() {
        droppedFruit = selectedFruit;
        score += 10;
      });

      dragDisabled = true;
      _confettiController.play();
      _playCorrectSound();

      Future.delayed(const Duration(seconds: 1), () {
        dragDisabled = false;
        _generateNewFruit();
      });
    } else {
      /// ❌ Wrong answer → shake + deduct score
      setState(() => score -= 5);

      dragDisabled = true;

      _shakeController.forward(from: 0).then((_) {
        /// ✨ FIX: enable dragging immediately after shake
        setState(() {
          dragDisabled = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (showHowToPlay) {
          setState(() => showHowToPlay = false);
          return false;
        }
        if (showWinPopup) return false;
        if (showMenu) {
          setState(() => showMenu = false);
          return false;
        }
        setState(() => showMenu = true);
        return false;
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/games/objectify/images/bg2.png',
                fit: BoxFit.cover,
              ),
            ),

            /// CONFETTI
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 25,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  /// SCORE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/games/objectify/images/scoreplaceholder.png',
                              width: 200,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 70),
                              child: Text(
                                "Score: $score",
                                style: GoogleFonts.dynaPuff(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => setState(() => showMenu = true),
                          child: Image.asset(
                            'assets/games/objectify/images/menu.png',
                            width: 55,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Fruit",
                    style: GoogleFonts.dynaPuff(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Identify the correct fruit by looking at the picture.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// FRUIT IMAGE
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutBack,
                    child: Image.asset(
                      'assets/games/objectify/images/$currentFruit.png',
                      key: ValueKey(currentFruit),
                      width: size.width * 0.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DRAG TARGET + SHAKE
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: DragTarget<String>(
                      onWillAccept: (data) => !dragDisabled && data != null,
                      onAccept: (data) => _checkAnswer(data),
                      builder: (_, __, ___) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/games/objectify/images/cotainer.png',
                              width: size.width * 0.6,
                            ),
                            if (droppedFruit != null)
                              Image.asset(
                                'assets/games/objectify/images/card_$droppedFruit.png',
                                width: 120,
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  /// CHOICE BUTTONS
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.99,
                          ),
                      itemCount: currentChoices.length,
                      itemBuilder: (_, index) {
                        final fruit = currentChoices[index];

                        return Draggable<String>(
                          data: dragDisabled ? null : fruit,
                          feedback: Image.asset(
                            'assets/games/objectify/images/card_$fruit.png',
                            width: 110,
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Image.asset(
                              'assets/games/objectify/images/card_$fruit.png',
                            ),
                          ),
                          child: Image.asset(
                            'assets/games/objectify/images/card_$fruit.png',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// MENU POPUP
            if (showMenu)
              _dim(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    menuBtn("continue.png", () {
                      setState(() => showMenu = false);
                    }),
                    const SizedBox(height: 15),
                    menuBtn("htp.png", () {
                      setState(() {
                        showMenu = false;
                        showHowToPlay = true;
                      });
                    }),
                    const SizedBox(height: 15),
                    menuBtn("quit.png", () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameMenuScreen(
                            lessonId: widget.lessonId,
                            studentId: widget.studentId,
                            gameId: widget.gameId,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            /// HOW TO PLAY
            if (showHowToPlay)
              _dim(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.asset(
                      'assets/games/objectify/images/how.png',
                      width: 330,
                    ),
                    Positioned(
                      top: 10,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => setState(() => showHowToPlay = false),
                        child: Image.asset(
                          'assets/games/objectify/images/x.png',
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// WIN POPUP
            if (showWinPopup)
              _dim(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/games/objectify/images/overlay.png",
                      width: 330,
                    ),

                    Positioned(
                      top: 96,
                      child: Text(
                        "Score: $score",
                        style: GoogleFonts.dynaPuff(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          popupIcon("home.png", () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameMenuScreen(
                                  lessonId: widget.lessonId,
                                  studentId: widget.studentId,
                                  gameId: widget.gameId,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 10),
                          popupIcon("restart.png", () {
                            setState(() {
                              score = 0;
                              unusedFruits = List.from(allFruits);
                              showWinPopup = false;
                              _generateNewFruit();
                            });
                          }),
                          const SizedBox(width: 10),
                          popupIcon("next.png", () {
                            setState(() => showWinPopup = false);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ThingGameScreen(
                                  lessonId: widget.lessonId,
                                  studentId: widget.studentId,
                                  gameId: widget.gameId,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget popupIcon(String file, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Image.asset("assets/games/objectify/images/$file", width: 55),
  );

  Widget menuBtn(String file, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Image.asset("assets/games/objectify/images/$file", width: 220),
  );

  Widget _dim({required Widget child}) => Container(
    color: Colors.black.withOpacity(0.75),
    child: Center(child: child),
  );
}
