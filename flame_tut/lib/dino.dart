import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tut/main.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tut/worm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

///Dino assets
///https://arks.itch.io/dino-characters
class Dino extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<DinoGame>, KeyboardHandler {
  Vector2 velocity = Vector2(0, -600);
  Vector2 gravity = Vector2(0, 550);
  bool hasJumped = false;
  final double sizeScale = 0.7;
  final double animationSpeed = 0.2;
  late final SpriteAnimation runRightAnimation;
  late final SpriteAnimation standingAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation hurtAnimation;
  final double speed = 150;
  late Timer hurtAnimationTimer;
  bool pressedJump = false;
  int lives = 3;

  Dino() : super(size: Vector2.all(100.0)) {
    debugMode = true;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
    hurtAnimationTimer = Timer(1.5, repeat: false, autoStart: false);
    add(RectangleHitbox(
        size: Vector2.all(size[0] * sizeScale),
        anchor: Anchor.topLeft,
        position: Vector2(size[0] / 8, size[1] / 6)));
    animation = standingAnimation;
    position.x = 0;
  }

  Future<void> loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('dinoSheet.png'),
      srcSize: Vector2(24.0, 24.0),
    );

    //right animation
    runRightAnimation = spriteSheet.createAnimation(
        row: 0, stepTime: animationSpeed, from: 4, to: 10);
    //jumping animation
    jumpingAnimation = spriteSheet.createAnimation(
        row: 0, stepTime: animationSpeed + 0.21, from: 10, to: 12);
    //standing animation
    standingAnimation = spriteSheet.createAnimation(
        row: 0, stepTime: animationSpeed, from: 0, to: 3);
    hurtAnimation = spriteSheet.createAnimation(
        row: 0, stepTime: animationSpeed, from: 14, to: 16);
  }

  @override
  void update(dt) {
    super.update(dt);

    hurtAnimationTimer.update(dt);

    if (hasJumped || pressedJump) {
      jump(dt);
    } else {
      if (!hurtAnimationTimer.isRunning()) {
        moveRight(dt);
      } else {
        animation = hurtAnimation;
      }
    }
  }

  void moveRight(dt) {
    animation = runRightAnimation;
    if (x <= (gameRef.size[0] / 2) - width) {
      x += speed * dt;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Worm) {
      if (!hurtAnimationTimer.isRunning()) {
        hurtAnimationTimer.start();
        animation = hurtAnimation;
        lives--;
        if (lives == 0) {
          print('Game Over💀');
          gameRef.overlays.add('EndGame');
          gameRef.pauseEngine();
        }
        print("colliding with worm");
      } else {
        print('colliding but not being hurt');
      }
    }
  }

  void jump(dt) {
    if (!hurtAnimationTimer.isRunning()) {
      //dont change the animation unless the hurtAnimation isnt being played
      animation = jumpingAnimation;
    }

    //every frame
    //position = position + dt * velocity
    //velocity = velocity + dt * gravity
    // print('jump called');

    y = y + velocity.y * dt;
    velocity.y = velocity.y + gravity.y * dt;
    // print(dino.y);
    // print(dinoVelocity.y);

    if (y >= gameRef.size[1] - height) {
      y = gameRef.size[1] - height;
      hasJumped = false;
      pressedJump = false;
      resetVelocity();
      return;
    }
  }

  void resetVelocity() {
    print('velocity reset');
    velocity = Vector2(0, -600);
  }

  void didPressedJump() {
    pressedJump = true;
  }
}
