import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tut/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame_tut/dino.dart';
import 'package:flame_tut/worm.dart';
import 'package:flame/timer.dart';
import 'package:flutter/services.dart';

///Parallax background credits
///https://jesse-m.itch.io/jungle-pack
void main() {
  final game = DinoGame();
  runApp(GameWidget(
    game: game,
    overlayBuilderMap: {
      'PauseMenu': (BuildContext context, DinoGame game) {
        return Text('A Pause Menu');
      }
    },
  ));
}

class DinoGame extends FlameGame
    with
        TapDetector,
        HasCollisionDetection,
        KeyboardEvents,
        HasKeyboardHandlerComponents {
  final Dino dino = Dino();
  final ParallaxBackground parallaxComponent = ParallaxBackground();
  late Timer wormIntervalTimer;

  Vector2 gravity = Vector2(0, 800);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    print('loading game assets');
    add(parallaxComponent);

    //set a timer so that worms can only spawn at a maximum of 1 second of interval
    wormIntervalTimer = Timer(1.5, repeat: false, autoStart: false);

    final screenWidth = size[0];
    //size is built in to Flame and gives you the dimensions of the screen
    final screenHeight = size[1];

    //load dino
    //cascade operator instead of doing dino.sprite and then dino.load etc.
    dino
      ..y = screenHeight - dino.height
      ..x = 0;

    //always add Dino last because we want him with the highest z index (on top of everything else depth wise)
    add(dino); // add is from FlameGame
    //position of sprite on y axis -- 0,0 is still top left
  }

  @override
  void update(double dt) {
    //!important worm.update is implicitly called because it was added (by using Flame add() - in the if statement below)
    //Must update the timer for it to work
    wormIntervalTimer.update(dt);
    super.update(dt);
    dino.update(dt);
    if (Random().nextDouble() < 0.01 && !wormIntervalTimer.isRunning()) {
      Worm newWorm = Worm();
      add(newWorm);
      wormIntervalTimer.start();
    }
  }

  @override
  bool onTapDown(TapDownInfo event) {
    // print("Player tap down on ${event.eventPosition.game}");
    if (!dino.hasJumped) {
      //Not working in android for some reason
      // FlameAudio.play('jump.mp3', volume: 1);
    }

    //jump
    dino.hasJumped = true;
    return true;
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;

    final isP = keysPressed.contains(LogicalKeyboardKey.keyP);

    if (isP) {
      if (overlays.isActive('PauseMenu')) {
        overlays.remove('PauseMenu');
        resumeEngine();
        return KeyEventResult.handled;
      } else {
        overlays.add('PauseMenu');
        pauseEngine();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
