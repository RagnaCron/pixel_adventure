import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/players/player.dart';
import 'package:pixel_adventure/tiles/collision_block.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';
import 'package:pixel_adventure/utils/collided.dart';

enum MovementState { movingRight, movingLeft, movingUp, movingDown }

enum PlatformState {
  on,
  off,
}

class Platform extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks
    implements CollisionBlock, Collided {
  final String type;
  final bool isClockWise;
  final double horizontalOffNeg;
  final double horizontalOffPos;
  final double verticalOffNeg;
  final double verticalOffPos;
  final String initialMovement;
  @override
  final bool isPlatform;


  Platform({
    super.key,
    super.position,
    super.size,
    required this.isPlatform,
    required this.type,
    this.isClockWise = true,
    this.horizontalOffNeg = 0,
    this.horizontalOffPos = 0,
    this.verticalOffNeg = 0,
    this.verticalOffPos = 0,
    this.initialMovement = "",
  });

  late final Player player;

  late final SpriteAnimation offAnimation;
  late final SpriteAnimation onAnimation;

  static const double moveSpeed = 50.0;
  static const int tileSize = 16;
  late MovementState movementState;
  double horizontalRangeNeg = 0;
  double horizontalRangePos = 0;
  double verticalRangeNeg = 0;
  double verticalRangePos = 0;
  bool isPlatformMoving = false;

  final CustomHitBox hitBox = CustomHitBox(
    offsetX: 0,
    offsetY: 2,
    width: 32,
    height: 6,
  );

  @override
  Future<void> onLoad() async {
    player = game.player;

    _loadAnimations();

    add(
      RectangleHitbox(
        position: hitBox.position,
        size: hitBox.size,
        collisionType: CollisionType.passive,
      ),
    );

    verticalRangeNeg = position.y - verticalOffNeg * tileSize;
    verticalRangePos = position.y + verticalOffPos * tileSize;
    horizontalRangeNeg = position.x - horizontalOffNeg * tileSize;
    horizontalRangePos = position.x + horizontalOffPos * tileSize;

    switch (initialMovement) {
      case 'movingRight':
        movementState = MovementState.movingRight;
      case 'movingLeft':
        movementState = MovementState.movingLeft;
      case 'movingUp':
        movementState = MovementState.movingUp;
      case 'movingDown':
        movementState = MovementState.movingDown;
    }

    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      isPlatformMoving = true;
      current = PlatformState.on;
      other.platformKey = key;
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    if (isPlatformMoving) {
      switch (movementState) {
        case MovementState.movingRight:
          _moveHorizontally(dt, isPositive: true);
          if (position.x >= horizontalRangePos) {
            movementState =
                isClockWise ? MovementState.movingDown : MovementState.movingUp;
          }
          if (player.isOnMovingPlatform && player.platformKey == key) {
            player.x += moveSpeed * dt;
          }

        case MovementState.movingDown:
          _moveVertically(dt, isPositive: true);
          if (position.y >= verticalRangePos) {
            movementState = isClockWise
                ? MovementState.movingLeft
                : MovementState.movingRight;
          }
          if (player.isOnMovingPlatform && player.platformKey == key) {
            player.y += moveSpeed * dt;
          }

        case MovementState.movingLeft:
          _moveHorizontally(dt, isPositive: false);
          if (position.x <= horizontalRangeNeg) {
            movementState =
                isClockWise ? MovementState.movingUp : MovementState.movingDown;
          }
          if (player.isOnMovingPlatform && player.platformKey == key) {
            player.x -= moveSpeed * dt;
          }

        case MovementState.movingUp:
          _moveVertically(dt, isPositive: false);
          if (position.y <= verticalRangeNeg) {
            movementState = isClockWise
                ? MovementState.movingRight
                : MovementState.movingLeft;
          }
          if (player.isOnMovingPlatform && player.platformKey == key) {
            player.y -= moveSpeed * dt;
          }
      }
    }

    super.update(dt);
  }

  void _moveHorizontally(double dt, {required bool isPositive}) {
    final direction = isPositive ? 1 : -1;
    position.x += direction * moveSpeed * dt;
  }

  void _moveVertically(double dt, {required bool isPositive}) {
    final direction = isPositive ? 1 : -1;
    position.y += direction * moveSpeed * dt;
  }

  void _loadAnimations() {
    offAnimation = _spriteAnimation('$type Off', 1);
    onAnimation = _spriteAnimation('$type On', 8);

    animations = {
      PlatformState.off: offAnimation,
      PlatformState.on: onAnimation,
    };

    current = PlatformState.off;
  }

  SpriteAnimation _spriteAnimation(String name, int amount,
      {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Platforms/$name (32x8).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.05,
        textureSize: Vector2(32, 8),
        loop: loop,
      ),
    );
  }

  @override
  void collidedWithPlayer() {
    player.isOnMovingPlatform = true;
  }
}
