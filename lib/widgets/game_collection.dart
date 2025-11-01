import 'package:flutter/material.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/GameActivityModel.dart';
import 'package:shape_mobile/utils.dart';
import 'package:shape_mobile/games/game_registry.dart';

class GameCollectionWidget extends StatefulWidget {
  final String title;
  final int? lessonId;

  const GameCollectionWidget({super.key, required this.title, this.lessonId});

  @override
  State<GameCollectionWidget> createState() => _GameCollectionWidgetState();
}

class _GameCollectionWidgetState extends State<GameCollectionWidget> {
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    final db = AppDatabase.instance;
    final results = widget.lessonId == null
        ? await db.fetchGamesWithLessonTitles()
        : await db.fetchGamesWithLessonTitlesByLessonId(widget.lessonId!);

    if (!mounted) return;

    setState(() {
      _games = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 150),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),

        if (_games.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.gamepad_rounded, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Games Available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 18,
            childAspectRatio: widget.lessonId == null ? 1.2 : 1.4,
            children: _games.map((item) {
              final game = item['game'] as GameActivity;
              final lessonTitle = item['lesson_title'] as String?;

              return Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                child: InkWell(
                  onTap: () async {
                    await GameRegistry.launchGameById(
                      context: context,
                      gameId: game.id,
                      lessonId: item['lesson_id'],
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          color: Colors.blue.shade100,
                          child: const Icon(
                            Icons.videogame_asset_rounded,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toTitleCase(game.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.lessonId == null)
                              Text(
                                toTitleCase(lessonTitle!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
