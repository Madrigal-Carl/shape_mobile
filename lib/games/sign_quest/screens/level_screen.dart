import 'package:flutter/material.dart';
import 'dart:math';
import 'game_screen.dart';
import 'victory_screen.dart';

class LevelScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const LevelScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isPaused = false;
  bool _showCorrectPopup = false;
  bool _showWrongPopup = false;

  int _currentLetterIndex = 0;
  int _wrongAttempts = 0;

  final List<String> _letters = List.generate(
    26,
    (i) => String.fromCharCode(97 + i),
  ); // a-z

  List<String> _choices = [];
  late String _correctChoice;

  final Map<String, AnimationController> _shakeControllers = {};

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.93,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // ❌ Removed shuffle — now letters go A → Z in order
    _generateChoices();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var c in _shakeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _controller.stop();
      } else {
        _controller.repeat(reverse: true);
      }
    });
  }

  void _restartGame() {
    setState(() {
      _isPaused = false;
      _currentLetterIndex = 0;
      _wrongAttempts = 0;
      _showCorrectPopup = false;
      _showWrongPopup = false;
    });
    _controller.reset();
    _controller.repeat(reverse: true);
    _generateChoices();
  }

  void _nextLetter() {
    if (_currentLetterIndex < 25) {
      setState(() => _currentLetterIndex++);
      _generateChoices();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VictoryScreen(
            lessonId: widget.lessonId,
            studentId: widget.studentId,
            gameId: widget.gameId,
          ),
        ),
      );
    }
  }

  void _showCorrect() {
    setState(() => _showCorrectPopup = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _showCorrectPopup = false);
      if (_currentLetterIndex == 25) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VictoryScreen(
              lessonId: widget.lessonId,
              studentId: widget.studentId,
              gameId: widget.gameId,
            ),
          ),
        );
      } else {
        _nextLetter();
      }
    });
  }

  void _generateChoices() {
    final random = Random();
    final currentLetter = _letters[_currentLetterIndex];
    _correctChoice = "assets/games/sign_quest/images/quiz_$currentLetter.png";

    final wrongLetters = _letters.where((l) => l != currentLetter).toList()
      ..shuffle(random);
    final wrongChoices = wrongLetters.take(2).toList();

    _choices = [
      _correctChoice,
      "assets/games/sign_quest/images/quiz_${wrongChoices[0]}.png",
      "assets/games/sign_quest/images/quiz_${wrongChoices[1]}.png",
    ]..shuffle(random);

    for (final choice in _choices) {
      _shakeControllers.putIfAbsent(
        choice,
        () => AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  void _handleWrongAnswer(String choice) {
    setState(() => _wrongAttempts++);

    _shakeControllers[choice]
      ?..reset()
      ..forward();

    if (_wrongAttempts >= 3) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _showWrongPopup = true);
          _controller.stop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentLetter = _letters[_currentLetterIndex];

    return WillPopScope(
      onWillPop: () async {
        if (_showCorrectPopup || _showWrongPopup) {
          return false;
        }
        setState(() {
          _isPaused = !_isPaused;
          if (_isPaused) {
            _controller.stop();
          } else {
            _controller.repeat(reverse: true);
          }
        });
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/games/sign_quest/images/gamebg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 28, right: 16),
                      child: GestureDetector(
                        onTap: _togglePause,
                        child: Image.asset(
                          "assets/games/sign_quest/images/menu.png",
                          height: size.height * 0.07,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Image.asset(
                    "assets/games/sign_quest/images/question.png",
                    height: size.height * 0.15,
                    fit: BoxFit.contain,
                  ),

                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.04),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: RotationTransition(
                            turns: _rotationAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow.withOpacity(0.6),
                                    blurRadius: 30,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/games/sign_quest/images/$currentLetter.png",
                                height: size.height * 0.36,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.035),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _choices.map((assetPath) {
                        final controller = _shakeControllers[assetPath]!;
                        return AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) {
                            final shake = sin(controller.value * pi * 10) * 6;
                            return Transform.translate(
                              offset: Offset(shake, 0),
                              child: child,
                            );
                          },
                          child: GestureDetector(
                            onTap: _isPaused
                                ? null
                                : () {
                                    if (assetPath == _correctChoice) {
                                      _showCorrect();
                                    } else {
                                      _handleWrongAnswer(assetPath);
                                    }
                                  },
                            child: Container(
                              width: size.width * 0.23,
                              height: size.height * 0.11,
                              decoration: BoxDecoration(
                                color: Colors.green.shade900.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  assetPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            if (_showCorrectPopup)
              _popupOverlay(
                size,
                "assets/games/sign_quest/images/correct.png",
                0.35,
              ),

            if (_showWrongPopup)
              _popupOverlay(
                size,
                "assets/games/sign_quest/images/nt.png",
                0.25,
                showReload: true,
              ),

            if (_isPaused) _pauseMenu(size),
          ],
        ),
      ),
    );
  }

  Widget _popupOverlay(
    Size size,
    String imagePath,
    double height, {
    bool showReload = false,
  }) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                imagePath,
                height: size.height * height,
                fit: BoxFit.contain,
              ),
              if (showReload)
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _restartGame();
                          setState(() => _showWrongPopup = false);
                        },
                        child: Image.asset(
                          "assets/games/sign_quest/images/reload.png",
                          height: size.height * 0.08,
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                lessonId: widget.lessonId,
                                studentId: widget.studentId,
                                gameId: widget.gameId,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          "assets/games/sign_quest/images/menu2.png",
                          height: size.height * 0.08,
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

  Widget _pauseMenu(Size size) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                "assets/games/sign_quest/images/pausecont.png",
                height: size.height * 0.25,
                fit: BoxFit.contain,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: size.height * 0.045),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _togglePause,
                        child: Image.asset(
                          "assets/games/sign_quest/images/play.png",
                          height: size.height * 0.085,
                        ),
                      ),
                      SizedBox(width: size.width * 0.01),
                      GestureDetector(
                        onTap: _restartGame,
                        child: Image.asset(
                          "assets/games/sign_quest/images/reload.png",
                          height: size.height * 0.075,
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                lessonId: widget.lessonId,
                                studentId: widget.studentId,
                                gameId: widget.gameId,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          "assets/games/sign_quest/images/menu2.png",
                          height: size.height * 0.075,
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
}
