import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'kitchen.dart';
import 'shower.dart';
import 'living_room.dart';
import '../main.dart';

class TeethScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const TeethScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<TeethScreen> createState() => _TeethScreenState();
}

class _TeethScreenState extends State<TeethScreen>
    with TickerProviderStateMixin {
  String currentTeeth = "assets/games/self_care/images/dirtyteeth.png";
  bool isBrushed = false;
  bool showFoam = false;
  bool isRinsing = false;
  List<_Bubble> bubbles = [];
  final Random random = Random();
  Timer? bubbleTimer;
  late AnimationController _waterController;

  final double teethWidth = 250;
  final double teethHeight = 200;

  // ✅ Menu popup + animations
  bool showMenuPopup = false;
  bool showHowToPlay = false;
  late AnimationController _menuScaleController;
  late Animation<double> _menuScaleAnim;

  @override
  void initState() {
    super.initState();
    _initTeethState();

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

  // 🧠 Load saved brushing data (10-minute clean duration)
  Future<void> _initTeethState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBrushTimeString = prefs.getString('last_brush_time');

    if (lastBrushTimeString != null) {
      final lastBrushTime = DateTime.tryParse(lastBrushTimeString);
      if (lastBrushTime != null) {
        final diff = DateTime.now().difference(lastBrushTime);
        if (diff.inMinutes < 10) {
          // ✅ Still clean within 10 minutes
          setState(() {
            currentTeeth = "assets/games/self_care/images/smile_face.png";
            isBrushed = true;
          });
          return;
        }
      }
    }

    // If more than 10 minutes or never brushed
    setState(() {
      currentTeeth = "assets/games/self_care/images/dirtyteeth.png";
      isBrushed = false;
    });
  }

  // 💾 Save brushing time
  Future<void> _saveBrushTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_brush_time', DateTime.now().toIso8601String());
  }

  void startBrushing() {
    if (!isBrushed) {
      setState(() {
        isBrushed = true;
        showFoam = true;
      });

      bubbleTimer ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {
          bubbles.add(
            _Bubble(
              left: random.nextDouble() * teethWidth + 60,
              top: random.nextDouble() * teethHeight + 80,
              size: random.nextDouble() * 15 + 8,
            ),
          );
        });
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            currentTeeth = "assets/games/self_care/images/openmouth_face.png";
          });
        }
      });
    }
  }

  void stopBrushing() {
    bubbleTimer?.cancel();
    bubbleTimer = null;
  }

  void rinseTeeth() async {
    if (isBrushed && !isRinsing) {
      stopBrushing();
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
          currentTeeth = "assets/games/self_care/images/smile_face.png";
        });

        // ✅ Save time of brushing (for 10 min clean state)
        await GameProgressPreference.saveProgress(
          studentId: widget.studentId,
          lessonId: widget.lessonId,
          gameId: widget.gameId,
          subgameName: 'brush_teeth',
        );
        await _saveBrushTime();
      });
    }
  }

  @override
  void dispose() {
    stopBrushing();
    _waterController.dispose();
    _menuScaleController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => showMenuPopup = !showMenuPopup);
    if (showMenuPopup) _menuScaleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/games/self_care/images/cr1.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: size.height * 0.04,
            left: 25,
            child: Image.asset(
              "assets/games/self_care/images/logo.png",
              height: 65,
            ),
          ),
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
                  "Carl's teeth are dirty! Help him brush them clean.",
                  style: GoogleFonts.dynaPuff(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 😬 Teeth area
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Image.asset(
                  currentTeeth,
                  height: size.height * 0.5,
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
                            color: Colors.white.withOpacity(0.85),
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

          // 🪥 Toothbrush
          Positioned(
            bottom: 145,
            left: 80,
            child: Draggable(
              data: "brush",
              feedback: Image.asset(
                "assets/games/self_care/images/toothbrush.png",
                height: 80,
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  "assets/games/self_care/images/toothbrush.png",
                  height: 80,
                ),
              ),
              onDragStarted: startBrushing,
              onDragEnd: (_) => stopBrushing(),
              child: Image.asset(
                "assets/games/self_care/images/toothbrush.png",
                height: 80,
              ),
            ),
          ),

          // 🚿 Water
          Positioned(
            bottom: 145,
            right: 80,
            child: Draggable(
              data: "water",
              feedback: Image.asset(
                "assets/games/self_care/images/water.png",
                height: 80,
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  "assets/games/self_care/images/water.png",
                  height: 80,
                ),
              ),
              onDragEnd: (_) => rinseTeeth(),
              child: Image.asset(
                "assets/games/self_care/images/water.png",
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
                        builder: (_) => LivingRoomScreen(
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
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KitchenScreen(
                          lessonId: widget.lessonId,
                          studentId: widget.studentId,
                          gameId: widget.gameId,
                        ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  "assets/games/self_care/images/showericon.png",
                  "Shower",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShowerScreen(
                          lessonId: widget.lessonId,
                          studentId: widget.studentId,
                          gameId: widget.gameId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          if (showMenuPopup) _buildMenuPopup(),
          if (showHowToPlay)
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
                      onTap: () => setState(() => showHowToPlay = false),
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
                onTap: () {
                  setState(() {
                    showMenuPopup = false;
                    showHowToPlay = true;
                  });
                },
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
            style: GoogleFonts.dynaPuff(
              fontSize: 12,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble {
  final double left;
  final double top;
  final double size;
  _Bubble({required this.left, required this.top, required this.size});
}

class _WaterPainter extends CustomPainter {
  final double offsetY;
  final Random random = Random();
  _WaterPainter({required this.offsetY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.25)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 80; i++) {
      final startX = random.nextDouble() * size.width;
      final startY =
          (random.nextDouble() * size.height + offsetY) % size.height;
      final length = 10 + random.nextDouble() * 15;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX, startY + length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) => true;
}
