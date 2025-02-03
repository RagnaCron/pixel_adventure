import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/players/player.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';

enum PlantState {
  attack,
  idle,
  hit,
}

class Plant extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Plant({
    super.position,
    super.size,
    required this.facingDirection,
    required this.viewField,
    super.removeOnFinish = const {PlantState.hit: true},
  });

  String facingDirection;
  double viewField;

  static const int tileSize = 16;
  static const double stepTime = 0.05;
  static const double _bouncedHeight = 260.0;

  late final Player player;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hitAnimation;

  bool gotStomped = false;
  double rangeNeg = 0;
  double rangePos = 0;

  final CustomHitBox hitBox = CustomHitBox(
    offsetX: 12,
    offsetY: 16,
    width: 31,
    height: 32,
  );

  @override
  Future<void> onLoad() async {
    debugMode = true;

    player = game.player;

    _loadAnimations();
    _calculateRange();

    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
        position: hitBox.position,
        size: hitBox.size,
        isSolid: true,
      ),
    );

    if (facingDirection == "right") {
      flipHorizontallyAroundCenter();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped && playerInRange()) {
      current = PlantState.attack;
    } else {
      current = PlantState.idle;
    }
    super.update(dt);
  }

  bool playerInRange() {
    if (facingDirection == "left") {
      double playerOffset = 0;
      return (player.x + playerOffset > rangeNeg &&
          player.y + player.height > position.y &&
          player.y < position.y + height);
    } else if (facingDirection == "right") {
      double playerOffset = -player.width;
      return (
          player.x + playerOffset < rangePos &&
          player.y + player.height > position.y &&
          player.y < position.y + height);
    }
    return false;
  }

  void collidedWithPlayer() {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSound) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume);
      }
      gotStomped = true;

      current = PlantState.hit;
      player.velocity.y = -_bouncedHeight;
    } else {
      player.collidedWithEnemy();
    }
  }

  void _calculateRange() {
    rangeNeg = position.x - viewField * tileSize;
    rangePos = position.x + viewField * tileSize;
  }

  void _loadAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    attackAnimation = _spriteAnimation('Attack', 8);
    hitAnimation = _spriteAnimation('Hit', 5, loop: false);

    animations = {
      PlantState.idle: idleAnimation,
      PlantState.attack: attackAnimation,
      PlantState.hit: hitAnimation,
    };

    current = PlantState.idle;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    int amount, {
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Plant/$state (44x42).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(44, 42),
        loop: loop,
      ),
    );
  }
}
