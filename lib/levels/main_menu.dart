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
        position: Vector2(
          game.size.x / 2 - (Letter.letterWidth * 8),
          game.size.y / 4 - Letter.letterHeight * 3.8,
        ),
        // onPressed: game.loadLevel, // todo: uncomment for actual gaming...
        buttonFontScale: 4,
        buttonDownFontScale: 3.8
      ),
    );

    return super.onLoad();
  }
}
