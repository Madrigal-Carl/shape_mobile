import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shape_mobile/services/preference_service.dart';

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
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          GFImageOverlay(
            height: 50,
            width: 50,
            shape: BoxShape.circle,
            image: AssetImage('assets/flutter/images/profile.png'),
            boxFit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting()),
              Text(
                PreferenceService.fullname ?? "Guest",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
