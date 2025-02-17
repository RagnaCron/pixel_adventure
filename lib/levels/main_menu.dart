import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/letters/letter.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class MainMenu extends World with HasGameReference<PixelAdventure> {
  late final TiledComponent menu;

  @override
  Future<void> onLoad() async {
    // debugMode = true;
    menu = await TiledComponent.load('main_menu.tmx', Vector2.all(16));
    add(menu);

    add(Letter(letterIndex: 0));
    add(Letter(letterIndex: 1, position: Vector2(8, 0)));
    add(Letter(letterIndex: 2, position: Vector2(16, 0)));
    add(Letter(letterIndex: 3, position: Vector2(24, 0)));

    return super.onLoad();
  }
}
