import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame
    with DragCallbacks, HasKeyboardHandlerComponents, HasCollisionDetection {
  Player player = Player(character: 'Mask Dude');

  // late Level level;
  late JoystickComponent joystick;
  bool showJoystick = false;

  List<String> levelNames = [
    'level-01',
    'level-01',
  ];
  int currentLevelIndex = 0;

  @override
  Color backgroundColor() => const Color(0xff211f30);

  @override
  FutureOr<void> onLoad() async {
    // Load all images in to cache.
    await images.loadAllImages();

    _loadLevel();

    if (showJoystick) {
      addJoyStick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void loadNextLevel() {
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
    } else {
      currentLevelIndex = 0;
    }
    _loadLevel();
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      _createCameraComponent();

      addAll([world]);
    });
  }

  void _createCameraComponent() {
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    camera.viewfinder.anchor = Anchor.topLeft;
  }

  void addJoyStick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png')),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 28, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;

      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;

      default:
        player.horizontalMovement = 0;
        break;
    }
  }
}
