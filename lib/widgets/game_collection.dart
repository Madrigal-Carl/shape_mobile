import 'package:flutter/material.dart';

class GameCollectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> games;
  final String title;
  final bool? showSubtitle;

  const GameCollectionWidget({
    super.key,
    required this.title,
    required this.games,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final aspect = showSubtitle! ? 1.3 : 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          padding: const EdgeInsets.only(bottom: 16),
          childAspectRatio: aspect,
          children: games.map((game) {
            game['game'] = getGame(game['title']);
            return Material(
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, game['game']);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 93,
                        child: Image.asset(game['image'], fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (showSubtitle == true)
                      Text(
                        game['subtitle'],
                        style: const TextStyle(fontSize: 12),
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

String getGame(String name) {
  switch (name) {
    case 'Flappy Bird':
      return '/flappybird';
    default:
      return '/home';
  }
}
