import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum MovementState { movingRight, movingLeft, movingUp, movingDown, none }

class Saw extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure> {
  final bool isClockWise;
  final double horizontalOffNeg;
  final double horizontalOffPos;
  final double verticalOffNeg;
  final double verticalOffPos;
  final String initialMovement;

  Saw({
    super.position,
    super.size,
    required this.initialMovement,
    required this.isClockWise,
    required this.horizontalOffNeg,
    required this.horizontalOffPos,
    required this.verticalOffNeg,
    required this.verticalOffPos,
  });

  static const double sawSpeed = 0.03;
  static const double moveSpeed = 50.0;
  static const int tileSize = 16;
  late MovementState movementState;
  double horizontalRangeNeg = 0;
  double horizontalRangePos = 0;
  double verticalRangeNeg = 0;
  double verticalRangePos = 0;

  @override
  Future<void> onLoad() async {
    priority = -1;
    animation = _spriteAnimation('On (38x38)', 8);

    add(CircleHitbox(collisionType: CollisionType.passive));

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
      default:
        movementState = MovementState.none;
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    switch (movementState) {
      case MovementState.movingRight:
        _moveHorizontally(dt, isPositive: true);
        if (position.x >= horizontalRangePos) {
          movementState =
              isClockWise ? MovementState.movingDown : MovementState.movingUp;
        }

      case MovementState.movingDown:
        _moveVertically(dt, isPositive: true);
        if (position.y >= verticalRangePos) {
          movementState = isClockWise
              ? MovementState.movingLeft
              : MovementState.movingRight;
        }

      case MovementState.movingLeft:
        _moveHorizontally(dt, isPositive: false);
        if (position.x <= horizontalRangeNeg) {
          movementState =
              isClockWise ? MovementState.movingUp : MovementState.movingDown;
        }

      case MovementState.movingUp:
        _moveVertically(dt, isPositive: false);
        if (position.y <= verticalRangeNeg) {
          movementState = isClockWise
              ? MovementState.movingRight
              : MovementState.movingLeft;
        }

      default:
        break;
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

  SpriteAnimation _spriteAnimation(String name, int amount,
      {bool loop = true, double textureSize = 38}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/$name.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: sawSpeed,
        textureSize: Vector2.all(textureSize),
        loop: loop,
      ),
    );
  }
}
