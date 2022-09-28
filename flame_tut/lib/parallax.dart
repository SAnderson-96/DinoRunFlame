import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tut/main.dart';

import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';

class ParallaxBackground extends ParallaxComponent<DinoGame> {
  @override
  Future<void> onLoad() async {
    parallax = await gameRef.loadParallax([
      ParallaxImageData('parallax/planetSingle.png'),
      ParallaxImageData('parallax/plx2.png'),
      ParallaxImageData('parallax/plx3.png'),
      ParallaxImageData('parallax/plx4.png'),
      ParallaxImageData('parallax/plx5.png'),
    ],
        baseVelocity: Vector2(20, 0),
        velocityMultiplierDelta: Vector2(1.8, 1.0),
        fill: LayerFill.width);
  }
}
