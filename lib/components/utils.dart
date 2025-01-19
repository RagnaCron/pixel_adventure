import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final playerX = player.position.x;
  final playerY = player.position.y;
  final playerW = player.width;
  final playerH = player.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockW = block.width;
  final blockH = block.height;

  final fixedX = player.scale.x < 0 ? playerX - playerW : playerX;

  return (playerY < blockY + blockH &&
      playerY + playerH > blockY &&
      fixedX < blockX + blockW &&
      fixedX + playerW > blockX);
}
