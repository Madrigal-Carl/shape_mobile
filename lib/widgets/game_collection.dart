import 'package:flutter/material.dart';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/GameActivityModel.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'package:shape_mobile/services/preference_service.dart';
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
  Map<String, List<Map<String, dynamic>>> _groupedGames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    final db = AppDatabase.instance;
    final studentId = PreferenceService.studentId;

    final results = widget.lessonId == null
        ? await db.fetchGamesWithLessonTitles(studentId!)
        : await db.fetchGamesWithLessonTitlesByLessonId(widget.lessonId!);

    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in results) {
      final lessonId = item['lesson_id'] as int;
      final lessonResult = await (await db.database).query(
        AppDatabase.lessonsTable,
        where: 'id = ?',
        whereArgs: [lessonId],
      );

      if (lessonResult.isEmpty) continue;
      final lesson = Lesson.fromJson(lessonResult.first);
      final subject = lesson.subjectName ?? 'No Subject';

      if (!grouped.containsKey(subject)) grouped[subject] = [];
      grouped[subject]!.add(item);
    }

    if (!mounted) return;

    setState(() {
      _games = results;
      _groupedGames = grouped;
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 18,
            children: _groupedGames.entries.map((entry) {
              final subject = entry.key;
              final games = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  if (widget.lessonId == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        toTitleCase(subject),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 18,
                    childAspectRatio: widget.lessonId == null ? 1.1 : 1.3,
                    children: games.map((item) {
                      final game = item['game'] as GameActivity;
                      final entry = GameRegistry.getGameEntry(game.id);

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

                                  child: entry != null
                                      ? Image.asset(
                                          entry.thumbnailPath,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.videogame_asset_rounded,
                                          size: 60,
                                          color: Colors.blueAccent,
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                        toTitleCase(
                                          games.first['lesson_title'] ??
                                              'No Lesson',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
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
            }).toList(),
          ),
      ],
    );
  }
}
