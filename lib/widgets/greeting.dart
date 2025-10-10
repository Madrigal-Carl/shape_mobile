import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shape_mobile/services/preference_service.dart';

class GreetingWidget extends StatefulWidget {
  const GreetingWidget({super.key});

  @override
  _GreetingWidgetState createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends State<GreetingWidget> {
  String? avatarPath;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    // 🔁 Reload avatar from shared preferences (fresh data)
    setState(() {
      avatarPath = PreferenceService.avatarPath;
    });
  }

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
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          FutureBuilder(
            future: _checkLocalImage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 25,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              if (snapshot.data == true && avatarPath != null) {
                return GFImageOverlay(
                  height: 50,
                  width: 50,
                  shape: BoxShape.circle,
                  image: FileImage(File(avatarPath!)),
                  boxFit: BoxFit.cover,
                );
              } else {
                return GFImageOverlay(
                  height: 50,
                  width: 50,
                  shape: BoxShape.circle,
                  image: const AssetImage('assets/flutter/images/profile.png'),
                  boxFit: BoxFit.cover,
                );
              }
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting()),
              Text(
                PreferenceService.fullname ?? 'Guest',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _checkLocalImage() async {
    if (avatarPath == null) return false;
    return File(avatarPath!).existsSync();
  }
}
