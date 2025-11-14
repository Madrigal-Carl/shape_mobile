import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/recent_lesson.dart';
import 'package:shape_mobile/widgets/casual_game_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _resetPortraitOrientation();
  }

  Future<void> _resetPortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GreetingWidget(),
              const RecentLessonWidget(),
              CasualGamesSection(
                games: [
                  CasualGame(
                    id: 1,
                    title: "Match a Pair",
                    thumbnailPath:
                        "assets/games/count_quest/count-quest-icon.png",
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
