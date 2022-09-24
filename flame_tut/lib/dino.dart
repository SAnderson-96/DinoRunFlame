import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tut/main.dart';
import 'package:flame/sprite.dart';

class Dino extends SpriteAnimationComponent with HasGameRef<DinoGame> {
  Vector2 velocity = Vector2(0, -500);
  Vector2 gravity = Vector2(0, 550);
  bool hasJumped = false;
  final double animationSpeed = 0.2;
  late final SpriteAnimation runRightAnimation;
  late final SpriteAnimation standingAnimation;
  late final SpriteAnimation jumpingAnimation;

  Dino() : super(size: Vector2.all(100.0));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
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
  }

  @override
  void update(dt) {
    super.update(dt);

    if (hasJumped) {
      jump(dt);
    } else {
      moveRight(dt);
    }
  }

  void moveRight(dt) {
    animation = runRightAnimation;
    if (x <= (gameRef.size[0] / 2) - width) {
      x += 100 * dt;
    }
  }

  void jump(dt) {
    animation = jumpingAnimation;
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
      resetVelocity();
      return;
    }
  }

  void resetVelocity() {
    print('velocity reset');
    velocity = Vector2(0, -500);
  }
}
