import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'game_menu.dart';
import 'fruit_game.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';

class AnimalGameScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const AnimalGameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<AnimalGameScreen> createState() => _AnimalGameScreenState();
}

class _AnimalGameScreenState extends State<AnimalGameScreen>
    with SingleTickerProviderStateMixin {
  final List<String> allAnimals = [
    'dog',
    'cat',
    'lion',
    'bird',
    'fish',
    'cow',
    'duck',
    'elephant',
    'rabbit',
  ];

  late List<String> unusedAnimals;
  late String currentAnimal;
  List<String> currentChoices = [];
  String? droppedAnimal;
  int score = 0;

  bool showMenu = false;
  bool showHowToPlay = false;
  bool showWinPopup = false;
  bool dragDisabled = false;

  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation = AlwaysStoppedAnimation(0);

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    /// 🔥 SHAKE ANIMATION
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 15,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    unusedAnimals = List.from(allAnimals);
    _generateNewAnimal();
  }

  void _generateNewAnimal() {
    if (unusedAnimals.isEmpty) {
      GameProgressPreference.saveProgress(
        studentId: widget.studentId,
        lessonId: widget.lessonId,
        gameId: widget.gameId,
        subgameName: 'animal_game',
      );
      setState(() => showWinPopup = true);
      return;
    }

    final random = Random();
    setState(() {
      currentAnimal = unusedAnimals[random.nextInt(unusedAnimals.length)];
      unusedAnimals.remove(currentAnimal);
      droppedAnimal = null;

      List<String> temp = List.from(allAnimals)..remove(currentAnimal);
      temp.shuffle();
      currentChoices = [...temp.take(5), currentAnimal]..shuffle();
    });
  }

  Future<void> _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('games/objectify/music/correct.m4a'));
  }

  /// ✅ CORRECT WRONG ANSWER HANDLING
  void _checkAnswer(String selectedAnimal) {
    if (dragDisabled) return;

    if (selectedAnimal == currentAnimal) {
      setState(() {
        droppedAnimal = selectedAnimal;
        score += 10;
      });

      dragDisabled = true;
      _confettiController.play();
      _playCorrectSound();

      Future.delayed(const Duration(seconds: 1), () {
        dragDisabled = false;
        _generateNewAnimal();
      });
    } else {
      /// ❌ WRONG ANSWER (shake + score penalty)
      setState(() => score -= 5);

      dragDisabled = true;
      _shakeController.forward(from: 0).then((_) {
        dragDisabled = false;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _audioPlayer.dispose();
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

                  /// SCORE TOP UI
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
                    "Animal",
                    style: GoogleFonts.dynaPuff(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Identify the correct object by looking at the picture and choosing the right answer",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ✅ SUPER SMOOTH FADE & SCALE ANIMATION
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
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
                      'assets/games/objectify/images/$currentAnimal.png',
                      key: ValueKey(currentAnimal),
                      width: size.width * 0.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ✅ DROP CONTAINER + SHAKE animation
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
                      builder: (context, accepted, rejected) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/games/objectify/images/cotainer.png',
                              width: size.width * 0.6,
                            ),
                            if (droppedAnimal != null)
                              Image.asset(
                                'assets/games/objectify/images/card_$droppedAnimal.png',
                                width: 120,
                              ),
                          ],
                        );
                      },
                    ),
                  ),

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
                      itemBuilder: (context, index) {
                        final animal = currentChoices[index];

                        return Draggable<String>(
                          data: dragDisabled ? null : animal,
                          feedback: Image.asset(
                            'assets/games/objectify/images/card_$animal.png',
                            width: 110,
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Image.asset(
                              'assets/games/objectify/images/card_$animal.png',
                            ),
                          ),
                          child: Image.asset(
                            'assets/games/objectify/images/card_$animal.png',
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
                              unusedAnimals = List.from(allAnimals);
                              showWinPopup = false;
                              _generateNewAnimal();
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
                                builder: (context) => FruitGameScreen(
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
