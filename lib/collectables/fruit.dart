import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/collided.dart';

enum FruitState {
  fruity,
  collected,
}

class Fruit extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>
    implements Collided {
  final String fruit;

  Fruit({
    super.position,
    super.size,
    this.fruit = 'Apples',
    super.removeOnFinish = const {FruitState.collected: true},
  });

  final double stepTime = 0.05;
  late final SpriteAnimation fruityAnimation;
  late final SpriteAnimation poppingAnimation;

  final hitBox = CustomHitBox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );

  @override
  Future<void> onLoad() async {
    priority = -1;
    add(RectangleHitbox(
      collisionType: CollisionType.passive,
      position: Vector2(hitBox.offsetX, hitBox.offsetY),
      size: Vector2(hitBox.width, hitBox.height),
      isSolid: true,
    ));
    fruityAnimation = _spriteAnimation(fruit, 17);
    poppingAnimation = _spriteAnimation('Collected', 6, loop: false);

    animations = {
      FruitState.fruity: fruityAnimation,
      FruitState.collected: poppingAnimation,
    };

    current = FruitState.fruity;

    return super.onLoad();
  }

  @override
  void collidedWithPlayer() async {
    if (game.playSound) {
      FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
    }
    current = FruitState.collected;
  }

  SpriteAnimation _spriteAnimation(String name, int amount,
      {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$name.png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: loop),
    );
  }
}
