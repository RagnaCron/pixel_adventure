
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;

  BackgroundTile({
    super.position,
    this.color = 'Blue',
  });

  final double scrollSpeedX = 0.1;
  final double scrollSpeedY = 0.3;

  @override
  Future<void> onLoad() async {
    priority = -1;
    size = Vector2.all(64);

    parallax = await game.loadParallax(
      [ParallaxImageData('Background/$color.png')],
      baseVelocity: Vector2(-20, -50),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );

    return super.onLoad();
  }
}
