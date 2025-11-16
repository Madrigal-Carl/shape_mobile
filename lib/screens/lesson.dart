import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/recent_lesson.dart';
import 'package:shape_mobile/widgets/lesson_collection.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          spacing: 12,
          children: [
            GreetingWidget(),
            RecentLessonWidget(showTitle: true),
            LessonCollectionWidget(),
          ],
        ),
      ),
    );
  }
}
