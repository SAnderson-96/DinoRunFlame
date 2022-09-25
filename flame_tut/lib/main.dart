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
import 'worm.dart';
import 'package:flame/timer.dart';

void main() {
  runApp(GameWidget(game: DinoGame()));
}

class DinoGame extends FlameGame with TapDetector, HasCollisionDetection {
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
    wormIntervalTimer = Timer(1, repeat: false, autoStart: false);

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
      FlameAudio.play('jump.mp3', volume: 1);
    }

    //jump
    dino.hasJumped = true;
    return true;
  }
}
