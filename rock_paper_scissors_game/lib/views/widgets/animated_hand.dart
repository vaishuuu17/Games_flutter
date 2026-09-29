import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../models/move_model.dart';

class AnimatedHand extends StatelessWidget {
  final MoveModel move;
  final bool isWinner;

  const AnimatedHand({Key? key, required this.move, required this.isWinner})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: isWinner ? AppColors.accent : AppColors.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (isWinner ? AppColors.accent : AppColors.primary)
                    .withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              move.emoji,
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.3))
        .then()
        .scale(
          duration: 500.milliseconds,
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
        )
        .then()
        .scale(
          duration: 500.milliseconds,
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1),
        );
  }
}
