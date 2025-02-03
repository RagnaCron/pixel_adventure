import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/checkpoints/checkpoint.dart';
import 'package:pixel_adventure/enemies/chicken.dart';
import 'package:pixel_adventure/enemies/mushroom.dart';
import 'package:pixel_adventure/tiles/collision_block.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';
import 'package:pixel_adventure/collectables/fruit.dart';
import 'package:pixel_adventure/tiles/platform.dart';
import 'package:pixel_adventure/traps/saw.dart';
import 'package:pixel_adventure/traps/trampoline.dart';
import 'package:pixel_adventure/utils/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  doubleJumping,
  wallSliding,
  falling,
  hit,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with KeyboardHandler, HasGameReference<PixelAdventure>, CollisionCallbacks {
  String character;

  Player({
    super.position,
    this.character = "Ninja Frog",
  });

  List<CollisionBlock> collisionBlocks = [];

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation doubleJumpingAnimation;
  late final SpriteAnimation wallSlidingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double _gravity = 11;
  final double _jumpForce = 320;
  final double _terminalVelocity = 400;
  double horizontalMovement = 0; // -1 (facing left), 1 (facing right)
  final double _moveSpeed = 120;
  Vector2 velocity = Vector2.zero();
  bool isOnGround =
      false; // todo: check if this can be removed, as it seams no longer needed, due to the double jumping..
  bool hasJumped = false;
  int jumpCount = 0;
  final int maxJumpCount = 2;
  bool isTouchingWall = false;
  int wallDirection =
      0; // -1 (left wall), 1 (right wall), 0 (not touching any wall)
  bool isJumpingFromTrampoline = false;
  final double _wallSlideGravity = 0.5;
  final double _wallJumpForceY = 300;
  bool isOnMovingPlatform = false;

  ComponentKey? platformKey;

  CustomHitBox hitBox = CustomHitBox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  Vector2 startingPosition = Vector2.zero();
  bool playerHit = false;

  bool _playerReachedCheckpoint = false;

  double fixedDeltaTime = 1 / 90;
  double accumulatedTime = 0;

  @override
  Future<void> onLoad() async {
    priority = 1;
    startingPosition = Vector2(position.x, position.y);

    _loadAllAnimations();
    add(RectangleHitbox(
      position: Vector2(hitBox.offsetX, hitBox.offsetY),
      size: Vector2(hitBox.width, hitBox.height),
      isSolid: true,
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!playerHit && !_playerReachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    bool isKeyDown = event is KeyDownEvent;

    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD);

    hasJumped = isKeyDown && keysPressed.contains(LogicalKeyboardKey.space);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    // todo: check documentation on key events, and how they are handled, as there is a noisy beeping sound on Mac if super is called.
    // this may be due to the event not being handled properly...?? as the event is passed on to the next handler ??(touch, gamepad, and so on).
    // return super.onKeyEvent(event, keysPressed);
    return false;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!_playerReachedCheckpoint) {
      if (other is Fruit) {
        other.collidedWithPlayer();
      }

      if (other is Saw) {
        _respawn();
      }

      if (other is Checkpoint) {
        _reachedCheckpoint();
      }

      if (other is Chicken) {
        other.collidedWithPlayer();
      }

      if (other is Mushroom) {
        other.collidedWithPlayer();
      }

      if (other is Trampoline) {
        other.collideWithPlayer();
      }

      if (other is Platform) {
        isOnMovingPlatform = true;
      }
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) async {
    if (other is Trampoline) {
      await other.animationTicker?.completed;
      other.current = TrampolineState.idle;
    }

    if (other is Platform) {
      isOnMovingPlatform = false;
    }

    super.onCollisionEnd(other);
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x != 0) {
      playerState = PlayerState.running;
    }

    // Check if wall sliding
    if (isTouchingWall && velocity.y > 0) {
      playerState = PlayerState.wallSliding;
    } else
    // Check if falling
    if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }

    // Check if jumping
    if (velocity.y < 0) {
      if (jumpCount == 1) {
        playerState = PlayerState.jumping;
      } else if (jumpCount == 2 && !isTouchingWall) {
        playerState = PlayerState.doubleJumping;
      }
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    // Set the initial move velocity.x as it could be reset in _playerWallJump.
    velocity.x = horizontalMovement * _moveSpeed;

    if (hasJumped) {
      if (jumpCount < maxJumpCount) {
        _playerJump(dt);
      } else if (isTouchingWall) {
        _playerWallJump();
      }
    }
    // Setting it to falls, if we move the player, else
    // there will be an animation bug.
    isTouchingWall = false;

    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (jumpCount < maxJumpCount) {
      if (game.playSound) {
        FlameAudio.play('jump.wav', volume: game.soundVolume);
      }

      velocity.y = -_jumpForce;
      position.y += velocity.y * dt;
      isOnGround = false;
      hasJumped = false;

      jumpCount++;
    }
  }

  void _playerWallJump() {
    if (game.playSound) {
      FlameAudio.play('jump.wav', volume: game.soundVolume);
    }

    hasJumped = false;
    velocity.y = -_wallJumpForceY;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitBox.offsetX - hitBox.width;
            isTouchingWall = true;
            wallDirection = 1;
            jumpCount = 0;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitBox.width + hitBox.offsetX;
            isTouchingWall = true;
            wallDirection = -1;
            jumpCount = 0;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    if (isJumpingFromTrampoline) {
      velocity.y -= _jumpForce;
    } else if (isTouchingWall && velocity.y > 0) {
      velocity.y += _wallSlideGravity;
    } else {
      velocity.y += _gravity;
    }

    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.offsetY - hitBox.height;
            isOnGround = true;
            jumpCount = 0;
            isJumpingFromTrampoline = false;
          }
          if (block is Platform) {
            position.y += 2;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.offsetY - hitBox.height;
            isOnGround = true;
            jumpCount = 0;
            isJumpingFromTrampoline = false;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitBox.offsetY;
            isJumpingFromTrampoline = false;
          }
        }
      }
    }
  }

  void _respawn() async {
    if (game.playSound) {
      FlameAudio.play('hit.wav', volume: game.soundVolume);
    }

    playerHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    playerHit = false;
  }

  void _reachedCheckpoint() async {
    if (game.playSound) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }
    _playerReachedCheckpoint = true;

    if (scale.x < 0) {
      position = position - Vector2(-32, 32);
    } else if (scale.x > 0) {
      position = position - Vector2.all(32);
    }
    current = PlayerState.disappearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    _playerReachedCheckpoint = false;
    position = Vector2.all(-640);

    Future.delayed(const Duration(seconds: 3), () => game.loadNextLevel());
  }

  void collidedWithEnemy() {
    _respawn();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    doubleJumpingAnimation = _spriteAnimation('Double Jump', 6, loop: false);
    wallSlidingAnimation = _spriteAnimation('Wall Jump', 5);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7, loop: false);
    appearingAnimation = _spriteSpecialAnimation('Appearing', 7, loop: false);
    disappearingAnimation =
        _spriteSpecialAnimation('Disappearing', 7, loop: false);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.doubleJumping: doubleJumpingAnimation,
      PlayerState.wallSliding: wallSlidingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // Set current animation
    current = PlayerState.appearing;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: loop,
      ),
    );
  }

  SpriteAnimation _spriteSpecialAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$state (96x96).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: loop,
      ),
    );
  }
}
