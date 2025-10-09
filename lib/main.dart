import 'package:flutter/material.dart';
import 'package:shape_mobile/screens/login.dart';
import 'package:shape_mobile/screens/default.dart';
import 'package:shape_mobile/screens/notification.dart';
import 'package:shape_mobile/screens/profile.dart';
import 'package:shape_mobile/screens/lesson_session.dart';
import 'package:shape_mobile/services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PreferenceService();
  await prefs.loadCache();

  runApp(MyApp(isLoggedIn: PreferenceService.isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const DefaultLayout(),
        '/notification': (context) => const NotificationScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (route) {
        if (route.name == '/lessonSession') {
          final lesson = route.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            settings: RouteSettings(name: '/lessonSession'),
            builder: (context) => LessonSessionScreen(lesson: lesson),
          );
        }
        return null;
      },
    );
  }
}
