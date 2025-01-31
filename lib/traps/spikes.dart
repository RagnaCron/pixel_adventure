import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/players/player.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';

class Spikes extends SpriteComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Spikes({
    super.position,
    super.size,
  });

  final hitBox = CustomHitBox(
    offsetX: 2,
    offsetY: 8,
    width: 12,
    height: 8,
  );

  @override
  Future<void> onLoad() async {
    debugMode = true;
    sprite = Sprite(
      game.images.fromCache('Traps/Spikes/Idle.png'),
      srcSize: Vector2.all(16),
    );

    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
        position: Vector2(hitBox.offsetX, hitBox.offsetY),
        size: Vector2(hitBox.width, hitBox.height),
      ),
    );

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.collidedWithEnemy();
    }

    super.onCollision(intersectionPoints, other);
  }
}
