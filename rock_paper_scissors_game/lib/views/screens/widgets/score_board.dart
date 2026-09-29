import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rock_paper_scissors_game/controllers/game_controller.dart';
import 'package:rock_paper_scissors_game/models/game_model.dart';
import 'package:rock_paper_scissors_game/utils/constants.dart';

class ScoreBoard extends GetWidget<GameController> {
  const ScoreBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "Score",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScoreItem(label: "You", score: controller.gameModel.userScore),
                _ScoreItem(label: "AI", score: controller.gameModel.aiScore),
                _ScoreItem(label: "Draws", score: controller.gameModel.draws),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  "High Score: ${controller.highScore.value}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

extension on Rx<GameModel> {
  get userScore => null;
  
  get aiScore => null;
  
  get draws => null;
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreItem({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
