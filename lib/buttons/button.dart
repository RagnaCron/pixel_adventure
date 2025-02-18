
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:pixel_adventure/letters/word.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Button extends ButtonComponent with HasGameReference<PixelAdventure> {
  String title;

  Button({
    super.size,
    super.position,
    super.onPressed,
    required this.title,
  });

  @override
  Future<void> onLoad() async {
    debugMode = true;
    button = Word(word: title);
    buttonDown = Word(word: title, fontScale: 0.9);

    return super.onLoad();
  }
}
