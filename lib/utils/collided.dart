import 'package:flame/components.dart';

abstract interface class Collided extends PositionComponent {
  void collidedWithPlayer();
}