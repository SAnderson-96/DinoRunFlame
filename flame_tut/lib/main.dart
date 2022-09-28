import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flame/text.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tut/flyingeye.dart';
import 'package:flame_tut/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame_tut/dino.dart';
import 'package:flame_tut/worm.dart';
import 'package:flame/timer.dart';
import 'package:flutter/services.dart';
import 'dart:ui' hide TextStyle;

///Parallax background credits
///https://jesse-m.itch.io/jungle-pack
void main() {
  final game = DinoGame();
  runApp(GameWidget(
    game: game,
    overlayBuilderMap: {
      'PauseMenu': (BuildContext context, DinoGame game) {
        return buildPauseMenu(context, game);
      },
      '3Hearts': (BuildContext context, DinoGame game) {
        return build3Hearts(context, game);
      },
      '2Hearts': (BuildContext context, DinoGame game) {
        return build2Hearts();
      },
      '1Hearts': (BuildContext context, DinoGame game) {
        return build1Hearts();
      },
      '0Hearts': (BuildContext context, DinoGame game) {
        return build0Hearts();
      },
      'EndGame': (BuildContext context, DinoGame game) {
        return buildEndGame(context, game);
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
  late Timer flyingEyeIntervalTimer;
  late FpsTextComponent fpsComponent;
  final TextPaint textPaint = TextPaint(
    style: TextStyle(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
      backgroundColor: Color.fromARGB(92, 0, 0, 0),
    ),
  );
  int wormsJumpedOver = 0;
  String scoreText = '';
  final hasReachedBreakPoint = [false, false, false];

  Vector2 gravity = Vector2(0, 800);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    children.register<Worm>();
    children.register<FlyingEye>();
    fpsComponent = FpsTextComponent();

    add(fpsComponent);
    print('loading game assets');
    add(parallaxComponent);
    scoreText = 'You\'ve Jumped over ${wormsJumpedOver} Worms!';

    //set a timer so that worms can only spawn at a maximum of 1 second of interval
    wormIntervalTimer = Timer(1.5, repeat: false, autoStart: false);
    flyingEyeIntervalTimer = Timer(1.5, repeat: false, autoStart: false);

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
    flyingEyeIntervalTimer.update(dt);
    super.update(dt);
    dino.update(dt);
    updateLives();
    if (Random().nextDouble() < 0.01 && !wormIntervalTimer.isRunning()) {
      Worm newWorm = Worm();
      add(newWorm);
      wormIntervalTimer.start();
    }
    if (Random().nextDouble() < 0.001 && !flyingEyeIntervalTimer.isRunning()) {
      FlyingEye eye = FlyingEye();
      add(eye);
      flyingEyeIntervalTimer.start();
    }

    scoreText = 'You\'ve Jumped over ${wormsJumpedOver} Worms!';
    final allWorms = children.query<Worm>();
    allWorms.forEach((worm) {
      if (worm.x + worm.width < 0) remove(worm);
    });

    final allFlyingEyes = children.query<FlyingEye>();
    allFlyingEyes.forEach((flyingEye) {
      if (flyingEye.x + flyingEye.width < 0) remove(flyingEye);
    });

    if (wormsJumpedOver == 10) {
      if (!hasReachedBreakPoint[0] && !wormIntervalTimer.isRunning()) {
        wormIntervalTimer = Timer(1.25, repeat: false, autoStart: false);
        hasReachedBreakPoint[0] = true;
      }
    } else if (wormsJumpedOver == 20) {
      if (!hasReachedBreakPoint[1] && !wormIntervalTimer.isRunning()) {
        wormIntervalTimer = Timer(1.15, repeat: false, autoStart: false);
        hasReachedBreakPoint[1] = true;
      }
    } else if (wormsJumpedOver == 30) {
      if (!hasReachedBreakPoint[2] && !wormIntervalTimer.isRunning()) {
        wormIntervalTimer = Timer(0.85, repeat: false, autoStart: false);
        hasReachedBreakPoint[2] = true;
      }
    }
  }

  @override
  void render(canvas) {
    super.render(canvas);

    textPaint.render(canvas, scoreText, Vector2(size[0] / 2, size[1] / 10),
        anchor: Anchor.center);

    fpsComponent.render(canvas);
  }

  @override
  bool onTapDown(TapDownInfo event) {
    // print("Player tap down on ${event.eventPosition.game}");
    if (!dino.hasJumped) {
      //Not working in android for some reason
      // FlameAudio.play('jump.mp3', volume: 1);
      dino.hasJumped = true;
    } else if (dino.hasJumped) {
      dino.isForcedDown = true;
    }

    //jump

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

  void updateLives() {
    switch (dino.lives) {
      case 3:
        if (overlays.isActive('2Hearts')) {
          overlays.remove('2Hearts');
        }
        if (!overlays.isActive('3Hearts')) {
          overlays.add('3Hearts');
        }
        break;
      case 2:
        if (overlays.isActive('3Hearts')) {
          overlays.remove('3Hearts');
        }
        if (overlays.isActive('1Hearts')) {
          overlays.remove('1Hearts');
        }
        if (!overlays.isActive('2Hearts')) {
          overlays.add('2Hearts');
        }
        break;
      case 1:
        if (overlays.isActive('2Hearts')) {
          overlays.remove('2Hearts');
        }
        if (!overlays.isActive('1Hearts')) {
          overlays.add('1Hearts');
        }
        break;
      case 0:
        if (overlays.isActive('1Hearts')) {
          overlays.remove('1Hearts');
        }
        overlays.add('0Hearts');
        break;
    }
  }
}

Widget buildPauseMenu(BuildContext context, DinoGame game) {
  return Center(
      child: Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(90, 0, 0, 0),
              border: Border.all(color: Colors.white)),
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(10, 10))),
                  child: Text('⏸️ Paused ⏸️',
                      style: TextStyle(
                          fontSize: 75,
                          fontFamily: 'Awesome Font',
                          backgroundColor: Color.fromARGB(90, 0, 0, 0)))))));
}

Widget build0Hearts() {
  return Positioned(
    top: 100,
    right: 0,
    child: Row(children: [
      Text('💀', style: TextStyle(fontSize: 90)),
      Text('💀', style: TextStyle(fontSize: 90)),
      Text('💀', style: TextStyle(fontSize: 90)),
    ]),
  );
}

Widget build1Hearts() {
  return Positioned(
    top: 100,
    right: 0,
    child: Row(children: [
      Text('❤️', style: TextStyle(fontSize: 90)),
      Text('💀', style: TextStyle(fontSize: 90)),
      Text('💀', style: TextStyle(fontSize: 90)),
    ]),
  );
}

Widget build2Hearts() {
  return Positioned(
    top: 100,
    right: 0,
    child: Row(children: [
      Text('❤️', style: TextStyle(fontSize: 90)),
      Text('❤️', style: TextStyle(fontSize: 90)),
      Text('💀', style: TextStyle(fontSize: 90)),
    ]),
  );
}

Widget build3Hearts(BuildContext context, DinoGame game) {
  return Positioned(
    top: 100,
    right: 0,
    child: Row(children: [
      Text('❤️', style: TextStyle(fontSize: 90)),
      Text('❤️', style: TextStyle(fontSize: 90)),
      Text('❤️', style: TextStyle(fontSize: 90)),
    ]),
  );
}

Widget buildEndGame(BuildContext context, DinoGame game) {
  return Center(
      child: Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(155, 0, 0, 0),
              border: Border.all(color: Colors.white)),
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(10, 10))),
                  child: Center(
                      child: Text(
                          'G A M E  O V E R\nYou Have Jumped over ${game.wormsJumpedOver} ${game.wormsJumpedOver != 1 ? "Worms" : "Worm\nYou are Trash"}.',
                          style: TextStyle(
                            fontSize: 90,
                            fontFamily: 'Awesome Font',
                          )))))));
}
