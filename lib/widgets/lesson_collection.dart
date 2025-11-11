import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'package:shape_mobile/utils.dart';
import 'package:shape_mobile/services/preference_service.dart';

class LessonCollectionWidget extends StatefulWidget {
  const LessonCollectionWidget({super.key});

  @override
  State<LessonCollectionWidget> createState() => _LessonCollectionWidgetState();
}

class _LessonCollectionWidgetState extends State<LessonCollectionWidget> {
  List<Lesson> _lessons = [];
  List<Map<String, dynamic>> _lessonProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final db = AppDatabase.instance;
    final dbInstance = await db.database;

    final result = await dbInstance.query(AppDatabase.lessonsTable);
    final lessons = result.map((e) => Lesson.fromJson(e)).toList();

    final studentId = PreferenceService.studentId!;

    List<Map<String, dynamic>> lessonsWithProgress = [];
    for (final lesson in lessons) {
      final progress = await db.getLessonProgress(lesson.id, studentId);
      lessonsWithProgress.add({'lesson': lesson, 'progress': progress});
    }

    if (!mounted) return;

    setState(() {
      _lessons = lessons;
      _lessonProgress = lessonsWithProgress;
      _isLoading = false;
    });
  }

  Map<String, List<Lesson>> _groupLessonsBySubject(List<Lesson> lessons) {
    final Map<String, List<Lesson>> grouped = {};

    for (var lesson in lessons) {
      final subject = lesson.subjectName ?? 'No Subject';
      if (!grouped.containsKey(subject)) {
        grouped[subject] = [];
      }
      grouped[subject]!.add(lesson);
    }

    return grouped;
  }

  final List<String> lessonImages = [
    "assets/flutter/lessons/lesson_1.png",
    "assets/flutter/lessons/lesson_2.png",
    "assets/flutter/lessons/lesson_3.png",
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 150),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()],
          ),
        ),
      );
    }

    final groupedLessons = _groupLessonsBySubject(_lessons);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // ✅ If no lessons — show centered message in same area as the list
        if (_lessons.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu_book_sharp, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Lessons Available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // ✅ Lessons list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groupedLessons.keys.length,
            itemBuilder: (context, subjectIndex) {
              final subjectName = groupedLessons.keys.elementAt(subjectIndex);
              final lessons = groupedLessons[subjectName]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      toTitleCase(subjectName), // Capitalizes each word
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Lessons under this subject (keep original layout)
                  ...lessons.asMap().entries.map((entry) {
                    final lesson = entry.value;
                    final lessonIndex = _lessons.indexOf(lesson);
                    final data = _lessonProgress[lessonIndex];
                    final double progress = data['progress'] as double;
                    final int progressPercent = (progress * 100).toInt();

                    final bannerImage =
                        lessonImages[lessonIndex % lessonImages.length];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/lessonSession',
                              arguments: lesson,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  bannerImage,
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.45,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      toTitleCase(lesson.title),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.45,
                                    alignment: Alignment.centerRight,
                                    child: GFProgressBar(
                                      percentage: progress,
                                      animationDuration: 1500,
                                      lineHeight: 18,
                                      animation: true,
                                      alignment: MainAxisAlignment.spaceBetween,
                                      linearGradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF247BFF),
                                          Color(0xFF2BB4EE),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      child: Text(
                                        '$progressPercent%',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
      ],
    );
  }
}
