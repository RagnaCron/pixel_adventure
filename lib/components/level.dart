import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/rendering.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Level extends World with HasGameReference<PixelAdventure> {
  final String levelName;
  final Player player;

  Level({
    required this.levelName,
    required this.player,
  });

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];
  List<Fruit> fruits = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor') ?? 'Gray';
      final background = ParallaxComponent(
        priority: -1,
        parallax: Parallax(
          [
            ParallaxLayer(
              ParallaxImage(
                game.images.fromCache('Background/$backgroundColor.png'),
                repeat: ImageRepeat.repeat,
                fill: LayerFill.none,
              ),
            ),
          ],
          baseVelocity: Vector2(-20, -50),
        ),
      );
      add(background);
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);

          case 'Fruits':
            final fruit = Fruit(
              position: spawnPoint.position,
              size: spawnPoint.size,
              fruit: spawnPoint.name,
            );
            fruits.add(fruit);
            add(fruit);

          case 'Saw':
            final saw = Saw(
              position: spawnPoint.position,
              size: spawnPoint.size,
              isVertical: spawnPoint.properties.getValue('isVertical'),
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
            );
            add(saw);
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case ('Platform'):
            final platform = CollisionBlock(
              position: collision.position,
              size: collision.size,
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);

          default:
            final block = CollisionBlock(
              position: collision.position,
              size: collision.size,
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }

    player.collisionBlocks = collisionBlocks;
  }
}
