import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../overlay/how_to_play_overlay.dart';

class AnimalMatchScreen extends StatefulWidget {
  const AnimalMatchScreen({super.key});

  @override
  State<AnimalMatchScreen> createState() => _AnimalMatchScreenState();
}

class _AnimalMatchScreenState extends State<AnimalMatchScreen>
    with SingleTickerProviderStateMixin {
  int score = 0;
  int currentSet = 1;
  Map<String, String> currentTargets = {};
  List<String> shuffledKeys = [];
  Map<String, bool> matched = {};
  List<Map<String, String>> randomizedSets = [];

  final List<Map<String, String>> animalSets = [
    {
      'cat': 'Cat',
      'dog': 'Dog',
      'pig': 'Pig',
      'chicken': 'Chicken',
      'cow': 'Cow',
      'sheep': 'Sheep',
    },
    {
      'fox': 'Fox',
      'eagle': 'Eagle',
      'dove': 'Dove',
      'goat': 'Goat',
      'parrot': 'Parrot',
      'hamster': 'Hamster',
    },
  ];

  late final ConfettiController _confettiController;
  late AnimationController _wrongAnimController;
  double _wrongShakeOffset = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _wrongAnimController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 350),
        )..addListener(() {
          setState(() {
            _wrongShakeOffset = sin(_wrongAnimController.value * pi * 6) * 8;
          });
        });

    _initializeGame();
  }

  void _initializeGame() {
    randomizedSets = List<Map<String, String>>.from(animalSets);
    randomizedSets.shuffle(Random());

    for (int i = 0; i < randomizedSets.length; i++) {
      final entries = randomizedSets[i].entries.toList()..shuffle();
      randomizedSets[i] = {for (var e in entries) e.key: e.value};
    }

    _loadSet(1);
  }

  void _loadSet(int setNumber) {
    final animals = Map<String, String>.from(randomizedSets[setNumber - 1]);
    final shuffledEntries = animals.entries.toList()..shuffle();
    final shuffledMap = {for (var e in shuffledEntries) e.key: e.value};

    setState(() {
      currentSet = setNumber;
      currentTargets = shuffledMap;
      shuffledKeys = animals.keys.toList()..shuffle();
      matched = {for (var key in animals.keys) key: false};
    });
  }

  bool get allMatched => matched.values.every((v) => v == true);

  @override
  void dispose() {
    _confettiController.dispose();
    _wrongAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (currentTargets.isEmpty || matched.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.05)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 35,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/scoreph.png', height: 65),
                          const SizedBox(width: 10),
                          Transform.translate(
                            offset: const Offset(-118, 0),
                            child: Text(
                              'Score:',
                              style: GoogleFonts.dynaPuff(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Transform.translate(
                            offset: const Offset(-116, 0),
                            child: Text(
                              '$score',
                              style: GoogleFonts.dynaPuff(
                                color: Colors.yellowAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _showMenuPopup,
                        child: Image.asset(
                          'assets/images/menu.png',
                          height: 45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Image.asset(
                  'assets/images/animaltitle.png',
                  width: size.width * 0.75,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Set $currentSet of ${randomizedSets.length}',
                  style: GoogleFonts.dynaPuff(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Transform.translate(
                    offset: Offset(_wrongShakeOffset, 0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: currentTargets.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final key = currentTargets.keys.elementAt(index);
                        final label = currentTargets[key]!;

                        return DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: matched[key]!
                                    ? Colors.green.withOpacity(0.4)
                                    : Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: matched[key]!
                                      ? Colors.green
                                      : Colors.white,
                                  width: 2.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: GoogleFonts.dynaPuff(
                                    color: Colors.brown[800],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                          onWillAccept: (data) => true,
                          onAccept: (data) {
                            if (data == key) {
                              setState(() {
                                matched[key] = true;
                                score += 10;
                              });

                              if (allMatched) {
                                _confettiController.play();
                                Future.delayed(
                                  const Duration(milliseconds: 800),
                                  () {
                                    if (currentSet < randomizedSets.length) {
                                      _loadSet(currentSet + 1);
                                    } else {
                                      _showFinishPopup(context);
                                    }
                                  },
                                );
                              }
                            } else {
                              _wrongAnimController.forward(from: 0);
                              setState(() {
                                score = (score - 5).clamp(0, 9999);
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: shuffledKeys
                        .map((key) => _buildAnimalIcon(key))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                gravity: 0.4,
                colors: const [
                  Colors.red,
                  Colors.yellow,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📋 MENU POPUP with HowToPlay overlay logic
  void _showMenuPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(color: Colors.black.withOpacity(0.5)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Image.asset(
                      'assets/images/continue.png',
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showHowToPlayPopup();
                    },
                    child: Image.asset(
                      'assets/images/htp.png',
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/images/quit.png',
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 🧭 HOW TO PLAY OVERLAY POPUP
  void _showHowToPlayPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
            ),
            HowToPlayOverlay(onClose: () => Navigator.pop(ctx)),
          ],
        );
      },
    );
  }

  // 🎉 FINISH POPUP
  void _showFinishPopup(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/overlay.png',
                  width: 347,
                  height: 479,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 212,
                  child: Text(
                    'Score: $score',
                    style: GoogleFonts.dynaPuff(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: Image.asset('assets/images/home.png', width: 60),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            score = 0;
                            _initializeGame();
                          });
                        },
                        child: Image.asset(
                          'assets/images/restart.png',
                          width: 60,
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: Image.asset('assets/images/next.png', width: 60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalIcon(String key) {
    final isMatched = matched[key] ?? false;
    final imageWidget = Image.asset(
      'assets/images/$key.png',
      height: 78,
      width: 78,
    );

    if (isMatched) {
      return const SizedBox(width: 78, height: 78);
    }

    return Draggable<String>(
      data: key,
      feedback: Material(color: Colors.transparent, child: imageWidget),
      feedbackOffset: const Offset(-10, -10),
      childWhenDragging: Opacity(opacity: 0.5, child: imageWidget),
      child: imageWidget,
    );
  }
}
