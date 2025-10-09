import 'package:flutter/material.dart';
import 'package:shape_mobile/screens/home.dart';
import 'package:shape_mobile/screens/game.dart';
import 'package:shape_mobile/screens/video.dart';
import 'package:shape_mobile/screens/lesson.dart';
import 'package:shape_mobile/widgets/app_bar.dart';
import 'package:shape_mobile/widgets/bottom_navbar.dart';

class DefaultLayout extends StatefulWidget {
  const DefaultLayout({super.key});

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  int currentPage = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    GameScreen(),
    VideoScreen(),
    LessonScreen(),
  ];

  final List<String> _titles = ['Home', 'Game', 'Video', 'Lesson'];

  void onTabChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: _titles[currentPage]),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _pages[currentPage],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: currentPage,
        onTabChanged: onTabChanged,
      ),
    );
  }
}
