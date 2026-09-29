import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiPainter extends CustomPainter {
  final AnimationController controller;
  final List<Confetti> _confetti = [];
  final Random random = Random();

  ConfettiPainter({required this.controller}) {
    // Create confetti particles
    for (int i = 0; i < 100; i++) {
      _confetti.add(Confetti(random));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final confettiPaint = Paint();

    // Update and draw each confetti particle
    for (var confetti in _confetti) {
      confetti.update(controller.value, size);

      confettiPaint.color = confetti.color;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(confetti.x, confetti.y),
          width: confetti.size,
          height: confetti.size * 1.5,
        ),
        confettiPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Confetti {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;
  late double angle;
  late double spin;
  late double initialY;

  final Random random;

  Confetti(this.random) {
    reset(0);
  }

  void reset(double startPosition) {
    // Initialize confetti with random properties
    x = random.nextDouble() * 1000;
    initialY = random.nextDouble() * -100 - 100; // Start above the screen
    y = initialY * startPosition;
    size = random.nextDouble() * 10 + 5;
    speed = random.nextDouble() * 30 + 10;
    angle = random.nextDouble() * pi * 2;
    spin = (random.nextDouble() * 2 - 1) * 0.1;

    // Random bright colors for confetti
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update(double animationValue, Size size) {
    // Move confetti downward
    y = initialY + speed * animationValue * 20;

    // Add some horizontal movement
    x += sin(angle) * 2;
    angle += spin;

    // Reset if it goes out of bounds
    if (y > size.height) {
      reset(animationValue);
    }
  }
}
