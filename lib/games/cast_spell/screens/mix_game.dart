import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'game_menu.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';

class MixedGameScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const MixedGameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<MixedGameScreen> createState() => _MixedGameScreenState();
}

class _MixedGameScreenState extends State<MixedGameScreen>
    with TickerProviderStateMixin {
  final List<Map<String, String>> allItems = [
    // Animals
    {'word': 'aso', 'image': 'dog.png'},
    {'word': 'pusa', 'image': 'cat.png'},
    {'word': 'ibon', 'image': 'bird.png'},
    {'word': 'isda', 'image': 'fish.png'},
    {'word': 'baka', 'image': 'cow.png'},
    {'word': 'pato', 'image': 'duck.png'},
    {'word': 'elepante', 'image': 'elephant.png'},
    {'word': 'kuneho', 'image': 'rabbit.png'},
    {'word': 'leon', 'image': 'lion.png'},

    // Fruits
    {'word': 'mansanas', 'image': 'apple.png'},
    {'word': 'saging', 'image': 'banana.png'},
    {'word': 'kahel', 'image': 'orange.png'},
    {'word': 'ubas', 'image': 'grapes.png'},
    {'word': 'pakwan', 'image': 'watermelon.png'},
    {'word': 'presa', 'image': 'strawberry.png'},
    {'word': 'pinya', 'image': 'pineapple.png'},
    {'word': 'seresa', 'image': 'cherry.png'},
    {'word': 'limon', 'image': 'lemon.png'},

    // Things
    {'word': 'upuan', 'image': 'chair.png'},
    {'word': 'relo', 'image': 'clock.png'},
    {'word': 'bag', 'image': 'bag.png'},
    {'word': 'kotse', 'image': 'car.png'},
    {'word': 'bola', 'image': 'ball.png'},
    {'word': 'lapis', 'image': 'pencil.png'},
    {'word': 'sapatos', 'image': 'shoes.png'},
    {'word': 'kutsara', 'image': 'spoon.png'},
  ];

  late List<Map<String, String>> gameItems;
  late List<Map<String, String>> unusedItems;
  late Map<String, String> currentItem;
  late String currentWord;
  late String missingLetter;
  late int missingIndex;
  late List<String> letterChoices;
  late List<int> signLetterIndexes;

  String? droppedLetter;
  int score = 0;

  bool showMenu = false;
  bool showHowToPlay = false;
  bool showWinPopup = false;
  bool showTryAgain = false;

  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late AnimationController _imageController;
  late AnimationController _fadeInController;
  final AudioPlayer _audioPlayer = AudioPlayer(); // background music only

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    allItems.shuffle();
    gameItems = allItems.take(10).toList();
    unusedItems = List.from(gameItems);
    _generateNewItem();
  }

  void _generateNewItem() {
    if (unusedItems.isEmpty) {
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
      showTryAgain = false;
      droppedLetter = null;

      currentItem = unusedItems.removeAt(random.nextInt(unusedItems.length));
      currentWord = currentItem['word']!;
      missingIndex = random.nextInt(currentWord.length);
      missingLetter = currentWord[missingIndex];

      signLetterIndexes = [];
      while (signLetterIndexes.length < 2 &&
          signLetterIndexes.length < currentWord.length) {
        int idx = random.nextInt(currentWord.length);
        if (idx != missingIndex && !signLetterIndexes.contains(idx)) {
          signLetterIndexes.add(idx);
        }
      }

      List<String> alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');
      alphabet.shuffle();
      letterChoices = [...alphabet.take(5), missingLetter];
      letterChoices.shuffle();

      _fadeInController.forward(from: 0);
      _imageController.forward(from: 0);
    });
  }

  // REMOVED playSound() completely

  void _checkAnswer(String letter) {
    if (letter == missingLetter) {
      setState(() {
        droppedLetter = letter;
        score += 10;
        showTryAgain = false;
      });
      _confettiController.play();
      // ❌ removed: _playSound('correct');
      Future.delayed(const Duration(seconds: 1), _generateNewItem);
    } else {
      setState(() {
        score = max(0, score - 5);
        showTryAgain = true;
      });
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _imageController.dispose();
    _fadeInController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double tileSize = size.width < 380 ? 55 : 65;

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
                'assets/games/cast_spell/images/bg2.png',
                fit: BoxFit.cover,
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.3,
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeInController,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/games/cast_spell/images/scoreplaceholder.png',
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
                              'assets/games/cast_spell/images/menu.png',
                              width: 55,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "Halo-halo",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 34,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showTryAgain
                          ? "Oops! Try again!"
                          : "I-drag ang tamang letra para mabuo ang salita!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 14,
                        color: showTryAgain ? Colors.red[300] : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _imageController,
                        curve: Curves.elasticOut,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Image.asset(
                          'assets/games/cast_spell/images/${currentItem['image']}',
                          key: ValueKey(currentItem['image']),
                          width: size.width * 0.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            sin(_shakeController.value * pi * 6) * 6,
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: currentWord.split('').asMap().entries.map((
                          entry,
                        ) {
                          int i = entry.key;
                          String letter = entry.value;

                          if (i == missingIndex) {
                            return DragTarget<String>(
                              onWillAccept: (_) => true,
                              onAccept: _checkAnswer,
                              builder: (context, accepted, rejected) {
                                bool isHovering = accepted.isNotEmpty;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: tileSize,
                                  height: tileSize,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    boxShadow: isHovering
                                        ? [
                                            BoxShadow(
                                              color: Colors.yellow.withOpacity(
                                                0.6,
                                              ),
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/games/cast_spell/images/blank_wood.png',
                                        width: tileSize,
                                      ),
                                      if (droppedLetter != null)
                                        Image.asset(
                                          'assets/games/cast_spell/images/letter_${droppedLetter!.toLowerCase()}.png',
                                          width: tileSize - 10,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            bool useSign = signLetterIndexes.contains(i);
                            String asset = useSign
                                ? 'assets/games/cast_spell/images/${letter.toLowerCase()}.png'
                                : 'assets/games/cast_spell/images/letter_${letter.toLowerCase()}.png';

                            return Container(
                              width: tileSize,
                              height: tileSize,
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/games/cast_spell/images/blank_wood.png',
                                    width: tileSize,
                                  ),
                                  Image.asset(
                                    asset,
                                    width: tileSize - 10,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/games/cast_spell/images/letter_${letter.toLowerCase()}.png',
                                      width: tileSize - 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 55),

                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                        itemCount: letterChoices.length,
                        itemBuilder: (context, index) {
                          final letter = letterChoices[index];
                          return Draggable<String>(
                            data: letter,
                            feedback: Transform.scale(
                              scale: 0.3,
                              child: Image.asset(
                                'assets/games/cast_spell/images/letter_${letter.toLowerCase()}.png',
                                width: 100,
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: Image.asset(
                                'assets/games/cast_spell/images/letter_${letter.toLowerCase()}.png',
                                width: 85,
                              ),
                            ),
                            child: Image.asset(
                              'assets/games/cast_spell/images/letter_${letter.toLowerCase()}.png',
                              width: 90,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

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

            if (showHowToPlay)
              _dim(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.asset(
                      'assets/games/cast_spell/images/how.png',
                      width: 330,
                    ),
                    Positioned(
                      top: 10,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => setState(() => showHowToPlay = false),
                        child: Image.asset(
                          'assets/games/cast_spell/images/close.png',
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (showWinPopup)
              _dim(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/games/cast_spell/images/overlay.png",
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
                              allItems.shuffle();
                              gameItems = allItems.take(10).toList();
                              unusedItems = List.from(gameItems);
                              showWinPopup = false;
                              _generateNewItem();
                            });
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
    child: Image.asset("assets/games/cast_spell/images/$file", width: 55),
  );

  Widget menuBtn(String file, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Image.asset("assets/games/cast_spell/images/$file", width: 220),
  );

  Widget _dim({required Widget child}) => Container(
    color: Colors.black.withOpacity(0.75),
    child: Center(child: child),
  );
}
