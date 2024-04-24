import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_racer/screen/racing_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: RacingGame(onGameOver: () => Navigator.pop(context)),
      ),
    );
  }
}
