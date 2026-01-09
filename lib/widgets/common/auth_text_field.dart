import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Ortak Auth TextField Widget'ı
/// Login ve Register ekranlarında kullanılabilecek özelleştirilebilir TextField
///
/// Özellikler:
/// - Glassmorphism efekti
/// - Animasyonlu focus state
/// - Şifre görünürlük toggle
/// - Haptic feedback
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final bool isDarkMode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int animationDelay;

  const AuthTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.primaryColor = const Color(0xFF6C5CE7),
    this.backgroundColor = const Color(0xFFF5F6FA),
    this.textColor = const Color(0xFF2D3436),
    this.isDarkMode = false,
    this.validator,
    this.onChanged,
    this.animationDelay = 0,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = _isFocused
        ? widget.primaryColor.withOpacity(0.3)
        : Colors.transparent;

    final borderColor = _isFocused
        ? widget.primaryColor
        : widget.isDarkMode
        ? Colors.white.withOpacity(0.1)
        : widget.textColor.withOpacity(0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: _isFocused ? 15 : 0,
            spreadRadius: _isFocused ? 2 : 0,
          ),
        ],
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isFocused ? 1.02 : 1.0,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.isPassword && _obscurePassword,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : widget.textColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.nunito(
              color: widget.isDarkMode
                  ? Colors.white.withOpacity(0.4)
                  : widget.textColor.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: _isFocused ? 1.1 : 1.0,
              child: Icon(
                widget.icon,
                color: _isFocused
                    ? widget.primaryColor
                    : (widget.isDarkMode
                          ? Colors.white.withOpacity(0.5)
                          : widget.textColor.withOpacity(0.5)),
              ),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: widget.isDarkMode
                          ? Colors.white.withOpacity(0.5)
                          : widget.textColor.withOpacity(0.5),
                    ),
                    onPressed: () {
                      _triggerHaptic();
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  )
                : null,
            filled: true,
            fillColor: widget.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : widget.backgroundColor.withOpacity(0.8),
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
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : widget.textColor.withOpacity(0.1),
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
    );
  }
}
