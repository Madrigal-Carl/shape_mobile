import 'package:flutter/material.dart';
import 'main.dart' as match_mania;

class MatchManiaEntry extends StatelessWidget {
  const MatchManiaEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: match_mania.MatchManiaRoot());
  }
}
