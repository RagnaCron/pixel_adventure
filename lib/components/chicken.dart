import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum ChickenState {
  idle,
  hit,
  run,
}

class Chicken extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  double offNeg;
  double offPos;

  Chicken({
    super.position,
    super.size,
    required this.offNeg,
    required this.offPos,
    super.removeOnFinish = const {ChickenState.hit: true},
  });

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation runAnimation;

  static const double moveSpeed = 50.0;
  static const int tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  CustomHitBox hitBox = CustomHitBox(
    offsetX: 0,
    offsetY: 0,
    width: 32,
    height: 32,
  );

  @override
  Future<void> onLoad() async {
    debugMode = true;

    _loadAllAnimations();

    add(RectangleHitbox(
      position: Vector2(hitBox.offsetX, hitBox.offsetY),
      size: Vector2(hitBox.width, hitBox.height),
      isSolid: true,
    ));

    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // _moveHorizontally(dt);
    
    super.update(dt);
  }
  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 13);
    runAnimation = _spriteAnimation('Run', 14);
    hitAnimation = _spriteAnimation('Hit', 5, loop: false);

    animations = {
      ChickenState.idle: idleAnimation,
      ChickenState.hit: hitAnimation,
      ChickenState.run: runAnimation,
    };

    current = ChickenState.idle;
  }



  SpriteAnimation _spriteAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Chicken/$state (32x34).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(32, 34),
        loop: loop,
      ),
    );
  }


}
