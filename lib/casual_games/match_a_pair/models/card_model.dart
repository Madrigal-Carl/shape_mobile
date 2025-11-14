class CardModel {
  final String shapeAsset;
  final String faceAsset;
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.shapeAsset,
    required this.faceAsset,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
