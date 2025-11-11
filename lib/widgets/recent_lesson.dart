import 'package:flutter/material.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/services/preference_service.dart';

class RecentLessonWidget extends StatefulWidget {
  final String title;
  final bool showTitle;

  const RecentLessonWidget({
    super.key,
    this.showTitle = false,
    this.title = 'To Do:',
  });

  @override
  State<RecentLessonWidget> createState() => _RecentLessonWidgetState();
}

class _RecentLessonWidgetState extends State<RecentLessonWidget> {
  Lesson? _latestLesson;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedLesson();
    _fetchLatestLessonFromDB();
  }

  void _loadCachedLesson() {
    final cachedId = PreferenceService.latestLessonId;
    final cachedTitle = PreferenceService.latestLessonTitle;

    if (cachedId != null && cachedTitle != null) {
      _latestLesson = Lesson(id: cachedId, title: cachedTitle, schoolYearId: 0);
      _isLoading = false;
    }
  }

  /// Fetch the latest lesson from DB in background
  Future<void> _fetchLatestLessonFromDB() async {
    try {
      final studentId = PreferenceService.studentId;
      if (studentId == null) return;

      final latestLesson = await AppDatabase.instance.fetchLatestLesson(
        studentId: studentId,
      );

      if (latestLesson != null) {
        setState(() {
          _latestLesson = latestLesson;
          _isLoading = false;
        });

        // Update cache
        await PreferenceService.saveLatestLesson(latestLesson);
      } else {
        setState(() => _isLoading = false);
        debugPrint("✅ All lessons completed or none found.");
      }
    } catch (e) {
      debugPrint("Error fetching latest lesson: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_latestLesson == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          if (widget.showTitle)
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/lessonSession',
                arguments: _latestLesson,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 135,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/flutter/images/lesson_banner.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        spacing: 2,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Lesson',
                            style: TextStyle(color: Colors.white),
                          ),
                          RichText(
                            text: TextSpan(
                              text: _latestLesson!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
