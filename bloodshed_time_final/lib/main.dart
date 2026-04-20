import 'dart:async' as dart_async;

import 'package:bloodshed_time_final/level_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

void main() {
  final levelGame = LevelGame();
  final myGame = MyGame(levelGame);
  levelGame.gameRef = myGame;

  final gameOverOverlay = {
    'GameOverMenu': (BuildContext context, MyGame game) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Game Over',
            style: TextStyle(
              fontSize: 40,
              color: Colors.red,
              fontWeight: FontWeight.bold,
             ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              game.levelGame.reset();
              game.overlays.remove('GameOverMenu');
              game.resumeEngine();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  };

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: myGame,
              overlayBuilderMap: {
                'GameOverMenu': (context, game) =>
                    gameOverOverlay['GameOverMenu']!(context, game as MyGame),
              },
            ),
            Positioned(
              top: 30,
              left: 30,
              child: ScoreDisplay(levelGame: myGame.levelGame),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: [
                  ControlButton(
                    icon: Icons.arrow_left,
                    onPressed: () => myGame.levelGame.movePlayerLeft(),
                    onReleased: () => myGame.levelGame.stopPlayer(),
                  ),
                  const SizedBox(width: 20),
                  ControlButton(
                    icon: Icons.arrow_right,
                    onPressed: () => myGame.levelGame.movePlayerRight(),
                    onReleased: () => myGame.levelGame.stopPlayer(),
                  ),
                  const SizedBox(width: 20),
                  ControlButton(
                    icon: Icons.bolt,
                    onPressed: () => myGame.levelGame.shootPlayer(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  static Vector2 sceneSize = Vector2(400, 600);
  late CameraComponent cameraComponent;
  final LevelGame levelGame;

  MyGame(this.levelGame);

  @override
  dart_async.FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('CastleVein.mp3');

    cameraComponent = CameraComponent.withFixedResolution(
      world: levelGame,
      width: sceneSize.x,
      height: sceneSize.y,
    );

    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, levelGame]);
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback? onReleased;

  const ControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onReleased,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased?.call(),
      onTapCancel: () => onReleased?.call(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class ScoreDisplay extends StatefulWidget {
  final LevelGame levelGame;

  const ScoreDisplay({super.key, required this.levelGame});

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay> {
  late final dart_async.Timer timer;

  @override
  void initState() {
    super.initState();
    // Actualiza cada 0.5 segundos
    timer = dart_async.Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScoreText('Puntaje: ${widget.levelGame.score}'),
        ScoreText('Récord: ${widget.levelGame.highScore}'),
      ],
    );
  }
}

class ScoreText extends StatelessWidget {
  final String text;

  const ScoreText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 3, color: Colors.black, offset: Offset(1, 1)),
        ],
      ),
    );
  }
}
