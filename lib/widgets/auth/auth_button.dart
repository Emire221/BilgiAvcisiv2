import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🚀 Oyunlaştırılmış Auth Button Widget
/// Gradient + Glow efekti + Haptic feedback
/// Login ve Register ekranlarında ortak kullanım için
class AuthButton extends StatefulWidget {
  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradientColors,
    this.icon,
    this.animationDelay = 0,
    this.width,
    this.height = 56,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final List<Color>? gradientColors;
  final IconData? icon;
  final int animationDelay;
  final double? width;
  final double height;

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _isPressed = false;

  static const _defaultGradient = [Color(0xFF6C5CE7), Color(0xFF00CEC9)];

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ?? _defaultGradient;
    final glowColor = colors.first.withValues(alpha: 0.4);

    return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: _isPressed ? 20 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              onTapDown: widget.isLoading ? null : _handleTapDown,
              onTapUp: widget.isLoading ? null : _handleTapUp,
              onTapCancel: widget.isLoading ? null : _handleTapCancel,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text,
                            style: GoogleFonts.nunito(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: widget.animationDelay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

/// 🌌 Kozmik tema için neon button
/// Register ekranı için özel tasarım
class AuthButtonNeon extends StatefulWidget {
  const AuthButtonNeon({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.primaryColor = const Color(0xFF00f5d4),
    this.icon,
    this.animationDelay = 0,
    this.width,
    this.height = 56,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color primaryColor;
  final IconData? icon;
  final int animationDelay;
  final double? width;
  final double height;

  @override
  State<AuthButtonNeon> createState() => _AuthButtonNeonState();
}

class _AuthButtonNeonState extends State<AuthButtonNeon> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.mediumImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                widget.primaryColor,
                widget.primaryColor.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withValues(
                  alpha: _isPressed ? 0.6 : 0.4,
                ),
                blurRadius: _isPressed ? 25 : 15,
                spreadRadius: _isPressed ? 2 : 0,
              ),
            ],
          ),
          transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              onTapDown: widget.isLoading ? null : _handleTapDown,
              onTapUp: widget.isLoading ? null : _handleTapUp,
              onTapCancel: widget.isLoading ? null : _handleTapCancel,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: const Color(0xFF0d1b2a),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text,
                            style: GoogleFonts.nunito(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0d1b2a),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: widget.animationDelay))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9));
  }
}

/// 🔗 Navigasyon linki (Hesabın var mı? / Hesabın yok mu?)
class AuthNavigationLink extends StatelessWidget {
  const AuthNavigationLink({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onTap,
    this.animationDelay = 0,
    this.textColor = const Color(0xFF2D3436),
    this.actionColor = const Color(0xFF6C5CE7),
  });

  final String questionText;
  final String actionText;
  final VoidCallback onTap;
  final int animationDelay;
  final Color textColor;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              questionText,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionText,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: actionColor,
                ),
              ),
            ),
          ],
        )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 400.ms);
  }
}
