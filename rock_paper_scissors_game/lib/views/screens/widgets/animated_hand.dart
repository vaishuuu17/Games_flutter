import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rock_paper_scissors_game/models/move_model.dart';

class AnimatedHand extends StatefulWidget {
  final MoveModel move;
  final bool isUser;
  final bool isWinner;

  const AnimatedHand({
    Key? key,
    required this.move,
    required this.isUser,
    required this.isWinner,
  }) : super(key: key);

  @override
  State<AnimatedHand> createState() => _AnimatedHandState();
}

class _AnimatedHandState extends State<AnimatedHand>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  StateMachineController? _riveController;
  SMITrigger? _playTrigger;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _riveController?.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    _riveController = StateMachineController.fromArtboard(
      artboard,
      'state_machine',
    );

    if (_riveController != null) {
      artboard.addController(_riveController!);
      _playTrigger = _riveController!.findSMI('play');
      _playTrigger?.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Transform.scale(
          scale: 1.0 + (widget.isWinner ? 0.2 * value : 0),
          child: Transform.rotate(
            angle: widget.isUser ? 0 : 3.14, // Flip if AI
            child: SizedBox(
              height: 200,
              width: 200,
              child: RiveAnimation.asset(
                widget.move.assetPath,
                fit: BoxFit.contain,
                onInit: _onRiveInit,
              ),
            ),
          ),
        );
      },
    );
  }
}
