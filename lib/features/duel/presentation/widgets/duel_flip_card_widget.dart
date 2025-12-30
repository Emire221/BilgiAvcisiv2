import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/duel_entities.dart';

/// Düello için çevrilebilir hafıza kartı widget'ı
class DuelFlipCardWidget extends StatefulWidget {
  final DuelMemoryCard card;
  final VoidCallback onTap;
  final bool disabled;

  const DuelFlipCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.disabled = false,
  });

  @override
  State<DuelFlipCardWidget> createState() => _DuelFlipCardWidgetState();
}

class _DuelFlipCardWidgetState extends State<DuelFlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  // Theme colors
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _neonOrange = Color(0xFFFF6B35);

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
  void didUpdateWidget(DuelFlipCardWidget oldWidget) {
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
          colors: [
            _neonPurple.withValues(alpha: 0.8),
            _neonCyan.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _neonCyan.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: _neonPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.question_mark,
          size: 40,
          color: Colors.white.withValues(alpha: 0.9),
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
                ? [
                    _neonGreen.withValues(alpha: 0.8),
                    _neonGreen.withValues(alpha: 0.6),
                  ]
                : [
                    _neonOrange.withValues(alpha: 0.8),
                    _neonOrange.withValues(alpha: 0.6),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMatched
                ? _neonGreen.withValues(alpha: 0.8)
                : _neonOrange.withValues(alpha: 0.6),
            width: isMatched ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isMatched ? _neonGreen : _neonOrange).withValues(
                alpha: 0.4,
              ),
              blurRadius: 12,
              spreadRadius: isMatched ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.card.number}',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
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
