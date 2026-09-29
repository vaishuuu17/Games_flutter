import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rock_paper_scissors_game/models/move_model.dart';
import 'package:rock_paper_scissors_game/utils/constants.dart' show AppColors;

class MoveButton extends StatelessWidget {
  final MoveModel move;
  final bool isActive;
  final Function(MoveModel) onPressed;

  const MoveButton({
    Key? key,
    required this.move,
    required this.onPressed,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? () => onPressed(move) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primary : AppColors.primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: RiveAnimation.asset(move.assetPath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(
              move.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
