import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'medium_game_screen.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';

class CountingGameScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const CountingGameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<CountingGameScreen> createState() => _CountingGameScreenState();
}

class _CountingGameScreenState extends State<CountingGameScreen>
    with SingleTickerProviderStateMixin {
  int currentCount = 1;
  int score = 0;
  bool showOverlay = false;
  bool showMenu = false;
  List<int> choices = [];
  final Random _random = Random();

  List<int> levelOrder = [];
  int currentLevelIndex = 0;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // 🎨 Random ball type (changes each round)
  String currentBallAsset = 'ball_b.png';
  final List<String> ballTypes = ['ball_b.png', 'ball_v.png', 'ball_s.png'];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.8,
      upperBound: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _generateLevelOrder();
    _setCurrentRound();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateLevelOrder() {
    levelOrder = [1, 2, 3, 4, 5]..shuffle();
    currentLevelIndex = 0;
  }

  // ⚙️ Setup current round
  void _setCurrentRound() {
    currentCount = levelOrder[currentLevelIndex];
    _generateChoices();

    // 🔀 Randomize which ball image is used this round
    currentBallAsset = ballTypes[_random.nextInt(ballTypes.length)];

    _controller.forward(from: 0.8);
  }

  void _generateChoices() {
    List<int> all = [1, 2, 3, 4, 5];
    all.remove(currentCount);
    all.shuffle();
    choices = [currentCount, all[0], all[1]]..shuffle();
  }

  void checkAnswer(int selected) async {
    if (selected == currentCount) {
      _controller.forward(from: 0.8);
      setState(() {
        score += 10;
        if (currentLevelIndex == levelOrder.length - 1) {
          GameProgressPreference.saveProgress(
            studentId: widget.studentId,
            lessonId: widget.lessonId,
            gameId: widget.gameId,
            subgameName: 'counting',
          );
          showOverlay = true;
        } else {
          currentLevelIndex++;
          _setCurrentRound();
        }
      });
    } else {
      setState(() {
        score = (score - 5).clamp(0, score);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Try again!"),
          backgroundColor: Colors.redAccent.shade200,
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 🪧 HOW TO PLAY popup
  void _showHowToPlayPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/games/count_quest/images/how.png',
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Image.asset(
                      'assets/games/count_quest/images/x.png',
                      width: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        if (showMenu) {
          setState(() {
            showMenu = false;
          });
        } else {
          setState(() {
            showMenu = true;
          });
        }
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/games/count_quest/images/bg2.png',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // 🧮 SCORE BAR
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/games/count_quest/images/scoreplacholder.png',
                        width: width * 0.55,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Score: ",
                              style: GoogleFonts.dynaPuff(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(2, 2),
                                    blurRadius: 3,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) =>
                                      ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                              child: Text(
                                "$score",
                                key: ValueKey<int>(score),
                                style: GoogleFonts.dynaPuff(
                                  color: Colors.yellowAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(2, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 🔢 Question
                  Column(
                    children: [
                      Image.asset(
                        'assets/games/count_quest/images/1-5.png',
                        width: width * 0.6,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "How many balls do you see?\nPick the correct number!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dynaPuff(
                          color: Colors.white,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 2),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🎾 Balls display
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double ballSize = width * 0.18;
                        double spacing = 14;

                        List<Widget> topRow = [];
                        List<Widget> bottomRow = [];

                        for (int i = 0; i < currentCount; i++) {
                          Widget ball = ScaleTransition(
                            scale: _scaleAnimation,
                            child: Image.asset(
                              'assets/games/count_quest/images/$currentBallAsset',
                              width: ballSize,
                            ),
                          );

                          if (i < 3) {
                            topRow.add(ball);
                          } else {
                            bottomRow.add(ball);
                          }
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < topRow.length; i++) ...[
                                  if (i > 0) SizedBox(width: spacing),
                                  topRow[i],
                                ],
                              ],
                            ),
                            if (bottomRow.isNotEmpty) ...[
                              const SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (
                                    int i = 0;
                                    i < bottomRow.length;
                                    i++
                                  ) ...[
                                    if (i > 0) SizedBox(width: spacing),
                                    bottomRow[i],
                                  ],
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),

                  // 🪵 Choices
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Container(
                      width: width * 0.85,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/games/count_quest/images/wood.png',
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          choices.length,
                          (index) => GestureDetector(
                            onTap: () => checkAnswer(choices[index]),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Image.asset(
                                'assets/games/count_quest/images/${choices[index]}.png',
                                width: width * 0.17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 📋 Menu button
            Positioned(
              top: 55,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showMenu = true;
                  });
                },
                child: Image.asset(
                  'assets/games/count_quest/images/menu.png',
                  width: 50,
                ),
              ),
            ),

            if (showOverlay) _buildVictoryOverlay(width),
            if (showMenu) _buildMenuOverlay(width),
          ],
        ),
      ),
    );
  }

  Widget _buildVictoryOverlay(double width) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/games/count_quest/images/overlay.png',
                width: width * 0.85,
                fit: BoxFit.contain,
              ),
              Positioned(
                top: width * 0.24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Score: ",
                      style: GoogleFonts.dynaPuff(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$score",
                      style: GoogleFonts.dynaPuff(
                        color: Colors.yellowAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: width * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/games/count_quest/images/home.png',
                        width: 60,
                      ),
                    ),
                    const SizedBox(width: 25),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          score = 0;
                          showOverlay = false;
                          _generateLevelOrder();
                          _setCurrentRound();
                        });
                      },
                      child: Image.asset(
                        'assets/games/count_quest/images/restart.png',
                        width: 60,
                      ),
                    ),
                    const SizedBox(width: 25),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MediumGameScreen(
                              studentId: widget.studentId,
                              lessonId: widget.lessonId,
                              gameId: widget.gameId,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/games/count_quest/images/next.png',
                        width: 60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOverlay(double width) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    showMenu = false;
                  });
                },
                child: Image.asset(
                  'assets/games/count_quest/images/continue.png',
                  width: width * 0.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showHowToPlayPopup, // ✅ now triggers popup
                child: Image.asset(
                  'assets/games/count_quest/images/htp.png',
                  width: width * 0.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  'assets/games/count_quest/images/quit.png',
                  width: width * 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
