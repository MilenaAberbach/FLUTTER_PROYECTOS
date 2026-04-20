import 'dart:async';

import 'package:bloodshed_time_final/main.dart';
import 'package:bloodshed_time_final/players/projectile.dart';
import 'package:bloodshed_time_final/level_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Enemy extends SpriteComponent with CollisionCallbacks {
  Enemy({super.position});
  final double speed = 100.00;

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('gabriel.png');
    size = Vector2.all(50);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    if (position.y > MyGame.sceneSize.y + size.y) {
      final level = parent as LevelGame?;
      level?.triggerGameOver();
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Projectile) {
      final level = parent as LevelGame?;
      level?.onEnemyKilled();
      removeFromParent();
      other.removeFromParent();
    }
  }
}
