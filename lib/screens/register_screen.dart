// ignore_for_file: deprecated_member_use
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'profile_setup_screen.dart';
import 'login_screen.dart';

/// 🚀 KAYIT OL EKRANI - Kozmik Tema
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Deep Violet → Night Blue gradient arka plan
/// Yıldız partikülleri ve neon efektler
/// Güçlü şifre göstergesi ve şifremi unuttum butonu
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // State
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;
  double _passwordStrength = 0;
  String _strengthText = '';

  // Animation controllers
  late AnimationController _shimmerController;
  late AnimationController _floatController;

  // Particles
  final List<_StarParticle> _stars = [];

  // Theme colors
  static const _primaryCyan = Color(0xFF00f5d4);
  static const _primaryPurple = Color(0xFF9b5de5);
  static const _primaryPink = Color(0xFFf15bb5);
  static const _darkBg = Color(0xFF0d1b2a);
  static const _cardBg = Color(0xFF1a1a2e);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initStars();
    _setupFocusListeners();
  }

  void _initAnimations() {
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  void _initStars() {
    final random = math.Random();
    for (int i = 0; i < 40; i++) {
      _stars.add(
        _StarParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 2 + 1,
          opacity: random.nextDouble() * 0.5 + 0.2,
          twinkleSpeed: random.nextDouble() * 2 + 1,
        ),
      );
    }
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(
        () => _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PASSWORD STRENGTH
  // ─────────────────────────────────────────────────────────────────────────
  void _checkPasswordStrength(String password) {
    double strength = 0;
    String text = '';

    if (password.isEmpty) {
      strength = 0;
      text = '';
    } else if (password.length < 6) {
      strength = 0.15;
      text = 'Çok Kısa';
    } else {
      if (password.length >= 8) strength += 0.2;
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
      if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

      if (strength <= 0.3) {
        text = 'Zayıf';
      } else if (strength <= 0.5) {
        text = 'Orta';
      } else if (strength <= 0.7) {
        text = 'İyi';
      } else {
        text = 'Güçlü';
      }
    }

    setState(() {
      _passwordStrength = strength;
      _strengthText = text;
    });
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 0.3) return const Color(0xFFf15bb5);
    if (_passwordStrength <= 0.5) return const Color(0xFFfee440);
    if (_passwordStrength <= 0.7) return const Color(0xFF00bbf9);
    return const Color(0xFF00f5d4);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REGISTER LOGIC
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar('Lütfen tüm alanları doldurun');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Geçerli bir e-posta adresi girin');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Şifre en az 6 karakter olmalıdır');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('Şifreler eşleşmiyor');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ProfileSetupScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Kayıt hatası oluştu';
      if (e.code == 'email-already-in-use') {
        message = 'Bu e-posta adresi zaten kullanımda';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta adresi';
      } else if (e.code == 'weak-password') {
        message = 'Şifre çok zayıf';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('Bir hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showErrorSnackBar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────────────────────────────────
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_cardBg.withOpacity(0.95), _darkBg.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _primaryCyan.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: _primaryCyan.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _primaryPurple.withOpacity(0.3),
                      _primaryCyan.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: _primaryPurple.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: _primaryPurple,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Şifreni Sıfırla',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'E-posta adresine şifre sıfırlama linki göndereceğiz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              // Email input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primaryCyan.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: resetEmailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'E-posta adresin',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: Icon(
                      Icons.email_rounded,
                      color: _primaryCyan.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty || !_isValidEmail(email)) {
                          _showErrorSnackBar('Geçerli bir e-posta girin');
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: email,
                          );
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Şifre sıfırlama linki $email adresine gönderildi',
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: _primaryCyan,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        } catch (e) {
                          _showErrorSnackBar(
                            'Link gönderilemedi. E-postayı kontrol edin.',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryCyan,
                        foregroundColor: _darkBg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Gönder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a0033), // Deep Violet
              Color(0xFF0d1b2a), // Night Blue
              Color(0xFF1b263b), // Dark Navy
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Star particles
            ..._buildStars(),

            // Grid pattern
            _buildGridPattern(),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isSmallScreen ? 16 : 24,
                  ),
                  child: Column(
                    children: [
                      // Back button
                      _buildBackButton()
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.3),

                      SizedBox(height: isSmallScreen ? 16 : 32),

                      // Mascot
                      _buildMascot(isSmallScreen)
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .scale(begin: const Offset(0.8, 0.8)),

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Title
                      _buildTitle()
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.3),

                      SizedBox(height: isSmallScreen ? 24 : 32),

                      // Form Card
                      _buildFormCard(isSmallScreen)
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.2),

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Login link
                      _buildLoginLink().animate().fadeIn(
                        delay: 600.ms,
                        duration: 400.ms,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    return _stars.map((star) {
      return Positioned(
        left: star.x * MediaQuery.of(context).size.width,
        top: star.y * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            final twinkle =
                (math.sin(
                      _shimmerController.value *
                          math.pi *
                          2 *
                          star.twinkleSpeed,
                    ) +
                    1) /
                2;
            return Opacity(
              opacity: star.opacity * twinkle,
              child: Container(
                width: star.size * 2,
                height: star.size * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryCyan.withOpacity(0.5),
                      blurRadius: star.size * 3,
                      spreadRadius: star.size / 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildGridPattern() {
    return Opacity(
      opacity: 0.03,
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _GridPainter(),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primaryCyan.withOpacity(0.3)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildMascot(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_floatController.value * math.pi) * 8),
          child: Container(
            height: isSmallScreen ? 100 : 130,
            width: isSmallScreen ? 100 : 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primaryPurple.withOpacity(0.3),
                  _primaryCyan.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: _primaryCyan.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryPurple.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Lottie.asset(
                'assets/animation/kedi_mascot.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Animated title with shimmer
        AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment(-1 + _shimmerController.value * 3, 0),
                  end: Alignment(_shimmerController.value * 3, 0),
                  colors: const [_primaryCyan, _primaryPurple, _primaryCyan],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              child: Text(
                '🚀 MACERAYA KATIL',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        Text(
          'Bilgi evrenini keşfetmeye hazır mısın?',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardBg.withOpacity(0.8), _darkBg.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _primaryCyan.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Email input
          _buildInputField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            isFocused: _isEmailFocused,
            hintText: 'E-posta',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          SizedBox(height: isSmallScreen ? 14 : 18),

          // Password input
          _buildInputField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            isFocused: _isPasswordFocused,
            hintText: 'Şifre',
            icon: Icons.lock_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleObscure: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            onChanged: _checkPasswordStrength,
          ),

          // Password strength indicator
          if (_passwordStrength > 0) ...[
            const SizedBox(height: 12),
            _buildPasswordStrengthIndicator(),
          ],

          SizedBox(height: isSmallScreen ? 14 : 18),

          // Confirm password input
          _buildInputField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            isFocused: _isConfirmPasswordFocused,
            hintText: 'Şifre Tekrar',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            obscureText: _obscureConfirmPassword,
            onToggleObscure: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
          ),

          SizedBox(height: isSmallScreen ? 10 : 14),

          // Forgot password button
          _buildForgotPasswordButton(),

          SizedBox(height: isSmallScreen ? 20 : 28),

          // Register button
          _buildRegisterButton(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    final borderColor = isFocused
        ? _primaryCyan
        : Colors.white.withOpacity(0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isFocused ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isFocused ? 2 : 1),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: _primaryCyan.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.nunito(
            color: Colors.white.withOpacity(0.4),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: isFocused ? _primaryCyan : Colors.white.withOpacity(0.5),
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 22,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(_getStrengthColor()),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _strengthText,
              style: GoogleFonts.nunito(
                color: _getStrengthColor(),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showForgotPasswordDialog();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline_rounded,
              color: _primaryPurple.withOpacity(0.8),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Şifremi Unuttum',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(bool isSmallScreen) {
    return GestureDetector(
      onTap: _isLoading ? null : _register,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: isSmallScreen ? 54 : 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [
                    _primaryCyan.withOpacity(0.5),
                    _primaryPurple.withOpacity(0.5),
                  ]
                : [_primaryCyan, _primaryPurple],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _primaryCyan.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Kayıt Ol',
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaten hesabın var mı? ',
          style: GoogleFonts.nunito(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const LoginScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Text(
            'Giriş Yap',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _primaryCyan,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER CLASSES
// ─────────────────────────────────────────────────────────────────────────────
class _StarParticle {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double twinkleSpeed;

  _StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
  });
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
