import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum FruitState {
  idle,
  popping,
}

class Fruit extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure> {
  final String fruit;

  Fruit({
    super.position,
    super.size,
    this.fruit = 'Apples',
  });

  final double stepTime = 0.05;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();

    return super.onLoad();
  }

  void _loadAllAnimations() {
    animation = _spriteAnimation(17);

  }

  SpriteAnimation _spriteAnimation(int amount) {
    return SpriteAnimation.fromFrameData(
    game.images.fromCache('Items/Fruits/$fruit.png'),
    SpriteAnimationData.sequenced(
      amount: amount,
      stepTime: stepTime,
      textureSize: Vector2.all(32),
    ),
  );
  }
}
