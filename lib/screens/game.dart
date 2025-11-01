import 'package:flutter/material.dart';
import 'package:shape_mobile/widgets/greeting.dart';
import 'package:shape_mobile/widgets/game_collection.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          spacing: 12,
          children: [
            GreetingWidget(),
            GameCollectionWidget(title: 'Gamified Activities'),
          ],
        ),
      ),
    );
  }
}
