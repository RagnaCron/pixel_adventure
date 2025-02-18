import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Letter extends SpriteComponent with HasGameReference<PixelAdventure> {
  final int letterIndex;

  Letter({
    super.position,
    super.size,
    required this.letterIndex,
  });

  static const letterWidth = 8.0;
  static const letterHeight = 10.0;
  static const totalColumns = 10;
  static const totalRows = 5;

  late final Image image;

  @override
  Future<void> onLoad() async {
    image = game.images.fromCache('Menu/Text/Text (White) (8x10).png');

    sprite = Sprite(
      image,
      srcPosition: _getLetterPosition(letterIndex),
      srcSize: Vector2(letterWidth, letterHeight),
    );

    return super.onLoad();
  }

  Vector2 _getLetterPosition(int index) {
    int column = index % totalColumns;
    int row = (index / totalColumns).floor();
    return Vector2(column * letterWidth, row * letterHeight);
  }
}
