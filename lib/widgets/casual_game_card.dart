import 'package:flutter/material.dart';
import 'package:shape_mobile/games/game_registry.dart';
import 'package:shape_mobile/utils.dart';

class CasualGameCard extends StatelessWidget {
  final int gameId;
  final String title;

  const CasualGameCard({super.key, required this.gameId, required this.title});

  @override
  Widget build(BuildContext context) {
    final entry = GameRegistry.getGameEntry(gameId);
    if (entry == null) return const SizedBox();

    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          final gameWidget = entry.builder(
            context,
            0,
            0,
            gameId,
          ); // no student or lesson
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => gameWidget),
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
                child: Image.asset(entry.thumbnailPath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                toTitleCase(title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New data structure for casual games
class CasualGame {
  final int id;
  final String title;

  CasualGame({required this.id, required this.title});
}

// Wrapper widget with header
class CasualGamesSection extends StatelessWidget {
  final List<CasualGame> games;

  const CasualGamesSection({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.only(bottom: 18.0),
          child: Text(
            "Casual Games",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),

        // Grid of casual game cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 18,
            childAspectRatio: 1.2,
            children: games
                .map(
                  (game) => CasualGameCard(gameId: game.id, title: game.title),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
