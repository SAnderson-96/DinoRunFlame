import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tut/main.dart';

import 'dino.dart';

class FlyingEye extends SpriteAnimationComponent
    with HasGameRef<DinoGame>, CollisionCallbacks {
  late final SpriteAnimation flyingAnimation;
  final double animationSpeed = 0.15;
  final double sizeScale = 0.3;
  final double spriteSize = 150;
  double speed = 200;
  bool hasBeenHit = false;
  bool hasBeenAddedToCount = false;
  FlyingEye() : super(size: Vector2.all(150 * 1.5)) {
    debugMode = true;
    anchor = Anchor.topRight;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await loadAnimations();
    flipHorizontally();
    speed = speed + (gameRef.wormsJumpedOver * 10);
    add(RectangleHitbox(
        size: Vector2(size[0] * sizeScale, size[1] * 0.2),
        anchor: Anchor.topLeft,
        position: Vector2(size[0] / 2.75, size[1] / 2.35)));

    animation = flyingAnimation;
    position.y = getRandomHeight();
    position.x = gameRef.size[0];
  }

  Future<void> loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('flyingEye/Flight.png'),
      srcSize: Vector2(150, 150),
    );

    flyingAnimation = spriteSheet.createAnimation(
        row: 0, stepTime: animationSpeed, from: 0, to: 7);
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
      speed = speed + 20;
      print(speed);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);

    if (other is Dino) {
      hasBeenHit = true;
    }
  }

  double getRandomHeight() {
    return 250;
  }
}
