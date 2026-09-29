import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../widgets/animated_hand.dart';

class ResultScreen extends StatelessWidget {
  final String result;
  final Color resultColor;
  final String playerMove;
  final String computerMove;
  final bool isWin;

  const ResultScreen({
    Key? key,
    required this.result,
    required this.resultColor,
    required this.playerMove,
    required this.computerMove,
    required this.isWin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                  result,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(delay: 200.ms)
                .then()
                .shake(duration: 500.ms),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      "You",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    AnimatedHand(
                      move: playerMove,
                      isUser: true,
                      isWinner: isWin,
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "Computer",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    AnimatedHand(
                      move: computerMove,
                      isUser: false,
                      isWinner: !isWin && result != AppText.draw,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                AppText.playAgain,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
