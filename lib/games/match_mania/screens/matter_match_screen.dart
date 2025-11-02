import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'animal_match_screen.dart';
import '../overlay/how_to_play_overlay.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';

class MatterMatchScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const MatterMatchScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<MatterMatchScreen> createState() => _MatterMatchScreenState();
}

class _MatterMatchScreenState extends State<MatterMatchScreen>
    with SingleTickerProviderStateMixin {
  int score = 0;
  int currentSet = 1;
  late ConfettiController _confettiController;
  late AnimationController _wrongAnimController;
  double _wrongShakeOffset = 0;
  bool _showHowToPlay = false; // 👈 overlay visibility

  final Map<String, String> allItems = {
    // Solids
    'pencil': 'Solid',
    'bag': 'Solid',
    'fork': 'Solid',
    'paper': 'Solid',

    // Liquids
    'milk': 'Liquid',
    'juice': 'Liquid',
    'shampoo': 'Liquid',
    'water': 'Liquid',

    // Gases
    'oxygen': 'Gas',
    'o2': 'Gas',
    'baloon_helium': 'Gas',
    'cloud': 'Gas',
  };

  late Map<String, String> currentItems;
  late List<String> shuffledItems;
  Map<String, String> placedItems = {};
  Map<String, bool> boxComplete = {
    'Solid': false,
    'Liquid': false,
    'Gas': false,
  };

  final int itemsPerSet = 6;
  final int totalSets = 3;

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
    score = 0;
    currentSet = 1;
    _loadSet(1);
  }

  Map<String, String> _generateRandomSet() {
    final random = Random();

    final solids = allItems.entries
        .where((e) => e.value == 'Solid')
        .map((e) => e.key)
        .toList();
    final liquids = allItems.entries
        .where((e) => e.value == 'Liquid')
        .map((e) => e.key)
        .toList();
    final gases = allItems.entries
        .where((e) => e.value == 'Gas')
        .map((e) => e.key)
        .toList();

    solids.shuffle(random);
    liquids.shuffle(random);
    gases.shuffle(random);

    final selected = <String, String>{
      solids.first: 'Solid',
      liquids.first: 'Liquid',
      gases.first: 'Gas',
    };

    final remainingItems = [
      ...solids.skip(1),
      ...liquids.skip(1),
      ...gases.skip(1),
    ]..shuffle(random);

    for (int i = 0; i < itemsPerSet - 3; i++) {
      final item = remainingItems[i];
      selected[item] = allItems[item]!;
    }

    return selected;
  }

  void _loadSet(int setNumber) {
    setState(() {
      currentSet = setNumber;
      currentItems = _generateRandomSet();
      shuffledItems = currentItems.keys.toList()..shuffle(Random());
      placedItems.clear();
      boxComplete = {'Solid': false, 'Liquid': false, 'Gas': false};
    });
  }

  bool get allMatched => placedItems.length == currentItems.length;

  void _checkBoxCompletion() {
    setState(() {
      boxComplete['Solid'] = currentItems.entries
          .where((e) => e.value == 'Solid')
          .every((e) => placedItems[e.key] == 'Solid');
      boxComplete['Liquid'] = currentItems.entries
          .where((e) => e.value == 'Liquid')
          .every((e) => placedItems[e.key] == 'Liquid');
      boxComplete['Gas'] = currentItems.entries
          .where((e) => e.value == 'Gas')
          .every((e) => placedItems[e.key] == 'Gas');
    });
  }

  void _handleDrop(String item, String box) {
    if (currentItems[item] == box) {
      setState(() {
        placedItems[item] = box;
        score += 10;
      });
      _checkBoxCompletion();

      if (allMatched) {
        _confettiController.play();
        Future.delayed(const Duration(milliseconds: 800), () async {
          if (currentSet < totalSets) {
            _loadSet(currentSet + 1);
          } else {
            await GameProgressPreference.saveProgress(
              studentId: widget.studentId,
              lessonId: widget.lessonId,
              gameId: widget.gameId,
              subgameName: 'matter_match',
            );
            _showFinishPopup(context);
          }
        });
      }
    } else {
      _wrongAnimController.forward(from: 0);
      setState(() {
        score = (score - 5).clamp(0, 9999);
      });
    }
  }

  void _toggleHowToPlay() {
    setState(() {
      _showHowToPlay = !_showHowToPlay;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _wrongAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _showMenuPopup();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 🏞️ Background
            Positioned.fill(
              child: Image.asset(
                'assets/games/match_mania/images/bg.png',
                fit: BoxFit.cover,
              ),
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
                            Image.asset(
                              'assets/games/match_mania/images/scoreph.png',
                              height: 65,
                            ),
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
                            'assets/games/match_mania/images/menu.png',
                            height: 45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/games/match_mania/images/mattertitle.png',
                    width: size.width * 0.75,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    'Set $currentSet of $totalSets',
                    style: GoogleFonts.dynaPuff(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Transform.translate(
                    offset: Offset(_wrongShakeOffset, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        'Solid',
                        'Liquid',
                        'Gas',
                      ].map((type) => _buildBox(type)).toList(),
                    ),
                  ),
                  const SizedBox(height: 100),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 20,
                        children: shuffledItems
                            .where((item) => !placedItems.containsKey(item))
                            .map((item) => _buildMatterIcon(item))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🎊 Confetti
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

            // 🧭 How To Play Overlay
            if (_showHowToPlay) HowToPlayOverlay(onClose: _toggleHowToPlay),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String label) {
    final isComplete = boxComplete[label] ?? false;
    return DragTarget<String>(
      onWillAccept: (data) => true,
      onAccept: (item) => _handleDrop(item, label),
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 120,
          width: 100,
          decoration: BoxDecoration(
            color: isComplete
                ? Colors.green.withOpacity(0.6)
                : Colors.white.withOpacity(0.4),
            border: Border.all(
              color: isComplete ? Colors.green : Colors.white,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
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
    );
  }

  Widget _buildMatterIcon(String key) {
    final imageWidget = Image.asset(
      'assets/games/match_mania/images/$key.png',
      height: 78,
      width: 78,
    );

    return Draggable<String>(
      data: key,
      feedback: Material(color: Colors.transparent, child: imageWidget),
      feedbackOffset: const Offset(-10, -10),
      childWhenDragging: Opacity(opacity: 0.5, child: imageWidget),
      child: imageWidget,
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
                  'assets/games/match_mania/images/overlay.png',
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
                        child: Image.asset(
                          'assets/games/match_mania/images/home.png',
                          width: 60,
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _initializeGame();
                          });
                        },
                        child: Image.asset(
                          'assets/games/match_mania/images/restart.png',
                          width: 60,
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnimalMatchScreen(
                                lessonId: widget.lessonId,
                                studentId: widget.studentId,
                                gameId: widget.gameId,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/games/match_mania/images/next.png',
                          width: 60,
                        ),
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

  // 📋 MENU POPUP (Pause Menu)
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
                      'assets/games/match_mania/images/continue.png',
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _toggleHowToPlay(); // 👈 directly show overlay
                    },
                    child: Image.asset(
                      'assets/games/match_mania/images/htp.png',
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
                      'assets/games/match_mania/images/quit.png',
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
}
