import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'package:audioplayers/audioplayers.dart';
import 'size_game.dart';
import 'game_menu.dart';

class ColorGameScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const ColorGameScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen>
    with TickerProviderStateMixin {
  final Map<String, List<String>> colorAssets = {
    'pula': ['red1.png', 'red2.png', 'red3.png'],
    'asul': ['blue1.png', 'blue2.png', 'blue3.png'],
    'berde': ['green1.png', 'green2.png', 'green3.png'],
    'dilaw': ['yellow1.png', 'yellow2.png', 'yellow3.png'],
    'purple': ['purple1.png', 'purple2.png', 'purple3.png'],
  };

  late List<String> remainingColors;
  late String targetColorKey;
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

    remainingColors = colorAssets.keys.toList()..shuffle();
    _setupNextRound();
  }

  void _setupNextRound() {
    if (remainingColors.isEmpty) {
      GameProgressPreference.saveProgress(
        studentId: widget.studentId,
        lessonId: widget.lessonId,
        gameId: widget.gameId,
        subgameName: 'color_game',
      );
      setState(() => showWinPopup = true);
      return;
    }

    setState(() {
      correctFound = 0;
      _fadeInController.forward(from: 0);
      targetColorKey = remainingColors.removeAt(0);
      targetDisplayName = _mapKeyToEnglish(targetColorKey);

      // Generate unique items (no repeating assets)
      final List<String> allAssets = [];
      colorAssets.forEach((key, assets) {
        allAssets.addAll(assets);
      });
      allAssets.shuffle();

      // Ensure all are unique and include target color’s items
      final targetAssets = List<String>.from(colorAssets[targetColorKey]!);
      targetAssets.shuffle();
      final items = targetAssets.take(3).toList();

      // Fill up to 12 unique total assets
      for (final asset in allAssets) {
        if (items.length >= 12) break;
        if (!items.contains(asset)) items.add(asset);
      }

      items.shuffle();

      gridItems = items.map((asset) {
        final colorKey = _inferColorKeyFromAsset(asset);
        return _GridItem(asset: asset, colorKey: colorKey, selected: false);
      }).toList();
    });
  }

  String _mapKeyToEnglish(String key) {
    switch (key) {
      case 'pula':
        return 'red';
      case 'asul':
        return 'blue';
      case 'berde':
        return 'green';
      case 'dilaw':
        return 'yellow';
      case 'purple':
        return 'purple';
      default:
        return key;
    }
  }

  String _inferColorKeyFromAsset(String asset) {
    final name = asset.toLowerCase();
    if (name.contains('red')) return 'pula';
    if (name.contains('blue')) return 'asul';
    if (name.contains('green')) return 'berde';
    if (name.contains('yellow')) return 'dilaw';
    if (name.contains('purple')) return 'purple';
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

    if (item.colorKey == targetColorKey) {
      setState(() {
        gridItems[index] = item.copyWith(selected: true);
        score += 10;
        correctFound += 1;
      });
      _playSound('correct');
      if (correctFound >= 3) {
        _confettiController.play();
        Future.delayed(const Duration(milliseconds: 900), () {
          if (remainingColors.isEmpty) {
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
            // 🌈 Background
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

                    // 🔹 Score and Menu Row
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

                    // 🟩 Title
                    Text(
                      "Color",
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

                    // 📝 Instructions
                    Text(
                      "Sort all the objects\naccording to their color",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Select all the ${targetDisplayName} color",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // 🔳 Grid
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

            // 🧭 Menu + HowTo + Win Popups
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
                    Image.asset(
                      "assets/games/sort_safari/images/overlay.png",
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
                              remainingColors = colorAssets.keys.toList()
                                ..shuffle();
                              showWinPopup = false;
                              _setupNextRound();
                            });
                          }),
                          const SizedBox(width: 10),
                          popupIcon("next.png", () {
                            setState(() => showWinPopup = false);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SizeGameScreen(
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
  final String colorKey;
  final bool selected;

  _GridItem({
    required this.asset,
    required this.colorKey,
    required this.selected,
  });

  _GridItem copyWith({String? asset, String? colorKey, bool? selected}) {
    return _GridItem(
      asset: asset ?? this.asset,
      colorKey: colorKey ?? this.colorKey,
      selected: selected ?? this.selected,
    );
  }
}

class PlaceholderNextScreen extends StatelessWidget {
  const PlaceholderNextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Next Game Coming Soon")),
      body: const Center(child: Text("Size Sort Game placeholder screen")),
    );
  }
}
