import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎮 Oyunlaştırılmış Auth TextField Widget
/// Glassmorphism + Glow efekti + Animasyonlar
/// Login ve Register ekranlarında ortak kullanım için
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.animationDelay = 0,
    this.primaryColor = const Color(0xFF6C5CE7),
    this.backgroundColor = const Color(0xFFF5F6FA),
    this.textColor = const Color(0xFF2D3436),
    this.onChanged,
    this.suffixWidget,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final int animationDelay;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final ValueChanged<String>? onChanged;
  final Widget? suffixWidget;

  @override
  Widget build(BuildContext context) {
    final borderColor = isFocused ? primaryColor : Colors.transparent;
    final glowColor = isFocused
        ? primaryColor.withValues(alpha: 0.3)
        : Colors.transparent;

    return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: isFocused ? 15 : 0,
                spreadRadius: isFocused ? 2 : 0,
              ),
            ],
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: isFocused ? 1.02 : 1.0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: isPassword && obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.nunito(
                  color: textColor.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon:
                    Icon(
                          icon,
                          color: isFocused
                              ? primaryColor
                              : textColor.withValues(alpha: 0.5),
                        )
                        .animate(target: isFocused ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                        ),
                suffixIcon: _buildSuffixIcon(),
                filled: true,
                fillColor: backgroundColor.withValues(alpha: 0.8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: textColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget? _buildSuffixIcon() {
    if (suffixWidget != null) return suffixWidget;

    if (isPassword && onToggleObscure != null) {
      return IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: textColor.withValues(alpha: 0.5),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          onToggleObscure?.call();
        },
      );
    }
    return null;
  }
}

/// 🌌 Kozmik tema için dark mode TextField
/// Register ekranı için özel tasarım
class AuthTextFieldDark extends StatelessWidget {
  const AuthTextFieldDark({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.animationDelay = 0,
    this.accentColor = const Color(0xFF00f5d4),
    this.onChanged,
    this.suffixWidget,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final int animationDelay;
  final Color accentColor;
  final ValueChanged<String>? onChanged;
  final Widget? suffixWidget;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isFocused ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? accentColor.withValues(alpha: 0.5)
                  : accentColor.withValues(alpha: 0.2),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword && obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              prefixIcon: Icon(
                icon,
                color: isFocused
                    ? accentColor
                    : Colors.white.withValues(alpha: 0.5),
              ),
              suffixIcon: _buildSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget? _buildSuffixIcon() {
    if (suffixWidget != null) return suffixWidget;

    if (isPassword && onToggleObscure != null) {
      return IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          onToggleObscure?.call();
        },
      );
    }
    return null;
  }
}
