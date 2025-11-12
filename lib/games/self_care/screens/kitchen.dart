import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shape_mobile/services/game_progress_preference.dart';
import 'teeth.dart';
import 'shower.dart';
import 'living_room.dart';
import '../main.dart';

class KitchenScreen extends StatefulWidget {
  final int lessonId;
  final int studentId;
  final int gameId;

  const KitchenScreen({
    super.key,
    required this.lessonId,
    required this.studentId,
    required this.gameId,
  });

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen>
    with TickerProviderStateMixin {
  String currentCarlFace = "assets/games/self_care/images/hungry_face.png";

  bool showMenuPopup = false;
  bool showHowPopup = false;

  late AnimationController _menuScaleController;
  late Animation<double> _menuScaleAnim;

  late AnimationController _chewController;
  late Animation<double> _chewScale;
  bool isChewing = false;

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefsAndState();

    _menuScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuScaleAnim = CurvedAnimation(
      parent: _menuScaleController,
      curve: Curves.easeOutBack,
    );

    _chewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _chewScale =
        Tween<double>(
            begin: 0.95,
            end: 1.05,
          ).chain(CurveTween(curve: Curves.easeInOut)).animate(_chewController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _chewController.reverse();
            }
          });
  }

  Future<void> _initPrefsAndState() async {
    _prefs = await SharedPreferences.getInstance();
    final lastEatTimeString = _prefs?.getString('last_eat_time');

    if (lastEatTimeString != null) {
      final lastEatTime = DateTime.tryParse(lastEatTimeString);
      if (lastEatTime != null) {
        final diff = DateTime.now().difference(lastEatTime);
        if (diff.inMinutes < 10) {
          // ✅ Still full
          setState(() {
            currentCarlFace = "assets/games/self_care/images/smile_face.png";
          });
          return;
        }
      }
    }

    // 😋 Hungry again after 10 minutes
    setState(() {
      currentCarlFace = "assets/games/self_care/images/hungry_face.png";
    });
  }

  Future<void> _saveHungerAfterFeeding() async {
    if (_prefs == null) return;
    _prefs!.setDouble("carl_hunger", 0);
    await _prefs!.setString('last_eat_time', DateTime.now().toIso8601String());
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

  Future<void> _chewFood() async {
    if (isChewing) return;
    setState(() {
      isChewing = true;
      currentCarlFace = "assets/games/self_care/images/chew.png";
    });

    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      _chewController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 350));
    }

    if (!mounted) return;
    setState(() {
      currentCarlFace = "assets/games/self_care/images/smile_face.png";
      isChewing = false;
    });

    // ✅ Save eat time so Carl stays full for 10 minutes
    await GameProgressPreference.saveProgress(
      studentId: widget.studentId,
      lessonId: widget.lessonId,
      gameId: widget.gameId,
      subgameName: 'eat',
    );
    await _saveHungerAfterFeeding();
  }

  @override
  void dispose() {
    _menuScaleController.dispose();
    _chewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /// 🏡 Background
          Positioned.fill(
            child: Image.asset(
              "assets/games/self_care/images/kitchen.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 🧼 Logo
          Positioned(
            top: 50,
            left: 30,
            child: Image.asset(
              "assets/games/self_care/images/logo.png",
              height: 60,
            ),
          ),

          /// 🍔 Menu Button
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

          /// ✨ Title
          Positioned(
            top: size.height * 0.13,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Kitchen",
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
                  "Feed Carl! He's hungry again.",
                  style: GoogleFonts.dynaPuff(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          /// 🧍‍♂️ Carl Face (with chew animation)
          Align(
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _chewScale,
              child: Image.asset(
                currentCarlFace,
                height: size.height * 0.45,
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// 🍎 Food items (draggable)
          Positioned(
            bottom: 155,
            left: 80,
            child: _buildFood("assets/games/self_care/images/apple.png"),
          ),
          Positioned(
            bottom: 155,
            left: size.width / 2 - 30,
            child: _buildFood("assets/games/self_care/images/chicken.png"),
          ),
          Positioned(
            bottom: 155,
            right: 90,
            child: _buildFood("assets/games/self_care/images/carrot.png"),
          ),

          /// 🧭 Bottom Navigation
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomButton(
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
                _buildBottomButton(
                  "assets/games/self_care/images/teeth.png",
                  "Brush",
                  () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TeethScreen(
                              lessonId: widget.lessonId,
                              studentId: widget.studentId,
                              gameId: widget.gameId,
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 400),
                        reverseTransitionDuration: const Duration(
                          milliseconds: 300,
                        ),
                      ),
                    );
                  },
                ),
                _buildBottomButton(
                  "assets/games/self_care/images/showericon.png",
                  "Shower",
                  () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ShowerScreen(
                              lessonId: widget.lessonId,
                              studentId: widget.studentId,
                              gameId: widget.gameId,
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 400),
                        reverseTransitionDuration: const Duration(
                          milliseconds: 300,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          /// 📋 Menu Popup
          if (showMenuPopup) _buildMenuPopup(),

          /// ❓ How-to-play Popup (with close.png)
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

  /// 🍽 Draggable Food
  Widget _buildFood(String asset) {
    return Draggable<String>(
      data: asset,
      feedback: Image.asset(asset, height: 60),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Image.asset(asset, height: 60),
      ),
      onDragStarted: () {
        setState(
          () => currentCarlFace =
              "assets/games/self_care/images/openmouth_face.png",
        );
      },
      onDragEnd: (_) {
        _chewFood();
      },
      child: Image.asset(asset, height: 60),
    );
  }

  /// 🧭 Bottom Button Widget
  Widget _buildBottomButton(String asset, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 60),
          const SizedBox(height: 4),
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

  /// 📋 Menu Popup
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
