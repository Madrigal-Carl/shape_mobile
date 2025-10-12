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
                VideoCollectionWidget(title: 'Videos', lessonId: lesson!.id),
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
