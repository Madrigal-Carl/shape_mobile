import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'package:audioplayers/audioplayers.dart';
import 'game_menu.dart';

class ShapeGameScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const ShapeGameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends State<ShapeGameScreen>
    with TickerProviderStateMixin {
  final Map<String, List<String>> shapeAssets = {
    'circle': [
      'circle1.png',
      'circle2.png',
      'circle3.png',
      'circle4.png',
      'circle5.png',
      'circle6.png',
    ],
    'square': [
      'square1.png',
      'square2.png',
      'square3.png',
      'square4.png',
      'square5.png',
      'square6.png',
    ],
  };

  late List<String> remainingShapes;
  late String targetShapeKey;
  late String targetDisplayName;
  late List<_GridItem> gridItems;

  int score = 0;
  int correctFound = 0;

  bool showMenu = false;
  bool showHowToPlay = false;
  bool showWinPopup = false;

  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late AnimationController _fadeInController;
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    remainingShapes = shapeAssets.keys.toList()..shuffle();
    _setupNextRound();
  }

  void _setupNextRound() {
    if (remainingShapes.isEmpty) {
      GameProgressPreference.saveProgress(
        studentId: widget.studentId,
        lessonId: widget.lessonId,
        gameId: widget.gameId,
        subgameName: 'animal_game',
      );
      setState(() => showWinPopup = true);
      return;
    }

    setState(() {
      correctFound = 0;
      _fadeInController.forward(from: 0);
      targetShapeKey = remainingShapes.removeAt(0);
      targetDisplayName = targetShapeKey == 'circle' ? 'CIRCLE' : 'SQUARE';

      // ✅ Create 12 items with mixed circle/square
      final List<String> allAssets = [];
      shapeAssets.forEach((key, assets) => allAssets.addAll(assets));
      allAssets.shuffle();

      final targetAssets = List<String>.from(shapeAssets[targetShapeKey]!);
      targetAssets.shuffle();

      // ✅ 6 correct target items
      final items = targetAssets.take(6).toList();

      // ✅ Fill remaining slots
      for (final asset in allAssets) {
        if (items.length >= 12) break;
        if (!items.contains(asset)) items.add(asset);
      }

      items.shuffle();

      gridItems = items.map((asset) {
        final shapeKey = _inferShapeKeyFromAsset(asset);
        return _GridItem(asset: asset, shapeKey: shapeKey, selected: false);
      }).toList();
    });
  }

  String _inferShapeKeyFromAsset(String asset) {
    final name = asset.toLowerCase();
    if (name.contains('circle')) return 'circle';
    if (name.contains('square')) return 'square';
    return 'unknown';
  }

  Future<void> _playSound(String file) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$file.mp3'));
    } catch (_) {}
  }

  void _onTapGridItem(int index) {
    final item = gridItems[index];
    if (item.selected) return;

    if (item.shapeKey == targetShapeKey) {
      setState(() {
        gridItems[index] = item.copyWith(selected: true);
        score += 10;
        correctFound += 1;
      });
      _playSound('correct');

      // ✅ When all 6 correct are found
      if (correctFound >= 6) {
        _confettiController.play();
        Future.delayed(const Duration(milliseconds: 900), () {
          if (remainingShapes.isEmpty) {
            setState(() => showWinPopup = true);
          } else {
            _setupNextRound();
          }
        });
      }
    } else {
      setState(() {
        score = max(0, score - 5);
      });
      _playSound('wrong');
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _fadeInController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // 🌌 Background
            Positioned.fill(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/games/sort_safari/images/bg.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(color: Colors.black.withOpacity(0.55)),
                ],
              ),
            ),

            // 🎉 Confetti
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
                    const SizedBox(height: 25),

                    // 🧮 Score + Menu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/games/sort_safari/images/scoreplaceholder.png',
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
                              'assets/games/sort_safari/images/menu.png',
                              width: 55,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🏷️ Title
                    Text(
                      "Shape",
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

                    const SizedBox(height: 6),

                    // 🎯 Instruction
                    Text(
                      "Sort all the objects\naccording to their shape",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Select all the ${targetDisplayName} objects",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // 🧩 Grid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            final offset = Offset(
                              sin(_shakeController.value * pi * 6) * 6,
                              0,
                            );
                            return Transform.translate(
                              offset: offset,
                              child: child,
                            );
                          },
                          child: GridView.builder(
                            itemCount: gridItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemBuilder: (context, index) {
                              final gi = gridItems[index];
                              return GestureDetector(
                                onTap: () => _onTapGridItem(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: gi.selected
                                        ? Border.all(
                                            color: Colors.yellowAccent,
                                            width: 4,
                                          )
                                        : Border.all(
                                            color: Colors.transparent,
                                            width: 2,
                                          ),
                                    boxShadow: [
                                      if (gi.selected)
                                        BoxShadow(
                                          color: Colors.yellow.withOpacity(0.6),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/games/sort_safari/images/${gi.asset}',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),

            // 🧭 Menu + HowTo + Win Popup
            if (showMenu)
              _dim(
                Column(
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
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.asset(
                      'assets/games/sort_safari/images/how.png',
                      width: 330,
                    ),
                    Positioned(
                      top: 10,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => setState(() => showHowToPlay = false),
                        child: Image.asset(
                          'assets/games/sort_safari/images/close.png',
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (showWinPopup)
              _dim(
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // ✅ Changed overlay.png → complete.png
                    Image.asset(
                      "assets/games/sort_safari/images/complete.png",
                      width: 330,
                    ),
                    Positioned(
                      top: 215,
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
                      bottom: 10,
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
                              remainingShapes = shapeAssets.keys.toList()
                                ..shuffle();
                              showWinPopup = false;
                              _setupNextRound();
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

  Widget _dim(Widget child) => Container(
    color: Colors.black.withOpacity(0.75),
    child: Center(child: child),
  );

  Widget popupIcon(String file, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Image.asset("assets/games/sort_safari/images/$file", width: 55),
  );

  Widget menuBtn(String file, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Image.asset("assets/games/sort_safari/images/$file", width: 220),
  );
}

class _GridItem {
  final String asset;
  final String shapeKey;
  final bool selected;

  _GridItem({
    required this.asset,
    required this.shapeKey,
    required this.selected,
  });

  _GridItem copyWith({String? asset, String? shapeKey, bool? selected}) {
    return _GridItem(
      asset: asset ?? this.asset,
      shapeKey: shapeKey ?? this.shapeKey,
      selected: selected ?? this.selected,
    );
  }
}
