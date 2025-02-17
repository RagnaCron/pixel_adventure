import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class MainMenu extends World with HasGameReference<PixelAdventure> {

  late TiledComponent menu;

  @override
  Future<void> onLoad() async {
    menu = await TiledComponent.load('main_menu.tmx', Vector2.all(16));
    add(menu);

    return super.onLoad();
  }

}