import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/app_bar.dart';
import 'package:shape_mobile/widgets/video_collection.dart';
import 'package:shape_mobile/widgets/game_collection.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/LessonModel.dart';

class LessonSessionScreen extends StatefulWidget {
  final int lessonId;

  const LessonSessionScreen({super.key, required this.lessonId});

  @override
  State<LessonSessionScreen> createState() => _LessonSessionScreenState();
}

class _LessonSessionScreenState extends State<LessonSessionScreen> {
  Lesson? lesson;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    final db = AppDatabase.instance;
    final dbInstance = await db.database;

    final result = await dbInstance.query(
      AppDatabase.lessonsTable,
      where: 'id = ?',
      whereArgs: [widget.lessonId],
      limit: 1,
    );

    if (!mounted) return;

    setState(() {
      if (result.isNotEmpty) {
        lesson = Lesson.fromJson(result.first);
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || lesson == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: lesson!.title, showReturn: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                VideoCollectionWidget(
                  title: 'Educational Videos',
                  lessonId: lesson!.id,
                ),
                const SizedBox(height: 12),
                GameCollectionWidget(
                  title: 'Gamified Activities',
                  lessonId: lesson!.id,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
