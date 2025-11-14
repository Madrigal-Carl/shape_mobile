import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';
import 'package:shape_mobile/screens/default.dart';

void main() {
  runApp(const MatchAPairApp());
}

class MatchAPairApp extends StatelessWidget {
  const MatchAPairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match A Pair',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainMenuScreen(),
        '/home': (context) => const DefaultLayout(),
      },
    );
  }
}
