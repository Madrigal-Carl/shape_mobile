import '../models/card_model.dart';
import 'dart:math';

class CardGenerator {
  static final List<String> figures = [
    'figures/apple.png',
    'figures/banana.png',
    'figures/blue.png',
    'figures/grapes.png',
    'figures/green.png',
    'figures/kiwi.png',
    'figures/lemon.png',
    'figures/orange_fruit.png',
    'figures/orange.png',
    'figures/pineapple.png',
    'figures/red.png',
    'figures/strawberry.png',
    'figures/violet.png',
    'figures/watermelon.png',
    'figures/yellow.png',
  ];

  static List<CardModel> generateCards() {
    final rand = Random();
    final figuresPool = List<String>.from(figures)..shuffle(rand);
    final selectedFigures = figuresPool.take(6).toList();

    // For each figure, create two cards (for matching pairs)
    final List<CardModel> cards = [];
    for (final figure in selectedFigures) {
      cards.add(CardModel(shapeAsset: figure, faceAsset: figure));
      cards.add(CardModel(shapeAsset: figure, faceAsset: figure));
    }

    cards.shuffle(rand);
    return cards;
  }
}
