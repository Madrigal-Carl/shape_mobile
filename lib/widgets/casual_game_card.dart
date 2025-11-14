import 'package:flutter/material.dart';
import 'package:shape_mobile/utils.dart';
import 'package:toastification/toastification.dart';
import 'package:shape_mobile/casual_games/match_a_pair/main.dart';

class CasualGameCard extends StatelessWidget {
  final int gameId;
  final String title;
  final String thumbnailPath;

  const CasualGameCard({
    super.key,
    required this.gameId,
    required this.title,
    required this.thumbnailPath,
  });

  void _launchGame(BuildContext context, int gameId) {
    switch (gameId) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MatchAPairApp()),
        );
        break;
      default:
        toastification.showError(
          context: context,
          title: 'Game not available',
          autoCloseDuration: const Duration(seconds: 5),
          padding: const EdgeInsets.all(10),
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: () => _launchGame(context, gameId),
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
                child: Image.asset(
                  thumbnailPath,
                  fit: BoxFit.cover,
                ), // Placeholder thumbnail
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
  final String thumbnailPath;

  CasualGame({
    required this.id,
    required this.title,
    required this.thumbnailPath,
  });
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
                  (game) => CasualGameCard(
                    gameId: game.id,
                    title: game.title,
                    thumbnailPath: game.thumbnailPath,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
