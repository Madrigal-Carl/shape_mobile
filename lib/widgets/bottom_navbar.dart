import 'package:flutter/material.dart';
import 'package:circle_bottom_navigation/circle_bottom_navigation.dart';
import 'package:circle_bottom_navigation/widgets/tab_data.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CircleBottomNavigation(
      barHeight: 65,
      circleSize: 55,
      circleColor: Colors.blueAccent,
      barBackgroundColor: Colors.white,
      initialSelection: selectedIndex,
      activeIconColor: Colors.white,
      inactiveIconColor: Colors.grey,
      textColor: Colors.blueAccent,
      hasElevationShadows: true,
      tabs: [
        TabData(icon: Icons.home, title: 'Home', iconSize: 32),
        TabData(icon: Icons.gamepad_rounded, title: 'Game', iconSize: 32),
        TabData(icon: Icons.video_collection, title: 'Video', iconSize: 32),
        TabData(icon: Icons.menu_book_sharp, title: 'Lesson', iconSize: 32),
      ],
      onTabChangedListener: onTabChanged,
    );
  }
}
