import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Projectile extends SpriteComponent {
  final double speed = 200;

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('laser-1.png');
    size = Vector2(10, 20);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y -= speed * dt;
    if (position.y < -size.y) {
      removeFromParent();
    }
  }
}
