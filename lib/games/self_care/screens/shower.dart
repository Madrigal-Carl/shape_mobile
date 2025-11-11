import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'kitchen.dart';
import 'teeth.dart';
import '../main.dart';
import 'living_room.dart';

class ShowerScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const ShowerScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<ShowerScreen> createState() => _ShowerScreenState();
}

class _ShowerScreenState extends State<ShowerScreen>
    with TickerProviderStateMixin {
  String currentBody = "assets/games/self_care/images/dirty_body.png";
  bool isScrubbing = false;
  bool showFoam = false;
  bool isRinsing = false;
  bool showMenuPopup = false;
  bool showHowPopup = false;

  List<_Bubble> bubbles = [];
  final Random random = Random();
  Timer? bubbleTimer;
  late AnimationController _waterController;
  late AnimationController _menuScaleController;
  late Animation<double> _menuScaleAnim;

  final double bodyWidth = 250;
  final double bodyHeight = 350;

  @override
  void initState() {
    super.initState();
    _initCleanState();

    _waterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _menuScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuScaleAnim = CurvedAnimation(
      parent: _menuScaleController,
      curve: Curves.easeOutBack,
    );
  }

  // 🧠 Load last shower time
  Future<void> _initCleanState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShowerTime = prefs.getString('last_shower_time');

    if (lastShowerTime != null) {
      final lastShower = DateTime.tryParse(lastShowerTime);
      if (lastShower != null) {
        final diff = DateTime.now().difference(lastShower);
        if (diff.inMinutes < 10) {
          // ✅ Still clean
          setState(() {
            currentBody = "assets/games/self_care/images/clean_body.png";
          });
          return;
        }
      }
    }

    // 🧍 Dirty again after 10 mins
    setState(() {
      currentBody = "assets/games/self_care/images/dirty_body.png";
    });
  }

  // 💾 Save shower time
  Future<void> _saveShowerTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_shower_time', DateTime.now().toIso8601String());
  }

  void _toggleMenu() {
    setState(() => showMenuPopup = !showMenuPopup);
    if (showMenuPopup) {
      _menuScaleController.forward(from: 0);
    }
  }

  void _showHowToPlay() {
    setState(() {
      showHowPopup = true;
      showMenuPopup = false;
    });
  }

  void _closeHowToPlay() {
    setState(() {
      showHowPopup = false;
    });
  }

  void startScrubbing() {
    if (!isScrubbing) {
      setState(() {
        isScrubbing = true;
        showFoam = true;
      });

      bubbleTimer ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {
          bubbles.add(
            _Bubble(
              left: random.nextDouble() * bodyWidth + 60,
              top: random.nextDouble() * bodyHeight + 180,
              size: random.nextDouble() * 20 + 10,
            ),
          );
        });
      });
    }
  }

  void stopScrubbing() {
    bubbleTimer?.cancel();
    bubbleTimer = null;
  }

  void rinseBody() async {
    if (showFoam && !isRinsing) {
      stopScrubbing();
      setState(() {
        isRinsing = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          bubbles.clear();
        });
      });

      Future.delayed(const Duration(seconds: 1), () async {
        setState(() {
          isRinsing = false;
          showFoam = false;
          currentBody = "assets/games/self_care/images/clean_body.png";
        });

        // ✅ Save time of cleaning
        await GameProgressPreference.saveProgress(
          studentId: widget.studentId,
          lessonId: widget.lessonId,
          gameId: widget.gameId,
          subgameName: 'fruit_addition',
        );
        await _saveShowerTime();
      });
    }
  }

  @override
  void dispose() {
    stopScrubbing();
    _waterController.dispose();
    _menuScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🛁 Background
          Positioned.fill(
            child: Image.asset(
              "assets/games/self_care/images/cr2.png",
              fit: BoxFit.cover,
            ),
          ),

          // 🧼 Logo
          Positioned(
            top: size.height * 0.04,
            left: 25,
            child: Image.asset(
              "assets/games/self_care/images/logo.png",
              height: 65,
            ),
          ),

          // 🍔 Menu Button
          Positioned(
            top: size.height * 0.05,
            right: 25,
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Image.asset(
                "assets/games/self_care/images/menu.png",
                height: 50,
              ),
            ),
          ),

          // ✨ Title and Subtitle
          Positioned(
            top: size.height * 0.14,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Comfort Room",
                  style: GoogleFonts.dynaPuff(
                    fontSize: 36,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Carl is dirty! Give him a nice bath.",
                  style: GoogleFonts.dynaPuff(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 🧍 Carl Body + Bubbles
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Image.asset(
                  currentBody,
                  height: size.height * 0.6,
                  fit: BoxFit.contain,
                ),
                if (showFoam)
                  ...bubbles.map(
                    (bubble) => Positioned(
                      left: bubble.left,
                      top: bubble.top,
                      child: AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: bubble.size,
                          height: bubble.size,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isRinsing)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _waterController,
                      builder: (_, __) => CustomPaint(
                        painter: _WaterPainter(
                          offsetY: _waterController.value * size.height,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 🧽 Soap Draggable
          Positioned(
            bottom: 145,
            left: 80,
            child: Draggable(
              data: "soap",
              feedback: Image.asset(
                "assets/games/self_care/images/soap.png",
                height: 80,
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  "assets/games/self_care/images/soap.png",
                  height: 80,
                ),
              ),
              onDragStarted: startScrubbing,
              onDragEnd: (_) => stopScrubbing(),
              child: Image.asset(
                "assets/games/self_care/images/soap.png",
                height: 80,
              ),
            ),
          ),

          // 🚿 Shower Draggable
          Positioned(
            bottom: 145,
            right: 80,
            child: Draggable(
              data: "shower",
              feedback: Image.asset(
                "assets/games/self_care/images/shower.png",
                height: 80,
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  "assets/games/self_care/images/shower.png",
                  height: 80,
                ),
              ),
              onDragEnd: (_) => rinseBody(),
              child: Image.asset(
                "assets/games/self_care/images/shower.png",
                height: 80,
              ),
            ),
          ),

          // 🧭 Bottom Navigation
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  "assets/games/self_care/images/lv.png",
                  "Living Room",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LivingRoomScreen(
                          lessonId: widget.lessonId,
                          studentId: widget.studentId,
                          gameId: widget.gameId,
                        ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  "assets/games/self_care/images/kc.png",
                  "Eat",
                  _feedCarl,
                ),
                _buildActionButton(
                  "assets/games/self_care/images/teeth.png",
                  "Brush",
                  _brushCarl,
                ),
              ],
            ),
          ),

          // 📋 Menu Popup
          if (showMenuPopup) _buildMenuPopup(),

          // ❓ How-to-Play Popup
          if (showHowPopup)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.asset(
                      "assets/games/self_care/images/how.png",
                      width: 330,
                      fit: BoxFit.contain,
                    ),
                    GestureDetector(
                      onTap: _closeHowToPlay,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          "assets/games/self_care/images/close.png",
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🧭 Bottom Navigation Buttons
  Widget _buildActionButton(String asset, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 65),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.dynaPuff(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 🥘 Navigate to Kitchen
  void _feedCarl() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KitchenScreen(
          lessonId: widget.lessonId,
          studentId: widget.studentId,
          gameId: widget.gameId,
        ),
      ),
    );
  }

  // 🪥 Navigate to Teeth
  void _brushCarl() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeethScreen(
          lessonId: widget.lessonId,
          studentId: widget.studentId,
          gameId: widget.gameId,
        ),
      ),
    );
  }

  // 📋 Menu Popup
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
                  "assets/games/self_care/images/continue.png",
                  height: 70,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showHowToPlay,
                child: Image.asset(
                  "assets/games/self_care/images/htp.png",
                  height: 70,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelfCareRoot(
                        lessonId: widget.lessonId,
                        studentId: widget.studentId,
                        gameId: widget.gameId,
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: Image.asset(
                  "assets/games/self_care/images/quit.png",
                  height: 70,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// 🫧 Bubble Class
class _Bubble {
  final double left;
  final double top;
  final double size;
  _Bubble({required this.left, required this.top, required this.size});
}

// 💧 Animated Water Effect Painter
class _WaterPainter extends CustomPainter {
  final double offsetY;
  final Random random = Random();

  _WaterPainter({required this.offsetY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 70; i++) {
      final startX = random.nextDouble() * size.width;
      final startY =
          (random.nextDouble() * size.height + offsetY) % size.height;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX, startY + 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) => true;
}
