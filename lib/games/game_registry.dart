import 'package:flutter/material.dart';

import 'match_mania/main.dart' as match_mania;

class GameRegistry {
  static final Map<int, WidgetBuilder> _registry = {
    4: (context) => match_mania.MatchManiaApp(),
  };

  static Widget? getGameById(BuildContext context, int id) {
    final builder = _registry[id];
    return builder != null ? builder(context) : null;
  }
}
