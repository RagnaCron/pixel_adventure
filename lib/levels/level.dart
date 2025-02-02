import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/enemies/mushroom.dart';
import 'package:pixel_adventure/tiles/background_tile.dart';
import 'package:pixel_adventure/checkpoints/checkpoint.dart';
import 'package:pixel_adventure/enemies/chicken.dart';
import 'package:pixel_adventure/tiles/platform.dart';
import 'package:pixel_adventure/traps/saw.dart';
import 'package:pixel_adventure/tiles/collision_block.dart';
import 'package:pixel_adventure/collectables/fruit.dart';
import 'package:pixel_adventure/players/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/traps/spikes.dart';
import 'package:pixel_adventure/traps/trampoline.dart';

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
    add(BackgroundTile());
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
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
              initialMovement:
                  spawnPoint.properties.getValue('initialMovement'),
              isClockWise: spawnPoint.properties.getValue('isClockWise'),
              horizontalOffNeg:
                  spawnPoint.properties.getValue('horizontalOffNeg'),
              horizontalOffPos:
                  spawnPoint.properties.getValue('horizontalOffPos'),
              verticalOffNeg: spawnPoint.properties.getValue('verticalOffNeg'),
              verticalOffPos: spawnPoint.properties.getValue('verticalOffPos'),
            );
            add(saw);

          case 'Spikes':
            final spikes = Spikes(
              position: spawnPoint.position,
              size: spawnPoint.size,
              isUpSideDown: spawnPoint.properties.getValue('isUpSideDown'),
            );
            add(spikes);

          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: spawnPoint.position,
              size: spawnPoint.size,
            );
            add(checkpoint);

          case 'Chicken':
            final chicken = Chicken(
              position: spawnPoint.position,
              size: spawnPoint.size,
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
            );
            add(chicken);

          case 'Mushroom':
            final mushroom = Mushroom(
              position: spawnPoint.position,
              size: spawnPoint.size,
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
            );
            add(mushroom);

          case 'Trampoline':
            final trampoline = Trampoline(
              position: spawnPoint.position,
              size: spawnPoint.size,
            );
            add(trampoline);

          case 'Platform':
            final platform = Platform(
              position: spawnPoint.position,
              size: spawnPoint.size,
              isPlatform: spawnPoint.properties.getValue('isPlatform'),
              type: spawnPoint.properties.getValue('type'),
              isClockWise: spawnPoint.properties.getValue('isClockWise'),
              horizontalOffNeg:
                  spawnPoint.properties.getValue('horizontalOffNeg'),
              horizontalOffPos:
                  spawnPoint.properties.getValue('horizontalOffPos'),
              verticalOffNeg: spawnPoint.properties.getValue('verticalOffNeg'),
              verticalOffPos: spawnPoint.properties.getValue('verticalOffPos'),
              initialMovement:
                  spawnPoint.properties.getValue('initialMovement'),
            );
            collisionBlocks.add(platform as CollisionBlock);
            add(platform);
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case ('StaticPlatform'):
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
