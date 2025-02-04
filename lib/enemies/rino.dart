import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/players/player.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';

enum State {
  idle,
  run,
  hit,
  hitWall,
}

class Rino extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  double offNeg;
  double offPos;

  Rino({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
    super.removeOnFinish = const {State.hit: true},
  });

  static const int tileSize = 16;
  static const double stepTime = 0.05;
  static const double moveSpeed = 100.0;
  static const double _bouncedHeight = 260.0;

  late final Player player;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation hitWallAnimation;

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
    height: 26,
  );

  @override
  Future<void> onLoad() async {
    debugMode = true;

    player = game.player;

    _loadAnimations();
    _calculateRange();

    // add(RectangleHitbox(
    //   collisionType: CollisionType.passive,
    //   position: hitBox.position,
    //   size: hitBox.size,
    //   isSolid: true,
    // ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateState();
      _movement(dt);
      // todo: check for horizontal collisions with wall so we can set off a nice animation. with a small bump bag velocity... would be nice!!!
    }
    super.update(dt);
  }

  void _movement(double dt) {
    velocity.x = 0;

    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double rinoOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + rinoOffset) ? -1 : 1;
      velocity.x = targetDirection * moveSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  void _updateState() {
    current = (velocity.x != 0) ? State.run : State.idle;

    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return (player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height);
  }

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

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _loadAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runAnimation = _spriteAnimation('Run', 6);
    hitWallAnimation = _spriteAnimation('Hit Wall', 4, loop: false);
    hitAnimation = _spriteAnimation('Hit', 5, loop: false);

    animations = {
      State.idle: idleAnimation,
      State.run: runAnimation,
      State.hit: hitAnimation,
      State.hitWall: hitWallAnimation,
    };

    current = State.idle;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Rino/$state (52x34).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(52, 34),
        loop: loop,
      ),
    );
  }
}
