import 'package:flutter/material.dart';
import 'package:shape_mobile/db/app_database.dart';

class ProfileSummaryWidget extends StatefulWidget {
  const ProfileSummaryWidget({super.key});

  @override
  State<ProfileSummaryWidget> createState() => _ProfileSummaryWidgetState();
}

class _ProfileSummaryWidgetState extends State<ProfileSummaryWidget> {
  int totalLessons = 0;
  int completedLessons = 0;
  int totalActivities = 0;
  int completedActivities = 0;
  int earnedAwards = 0;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    final db = AppDatabase.instance;

    // 1️⃣ Fetch total lessons
    final totalLessonResult = await (await db.database).rawQuery(
      'SELECT COUNT(*) as count FROM ${AppDatabase.lessonsTable}',
    );
    totalLessons = totalLessonResult.first['count'] as int? ?? 0;

    // 2️⃣ Fetch total activities
    final totalActivityResult = await (await db.database).rawQuery(
      'SELECT COUNT(*) as count FROM ${AppDatabase.studentActivitiesTable}',
    );
    totalActivities = totalActivityResult.first['count'] as int? ?? 0;

    // 3️⃣ Fetch completed activities
    final completedActivityResult = await (await db.database).rawQuery('''
      SELECT COUNT(*) as count 
      FROM ${AppDatabase.studentActivitiesTable} 
      WHERE status = 'completed'
    ''');
    completedActivities = completedActivityResult.first['count'] as int? ?? 0;

    // 4️⃣ Fetch completed lessons
    // A lesson is complete if all its activities are completed.
    final completedLessonResult = await (await db.database).rawQuery('''
      SELECT l.id
      FROM ${AppDatabase.lessonsTable} l
      JOIN ${AppDatabase.gameActivityLessonsTable} gal ON gal.lesson_id = l.id
      JOIN ${AppDatabase.studentActivitiesTable} sa ON sa.activity_lesson_id = gal.id
      GROUP BY l.id
      HAVING SUM(CASE WHEN sa.status = 'completed' THEN 1 ELSE 0 END) = COUNT(*)
    ''');
    completedLessons = completedLessonResult.length;

    // 5️⃣ Fetch earned awards
    final earnedAwardsResult = await (await db.database).rawQuery(
      'SELECT COUNT(*) as count FROM ${AppDatabase.studentAwardsTable}',
    );
    earnedAwards = earnedAwardsResult.first['count'] as int? ?? 0;

    // Update UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        const Text(
          'Summary',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        IntrinsicHeight(
          child: Row(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x66D6DBED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 4,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total', style: TextStyle(fontSize: 18)),
                          Text(
                            'Pending',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${totalLessons - completedLessons}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 72,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7ADB37),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 4,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Lessons',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            spacing: 6,
                            children: [
                              Text(
                                '$completedLessons',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              Text(
                                '/$totalLessons',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB120),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Activities',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            spacing: 6,
                            children: [
                              Text(
                                '$completedActivities',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              Text(
                                '/$totalActivities',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2979FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Earned',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Awards',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$earnedAwards',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
