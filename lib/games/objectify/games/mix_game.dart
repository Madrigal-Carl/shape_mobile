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
    with SingleTickerProviderStateMixin {
  final List<String> allItems = [
    // Animals
    'dog', 'cat', 'bird', 'fish', 'cow', 'duck', 'elephant', 'rabbit', 'lion',
    // Fruits
    'apple', 'banana', 'orange', 'grapes', 'watermelon',
    'strawberry', 'pineapple', 'cherry', 'lemon',
    // Things
    'chair', 'clock', 'bag', 'car', 'ball', 'pencil', 'book', 'shoes', 'spoon',
  ];

  late List<String> gameItems; // 10 random items for this session
  late List<String> unusedItems;
  late String currentItem;
  List<String> currentChoices = [];

  String? droppedItem;
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

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 15,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    // Pick 10 random unique items
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
        subgameName: 'mixed_game',
      );
      setState(() => showWinPopup = true);
      return;
    }

    final random = Random();
    setState(() {
      currentItem = unusedItems[random.nextInt(unusedItems.length)];
      unusedItems.remove(currentItem);
      droppedItem = null;

      // Random choices: 1 correct + 5 random incorrect
      List<String> temp = List.from(allItems)..remove(currentItem);
      temp.shuffle();
      currentChoices = [...temp.take(5), currentItem]..shuffle();
    });
  }

  Future<void> _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('games/objectify/music/correct.m4a'));
  }

  void _checkAnswer(String selectedItem) {
    if (dragDisabled) return;

    if (selectedItem == currentItem) {
      setState(() {
        droppedItem = selectedItem;
        score += 10;
      });

      dragDisabled = true;
      _confettiController.play();
      _playCorrectSound();

      Future.delayed(const Duration(seconds: 1), () {
        dragDisabled = false;
        _generateNewItem();
      });
    } else {
      setState(() => score -= 5);
      dragDisabled = true;
      _shakeController.forward(from: 0).then((_) => dragDisabled = false);
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

                  // Score + Menu
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
                    "Mixed Game",
                    style: GoogleFonts.dynaPuff(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Identify the correct item by looking at the picture and choosing the right answer.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Current image
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
                      'assets/games/objectify/images/$currentItem.png',
                      key: ValueKey(currentItem),
                      width: size.width * 0.45,
                    ),
                  ),

                  const SizedBox(height: 20),

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
                            if (droppedItem != null)
                              Image.asset(
                                'assets/games/objectify/images/card_$droppedItem.png',
                                width: 120,
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Choices
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
                        final item = currentChoices[index];

                        return Draggable<String>(
                          data: dragDisabled ? null : item,
                          feedback: Image.asset(
                            'assets/games/objectify/images/card_$item.png',
                            width: 110,
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Image.asset(
                              'assets/games/objectify/images/card_$item.png',
                            ),
                          ),
                          child: Image.asset(
                            'assets/games/objectify/images/card_$item.png',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Menu
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

            // How to Play
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

            // Win popup (next.png removed)
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
