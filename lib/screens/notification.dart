import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/app_bar.dart';
import 'package:shape_mobile/widgets/notification_collection.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifs = [
      {
        'title': 'Welcome!',
        'subtitle':
            'Thank you for joining our app. We hope you enjoy your stay!',
      },
      {
        'title': 'New Video Added',
        'subtitle': 'Check out the latest video in your lessons section.',
      },
      {
        'title': 'Reminder',
        'subtitle': 'Don’t forget to complete your daily activity today!',
      },
      {
        'title': 'Update Available',
        'subtitle': 'A new version of the app is now available. Please update.',
      },
      {
        'title': 'Tips of the Day',
        'subtitle': 'Remember to take breaks and stay hydrated while learning.',
      },
      {
        'title': 'Lesson Unlocked',
        'subtitle': 'You’ve unlocked a new lesson. Great job!',
      },
      {
        'title': 'Achievement Earned',
        'subtitle': 'You’ve earned a new badge for completing your quiz.',
      },
      {
        'title': 'Live Event',
        'subtitle': 'Join our live Q&A this Friday at 5 PM!',
      },
      {
        'title': 'Survey',
        'subtitle': 'Help us improve by answering a short survey.',
      },
      {
        'title': 'Thanks!',
        'subtitle': 'We appreciate your continued use of the app.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Notification', showReturn: true),
      body: NotificationCollectionWidget(notifs: notifs),
    );
  }
}
