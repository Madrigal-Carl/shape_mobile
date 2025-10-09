import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/recent_lesson.dart';
import 'package:shape_mobile/widgets/game_collection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> games = [
      {"image": "assets/flutter/games/find_items.png", "title": "Flappy Bird"},
      {"image": "assets/flutter/games/puzzle.png", "title": "Puzzle"},
      {
        "image": "assets/flutter/games/coloring.png",
        "title": "Creative Coloring",
      },
      {
        "image": "assets/flutter/games/trace.png",
        "title": "Trace the alphabet",
      },
      {"image": "assets/flutter/games/self_care.png", "title": "Self Care"},
      {"image": "assets/flutter/games/make_a_pair.png", "title": "Make a pair"},
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              const GreetingWidget(),
              const RecentLessonWidget(),
              GameCollectionWidget(games: games, title: 'Casual Games'),
            ],
          ),
        ),
      ),
    );
  }
}
