import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/app_bar.dart';
import 'package:shape_mobile/widgets/profile_summary.dart';
import 'package:shape_mobile/widgets/recent_lesson.dart';
import 'package:getwidget/getwidget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Profile', showReturn: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 36,
          children: [
            Row(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GFAvatar(
                  backgroundImage: AssetImage(
                    'assets/flutter/images/profile.png',
                  ),
                  size: 45,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Carl S. Madrigal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text('LRN: 22B0943'),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF7ADB37),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ProfileSummaryWidget(),
            RecentLessonWidget(showTitle: true),
          ],
        ),
      ),
    );
  }
}
