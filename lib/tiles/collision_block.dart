import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  final bool isPlatform;

  CollisionBlock({
    super.position,
    super.size,
    this.isPlatform = false,
  });
}
