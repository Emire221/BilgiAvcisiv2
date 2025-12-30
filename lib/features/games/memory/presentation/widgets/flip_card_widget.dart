import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/memory_card.dart';

/// Çevrilebilir hafıza kartı widget'ı
class FlipCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final bool disabled;

  const FlipCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.disabled = false,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addListener(() {
      if (_controller.value >= 0.5 && _showFront) {
        setState(() => _showFront = false);
      } else if (_controller.value < 0.5 && !_showFront) {
        setState(() => _showFront = true);
      }
    });

    // Başlangıç durumunu ayarla
    if (widget.card.isFlipped || widget.card.isMatched) {
      _controller.value = 1.0;
      _showFront = false;
    }
  }

  @override
  void didUpdateWidget(FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldBeFlipped = widget.card.isFlipped || widget.card.isMatched;
    final wasFlipped = oldWidget.card.isFlipped || oldWidget.card.isMatched;

    if (shouldBeFlipped && !wasFlipped) {
      _controller.forward();
    } else if (!shouldBeFlipped && wasFlipped) {
      _controller.reverse();
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
      onTap: widget.disabled ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: _showFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo.shade400, Colors.purple.shade500],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.question_mark,
          size: 40,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildBack() {
    final isMatched = widget.card.isMatched;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isMatched
                ? [Colors.green.shade400, Colors.green.shade600]
                : [Colors.orange.shade400, Colors.deepOrange.shade500],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isMatched ? Colors.green : Colors.orange).withValues(
                alpha: 0.4,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: isMatched
              ? Border.all(color: Colors.greenAccent, width: 3)
              : null,
        ),
        child: Center(
          child: Text(
            '${widget.card.number}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
