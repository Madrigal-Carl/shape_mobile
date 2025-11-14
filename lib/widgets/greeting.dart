import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shape_mobile/services/preference_service.dart';
import 'package:shape_mobile/utils.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarPath = PreferenceService.avatarPath;
    final ImageProvider profileImage;

    // ✅ Same logic as AppBar: prefer local image if available, else use default
    if (avatarPath != null && File(avatarPath).existsSync()) {
      profileImage = FileImage(File(avatarPath));
    } else {
      profileImage = const AssetImage('assets/flutter/images/profile.png');
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          CircleAvatar(radius: 25, backgroundImage: profileImage),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                toTitleCase(PreferenceService.fullname ?? 'Guest'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
