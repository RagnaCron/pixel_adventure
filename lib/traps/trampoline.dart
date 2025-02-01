import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/players/player.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';

enum TrampolineState {
  idle,
  jump,
}

class Trampoline extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Trampoline({
    super.position,
    super.size,
  });

  bool hasBoosted = false;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation jumpAnimation;

  final CustomHitBox hitBox = CustomHitBox(
    offsetX: 4,
    offsetY: 20,
    width: 23,
    height: 12,
  );

  @override
  Future<void> onLoad() async {
    // debugMode = true;

    idleAnimation = _spriteAnimation('Idle', 1);
    jumpAnimation = _spriteAnimation('Jump', 8, loop: false);

    animations = {
      TrampolineState.idle: idleAnimation,
      TrampolineState.jump: jumpAnimation,
    };

    current = TrampolineState.idle;

    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
        position: hitBox.position,
        size: hitBox.size,
      ),
    );

    return super.onLoad();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !hasBoosted) {
      if (other.position.y + other.size.y <= position.y) {
        hasBoosted = true;
      }
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player) {
      hasBoosted = false;
    }

    super.onCollisionEnd(other);
  }

  void collideWithPlayer() {}

  SpriteAnimation _spriteAnimation(String name, int amount,
      {bool loop = true, double textureSize = 28}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Trampoline/$name (28x28).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.05,
        textureSize: Vector2.all(textureSize),
        loop: loop,
      ),
    );
  }


}
