import 'package:flame/components.dart';
import 'package:pixel_adventure/letters/letter.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Word extends PositionComponent with HasGameReference<PixelAdventure> {
  String word;
  double fontScale;

  Word({
    super.position,
    super.size,
    required this.word,
    this.fontScale = 1,
  });

  @override
  Future<void> onLoad() async {
    final letterIndexes = _mapWordToLetterPosition(word);
    _addLetters(letterIndexes);
    return super.onLoad();
  }

  void _addLetters(List<int> letterIndexes) {
    for (int i = 0; i < letterIndexes.length; i++) {
      final letter = Letter(
        letterIndex: letterIndexes[i],
        position: Vector2(
          x + (i * Letter.letterWidth * fontScale),
          y,
        ),
        size: Vector2(
          Letter.letterWidth * fontScale,
          Letter.letterHeight * fontScale,
        ),
      );
      add(letter);
    }
  }

  List<int> _mapWordToLetterPosition(String word) {
    // todo: change this, as it looks like ****, good thing is AI can write this in seconds, so I don't get my fingers dirty... =)
    List<int> letterIndexes = [];
    for (String char in word.split('')) {
      switch (char.toLowerCase()) {
        case 'a':
          letterIndexes.add(0);
        case 'b':
          letterIndexes.add(1);
        case 'c':
          letterIndexes.add(2);
        case 'd':
          letterIndexes.add(3);
        case 'e':
          letterIndexes.add(4);
        case 'f':
          letterIndexes.add(5);
        case 'g':
          letterIndexes.add(6);
        case 'h':
          letterIndexes.add(7);
        case 'i':
          letterIndexes.add(8);
        case 'j':
          letterIndexes.add(9);
        case 'k':
          letterIndexes.add(10);
        case 'l':
          letterIndexes.add(11);
        case 'm':
          letterIndexes.add(12);
        case 'n':
          letterIndexes.add(13);
        case 'o':
          letterIndexes.add(14);
        case 'p':
          letterIndexes.add(15);
        case 'q':
          letterIndexes.add(16);
        case 'r':
          letterIndexes.add(17);
        case 's':
          letterIndexes.add(18);
        case 't':
          letterIndexes.add(19);
        case 'u':
          letterIndexes.add(20);
        case 'v':
          letterIndexes.add(21);
        case 'w':
          letterIndexes.add(22);
        case 'x':
          letterIndexes.add(23);
        case 'y':
          letterIndexes.add(24);
        case 'z':
          letterIndexes.add(25);
        case '0':
          letterIndexes.add(30);
        case '1':
          letterIndexes.add(31);
        case '2':
          letterIndexes.add(32);
        case '3':
          letterIndexes.add(33);
        case '4':
          letterIndexes.add(34);
        case '5':
          letterIndexes.add(35);
        case '6':
          letterIndexes.add(36);
        case '7':
          letterIndexes.add(37);
        case '8':
          letterIndexes.add(38);
        case '9':
          letterIndexes.add(39);
        case '.':
          letterIndexes.add(40);
        case ',':
          letterIndexes.add(41);
        case ':':
          letterIndexes.add(42);
        case '?':
          letterIndexes.add(43);
        case '!':
          letterIndexes.add(44);
        case '(':
          letterIndexes.add(45);
        case ')':
          letterIndexes.add(46);
        case '+':
          letterIndexes.add(47);
        case '-':
          letterIndexes.add(48);
        case ' ':
          letterIndexes.add(49);
      }
    }
    return letterIndexes;
  }
}
