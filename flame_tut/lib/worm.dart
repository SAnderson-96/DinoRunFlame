import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tut/dino.dart';
import 'package:flame_tut/main.dart';
import 'package:flame/sprite.dart';

///Worm From
///https://luizmelo.itch.io/fire-worm
class Worm extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<DinoGame> {
  late final SpriteAnimation idleAnimation;
  final double animationSpeed = 0.1;
  final double sizeScale = 0.6;
  final double speed = 200;
  bool hasBeenHit = false;
  bool hasBeenAddedToCount = false;
  Worm() : super(size: Vector2.all(90 * 1.25)) {
    debugMode = true;
    anchor = Anchor.topRight;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
    flipHorizontally();
    add(RectangleHitbox(
        size: Vector2.all(this.size[0] * sizeScale),
        anchor: Anchor.topLeft,
        position: Vector2(this.size[0] / 6, this.size[1] / 6)));

    animation = idleAnimation;
    position.y = gameRef.size[1] - gameRef.dino.size.y;
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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);

    if (other is Dino) {
      hasBeenHit = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= speed * dt;

    if (x < gameRef.dino.x - gameRef.dino.width &&
        !hasBeenAddedToCount &&
        !hasBeenHit) {
      hasBeenAddedToCount = true;
      gameRef.wormsJumpedOver++;
    }
  }
}
