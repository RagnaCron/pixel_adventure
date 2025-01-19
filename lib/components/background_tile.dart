import 'dart:math';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent
    with HasGameReference<PixelAdventure> {
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
    size = Vector2.all(64.6);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.x += sin(scrollSpeedX);
    position.y += sin(scrollSpeedY);

    double tileSize = 64;
    int scrollHeight = (game.size.y / tileSize).floor();
    int scrollWidth = (game.size.x / tileSize).floor();

    if (position.x > scrollWidth * tileSize) {
      position.x = -tileSize;
    }
    if (position.y > scrollHeight * tileSize) {
      position.y = -tileSize;
    }
    super.update(dt);
  }
}

// void _scrollingBackground() {
// final backgroundLayer = level.tileMap.getLayer('Background');
//
// const tileSize = 64;
//
// final numTilesX = (game.size.x / tileSize).floor();
// final numTilesY = (game.size.y / tileSize).floor();
//
// if (backgroundLayer != null) {
//   final backgroundColor =
//       backgroundLayer.properties.getValue('BackgroundColor');
//
//   for (double y = 0; y <= numTilesY; y++) {
//     for (double x = 0; x <= numTilesX; x++) {
//       final backgroundTile = BackgroundTile(
//         color: backgroundColor ?? 'Pink',
//         position: Vector2((x * tileSize), (y * tileSize) - tileSize),
//       );
//       add(backgroundTile);
//     }
//   }
// }
// }
