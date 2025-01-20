import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  bool isVertical;
  final double offNeg;
  final double offPos;

  Saw({
    super.position,
    super.size,
    required this.isVertical,
    required this.offNeg,
    required this.offPos,
  });

  static const double sawSpeed = 0.02;
  static const double moveSpeed = 50.0;
  static const int tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  Future<void> onLoad() async {
    priority = -1;
    animation = _spriteAnimation('On (38x38)', 8);

    add(CircleHitbox());

    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  SpriteAnimation _spriteAnimation(String name, int amount,
      {bool loop = true, double textureSize = 38}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/$name.png'),
      SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: sawSpeed,
          textureSize: Vector2.all(textureSize),
          loop: loop),
    );
  }
}
