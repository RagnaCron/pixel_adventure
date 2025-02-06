import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum State {
  flying,
  hit,
}

class BlueBird extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure> {
  BlueBird({
    super.position,
    super.size,
    required this.offNeg,
    required this.offPos,
    super.removeOnFinish = const {State.hit: true},
  });

  final double offNeg;
  final double offPos;


}
