import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame {
  final level = Level();

  @override
  Color backgroundColor() => const Color(0xff211f30);

  @override
  FutureOr<void> onLoad() async {
    // Load all images in to cache.
    await images.loadAllImages();

    camera = CameraComponent.withFixedResolution(
      world: level,
      width: 640,
      height: 360,
    );
    camera.viewfinder.anchor = Anchor.topLeft;

    addAll([level]);



    return super.onLoad();
  }
}
