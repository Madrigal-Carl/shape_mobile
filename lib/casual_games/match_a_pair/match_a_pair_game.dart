import 'package:flame/game.dart';
import 'models/card_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'utils/card_generator.dart';
import 'components/card_component.dart';
import 'package:flame/cache.dart';

class MatchAPairGame extends FlameGame {
  late final AudioCache audioCache;
  late final Images imageCache;
  static const String pauseMenuOverlay = 'PauseMenu';
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  int comboStreak = 0;
  ValueNotifier<int> comboNotifier = ValueNotifier<int>(0);

  int get score => scoreNotifier.value;
  set score(int value) => scoreNotifier.value = value;
  List<CardModel> cards = [];
  final VoidCallback onQuitToMenu;
  final VoidCallback? onCardsRegenerated;
  MatchAPairGame({required this.onQuitToMenu, this.onCardsRegenerated});
  bool get canFlip => secondFlipped == null;
  CardComponent? firstFlipped;
  CardComponent? secondFlipped;
  double bgmVolume = 0.4;
  bool _bgmPlaying = false;

  @override
  Future<void> onLoad() async {
    audioCache = AudioCache(prefix: 'assets/casual_games/match_a_pair/audio/');
    imageCache = Images(prefix: 'assets/casual_games/match_a_pair/images/');

    await audioCache.loadAll([
      'BGM.mp3',
      'CLICK.wav',
      'POP.wav',
      'CORRECT.wav',
      'combos/combo_2.mp3',
      'combos/combo_3.mp3',
      'combos/combo_4.mp3',
      'combos/combo_5.mp3',
      'combos/combo_6.mp3',
    ]);
    final bgSprite = Sprite(await imageCache.load('background.png'));
    final imageSize = bgSprite.srcSize;
    final scale = size.y / imageSize.y; // Scale so height fits the screen
    final bgWidth = imageSize.x * scale;
    final bgHeight = size.y;

    final bg = SpriteComponent(
      sprite: bgSprite,
      size: Vector2(bgWidth, bgHeight),
      position: Vector2((size.x - bgWidth) / 2, 0), // Center horizontally
      anchor: Anchor.topLeft,
    );
    add(bg);
  }

  void onCardFlipped(CardComponent card) {
    FlameAudio.audioCache.clear('POP.wav');
    FlameAudio.play('POP.wav', volume: 1.0);
    if (firstFlipped == null) {
      firstFlipped = card;
    } else if (secondFlipped == null && card != firstFlipped) {
      secondFlipped = card;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (firstFlipped!.cardModel.shapeAsset ==
            secondFlipped!.cardModel.shapeAsset) {
          firstFlipped!.cardModel.isMatched = true;
          secondFlipped!.cardModel.isMatched = true;
          comboStreak++;
          comboNotifier.value = comboStreak;

          if (comboStreak >= 2) {
            // Mute or lower BGM
            FlameAudio.bgm.audioPlayer.setVolume(0.0); // Mute BGM
            // Play combo audio, slightly louder
            FlameAudio.audioCache.clear(
              'combos/combo_${comboStreak > 6 ? 6 : comboStreak}.mp3',
            );
            FlameAudio.play(
              'combos/combo_${comboStreak > 6 ? 6 : comboStreak}.mp3',
              volume: 1.0,
            ).then((player) {
              // When combo audio finishes, restore BGM volume
              player.onPlayerComplete.listen((_) {
                FlameAudio.bgm.audioPlayer.setVolume(bgmVolume); // Restore BGM
              });
            });
          } else {
            // Play correct audio
            FlameAudio.audioCache.clear('CORRECT.wav');
            FlameAudio.play('CORRECT.wav', volume: 1.0);
          }

          // Scoring based on combo
          int addScore = 8;
          if (comboStreak == 2)
            addScore = 10;
          else if (comboStreak == 3)
            addScore = 12;
          else if (comboStreak == 4)
            addScore = 15;
          else if (comboStreak == 5)
            addScore = 20;
          else if (comboStreak >= 6)
            addScore = 30;
          score += addScore;
        } else {
          firstFlipped!.cardModel.isFlipped = false;
          secondFlipped!.cardModel.isFlipped = false;
          comboStreak = 0;
          comboNotifier.value = 0;
          score = (score >= 5) ? score - 5 : 0;
        }
        firstFlipped!.updateView();
        secondFlipped!.updateView();
        firstFlipped = null;
        secondFlipped = null;
        if (cards.every((c) => c.isMatched)) {
          // Wait for combo overlay to disappear before regenerating
          final delay = comboStreak >= 2 ? 1500 : 0;
          Future.delayed(Duration(milliseconds: delay), () {
            startGame();
          });
        }
      });
    }
  }

  void spawnCards() {
    // Remove old cards
    children.whereType<CardComponent>().forEach(remove);

    // Card grid setup
    const columns = 3;
    const rows = 4;
    final cardWidth = size.x / 4;
    final cardHeight = size.y / 6;
    final startX = (size.x - columns * cardWidth) / 2;
    final startY = (size.y - rows * cardHeight) / 2 + 40;

    for (int i = 0; i < cards.length; i++) {
      final col = i % columns;
      final row = i ~/ columns;
      final position = Vector2(
        startX + col * cardWidth,
        startY + row * cardHeight,
      );
      add(
        CardComponent(
          cardModel: cards[i],
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          position: position,
          onFlip: onCardFlipped,
          canFlip: () => canFlip,
        ),
      );
    }
  }

  void startGame() {
    cards = CardGenerator.generateCards();
    spawnCards();
    overlays.add('ScoreOverlay');
    overlays.add('ComboOverlay');
    if (onCardsRegenerated != null) {
      onCardsRegenerated!();
    }
  }

  void pauseGame() {
    pauseBgm();
    pauseEngine();
    overlays.add(pauseMenuOverlay);
  }

  void resumeGame() {
    overlays.remove(pauseMenuOverlay);
    resumeBgm();
    resumeEngine();
  }

  void quitToMenu() {
    overlays.clear();
    stopBgm();
    resumeEngine();
    onQuitToMenu();
  }

  void playBgm() async {
    if (_bgmPlaying) return;
    _bgmPlaying = true;
    await FlameAudio.bgm.play('BGM.mp3', volume: bgmVolume);
    FlameAudio.bgm.audioPlayer.onPlayerComplete.listen((_) {
      // Fade out and restart
      FlameAudio.bgm.audioPlayer.setVolume(0.4);
      Future.delayed(const Duration(milliseconds: 300), () {
        FlameAudio.bgm.stop();
        FlameAudio.bgm.play('BGM.mp3', volume: bgmVolume);
      });
    });
  }

  void revealCardsWithFadeIn() {
    for (final card in children.whereType<CardComponent>()) {
      card.back?.add(OpacityEffect.to(1, LinearEffectController(3)));
    }
  }

  void previewAllCards({double previewSeconds = 1.5}) {
    // Show all cards face up
    for (final card in children.whereType<CardComponent>()) {
      card.showFront();
    }
    // After previewSeconds, flip all cards back
    Future.delayed(Duration(milliseconds: (previewSeconds * 1000).toInt()), () {
      for (final card in children.whereType<CardComponent>()) {
        card.showBack();
      }
    });
  }

  void stopBgm() {
    _bgmPlaying = false;
    FlameAudio.bgm.stop();
  }

  void pauseBgm() {
    FlameAudio.bgm.pause();
  }

  void resumeBgm() {
    FlameAudio.bgm.resume();
  }
}
