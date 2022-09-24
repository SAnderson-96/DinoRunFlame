import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tut/main.dart';
import 'package:flame/sprite.dart';

class Worm extends SpriteAnimationComponent with HasGameRef<DinoGame> {
  late final SpriteAnimation idleAnimation;
  final double animationSpeed = 0.15;

  Worm() : super(size: Vector2.all(90 * 1.75));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
    flipHorizontally();
    animation = idleAnimation;
    position.y = gameRef.size[1] - size.y + 40;
    position.x = gameRef.size[0];
  }

  Future<void> loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('worm/Idle.png'),
      srcSize: Vector2(90, 90),
    );

    idleAnimation = spriteSheet.createAnimation(
        row: 0, stepTime: animationSpeed, from: 0, to: 8);
  }

  @override
  void update(double dt) {
    super.update(dt);

    x -= 200 * dt;
  }
}
