import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/levels/level.dart';
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
  String facingDirection;

  Rino({
    super.position,
    super.size,
    required this.facingDirection,
    super.removeOnFinish = const {State.hit: true},
  });

  static const double sightRange = 32; // tiles
  static const int tileSize = 16;
  static const double stepTime = 0.05;
  static const double moveSpeed = 100.0;
  static const double _bouncedHeight = 260.0;

  late final Player player;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation hitWallAnimation;

  double moveDirection = -1;
  double targetDirection = -1;
  double sightLeft = 0;
  double sightRight = 0;
  Vector2 velocity = Vector2.zero();
  bool gotStomped = false;
  bool isMoving = false;

  CustomHitBox hitBox = CustomHitBox(
    offsetX: 2,
    offsetY: 5,
    width: 44,
    height: 27,
  );

  @override
  Future<void> onLoad() async {
    debugMode = true;

    player = game.player;

    _loadAnimations();
    _calculateSight();

    add(RectangleHitbox(
      collisionType: CollisionType.active,
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
      _checkHorizontalCollision();
      // todo: check for horizontal collisions with wall so we can set off a nice animation. with a small bump bag velocity... would be nice!!!
    }
    super.update(dt);
  }

  void _updateState() {
    if (current != State.hitWall) {
      current = (velocity.x != 0) ? State.run : State.idle;

      if ((moveDirection > 0 && scale.x > 0) ||
          (moveDirection < 0 && scale.x < 0)) {
        flipHorizontallyAroundCenter();
        print("ScaleX: $scale");
      }
    }
  }

  void _movement(double dt) {
    velocity.x = 0;

    if (isPlayerInSight() && !isMoving) {
      final double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
      final double rinoOffset = (scale.x > 0) ? 0 : -width;

      targetDirection =
          (player.x + playerOffset < position.x + rinoOffset) ? -1 : 1;
      isMoving = true;
    }

    if (isMoving) {
      velocity.x = targetDirection * moveSpeed; // Apply movement.
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt; // Update Rino's position.
  }

  void _checkHorizontalCollision() async {
    final level = game.world as Level;
    final double rinoOffset = (scale.x > 0) ? 0 : -width;

    for (final block in level.collisionBlocks) {
      if (position.x + rinoOffset < block.x + block.width &&
          position.x + width + rinoOffset > block.x &&
          block.y <= position.y &&
          block.y + block.height >= position.y &&
          isMoving) {
        velocity.x = 0;
        isMoving = false;

        current = State.hitWall;
        await animationTicker?.completed;

        current = State.idle;

        return;
      }
    }
  }

  bool isPlayerInRange() {
    final double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    final double playerX = player.x + playerOffset;

    return (playerX >= sightLeft &&
        playerX <= sightRight &&
        player.y + player.height > position.y &&
        player.y < position.y + height);
  }

  bool isPlayerInSight() {
    final double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    final double rinoOffset = (scale.x > 0) ? 0 : -width;

    final double rinoX = position.x + rinoOffset;
    final double playerX = player.x + playerOffset;

    if (isPlayerInRange()) {
      final level = game.world as Level;
      for (final block in level.collisionBlocks) {
        print("Block at: ${block.x}, Rino at: $rinoX, Player at: $playerX");
        print(
            "Obstacle Blocks Right: ${(rinoX < playerX && block.x > rinoX && block.x < playerX)}");
        print(
            "Obstacle Blocks Left: ${(rinoX > playerX && block.x < rinoX && block.x > playerX)}");

        // Check if there is an obstacle between the rino and the player
        final bool isObstacleBlocking =
            // When player is to the right of the rino
            (rinoX < playerX && block.x > rinoX && block.x < playerX) ||
                // When player is to the left of the rino
                (rinoX > playerX && block.x < rinoX && block.x > playerX);

        if (isObstacleBlocking) {
          return false;
        }
      }
      return true;
    }
    return false;
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

  void _calculateSight() {
    sightLeft = -sightRange * tileSize;
    sightRight = sightRange * tileSize;
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
