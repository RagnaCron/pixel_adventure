import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/buttons/button.dart';
import 'package:pixel_adventure/letters/letter.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class MainMenu extends World with HasGameReference<PixelAdventure> {
  late final TiledComponent menu;

  @override
  Future<void> onLoad() async {
    menu = await TiledComponent.load('main_menu.tmx', Vector2.all(16));
    add(menu);

    final play = "Play";
    add(
      Button(
        title: play,
        size: Vector2(4 * Letter.letterWidth, Letter.letterHeight),
        position: Vector2(
          game.size.x / 2 - (Letter.letterWidth * 4),
          game.size.y / 4 - Letter.letterHeight,
        ),
        onPressed: game.loadLevel,
      ),
    );

    return super.onLoad();
  }
}
