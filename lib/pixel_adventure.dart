import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame
    with DragCallbacks, HasKeyboardHandlerComponents {
  Player player = Player(character: 'Mask Dude');

  late final Level level;
  late JoystickComponent joystick;
  bool showJoystick = false;

  @override
  Color backgroundColor() => const Color(0xff211f30);

  @override
  FutureOr<void> onLoad() async {
    // Load all images in to cache.
    await images.loadAllImages();

    level = Level(
      levelName: 'level-01',
      player: player,
    );

    camera = CameraComponent.withFixedResolution(
      world: level,
      width: 640,
      height: 360,
    );
    camera.viewfinder.anchor = Anchor.topLeft;

    addAll([level]);

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
        player.playerDirection = PlayerDirection.left;
        break;

      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
        break;

      default:
        player.playerDirection = PlayerDirection.none;
        break;
    }
  }
}
