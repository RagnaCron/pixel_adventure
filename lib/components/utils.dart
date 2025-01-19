import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final hitBox = player.hitBox;
  final playerX = player.position.x + hitBox.offsetX;
  final playerY = player.position.y + hitBox.offsetY;
  final playerW = hitBox.width;
  final playerH = hitBox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockW = block.width;
  final blockH = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitBox.offsetX * 2) - playerW : playerX;
  final fixedY = block.isPlatform ? playerY + playerH : playerY;

  return (fixedY < blockY + blockH &&
      playerY + playerH > blockY &&
      fixedX < blockX + blockW &&
      fixedX + playerW > blockX);
}
