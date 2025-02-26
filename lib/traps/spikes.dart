import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';
import 'package:pixel_adventure/utils/collided.dart';

class Spikes extends SpriteComponent
    with HasGameReference<PixelAdventure>
    implements Collided {
  bool isUpSideDown;

  Spikes({
    super.position,
    super.size,
    required this.isUpSideDown,
  });

  final hitBox = CustomHitBox(
    offsetX: 3,
    offsetY: 8,
    width: 10,
    height: 8,
  );

  @override
  Future<void> onLoad() async {
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

    if (isUpSideDown) {
      flipVerticallyAroundCenter();
    }

    return super.onLoad();
  }

  @override
  void collidedWithPlayer() {
    game.player.collidedWithEnemy();
  }
}
