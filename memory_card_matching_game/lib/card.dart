import 'package:flutter/material.dart';
import 'dart:math';

class CardItem {
  final dynamic face; // Can be a String (image path or emoji) or IconData
  bool isFlipped = false;
  bool isMatched = false;

  CardItem(this.face);
}

class MemoryCard extends StatefulWidget {
  final CardItem card;
  final double size;
  final String theme;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.card,
    required this.size,
    required this.theme,
    required this.onTap,
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final rotateY = _animation.value * pi;
          return Transform(
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotateY),
            alignment: Alignment.center,
            child:
                rotateY < pi / 2
                    ? _buildCardBack()
                    : Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: _buildCardFront(),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color:
            widget.card.isMatched
                ? Colors.green.withOpacity(0.2)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                widget.card.isMatched
                    ? Colors.greenAccent.withOpacity(0.5)
                    : Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color:
              widget.card.isMatched
                  ? Colors.greenAccent
                  : Colors.purple.shade100,
          width: 2,
        ),
      ),
      child: Center(child: _buildCardContent()),
    );
  }

  Widget _buildCardContent() {
    // Handle different types of card faces based on theme
    if (widget.theme == 'Emoji' || widget.theme == 'Sports') {
      // For emoji themes, the face is directly a string
      return Text(widget.card.face, style: const TextStyle(fontSize: 32));
    } else if (widget.card.face is IconData) {
      // If the face is an IconData (for fallback)
      return Icon(
        widget.card.face as IconData,
        size: widget.size * 0.6,
        color: Colors.deepPurple,
      );
    } else {
      // For image-based themes
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: widget.size * 0.8,
          height: widget.size * 0.8,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Image.asset(widget.card.face as String, fit: BoxFit.cover),
        ),
      );
    }
  }

  IconData _getThemeIcon() {
    // Return appropriate icon for each theme
    switch (widget.theme) {
      case 'Nature':
        return Icons.landscape;
      case 'Animals':
        return Icons.pets;
      case 'Food':
        return Icons.fastfood;
      default:
        return Icons.star;
    }
  }

  Widget _buildCardBack() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple, Colors.purple.shade800],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.question_mark,
          size: widget.size * 0.4,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}
