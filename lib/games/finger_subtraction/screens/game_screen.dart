import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'dart:math';

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

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  int? firstNumber;
  int? secondNumber;
  int? answer;

  int score = 0;
  int currentRound = 0;
  bool showOverlay = false;
  bool showAnswerChoices = false;
  bool showMenuPopup = false;
  bool showHowToPlay = false;

  final Random random = Random();

  List<Map<String, int>> rounds = [];
  List<int> currentChoices = [];

  late ConfettiController _confettiController;
  late AnimationController _menuAnimController;
  late Animation<double> _menuScaleAnim;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _menuAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuScaleAnim = CurvedAnimation(
      parent: _menuAnimController,
      curve: Curves.easeOutBack,
    );
    _generateRounds();
    _loadNextRound();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _menuAnimController.dispose();
    super.dispose();
  }

  /// 🔢 Generate subtraction rounds (no negative answers)
  void _generateRounds() {
    List<Map<String, int>> allCombos = [];
    for (int a = 1; a <= 5; a++) {
      for (int b = 1; b <= a; b++) {
        allCombos.add({'a': a, 'b': b, 'result': a - b});
      }
    }
    allCombos.shuffle(random);
    rounds = allCombos.take(10).toList(); // 10 unique rounds
  }

  void _loadNextRound() {
    if (rounds.isEmpty || currentRound >= rounds.length) {
      setState(() => showOverlay = true);
      return;
    }

    int a = rounds[currentRound]['a']!;
    int b = rounds[currentRound]['b']!;

    Set<int> startChoices = {a, b};
    while (startChoices.length < 3) {
      startChoices.add(random.nextInt(9) + 1);
    }

    setState(() {
      firstNumber = null;
      secondNumber = null;
      answer = null;
      showAnswerChoices = false;
      currentChoices = startChoices.toList()..shuffle();
    });
  }

  void checkIfReadyForSubtraction() {
    if (rounds.isEmpty || currentRound >= rounds.length) return;

    final correctA = rounds[currentRound]['a']!;
    final correctB = rounds[currentRound]['b']!;

    if (firstNumber == correctA && secondNumber == correctB) {
      int result = correctA - correctB;
      Set<int> choices = {result};
      while (choices.length < 3) {
        choices.add(random.nextInt(9) + 1);
      }

      setState(() {
        showAnswerChoices = true;
        currentChoices = choices.toList()..shuffle();
      });
    }
  }

  void checkIfCorrect() {
    if (rounds.isEmpty || currentRound >= rounds.length) return;

    final correctA = rounds[currentRound]['a']!;
    final correctB = rounds[currentRound]['b']!;
    final correctResult = rounds[currentRound]['result']!;

    if (firstNumber == correctA &&
        secondNumber == correctB &&
        answer == correctResult) {
      score += 10;
      _confettiController.play();

      Future.delayed(const Duration(milliseconds: 1200), () async {
        if (currentRound + 1 >= rounds.length) {
          await GameProgressPreference.saveProgress(
            studentId: widget.studentId,
            lessonId: widget.lessonId,
            gameId: widget.gameId,
            subgameName: 'finger_subtraction',
          );

          setState(() => showOverlay = true);
        } else {
          setState(() {
            currentRound++;
            _loadNextRound();
          });
        }
      });
    } else {
      debugPrint("❌ WRONG!");
    }
  }

  void _removeValue(Function() clearFunction) {
    setState(() {
      clearFunction();
      score = (score - 5).clamp(0, 999);
    });
  }

  Widget draggableNum(String img, int value) {
    return Draggable<int>(
      data: value,
      feedback: Image.asset(
        "assets/games/finger_subtraction/images/$img",
        height: 60,
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(
          "assets/games/finger_subtraction/images/$img",
          height: 60,
        ),
      ),
      child: Image.asset(
        "assets/games/finger_subtraction/images/$img",
        height: 60,
      ),
    );
  }

  Widget buildDropBox(
    Function(int?) onAccept,
    int? currentValue,
    VoidCallback onClear,
  ) {
    return DragTarget<int>(
      onAccept: (value) {
        setState(() => onAccept(value));

        if (!showAnswerChoices && firstNumber != null && secondNumber != null) {
          checkIfReadyForSubtraction();
        }

        if (showAnswerChoices &&
            firstNumber != null &&
            secondNumber != null &&
            answer != null) {
          checkIfCorrect();
        }
      },
      builder: (context, _, __) => GestureDetector(
        onTap: () {
          if (currentValue != null) {
            _removeValue(onClear);
          }
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/games/finger_subtraction/images/woodbox.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: currentValue != null
              ? Image.asset(
                  "assets/games/finger_subtraction/images/$currentValue.png",
                  height: 45,
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int leftFinger =
        (!showOverlay && rounds.isNotEmpty && currentRound < rounds.length)
        ? rounds[currentRound]['a']!
        : 1;
    final int rightFinger =
        (!showOverlay && rounds.isNotEmpty && currentRound < rounds.length)
        ? rounds[currentRound]['b']!
        : 1;

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
            /// Background + UI
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/games/finger_subtraction/images/bg2.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
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
                                "assets/games/finger_subtraction/images/scoreplaceholder.png",
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

                          /// MENU
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showMenuPopup = true;
                              });
                              _menuAnimController.forward(from: 0);
                            },
                            child: Image.asset(
                              "assets/games/finger_subtraction/images/menu.png",
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Fingers Subtraction",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Count the fingers, drag the correct numbers\nthen find the difference!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/games/finger_subtraction/images/finger$leftFinger.png",
                          height: 120,
                        ),
                        const SizedBox(width: 25),
                        Image.asset(
                          "assets/games/finger_subtraction/images/add.png",
                          height: 15,
                        ), // 👈 keep the same image!
                        const SizedBox(width: 25),
                        Image.asset(
                          "assets/games/finger_subtraction/images/finger$rightFinger.png",
                          height: 120,
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildDropBox(
                          (v) => firstNumber = v,
                          firstNumber,
                          () => firstNumber = null,
                        ),
                        const SizedBox(width: 15),
                        Image.asset(
                          "assets/games/finger_subtraction/images/add.png",
                          height: 10,
                        ),
                        const SizedBox(width: 10),
                        buildDropBox(
                          (v) => secondNumber = v,
                          secondNumber,
                          () => secondNumber = null,
                        ),
                        const SizedBox(width: 15),
                        Image.asset(
                          "assets/games/finger_subtraction/images/equals.png",
                          height: 25,
                        ),
                        const SizedBox(width: 15),
                        buildDropBox(
                          (v) => answer = v,
                          answer,
                          () => answer = null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                    Container(
                      height: 80,
                      width: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/games/finger_subtraction/images/wood.png",
                          ),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: currentChoices
                            .map((n) => draggableNum("$n.png", n))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Confetti
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

            /// Game Over
            if (showOverlay) _buildEndOverlay(),

            /// Menu Popup
            if (showMenuPopup) _buildMenuPopup(),

            /// How To Play Popup
            if (showHowToPlay) _buildHowToPlayPopup(),
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
                  "assets/games/finger_subtraction/images/continue.png",
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
                  "assets/games/finger_subtraction/images/htp.png",
                  height: 70,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "assets/games/finger_subtraction/images/quit.png",
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
                "assets/games/finger_subtraction/images/how.png",
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
                  "assets/games/finger_subtraction/images/x.png",
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
              "assets/games/finger_subtraction/images/overlay.png",
              height: 250,
              width: 350,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 75),
                Text(
                  "Score: $score",
                  style: GoogleFonts.dynaPuff(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        "assets/games/finger_subtraction/images/home.png",
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
                          _loadNextRound();
                        });
                      },
                      child: Image.asset(
                        "assets/games/finger_subtraction/images/restart.png",
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
