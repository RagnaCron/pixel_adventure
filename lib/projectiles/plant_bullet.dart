import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/levels/level.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/tiles/collision_block.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';
import 'package:pixel_adventure/utils/utils.dart';

enum State {
  fly,
  hit,
}

class PlantBullet extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  PlantBullet({
    super.position,
    super.size,
    required this.facingDirection,
    super.removeOnFinish = const {State.hit: true},
  });

  String facingDirection;

  late final SpriteAnimation bulletAnimation;
  late final SpriteAnimation bulletPiecesAnimation;

  static const double stepTime = 0.05;
  static const double moveSpeed = 100;

  bool didNotHit = true;

  final CircleHitbox hitBox = CircleHitbox(
    radius: 2,
    position: Vector2(2, 2),
    collisionType: CollisionType.active,
    isSolid: true,
  );

  @override
  Future<void> onLoad() async {
    debugMode = true;

    _loadAnimations();

    add(hitBox);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateMovement(dt);
    _checkHorizontalCollision();

    super.update(dt);
  }

  void _updateMovement(double dt) {
    if (didNotHit) {
      if (facingDirection == 'left') {
        position.x += -moveSpeed * dt;
      }
      if (facingDirection == 'right') {
        position.x -= moveSpeed * dt;
      }
    }
  }

  void _checkHorizontalCollision() {
    final level = game.world as Level;
    level.collisionBlocks;

    final bulletX = position.x + hitBox.position.x;
    final bulletW = hitBox.size.x;

    for (final block in level.collisionBlocks) {
      if (facingDirection == "left") {
        if (block.width < block.height && block.x + block.width  >= position.x ) {
          print("hiiiittt!!!!");
        }
      }
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {}

    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAnimations() {
    bulletAnimation = _spriteAnimation('Bullet', 1);
    bulletPiecesAnimation = _spriteAnimation('Bullet Pieces', 1, loop: false);

    animations = {
      State.fly: bulletAnimation,
      State.hit: bulletPiecesAnimation,
    };

    current = State.fly;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Plant/$state.png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(32, 34),
        loop: loop,
      ),
    );
  }
}
