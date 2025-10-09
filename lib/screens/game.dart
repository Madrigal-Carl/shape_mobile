import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/game_collection.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> games = [
      {
        "image": "assets/flutter/games/find_items.png",
        "title": "Find the Item",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/games/puzzle.png",
        "title": "Puzzle",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/games/coloring.png",
        "title": "Creative Coloring",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/games/trace.png",
        "title": "Trace the alphabet",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/games/self_care.png",
        "title": "Self Care",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/games/make_a_pair.png",
        "title": "Make a pair",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/games/find_items.png",
        "title": "Find the items",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/games/puzzle.png",
        "title": "Puzzle",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/games/coloring.png",
        "title": "Creative Coloring",
        "subtitle": "Lesson 1",
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          spacing: 12,
          children: [
            GreetingWidget(),
            GameCollectionWidget(
              games: games,
              title: 'Gamified Activities',
              showSubtitle: true,
            ),
          ],
        ),
      ),
    );
  }
}
