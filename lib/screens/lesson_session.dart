import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/app_bar.dart';
import 'package:shape_mobile/widgets/video_collection.dart';
import 'package:shape_mobile/widgets/game_collection.dart';

class LessonSessionScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonSessionScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> videos = [
      {
        "image": "assets/flutter/videos/alphabet_song.png",
        "title": "Alphabet Song",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/videos/puzzle.png",
        "title": "Puzzle",
        "subtitle": "Lesson 1",
      },
    ];

    final List<Map<String, dynamic>> games = [
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
      {
        "image": "assets/flutter/games/trace.png",
        "title": "Trace the alphabet",
        "subtitle": "Lesson 1",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: lesson['title'], showReturn: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                VideoCollectionWidget(title: 'Video Lessons'),
                const SizedBox(height: 12),
                GameCollectionWidget(
                  title: 'Gamified Activities',
                  games: games,
                  showSubtitle: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
