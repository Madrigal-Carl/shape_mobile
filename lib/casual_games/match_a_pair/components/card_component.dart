import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import '../models/card_model.dart';
import 'package:flame/cache.dart';

class CardComponent extends PositionComponent with TapCallbacks {
  late final Images imageCache;
  final CardModel cardModel;
  final double cardWidth;
  final double cardHeight;
  final void Function(CardComponent) onFlip;
  bool _isFading = false;
  final bool Function() canFlip;
  final String cardBackAsset = 'cards/card_back.png';
  final String cardFrontAsset = 'cards/card_front.png';

  SpriteComponent? front;
  SpriteComponent? back;
  SpriteComponent? shape;
  SpriteComponent? face;

  CardComponent({
    required this.cardModel,
    required this.cardWidth,
    required this.cardHeight,
    required Vector2 position,
    required this.onFlip,
    required this.canFlip,
  }) : super(position: position, size: Vector2(cardWidth, cardHeight));

  @override
  Future<void> onLoad() async {
    imageCache = Images(prefix: 'assets/casual_games/match_a_pair/images/');

    back = SpriteComponent(
      sprite: await Sprite.load(cardBackAsset, images: imageCache),
      size: size,
    );
    front = SpriteComponent(
      sprite: await Sprite.load(cardFrontAsset, images: imageCache),
      size: size,
    );
    // Load the figure and center it on the card
    final figureSprite = await Sprite.load(
      cardModel.shapeAsset,
      images: imageCache,
    );
    final originalSize = figureSprite.srcSize;
    final desiredWidth = cardWidth * 0.6; // Adjust width here
    final scale = desiredWidth / originalSize.x;
    final desiredHeight = originalSize.y * scale;
    shape = SpriteComponent(
      sprite: figureSprite,
      size: Vector2(desiredWidth, desiredHeight),
      position: Vector2(
        (cardWidth - desiredWidth) / 2, // Center horizontally
        (cardHeight - desiredHeight) / 2, // Center vertically
      ),
    );
    add(back!);
    add(front!);
    add(shape!);
    updateView();
    // To adjust figure size or position, change desiredWidth or the position calculation above.
  }

  void updateView() {
    if (cardModel.isMatched) {
      if (!_isFading) {
        _isFading = true;
        front?.add(
          OpacityEffect.to(
            0,
            LinearEffectController(0.5),
            onComplete: () {
              add(RemoveEffect());
            },
          ),
        );
        shape?.add(OpacityEffect.to(0, LinearEffectController(0.5)));
      }
      front?.opacity = 1;
      shape?.opacity = 1;
      back?.opacity = 0;
    } else if (cardModel.isFlipped) {
      front?.opacity = 1;
      shape?.opacity = 1;
      back?.opacity = 0;
    } else {
      back?.opacity = 1;
      front?.opacity = 0;
      shape?.opacity = 0;
    }
  }

  void showFront() {
    cardModel.isFlipped = true;
    updateView();
  }

  void showBack() {
    cardModel.isFlipped = false;
    updateView();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!cardModel.isFlipped &&
        !cardModel.isMatched &&
        !_isFading &&
        canFlip()) {
      cardModel.isFlipped = true;
      updateView();
      onFlip(this);
    }
  }
}
