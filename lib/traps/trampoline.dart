import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/players/player.dart';
import 'package:pixel_adventure/tiles/custom_hitbox.dart';

enum TrampolineState {
  idle,
  jump,
}

class Trampoline extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Trampoline({
    super.position,
    super.size,
  });

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation jumpAnimation;
  late final Player player;

  final CustomHitBox hitBox = CustomHitBox(
    offsetX: 4,
    offsetY: 20,
    width: 23,
    height: 12,
  );

  @override
  Future<void> onLoad() async {
    priority = 1;
    player = game.player;
    debugMode = true;

    idleAnimation = _spriteAnimation('Idle', 1);
    jumpAnimation = _spriteAnimation('Jump', 8, loop: false);

    animations = {
      TrampolineState.idle: idleAnimation,
      TrampolineState.jump: jumpAnimation,
    };

    current = TrampolineState.idle;

    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
        position: hitBox.position,
        size: hitBox.size,
      ),
    );

    return super.onLoad();
  }

  void collideWithPlayer() {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSound) {
        FlameAudio.play('bounde.wav', volume: game.soundVolume);
      }

      current = TrampolineState.jump;
      player.jumpCount = 1;
      player.isJumpingFromTrampoline = true;
      Future.delayed(const Duration(milliseconds: 200), () => player.isJumpingFromTrampoline = false);
    }
  }

  SpriteAnimation _spriteAnimation(String name, int amount,
      {bool loop = true, double textureSize = 28}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Trampoline/$name (28x28).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.05,
        textureSize: Vector2.all(textureSize),
        loop: loop,
      ),
    );
  }


}
