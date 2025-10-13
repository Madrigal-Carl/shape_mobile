import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shape_mobile/widgets/app_bar.dart';
import 'package:shape_mobile/widgets/profile_summary.dart';
import 'package:shape_mobile/widgets/awards_list.dart';
import 'package:shape_mobile/widgets/recent_lesson.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shape_mobile/services/preference_service.dart';
import 'package:shape_mobile/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? fullname;
  String? lrn;
  String? avatarPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await PreferenceService.loadPreferences();

    setState(() {
      fullname = PreferenceService.fullname;
      lrn = PreferenceService.lrn;
      avatarPath = PreferenceService.avatarPath;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String? avatarPath = PreferenceService.avatarPath;
    final ImageProvider profileImage;

    if (avatarPath != null && File(avatarPath).existsSync()) {
      profileImage = FileImage(File(avatarPath));
    } else {
      profileImage = const AssetImage('assets/flutter/images/profile.png');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Profile', showReturn: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 26,
          children: [
            Row(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GFAvatar(backgroundImage: profileImage, size: 45),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullname!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text('LRN: ${lrn!}'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusBackgroundColor(
                          PreferenceService.status!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        toTitleCase(PreferenceService.status!),
                        style: TextStyle(
                          color: getStatusTextColor(PreferenceService.status!),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ProfileSummaryWidget(),
            AwardListWidget(),
            RecentLessonWidget(showTitle: true),
          ],
        ),
      ),
    );
  }
}
