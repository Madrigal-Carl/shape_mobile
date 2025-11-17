import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'mix_game.dart';
import 'game_menu.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';

class ThingGameScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const ThingGameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<ThingGameScreen> createState() => _ThingGameScreenState();
}

class _ThingGameScreenState extends State<ThingGameScreen>
    with SingleTickerProviderStateMixin {
  final List<String> allThings = [
    'chair',
    'ball',
    'book',
    'shoes',
    'pencil',
    'bag',
    'clock',
    'spoon',
    'car',
  ];

  late List<String> unusedThings;
  late String currentThing;
  List<String> currentChoices = [];

  String? droppedThing;
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
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 15,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    unusedThings = List.from(allThings);
    _generateNewThing();
  }

  void _generateNewThing() {
    if (unusedThings.isEmpty) {
      GameProgressPreference.saveProgress(
        studentId: widget.studentId,
        lessonId: widget.lessonId,
        gameId: widget.gameId,
        subgameName: 'things_game',
      );
      setState(() => showWinPopup = true);
      return;
    }

    final random = Random();
    setState(() {
      currentThing = unusedThings[random.nextInt(unusedThings.length)];
      unusedThings.remove(currentThing);
      droppedThing = null;

      List<String> temp = List.from(allThings)..remove(currentThing);
      temp.shuffle();
      currentChoices = [...temp.take(5), currentThing]..shuffle();
    });
  }

  Future<void> _playCorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('games/objectify/music/correct.m4a'));
    } catch (e) {
      // Ignore audio errors silently (or handle as you need)
    }
  }

  void _checkAnswer(String selectedThing) {
    if (dragDisabled) return;

    if (selectedThing == currentThing) {
      // correct
      setState(() {
        droppedThing = selectedThing;
        score += 10;
        dragDisabled = true;
      });

      _confettiController.play();
      _playCorrectSound();

      Future.delayed(const Duration(seconds: 1), () {
        // ensure UI updates when re-enabling drag
        setState(() {
          dragDisabled = false;
        });
        _generateNewThing();
      });
    } else {
      // wrong
      setState(() {
        score -= 5;
        dragDisabled = true;
      });

      // animate shake and then re-enable drags with a setState
      _shakeController.forward(from: 0).whenComplete(() {
        // reset controller so next forward(from:0) works predictably
        _shakeController.reset();
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

                  /// SCORE DISPLAY
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
                    "Thing",
                    style: GoogleFonts.dynaPuff(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Identify the correct object by looking at the picture and choosing the right answer.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// IMAGE
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.8,
                            end: 1.0,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/games/objectify/images/$currentThing.png',
                      key: ValueKey(currentThing),
                      width: size.width * 0.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DRAG TARGET
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: DragTarget<String>(
                      onAccept: (data) => _checkAnswer(data),
                      builder: (_, __, ___) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/games/objectify/images/cotainer.png',
                              width: size.width * 0.6,
                            ),
                            if (droppedThing != null)
                              Image.asset(
                                'assets/games/objectify/images/card_$droppedThing.png',
                                width: 120,
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  /// CHOICES GRID
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 40,
                        right: 40,
                        top: 20,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.99,
                          ),
                      itemCount: currentChoices.length,
                      itemBuilder: (_, index) {
                        final thing = currentChoices[index];
                        return Draggable<String>(
                          data: dragDisabled ? null : thing,
                          feedback: Image.asset(
                            'assets/games/objectify/images/card_$thing.png',
                            width: 110,
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Image.asset(
                              'assets/games/objectify/images/card_$thing.png',
                            ),
                          ),
                          child: Image.asset(
                            'assets/games/objectify/images/card_$thing.png',
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
                    menuBtn(
                      "continue.png",
                      () => setState(() => showMenu = false),
                    ),
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
                          builder: (context) => GameMenuScreen(
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

            /// HOW TO PLAY POPUP
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
                                builder: (context) => GameMenuScreen(
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
                              unusedThings = List.from(allThings);
                              showWinPopup = false;
                              _generateNewThing();
                            });
                          }),
                          const SizedBox(width: 10),
                          popupIcon("next.png", () {
                            setState(() {
                              showWinPopup = false;
                            });
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MixedGameScreen(
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
