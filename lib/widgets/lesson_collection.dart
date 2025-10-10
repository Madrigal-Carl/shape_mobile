import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'dart:math';

class LessonCollectionWidget extends StatefulWidget {
  final String title;

  const LessonCollectionWidget({super.key, required this.title});

  @override
  State<LessonCollectionWidget> createState() => _LessonCollectionWidgetState();
}

class _LessonCollectionWidgetState extends State<LessonCollectionWidget> {
  List<Lesson> _lessons = [];
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
    await Future.delayed(const Duration(milliseconds: 1500));

    // ✅ Only update state if widget is still mounted
    if (!mounted) return;

    setState(() {
      _lessons = result.map((e) => Lesson.fromJson(e)).toList();
      _isLoading = false;
    });
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
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),

        // ✅ If no lessons — show centered message in same area as the list
        if (_lessons.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu_book_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Lessons Yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // ✅ Lessons list (original style preserved)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lessons.length,
            itemBuilder: (context, index) {
              final lesson = _lessons[index];

              // Example: fake progress (replace with real field if you have one)
              final random = Random();
              final double progress = random.nextDouble();
              final int progressPercent = (progress * 100).toInt();

              // Pick a random image
              final bannerImage = lessonImages[index % lessonImages.length];

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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title section (left side)
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lesson.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            // Progress bar (right side)
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
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
            },
          ),
      ],
    );
  }
}
