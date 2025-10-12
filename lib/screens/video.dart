import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/video_collection.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

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
      {
        "image": "assets/flutter/videos/coloring.png",
        "title": "Creative Coloring",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/videos/trace.png",
        "title": "Trace the Alphabet",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/videos/self_care.png",
        "title": "Self Care",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/videos/make_a_pair.png",
        "title": "Make a Pair",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/videos/trace.png",
        "title": "Trace the Alphabet",
        "subtitle": "Lesson 1",
      },
      {
        "image": "assets/flutter/videos/puzzle.png",
        "title": "Puzzle",
        "subtitle": "Lesson 1",
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          spacing: 12,
          children: [
            GreetingWidget(),
            VideoCollectionWidget(title: 'Education Videos'),
          ],
        ),
      ),
    );
  }
}
