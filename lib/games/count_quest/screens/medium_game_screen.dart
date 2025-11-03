import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'hard_game_screen.dart';

class MediumGameScreen extends StatefulWidget {
  const MediumGameScreen({super.key});

  @override
  State<MediumGameScreen> createState() => _MediumGameScreenState();
}

class _MediumGameScreenState extends State<MediumGameScreen>
    with SingleTickerProviderStateMixin {
  int currentCount = 6;
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
  final List<String> ballTypes = [
    'cat_black.png',
    'cat_pink.png',
    'cat_white.png',
    'ball_b.png',
    'ball_v.png',
    'ball_s.png',
  ];

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

  // 🔢 Generate level order from 6–10
  void _generateLevelOrder() {
    levelOrder = [6, 7, 8, 9, 10]..shuffle();
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

  // 🎯 Generate 3 choices (1 correct, 2 wrong)
  void _generateChoices() {
    List<int> all = [6, 7, 8, 9, 10];
    all.remove(currentCount);
    all.shuffle();
    choices = [currentCount, all[0], all[1]]..shuffle();
  }

  // ✅ Check answer
  void checkAnswer(int selected) async {
    if (selected == currentCount) {
      _controller.forward(from: 0.8);
      setState(() {
        score += 15; // Medium = higher reward
        if (currentLevelIndex == levelOrder.length - 1) {
          showOverlay = true;
        } else {
          currentLevelIndex++;
          _setCurrentRound();
        }
      });
    } else {
      setState(() {
        score = (score - 10).clamp(0, score); // Medium = higher penalty
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
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
                      'assets/games/count_quest/images/6-10.png',
                      width: width * 0.6,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "How many items do you see?\nPick the correct number!",
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
                      double ballSize = width * 0.13;
                      double spacing = 10;

                      List<Widget> balls = List.generate(
                        currentCount,
                        (i) => ScaleTransition(
                          scale: _scaleAnimation,
                          child: Image.asset(
                            'assets/games/count_quest/images/$currentBallAsset',
                            width: ballSize,
                          ),
                        ),
                      );

                      // Split into rows (max 5 per row)
                      List<Widget> rows = [];
                      for (int i = 0; i < balls.length; i += 5) {
                        rows.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: balls
                                .skip(i)
                                .take(5)
                                .toList()
                                .expand(
                                  (ball) => [ball, SizedBox(width: spacing)],
                                )
                                .toList()
                                .sublist(
                                  0,
                                  min(balls.skip(i).take(5).length * 2 - 1, 9),
                                ),
                          ),
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: rows
                            .expand((row) => [row, const SizedBox(height: 18)])
                            .toList()
                            .sublist(0, rows.length * 2 - 1),
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
    );
  }

  // 🏆 Victory Overlay
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HardGameScreen(),
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

  // 🛠️ Pause Menu Overlay (with HOW popup)
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

              // HOW TO PLAY popup
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dark overlay background
                          Container(color: Colors.black.withOpacity(0.7)),

                          // Popup image
                          Center(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.asset(
                                  'assets/games/count_quest/images/how.png',
                                  width: width * 0.85,
                                  fit: BoxFit.contain,
                                ),

                                // ❌ Close button on top-right of the image
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(ctx),
                                    child: Image.asset(
                                      'assets/games/count_quest/images/x.png',
                                      width: 35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Image.asset(
                  'assets/games/count_quest/images/htp.png',
                  width: width * 0.5,
                ),
              ),

              const SizedBox(height: 20),

              // QUIT button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
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
