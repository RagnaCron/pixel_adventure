import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/players/player.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';
import 'package:pixel_adventure/utils/collided.dart';

enum State {
  flying,
  hit,
}

class BlueBird extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>
    implements Collided {
  BlueBird({
    super.position,
    super.size,
    required this.offNeg,
    required this.offPos,
    super.removeOnFinish = const {State.hit: true},
  });

  final double offNeg;
  final double offPos;

  static const double stepTime = 0.05;
  static const double moveSpeed = 100.0;
  static const int tileSize = 16;
  static const double _bouncedHeight = 260.0;

  late final SpriteAnimation flyingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation runAnimation;
  late final Player player;

  double moveDirection = 1;
  double targetDirection = -1;
  double rangeNeg = 0;
  double rangePos = 0;
  Vector2 velocity = Vector2.zero();
  bool gotStomped = false;

  CustomHitBox hitBox = CustomHitBox(
    offsetX: 4,
    offsetY: 6,
    width: 24,
    height: 22,
  );

  @override
  Future<void> onLoad() async {
    debugMode = true;
    player = game.player;

    _loadAnimations();
    _calculateRange();

    add(RectangleHitbox(
      collisionType: CollisionType.passive,
      position: hitBox.position,
      size: hitBox.size,
      isSolid: true,
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateState();
      _movement(dt);
    }
    super.update(dt);
  }

  void _movement(double dt) {
    velocity.x = 0;

    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * moveSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  void _updateState() {
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _loadAnimations() {
    flyingAnimation = _spriteAnimation('Flying', 9);
    hitAnimation = _spriteAnimation('Hit', 5, loop: false);

    animations = {
      State.flying: flyingAnimation,
      State.hit: hitAnimation,
    };

    current = State.flying;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/BlueBird/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: loop,
      ),
    );
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return (player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height);
  }

  @override
  void collidedWithPlayer() {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSound) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume);
      }
      gotStomped = true;

      current = State.hit;
      player.velocity.y = -_bouncedHeight;
    } else {
      player.collidedWithEnemy();
    }
  }
}
