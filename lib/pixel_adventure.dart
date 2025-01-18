import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame {
  late final CameraComponent cam;
  final level = Level();

  @override
  FutureOr<void> onLoad() async {
    cam = CameraComponent.withFixedResolution(
      world: level,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, level]);
    return super.onLoad();
  }
}
