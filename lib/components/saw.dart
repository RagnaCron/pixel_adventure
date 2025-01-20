import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Saw({
    super.position,
    super.size,
  });

  final double stepTime = 0.05;

  @override
  Future<void> onLoad() async {
    priority = -1;
    animation = _spriteAnimation('On (38x38)', 8);

    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(String name, int amount,
      {bool loop = true, double textureSize = 38}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/$name.png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(textureSize),
          loop: loop),
    );
  }
}
