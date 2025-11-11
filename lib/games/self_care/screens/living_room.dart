import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kitchen.dart';
import 'teeth.dart';
import 'shower.dart';

class LivingRoomScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const LivingRoomScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<LivingRoomScreen> createState() => _LivingRoomScreenState();
}

class _LivingRoomScreenState extends State<LivingRoomScreen>
    with TickerProviderStateMixin {
  bool showMenuPopup = false;
  bool showHowToPlay = false;

  late AnimationController _menuScaleController;
  late Animation<double> _menuScaleAnim;
  late AnimationController _carlIdleController;
  late AnimationController _blinkController;
  late AnimationController _tapReactionController;

  bool isCarlTapped = false;
  String currentCarlImage = "assets/games/self_care/images/livingr_normal.png";

  Timer? _needTimer;

  double hunger = 0;
  double cleanliness = 0;
  double dental = 0;

  final GlobalKey _carlKey = GlobalKey();
  final List<_HeartParticle> _hearts = [];
  final double _heartDuration = 1.0;

  @override
  void initState() {
    super.initState();
    _menuScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuScaleAnim = CurvedAnimation(
      parent: _menuScaleController,
      curve: Curves.easeOutBack,
    );

    _carlIdleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _tapReactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.9,
      upperBound: 1.1,
    );

    _initPrefsAndLoad();
    _blink();
    _startNeedsTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAllCareTimes();
  }

  Future<void> _initPrefsAndLoad() async {
    await _checkAllCareTimes();
  }

  /// 🔍 Check if Carl has eaten, brushed, and showered within 10 minutes
  Future<void> _checkAllCareTimes() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    final eatTime = DateTime.tryParse(prefs.getString('last_eat_time') ?? '');
    final brushTime = DateTime.tryParse(
      prefs.getString('last_brush_time') ?? '',
    );
    final showerTime = DateTime.tryParse(
      prefs.getString('last_shower_time') ?? '',
    );

    bool recentlyAte =
        eatTime != null && now.difference(eatTime).inMinutes < 10;
    bool recentlyBrushed =
        brushTime != null && now.difference(brushTime).inMinutes < 10;
    bool recentlyShowered =
        showerTime != null && now.difference(showerTime).inMinutes < 10;

    setState(() {
      if (recentlyAte && recentlyBrushed && recentlyShowered) {
        currentCarlImage =
            "assets/games/self_care/images/smile_face.png"; // 😁 All done
      } else if (!recentlyAte) {
        currentCarlImage =
            "assets/games/self_care/images/hungry_face.png"; // 🍽️ Hungry
      } else if (!recentlyBrushed) {
        currentCarlImage =
            "assets/games/self_care/images/dirtyteeth.png"; // 🦷 Dirty teeth
      } else if (!recentlyShowered) {
        currentCarlImage =
            "assets/games/self_care/images/dirtface.png"; // 🧼 Dirty
      } else {
        currentCarlImage =
            "assets/games/self_care/images/livingr_normal.png"; // default neutral
      }
    });
  }

  void _startNeedsTimer() {
    const tick = Duration(seconds: 5);
    _needTimer = Timer.periodic(tick, (timer) {
      _checkAllCareTimes();
    });
  }

  void _blink() async {
    final random = Random();
    while (mounted) {
      await Future.delayed(Duration(seconds: 3 + random.nextInt(3)));
      await _blinkController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      await _blinkController.reverse();
    }
  }

  @override
  void dispose() {
    _menuScaleController.dispose();
    _carlIdleController.dispose();
    _blinkController.dispose();
    _tapReactionController.dispose();
    _needTimer?.cancel();
    for (final h in _hearts) {
      h.controller.dispose();
    }
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      if (showHowToPlay) {
        // If How to Play is open, close it first
        showHowToPlay = false;
      } else if (showMenuPopup) {
        // If Main Menu is already open, close it
        showMenuPopup = false;
      } else {
        // Otherwise, open the Main Menu popup
        showMenuPopup = true;
        _menuScaleController.forward(from: 0);
      }
    });
  }

  void _createHeartsAndAnimate() {
    final renderBox = _carlKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final carlPos = renderBox.localToGlobal(Offset.zero);
    final carlSize = renderBox.size;
    final startX = carlPos.dx + carlSize.width / 2;
    final startY = carlPos.dy + carlSize.height / 4;
    final rng = Random();

    for (int i = 0; i < 3; i++) {
      final dx = (rng.nextDouble() * 120) - 60;
      final dy = -(rng.nextDouble() * 160 + 80);
      final rotation = (rng.nextDouble() - 0.5) * 1.0;

      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (_heartDuration * 1000).toInt()),
      );

      final particle = _HeartParticle(
        controller: controller,
        start: Offset(startX, startY),
        end: Offset(startX + dx, startY + dy),
        rotation: rotation,
        delay: i * 80,
      );

      setState(() => _hearts.add(particle));

      Future.delayed(Duration(milliseconds: particle.delay), () {
        if (!mounted) return;
        particle.controller.forward().whenComplete(() {
          particle.controller.dispose();
          if (mounted) setState(() => _hearts.remove(particle));
        });
      });
    }
  }

  void _onTapCarl() async {
    if (isCarlTapped) return;
    setState(() => isCarlTapped = true);
    _createHeartsAndAnimate();

    await _tapReactionController.forward();
    await _tapReactionController.reverse();
    setState(() => isCarlTapped = false);
  }

  void _goToTeethWithFade() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, _, __) => TeethScreen(
          lessonId: widget.lessonId,
          studentId: widget.studentId,
          gameId: widget.gameId,
        ),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _goToKitchenWithFade() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, _, __) => KitchenScreen(
          lessonId: widget.lessonId,
          studentId: widget.studentId,
          gameId: widget.gameId,
        ),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _goToShowerWithFade() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, _, __) => ShowerScreen(
          lessonId: widget.lessonId,
          studentId: widget.studentId,
          gameId: widget.gameId,
        ),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        _toggleMenu();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/games/self_care/images/livingroom.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 50,
              left: 30,
              child: Image.asset(
                "assets/games/self_care/images/logo.png",
                height: 60,
              ),
            ),
            Positioned(
              top: 50,
              right: 30,
              child: GestureDetector(
                onTap: _toggleMenu,
                child: Image.asset(
                  "assets/games/self_care/images/menu.png",
                  height: 50,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _carlIdleController,
                  _tapReactionController,
                ]),
                builder: (context, child) {
                  double bounce = 8 * _carlIdleController.value;
                  double scale = _tapReactionController.value == 0.0
                      ? 1.0
                      : _tapReactionController.value;
                  return GestureDetector(
                    onTap: _onTapCarl,
                    child: Transform.translate(
                      offset: Offset(0, bounce),
                      child: Transform.scale(
                        scale: scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              key: _carlKey,
                              width: size.width,
                              child: Image.asset(
                                currentCarlImage,
                                height: size.height * 0.75,
                                fit: BoxFit.contain,
                              ),
                            ),
                            FadeTransition(
                              opacity: Tween(
                                begin: 1.0,
                                end: 0.0,
                              ).animate(_blinkController),
                              child: Container(
                                height: size.height * 0.45,
                                color: Colors.transparent,
                              ),
                            ),
                            ..._hearts.map(_buildHeartWidget).toList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: size.height * 0.17,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    "Living Room",
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
                  const SizedBox(height: 8),
                  Text(
                    "Take care of Carl — feed, wash, and brush him!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dynaPuff(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    "assets/games/self_care/images/kc.png",
                    "Eat",
                    _goToKitchenWithFade,
                  ),
                  _buildActionButton(
                    "assets/games/self_care/images/teeth.png",
                    "Brush",
                    _goToTeethWithFade,
                  ),
                  _buildActionButton(
                    "assets/games/self_care/images/showericon.png",
                    "Shower",
                    _goToShowerWithFade,
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
      ),
    );
  }

  Widget _buildHeartWidget(_HeartParticle p) {
    return AnimatedBuilder(
      animation: p.controller,
      builder: (context, child) {
        final t = Curves.easeOut.transform(p.controller.value);
        final x = lerpDouble(p.start.dx, p.end.dx, t) ?? p.start.dx;
        final y = lerpDouble(p.start.dy, p.end.dy, t) ?? p.start.dy;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        final scale = 0.6 + 0.6 * (1 - (t));
        return Positioned(
          left: x - 12,
          top: y - 12,
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: p.rotation * t,
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  Icons.favorite,
                  size: 24,
                  color: Colors.pinkAccent.withOpacity(0.95),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String asset, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 60),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.dynaPuff(
              color: Colors.white,
              fontSize: 14,
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
                  Navigator.pop(context);
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

class _HeartParticle {
  final AnimationController controller;
  final Offset start;
  final Offset end;
  final double rotation;
  final int delay;
  _HeartParticle({
    required this.controller,
    required this.start,
    required this.end,
    required this.rotation,
    this.delay = 0,
  });
}

double? lerpDouble(num a, num b, double t) => a + (b - a) * t;
