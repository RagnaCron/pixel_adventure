import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:pixel_adventure/letters/letter.dart';
import 'package:pixel_adventure/letters/word.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Button extends ButtonComponent with HasGameReference<PixelAdventure> {
  String title;
  double buttonFontScale;
  double buttonDownFontScale;

  Button({
    super.position,
    super.onPressed,
    required this.title,
    this.buttonFontScale = 1,
    this.buttonDownFontScale = 1,
  });

  @override
  Future<void> onLoad() async {
    final buttonWidth = title.length * Letter.letterWidth * buttonFontScale;
    final buttonDownWidth = title.length * Letter.letterWidth * buttonDownFontScale;
    // doing this, need to set the 'hit box' size...
    size = Vector2(
      buttonWidth,
      Letter.letterHeight * buttonFontScale,
    );

    button = Word(
      word: title,
      fontScale: buttonFontScale,
    );
    buttonDown = Word(
      word: title,
      fontScale: buttonDownFontScale,
      position: Vector2((buttonWidth - buttonDownWidth) / 4, Letter.letterHeight * buttonDownFontScale / 16)
    );

    return super.onLoad();
  }
}
