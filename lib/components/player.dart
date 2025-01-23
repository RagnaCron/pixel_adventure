import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with
        KeyboardHandler,
        HasGameReference<PixelAdventure>,
        CollisionCallbacks {
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
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double _gravity = 9.8;

  // todo: check the jumpforce, as this seams to have some kind of problem depending on the OS it is running on, for mac os is would be ok to have 260, but not on windows 11...
  final double _jumpForce = 320;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
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
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    hasJumped = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.space);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    //return super.onKeyEvent(event, keysPressed);
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
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
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
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // Set current animation
    current = PlayerState.appearing;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    // Check if falling
    if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }

    // Check if jumping
    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  // IsolateCallback callback = FlameAudio.play('jump.wav', volume: game.soundVolume);

  void _playerJump(double dt) {
    if (game.playSound) {
      // isolateCompute(() => FlameAudio.play('jump.wav', volume: game.soundVolume));
      FlameAudio.play('jump.wav', volume: game.soundVolume);
    }
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
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

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitBox.offsetX - hitBox.width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitBox.width + hitBox.offsetX;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
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
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.offsetY - hitBox.height;
            isOnGround = true;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitBox.offsetY;
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
}
