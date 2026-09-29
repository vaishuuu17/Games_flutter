import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/game_controller.dart';
import '../../models/move_model.dart';
import '../../utils/constants.dart';
import '../widgets/move_button.dart';

import '../widgets/animated_hand.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final GameController _controller;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(GameController());
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleMoveSelection(MoveModel move) async {
    _playShakeAnimation();
    await _controller.playMove(move);

    if (_controller.lastResult.value != null) {
      Get.to(() => ResultScreen(result: _controller.lastResult.value!));
    }
  }

  void _playShakeAnimation() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(AppText.appName),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const ScoreBoard(),
          const SizedBox(height: 40),
          Obx(() {
            if (_controller.isAnimating.value) {
              return _buildGameAnimation();
            } else {
              return _buildMoveSelection();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildGameAnimation() {
    return Column(
      children: [
        const Text(
          "Game in progress...",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final sineValue =
                _shakeController.value < 0.5
                    ? _shakeController.value * 2
                    : 2 - (_shakeController.value * 2);

            return Transform.translate(
              offset: Offset(10 * (sineValue - 0.5), 0),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoveSelection() {
    return Column(
      children: [
        const Text(
          AppText.chooseYourMove,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              _controller.gameModel.moves.map((move) {
                return MoveButton(move: move, onPressed: _handleMoveSelection);
              }).toList(),
        ),
      ],
    );
  }
}

extension on GameController {
  Future<void> playMove(MoveModel move) {}
}
