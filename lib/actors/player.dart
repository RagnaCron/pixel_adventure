import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure> {
  late final SpriteAnimation idleAnimation;

  final int amount = 11;
  final double stepTime = 0.05;
  final Vector2 textureSize = Vector2.all(32);

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();

    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Mask Dude/Idle (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }
}
