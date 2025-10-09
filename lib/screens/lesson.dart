import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/recent_lesson.dart';
import 'package:shape_mobile/widgets/lesson_collection.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> lessons = [
      {
        "image": "assets/flutter/lessons/lesson_1.png",
        "title": "Lesson Title 1",
        "progress": 98,
      },
      {
        "image": "assets/flutter/lessons/lesson_2.png",
        "title": "Lesson Title 2",
        "progress": 75,
      },
      {
        "image": "assets/flutter/lessons/lesson_3.png",
        "title": "Lesson Title 3",
        "progress": 30,
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          spacing: 12,
          children: [
            GreetingWidget(),
            RecentLessonWidget(showTitle: true),
            LessonCollectionWidget(lessons: lessons, title: 'Ongoing Lessons'),
          ],
        ),
      ),
    );
  }
}
