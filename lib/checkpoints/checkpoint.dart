import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils/collided.dart';

enum FlagState {
  noFlag,
  flagOut,
  flagIdle,
}

class Checkpoint extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>
    implements Collided {
  Checkpoint({
    super.position,
    super.size,
  });

  late final SpriteAnimation noFlagAnimation;
  late final SpriteAnimation flagOutAnimation;
  late final SpriteAnimation flagIdleAnimation;

  final hitBox = CustomHitBox(
    offsetX: 19,
    offsetY: 59,
    width: 9,
    height: 5,
  );

  @override
  Future<void> onLoad() async {
    priority = -1;

    _addAnimations();

    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
        position: Vector2(hitBox.offsetX, hitBox.offsetY),
        size: Vector2(hitBox.width, hitBox.height),
      ),
    );

    return super.onLoad();
  }
  //
  // @override
  // void onCollisionStart(
  //     Set<Vector2> intersectionPoints, PositionComponent other) {
  //   if (other is Player) {
  //     _reachedCheckpoint();
  //   }
  //   super.onCollisionStart(intersectionPoints, other);
  // }

  void _reachedCheckpoint() async {
    current = FlagState.flagOut;

    await animationTicker?.completed;
    animationTicker?.reset();

    current = FlagState.flagIdle;
  }

  void _addAnimations() {
    noFlagAnimation = _spriteAnimation('Checkpoint (No Flag)', 1, loop: false);
    flagOutAnimation = _spriteAnimation('Checkpoint(FlagOut)', 26, loop: false);
    flagIdleAnimation = _spriteAnimation('Checkpoint (Flag Idle)', 10);

    animations = {
      FlagState.noFlag: noFlagAnimation,
      FlagState.flagOut: flagOutAnimation,
      FlagState.flagIdle: flagIdleAnimation,
    };

    current = FlagState.noFlag;
  }

  SpriteAnimation _spriteAnimation(String name, int amount,
      {double stepTime = 0.05, bool loop = true, double textureSize = 64}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/$name.png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(textureSize),
          loop: loop),
    );
  }

  @override
  void collidedWithPlayer() {
    _reachedCheckpoint();
    game.player.reachedCheckpoint();
  }
}
