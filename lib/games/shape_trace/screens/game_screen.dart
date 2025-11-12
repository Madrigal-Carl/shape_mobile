// tracing_game_screen_shapes.dart
// Modified from original tracing game to trace real shapes (outline) instead of letters

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';

class TracingGameScreen extends StatefulWidget {
  final bool isMuted;
  final VoidCallback onToggleMute;
  final int lessonId;
  final int studentId;
  final int gameId;

  const TracingGameScreen({
    super.key,
    required this.isMuted,
    required this.onToggleMute,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<TracingGameScreen> createState() => _TracingGameScreenState();
}

class _TracingGameScreenState extends State<TracingGameScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  final GlobalKey _paintKey = GlobalKey();

  final List<Offset> tracedPoints = [];
  final List<String> shapes = [
    "Square",
    "Triangle",
    "Circle",
    "Oval",
    "Rectangle",
    "Diamond",
    "Star",
    "Heart",
  ];
  late String currentShape;

  final List<Offset> _guideDots = [];
  final Set<int> _coveredDotIndices = {};

  int score = 0;
  int completedShapes = 0;
  bool showWinPopup = false;

  // Menu / How-to state
  bool showMenuPopup = false;
  bool showHowToPlay = false;
  late AnimationController _menuScaleController;
  late Animation<double> _menuScaleAnim;

  // Settings
  final double _pointMinDistance = 3.0;
  final double _coverageThreshold = 0.78;
  final double _sampleDistance = 8.0; // sample along path every N pixels
  final int _dotRadius = 4;
  final double _dotHitRadius = 14.0; // how close finger must be to a guide dot

  bool _isComputingDots = false;

  Timer? _coverageDebounceTimer;
  Timer? _sustainedCoverageTimer;
  final Duration _coverageDebounce = const Duration(milliseconds: 120);
  final Duration _sustainedCoverageRequired = const Duration(milliseconds: 600);

  // Guard to prevent double completion
  bool _shapeCompleted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _menuScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuScaleAnim = CurvedAnimation(
      parent: _menuScaleController,
      curve: Curves.elasticOut,
    );

    _nextShape();
  }

  void _openMenu() {
    setState(() => showMenuPopup = true);
    _menuScaleController.forward(from: 0.0);
  }

  void _closeMenu() {
    _menuScaleController.reverse().whenComplete(() {
      if (mounted) setState(() => showMenuPopup = false);
    });
  }

  void _nextShape() {
    setState(() {
      tracedPoints.clear();
      _guideDots.clear();
      _coveredDotIndices.clear();
      currentShape = (shapes..shuffle()).first;
      showWinPopup = false;
      _shapeCompleted = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeGuideDots());
  }

  void _onCompleteShape() {
    if (_shapeCompleted) return; // guard against double
    _shapeCompleted = true;

    _sustainedCoverageTimer?.cancel();
    _sustainedCoverageTimer = null;

    _confettiController.play();
    setState(() => score += 10);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        completedShapes++;
      });

      if (completedShapes >= 3) {
        GameProgressPreference.saveProgress(
          studentId: widget.studentId,
          lessonId: widget.lessonId,
          gameId: widget.gameId,
          subgameName: 'shape_trace',
        );
        setState(() => showWinPopup = true);
      } else {
        _nextShape();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    _menuScaleController.dispose();
    _coverageDebounceTimer?.cancel();
    _sustainedCoverageTimer?.cancel();
    super.dispose();
  }

  double _distance(Offset a, Offset b) => (a - b).distance;

  /// Build a path for the named shape centered in the provided rect (0..size)
  Path _buildShapePath(String shapeName, Size size) {
    final w = size.width;
    final h = size.height;
    final Path path = Path();
    switch (shapeName) {
      case 'Square':
        final side = min(w, h) * 0.7;
        final dx = (w - side) / 2.0;
        final dy = (h - side) / 2.0;
        path.addRect(Rect.fromLTWH(dx, dy, side, side));
        break;
      case 'Rectangle':
        final rw = w * 0.85;
        final rh = h * 0.6;
        path.addRect(Rect.fromLTWH((w - rw) / 2, (h - rh) / 2, rw, rh));
        break;
      case 'Circle':
        final r = min(w, h) * 0.35;
        path.addOval(Rect.fromCircle(center: Offset(w / 2, h / 2), radius: r));
        break;
      case 'Oval':
        path.addOval(
          Rect.fromCenter(
            center: Offset(w / 2, h / 2),
            width: w * 0.8,
            height: h * 0.55,
          ),
        );
        break;
      case 'Triangle':
        path.moveTo(w / 2, h * 0.15);
        path.lineTo(w * 0.85, h * 0.82);
        path.lineTo(w * 0.15, h * 0.82);
        path.close();
        break;
      case 'Diamond':
        path.moveTo(w / 2, h * 0.12);
        path.lineTo(w * 0.88, h / 2);
        path.lineTo(w / 2, h * 0.88);
        path.lineTo(w * 0.12, h / 2);
        path.close();
        break;
      case 'Star':
        // 5-point star
        final cx = w / 2;
        final cy = h / 2;
        final outer = min(w, h) * 0.36;
        final inner = outer * 0.45;
        for (int i = 0; i < 5; i++) {
          final a = -pi / 2 + i * 2 * pi / 5;
          final ax = cx + outer * cos(a);
          final ay = cy + outer * sin(a);
          final a2 = a + pi / 5;
          final bx = cx + inner * cos(a2);
          final by = cy + inner * sin(a2);
          if (i == 0) {
            path.moveTo(ax, ay);
          } else {
            path.lineTo(ax, ay);
          }
          path.lineTo(bx, by);
        }
        path.close();
        break;
      case 'Heart':
        // approximate heart with bezier curves
        final cx = w / 2;
        final cy = h / 2.3;
        final scale = min(w, h) * 0.24;
        path.moveTo(cx, cy + scale * 1.2);
        path.cubicTo(
          cx + scale * 2.2,
          cy - scale * 0.2,
          cx + scale * 1.6,
          cy - scale * 1.4,
          cx,
          cy - scale * 0.2,
        );
        path.cubicTo(
          cx - scale * 1.6,
          cy - scale * 1.4,
          cx - scale * 2.2,
          cy - scale * 0.2,
          cx,
          cy + scale * 1.2,
        );
        path.close();
        break;
      default:
        final r = min(w, h) * 0.35;
        path.addOval(Rect.fromCircle(center: Offset(w / 2, h / 2), radius: r));
        break;
    }
    return path;
  }

  Future<void> _computeGuideDots() async {
    if (_isComputingDots) return;
    _isComputingDots = true;

    final ctx = _paintKey.currentContext;
    if (ctx == null) {
      _isComputingDots = false;
      return;
    }
    final box = ctx.findRenderObject() as RenderBox;
    final size = box.size;
    if (size.width <= 0 || size.height <= 0) {
      _isComputingDots = false;
      return;
    }

    final Path path = _buildShapePath(currentShape, size);

    // use PathMetrics to sample points along the path
    final List<Offset> sampledDots = [];
    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      if (length <= 0) continue;
      for (double d = 0; d < length; d += _sampleDistance) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;
        sampledDots.add(tangent.position);
      }
      // ensure last point included
      final lastT = metric.getTangentForOffset(length - 0.1);
      if (lastT != null) sampledDots.add(lastT.position);
    }

    if (!mounted) {
      _isComputingDots = false;
      return;
    }

    setState(() {
      _guideDots
        ..clear()
        ..addAll(sampledDots);
      _coveredDotIndices.clear();
      _shapeCompleted = false; // ready to track this shape
    });

    _isComputingDots = false;
  }

  bool _isNearGuide(Offset point) {
    if (_guideDots.isEmpty) return false;
    for (final dot in _guideDots) {
      if (_distance(dot, point) <= _dotHitRadius * 1.05) return true;
    }
    return false;
  }

  void _updateCoverageFromPoints({bool scheduleDebounce = true}) {
    if (_guideDots.isEmpty) return;
    for (int i = 0; i < _guideDots.length; i++) {
      if (_coveredDotIndices.contains(i)) continue;
      final dot = _guideDots[i];
      for (final p in tracedPoints) {
        if (_distance(dot, p) <= _dotHitRadius) {
          _coveredDotIndices.add(i);
          break;
        }
      }
    }

    final coverage =
        _coveredDotIndices.length /
        (_guideDots.isEmpty ? 1 : _guideDots.length);

    if (coverage >= _coverageThreshold) {
      if (_sustainedCoverageTimer == null ||
          !_sustainedCoverageTimer!.isActive) {
        _sustainedCoverageTimer = Timer(_sustainedCoverageRequired, () {
          final currentCoverage =
              _coveredDotIndices.length /
              (_guideDots.isEmpty ? 1 : _guideDots.length);
          if (currentCoverage >= _coverageThreshold && !_shapeCompleted) {
            _onCompleteShape();
          } else {
            _sustainedCoverageTimer?.cancel();
            _sustainedCoverageTimer = null;
          }
        });
      }
    } else {
      _sustainedCoverageTimer?.cancel();
      _sustainedCoverageTimer = null;
    }

    if (scheduleDebounce) {
      _coverageDebounceTimer?.cancel();
      _coverageDebounceTimer = Timer(_coverageDebounce, () {
        if (mounted) setState(() {});
      });
    } else {
      if (mounted) setState(() {});
    }
  }

  Offset? _globalToLocalInPaintBox(Offset globalPosition) {
    final ctx = _paintKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox;
    return box.globalToLocal(globalPosition);
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
                onTap: () {
                  // continue
                  _closeMenu();
                },
                child: Image.asset(
                  "assets/games/shape_trace/images/continue.png",
                  height: 70,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _closeMenu();
                    showHowToPlay = true;
                  });
                },
                child: Image.asset(
                  "assets/games/shape_trace/images/htp.png",
                  height: 70,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "assets/games/shape_trace/images/quit.png",
                  height: 70,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final double shapeProgress = _guideDots.isEmpty
        ? 0.0
        : (_coveredDotIndices.length /
              (_guideDots.isEmpty ? 1 : _guideDots.length));

    return WillPopScope(
      onWillPop: () async {
        if (showWinPopup) {
          return false;
        }
        if (showHowToPlay) {
          setState(() => showHowToPlay = false);
          return false;
        }
        if (showMenuPopup) {
          _closeMenu();
          return false;
        }
        setState(() {
          showMenuPopup = true;
          _menuScaleController.forward(from: 0.0);
        });
        return false;
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/games/shape_trace/images/bg2.png',
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                gravity: 0.4,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/games/shape_trace/images/scoreplaceholder.png',
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
                          onTap: _openMenu,
                          child: Image.asset(
                            'assets/games/shape_trace/images/menu.png',
                            width: 55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Tracing Game",
                    style: GoogleFonts.dynaPuff(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Use your finger to trace the SHAPE outline.\nTry to follow the line closely!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dynaPuff(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/games/shape_trace/images/blackboard.png',
                            width: 350,
                          ),
                          GestureDetector(
                            onPanStart: (details) {
                              final local = _globalToLocalInPaintBox(
                                details.globalPosition,
                              );
                              if (local == null) return;

                              if (_guideDots.isEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _computeGuideDots(),
                                );
                                setState(() {
                                  tracedPoints.add(local);
                                });
                                return;
                              }

                              if (!_isNearGuide(local)) return;
                              setState(() => tracedPoints.add(local));
                              _updateCoverageFromPoints(
                                scheduleDebounce: false,
                              );
                            },
                            onPanUpdate: (details) {
                              final local = _globalToLocalInPaintBox(
                                details.globalPosition,
                              );
                              if (local == null) return;

                              if (_guideDots.isEmpty) {
                                if (tracedPoints.isEmpty ||
                                    _distance(tracedPoints.last, local) >
                                        _pointMinDistance) {
                                  tracedPoints.add(local);
                                  if (tracedPoints.length % 3 == 0)
                                    setState(() {});
                                }
                                return;
                              }

                              if (!_isNearGuide(local)) return;
                              if (tracedPoints.isEmpty ||
                                  _distance(tracedPoints.last, local) >
                                      _pointMinDistance) {
                                tracedPoints.add(local);
                                _updateCoverageFromPoints(
                                  scheduleDebounce: true,
                                );
                                if (tracedPoints.length % 3 == 0)
                                  setState(() {});
                              }
                            },
                            onPanEnd: (_) {
                              _coverageDebounceTimer?.cancel();
                              _coverageDebounceTimer = Timer(
                                _coverageDebounce,
                                () => _updateCoverageFromPoints(
                                  scheduleDebounce: false,
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: SizedBox(
                                key: _paintKey,
                                width: 300,
                                height: 220,
                                child: CustomPaint(
                                  painter: _ShapeGuideAndTracePainter(
                                    shapeName: currentShape,
                                    guideDots: _guideDots,
                                    coveredDotIndices: _coveredDotIndices,
                                    tracedPoints: tracedPoints,
                                    dotRadius: _dotRadius,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        Text(
                          currentShape,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Trace the outline",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 220,
                          child: LinearProgressIndicator(
                            value: shapeProgress.clamp(0.0, 1.0),
                            backgroundColor: Colors.white24,
                            color: Colors.greenAccent,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Completed shapes: $completedShapes / 3",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (showWinPopup)
              Container(
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/games/shape_trace/images/complete.png",
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
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Image.asset(
                                "assets/games/shape_trace/images/home.png",
                                width: 55,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  score = 0;
                                  completedShapes = 0;
                                  tracedPoints.clear();
                                  showWinPopup = false;
                                  _nextShape();
                                });
                              },
                              child: Image.asset(
                                "assets/games/shape_trace/images/restart.png",
                                width: 55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Menu popup overlay
            if (showMenuPopup) _buildMenuPopup(),

            // How to play overlay
            if (showHowToPlay)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.asset(
                        "assets/games/shape_trace/images/how.png",
                        width: 330,
                        fit: BoxFit.contain,
                      ),
                      GestureDetector(
                        onTap: () => setState(() => showHowToPlay = false),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            "assets/games/shape_trace/images/x.png",
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
}

class _ShapeGuideAndTracePainter extends CustomPainter {
  final String shapeName;
  final List<Offset> guideDots;
  final Set<int> coveredDotIndices;
  final List<Offset> tracedPoints;
  final int dotRadius;

  _ShapeGuideAndTracePainter({
    required this.shapeName,
    required this.guideDots,
    required this.coveredDotIndices,
    required this.tracedPoints,
    required this.dotRadius,
  });

  Path _buildShapePathForPaint(Size size) {
    final w = size.width;
    final h = size.height;
    final Path path = Path();
    switch (shapeName) {
      case 'Square':
        final side = min(w, h) * 0.7;
        final dx = (w - side) / 2.0;
        final dy = (h - side) / 2.0;
        path.addRect(Rect.fromLTWH(dx, dy, side, side));
        break;
      case 'Rectangle':
        final rw = w * 0.85;
        final rh = h * 0.6;
        path.addRect(Rect.fromLTWH((w - rw) / 2, (h - rh) / 2, rw, rh));
        break;
      case 'Circle':
        final r = min(w, h) * 0.35;
        path.addOval(Rect.fromCircle(center: Offset(w / 2, h / 2), radius: r));
        break;
      case 'Oval':
        path.addOval(
          Rect.fromCenter(
            center: Offset(w / 2, h / 2),
            width: w * 0.8,
            height: h * 0.55,
          ),
        );
        break;
      case 'Triangle':
        path.moveTo(w / 2, h * 0.15);
        path.lineTo(w * 0.85, h * 0.82);
        path.lineTo(w * 0.15, h * 0.82);
        path.close();
        break;
      case 'Diamond':
        path.moveTo(w / 2, h * 0.12);
        path.lineTo(w * 0.88, h / 2);
        path.lineTo(w / 2, h * 0.88);
        path.lineTo(w * 0.12, h / 2);
        path.close();
        break;
      case 'Star':
        final cx = w / 2;
        final cy = h / 2;
        final outer = min(w, h) * 0.36;
        final inner = outer * 0.45;
        for (int i = 0; i < 5; i++) {
          final a = -pi / 2 + i * 2 * pi / 5;
          final ax = cx + outer * cos(a);
          final ay = cy + outer * sin(a);
          final a2 = a + pi / 5;
          final bx = cx + inner * cos(a2);
          final by = cy + inner * sin(a2);
          if (i == 0) {
            path.moveTo(ax, ay);
          } else {
            path.lineTo(ax, ay);
          }
          path.lineTo(bx, by);
        }
        path.close();
        break;
      case 'Heart':
        final cx = w / 2;
        final cy = h / 2.3;
        final scale = min(w, h) * 0.24;
        path.moveTo(cx, cy + scale * 1.2);
        path.cubicTo(
          cx + scale * 2.2,
          cy - scale * 0.2,
          cx + scale * 1.6,
          cy - scale * 1.4,
          cx,
          cy - scale * 0.2,
        );
        path.cubicTo(
          cx - scale * 1.6,
          cy - scale * 1.4,
          cx - scale * 2.2,
          cy - scale * 0.2,
          cx,
          cy + scale * 1.2,
        );
        path.close();
        break;
      default:
        final r = min(w, h) * 0.35;
        path.addOval(Rect.fromCircle(center: Offset(w / 2, h / 2), radius: r));
        break;
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // faint outline of the target shape
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shapePath = _buildShapePathForPaint(size);
    canvas.drawPath(shapePath, outlinePaint);

    // dots
    final paintUncovered = Paint()..color = Colors.white.withOpacity(0.25);
    final paintCovered = Paint()..color = Colors.greenAccent.withOpacity(0.95);

    for (int i = 0; i < guideDots.length; i++) {
      final p = guideDots[i];
      final paint = coveredDotIndices.contains(i)
          ? paintCovered
          : paintUncovered;
      canvas.drawCircle(p, dotRadius.toDouble(), paint);
    }

    // visible trace
    if (tracedPoints.length >= 2) {
      final pathPaint = Paint()
        ..color = Colors.yellowAccent
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(tracedPoints.first.dx, tracedPoints.first.dy);
      for (int i = 1; i < tracedPoints.length; i++) {
        path.lineTo(tracedPoints[i].dx, tracedPoints[i].dy);
      }
      canvas.drawPath(path, pathPaint);
    }

    // glowing tip
    if (tracedPoints.isNotEmpty) {
      final last = tracedPoints.last;
      final tipPaint = Paint()
        ..color = Colors.yellowAccent.withOpacity(0.95)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
      canvas.drawCircle(last, 6.0, tipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapeGuideAndTracePainter oldDelegate) =>
      oldDelegate.guideDots != guideDots ||
      oldDelegate.coveredDotIndices != coveredDotIndices ||
      oldDelegate.tracedPoints != tracedPoints ||
      oldDelegate.shapeName != shapeName;
}
