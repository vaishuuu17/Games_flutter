import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../models/move_model.dart';
import '../../services/sound_service.dart';

class MoveButton extends StatelessWidget {
  final MoveModel move;
  final Function(MoveModel) onPressed;

  const MoveButton({Key? key, required this.move, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService().playMoveSound();
        onPressed(move);
      },
      child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                move.emoji,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.3))
          .then()
          .scale(
            duration: 500.milliseconds,
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
          )
          .then()
          .scale(
            duration: 500.milliseconds,
            begin: const Offset(1.05, 1.05),
            end: const Offset(1, 1),
          ),
    );
  }
}
