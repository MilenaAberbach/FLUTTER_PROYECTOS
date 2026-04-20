import 'dart:async';
import 'dart:math';

import 'package:bloodshed_time_final/enemies/enemy.dart';
import 'package:bloodshed_time_final/main.dart';
import 'package:bloodshed_time_final/players/player.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/widgets.dart';
import 'package:flame_audio/flame_audio.dart';

class LevelGame extends World {
  Random random = Random();
  double enemySpawnTimer = 0;
  late Player player;
  late MyGame gameRef;
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    player = Player();
    add(await loadParallaxComponent());
    add(player);
  }

  Future<ParallaxComponent> loadParallaxComponent() async {
    return ParallaxComponent.load(
      [
        ParallaxImageData('bg.png'),
        ParallaxImageData('Stars-B.png'),
        ParallaxImageData('Stars-A.png'),
      ],
      repeat: ImageRepeat.repeatY,
      baseVelocity: Vector2(0, -20),
      velocityMultiplierDelta: Vector2(1.0, 1.5),
      size: MyGame.sceneSize,
    );
  }

  void spawnEnemy() {
    final x = random.nextDouble() * (MyGame.sceneSize.x - 70);
    add(Enemy(position: Vector2(x, -70)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    enemySpawnTimer += dt;
    if (enemySpawnTimer > 2) {
      spawnEnemy();
      enemySpawnTimer = 0;
    }
  }

  void movePlayerLeft() {
    player.velocity.x = -player.speed;
  }

  void movePlayerRight() {
    player.velocity.x = player.speed;
  }

  void stopPlayer() {
    player.velocity.x = 0;
  }

  void shootPlayer() {
    player.shoot();
  }

  void onEnemyKilled() {
    score++;
    if (score > highScore) {
      highScore = score;
    }
  }

  void reset() {
    score = 0;
    isGameOver = false;
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    player.position = Vector2(MyGame.sceneSize.x / 2, MyGame.sceneSize.y - 70);
    FlameAudio.bgm.play('CastleVein.mp3');
    gameRef.resumeEngine();
  }

  void triggerGameOver() {
    isGameOver = true;
    gameRef.overlays.add('GameOverMenu');
    FlameAudio.bgm.stop();
    gameRef.pauseEngine();
  }
}
