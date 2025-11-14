import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/recent_lesson.dart';
import 'package:shape_mobile/widgets/casual_game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              const GreetingWidget(),
              const RecentLessonWidget(),
              CasualGamesSection(
                games: [CasualGame(id: 1, title: "Count Quest")],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
