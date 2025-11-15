import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/recent_lesson.dart';
// import 'package:shape_mobile/widgets/casual_game_card.dart';
import 'package:shape_mobile/widgets/temp_game_card.dart';

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
                  CasualGame(id: 1, title: "Count Quest"),
                  CasualGame(id: 2, title: "Finger Addition"),
                  CasualGame(id: 3, title: "Fruit Subtraction"),
                  CasualGame(id: 4, title: "Objectify"),
                  CasualGame(id: 5, title: "Fruit Addition"),
                  CasualGame(id: 6, title: "Finger Subtraction"),
                  CasualGame(id: 7, title: "Sign Quest"),
                  CasualGame(id: 8, title: "Cast Spell"),
                  CasualGame(id: 9, title: "Number Quest"),
                  CasualGame(id: 10, title: "Self Care"),
                  CasualGame(id: 11, title: "Sort Safari"),
                  CasualGame(id: 12, title: "The Fairly Multiplication"),
                  CasualGame(id: 13, title: "Animal Trace"),
                  CasualGame(id: 14, title: "Shape Trace"),
                  CasualGame(id: 15, title: "Count To 100"),
                  CasualGame(id: 16, title: "Match Mania"),
                  CasualGame(id: 17, title: "Emotion Test"),
                  CasualGame(id: 18, title: "Tracing Time"),
                  CasualGame(id: 19, title: "Balloon Pop"),
                ],
              ),

              // Casual Flame
              // CasualGamesSection(
              //   games: [
              //     CasualGame(
              //       id: 1,
              //       title: "Match a Pair",
              //       thumbnailPath:
              //           "assets/casual_games/match_a_pair/match-and-pair-icon.png",
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
