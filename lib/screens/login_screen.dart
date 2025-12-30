import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register_screen.dart';
import 'main_screen.dart';
import 'profile_setup_screen.dart';

/// 🎮 Oyunlaştırılmış Login Ekranı
/// Glassmorphism + Living UI + Haptic Feedback
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Form kontrolleri
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Animasyon kontrolleri
  late AnimationController _blobController;
  late AnimationController _shakeController;

  // Durum yönetimi
  bool _isCheckingAuth = true;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isLoading = false;
  bool _showContent = false;
  bool _showCard = false;
  bool _showMascot = false;
  bool _isButtonPressed = false;
  bool _obscurePassword = true;

  // Renk paleti (Splash ile uyumlu)
  static const Color _primaryPurple = Color(0xFF6C5CE7);
  static const Color _energeticCoral = Color(0xFFFF7675);
  static const Color _turquoise = Color(0xFF00CEC9);
  static const Color _backgroundBase = Color(0xFFF5F6FA);
  static const Color _darkText = Color(0xFF2D3436);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupFocusListeners();
    _checkAuthState();
  }

  void _initAnimations() {
    // Blob animasyonu
    _blobController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // Shake animasyonu (hata durumu için)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
  }

  void _startEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showContent = true);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _showCard = true);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showMascot = true);
  }

  Future<void> _checkAuthState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (doc.exists) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          );
        }
        return;
      } catch (e) {
        // Hata durumunda login ekranında kal
      }
    }
    if (mounted) {
      setState(() => _isCheckingAuth = false);
      _startEntryAnimation();
    }
  }

  /// Hafif titreşim (buton tıklama)
  void _hapticLight() {
    HapticFeedback.lightImpact();
  }

  /// Orta titreşim (başarı)
  void _hapticMedium() {
    HapticFeedback.mediumImpact();
  }

  /// Ağır titreşim (hata)
  void _hapticHeavy() {
    HapticFeedback.heavyImpact();
  }

  /// Shake animasyonu tetikle
  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  /// Login işlemi
  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _hapticHeavy();
      _triggerShake();
      _showErrorSnackbar('E-posta ve şifre boş bırakılamaz!');
      return;
    }

    setState(() => _isLoading = true);
    _hapticLight();

    try {
      // Firebase Authentication ile giriş yap
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Asenkron işlem sonrası mounted kontrolü
      if (!mounted) return;

      _hapticMedium();

      // Firestore'da kullanıcı dokümanını kontrol et
      final user = userCredential.user;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Asenkron işlem sonrası tekrar mounted kontrolü
        if (!mounted) return;

        // Yönlendirme: Kayıt varsa MainScreen, yoksa ProfileSetupScreen
        if (doc.exists) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _hapticHeavy();
      _triggerShake();
      String message = 'Giriş başarısız oldu';
      if (e.code == 'user-not-found') {
        message = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
      } else if (e.code == 'wrong-password') {
        message = 'Yanlış şifre girdiniz';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta formatı';
      }
      _showErrorSnackbar(message);
    } catch (e) {
      if (!mounted) return;
      _hapticHeavy();
      _triggerShake();
      _showErrorSnackbar('Bir hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _energeticCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _blobController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: _backgroundBase,
        body: Center(
          child: Lottie.asset(
            'assets/animation/loading-kum.json',
            width: 120,
            height: 120,
            errorBuilder: (_, __, ___) =>
                CircularProgressIndicator(color: _primaryPurple),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundBase,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenHeight < 700;
            final isNarrowScreen = screenWidth < 380;

            // Responsive boyutlar
            final cardWidth = (screenWidth * 0.9).clamp(300.0, 420.0);
            final mascotSize = (screenWidth * 0.28).clamp(80.0, 140.0);
            final titleSize = (screenWidth * 0.07).clamp(24.0, 32.0);
            final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 32.0);

            return Stack(
              children: [
                // 1. Living Background - Animated Blobs
                if (_showContent)
                  _buildLivingBackground(screenWidth, screenHeight),

                // 2. Ana içerik
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isSmallScreen ? 40 : 60),

                          // 3. Mascot + Glass Card Stack
                          if (_showCard)
                            _buildMascotCardStack(
                              cardWidth: cardWidth,
                              mascotSize: mascotSize,
                              titleSize: titleSize,
                              isSmallScreen: isSmallScreen,
                              isNarrowScreen: isNarrowScreen,
                            ),

                          SizedBox(height: isSmallScreen ? 20 : 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Hareketli Arka Plan (Living Background)
  Widget _buildLivingBackground(double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, child) {
        return Stack(
          children: [
            // Mor Blob - Sol üst
            _buildAnimatedBlob(
              color: _primaryPurple.withValues(alpha: 0.4),
              size: screenWidth * 0.8,
              left: -screenWidth * 0.3 + (_blobController.value * 50),
              top: -screenHeight * 0.1 + (_blobController.value * 30),
            ),
            // Mercan Blob - Sağ üst
            _buildAnimatedBlob(
              color: _energeticCoral.withValues(alpha: 0.35),
              size: screenWidth * 0.7,
              right: -screenWidth * 0.2 - (_blobController.value * 40),
              top: screenHeight * 0.1 + (_blobController.value * 20),
            ),
            // Turkuaz Blob - Alt
            _buildAnimatedBlob(
              color: _turquoise.withValues(alpha: 0.3),
              size: screenWidth * 0.6,
              left: screenWidth * 0.1 + (_blobController.value * 60),
              bottom: -screenHeight * 0.1 - (_blobController.value * 25),
            ),
            // Ekstra mor blob - Sağ alt
            _buildAnimatedBlob(
              color: _primaryPurple.withValues(alpha: 0.25),
              size: screenWidth * 0.5,
              right: -screenWidth * 0.1 + (_blobController.value * 35),
              bottom: screenHeight * 0.2 - (_blobController.value * 40),
            ),
          ],
        );
      },
    ).animate().fadeIn(duration: 800.ms, curve: Curves.easeOut);
  }

  Widget _buildAnimatedBlob({
    required Color color,
    required double size,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 100, spreadRadius: 40),
          ],
        ),
      ),
    );
  }

  /// Mascot + Glass Card Stack
  Widget _buildMascotCardStack({
    required double cardWidth,
    required double mascotSize,
    required double titleSize,
    required bool isSmallScreen,
    required bool isNarrowScreen,
  }) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // Shake efekti
        final shakeOffset = _shakeController.value < 0.5
            ? Curves.easeInOut.transform(_shakeController.value * 2) * 20
            : Curves.easeInOut.transform((1 - _shakeController.value) * 2) * 20;
        final shake =
            (_shakeController.value * 4 * 3.14159).sin() * shakeOffset;

        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Glass Card
          Container(
                width: cardWidth,
                margin: EdgeInsets.only(top: mascotSize * 0.5),
                child: _buildGlassCard(
                  titleSize: titleSize,
                  isSmallScreen: isSmallScreen,
                  isNarrowScreen: isNarrowScreen,
                ),
              )
              .animate()
              .slideY(
                begin: 0.3,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 500.ms),

          // Mascot (kartın üstünde)
          if (_showMascot)
            Positioned(
              top: -mascotSize * 0.15,
              child: _buildMascot(mascotSize),
            ),
        ],
      ),
    );
  }

  /// Maskot Widget
  Widget _buildMascot(double size) {
    // Şifre alanına odaklanıldığında maskot "gözlerini kapatır"
    final isWatching = !_isPasswordFocused;

    return GestureDetector(
          onTap: () {
            _hapticLight();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isWatching ? 1.0 : 0.6,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isWatching ? 1.0 : 0.9,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Lottie.asset(
                    'assets/animation/kedi_mascot.json',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackMascot(size);
                    },
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        )
        .shake(
          delay: 400.ms,
          duration: 300.ms,
          hz: 3,
          offset: const Offset(0, 3),
        );
  }

  Widget _buildFallbackMascot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _primaryPurple.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text('🐱', style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }

  /// Glass Card (Buzlu Cam Efekti)
  Widget _buildGlassCard({
    required double titleSize,
    required bool isSmallScreen,
    required bool isNarrowScreen,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            isNarrowScreen ? 20 : 28,
            isSmallScreen ? 50 : 60,
            isNarrowScreen ? 20 : 28,
            isNarrowScreen ? 24 : 32,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryPurple.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              _buildTitle(titleSize),
              SizedBox(height: isSmallScreen ? 24 : 32),

              // E-posta Input
              _buildAnimatedInput(
                controller: _emailController,
                focusNode: _emailFocusNode,
                isFocused: _isEmailFocused,
                hintText: 'E-posta',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                delay: 100,
              ),
              SizedBox(height: isSmallScreen ? 14 : 18),

              // Şifre Input
              _buildAnimatedInput(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                isFocused: _isPasswordFocused,
                hintText: 'Şifre',
                icon: Icons.lock_rounded,
                isPassword: true,
                delay: 200,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),

              // Şifremi Unuttum
              _buildForgotPassword(),
              SizedBox(height: isSmallScreen ? 20 : 28),

              // Login Butonu
              _buildLoginButton(isSmallScreen),
              SizedBox(height: isSmallScreen ? 20 : 28),

              // Ayırıcı
              _buildDivider(),
              SizedBox(height: isSmallScreen ? 20 : 28),

              // Sosyal Giriş
              _buildSocialButtons(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 24),

              // Kayıt Ol
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double fontSize) {
    return Column(
      children: [
        Text(
              'Hoş Geldin! 👋',
              style: GoogleFonts.nunito(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            )
            .animate(delay: 200.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0),
        const SizedBox(height: 6),
        Text(
          'Maceraya devam etmek için giriş yap',
          style: GoogleFonts.nunito(
            fontSize: fontSize * 0.5,
            fontWeight: FontWeight.w500,
            color: _darkText.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildAnimatedInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    int delay = 0,
  }) {
    final borderColor = isFocused ? _primaryPurple : Colors.transparent;
    final glowColor = isFocused
        ? _primaryPurple.withValues(alpha: 0.3)
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
              obscureText: isPassword && _obscurePassword,
              keyboardType: keyboardType,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _darkText,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.nunito(
                  color: _darkText.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon:
                    Icon(
                          icon,
                          color: isFocused
                              ? _primaryPurple
                              : _darkText.withValues(alpha: 0.5),
                        )
                        .animate(target: isFocused ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                        ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: _darkText.withValues(alpha: 0.5),
                        ),
                        onPressed: () {
                          _hapticLight();
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      )
                    : null,
                filled: true,
                fillColor: _backgroundBase.withValues(alpha: 0.8),
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
                    color: _darkText.withValues(alpha: 0.1),
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
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          _hapticLight();
          _showForgotPasswordDialog();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          'Şifremi Unuttum',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primaryPurple,
          ),
        ),
      ),
    ).animate(delay: 350.ms).fadeIn(duration: 400.ms);
  }

  /// 🔐 Şifremi Unuttum Dialog
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                color: _primaryPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Şifre Sıfırlama',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkText,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'E-posta adresinizi girin, şifre sıfırlama linki gönderelim.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: _darkText.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'E-posta adresiniz',
                hintStyle: GoogleFonts.nunito(
                  color: _darkText.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(Icons.email_outlined, color: _primaryPurple),
                filled: true,
                fillColor: _backgroundBase,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _primaryPurple, width: 2),
                ),
              ),
              style: GoogleFonts.nunito(
                color: _darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'İptal',
              style: GoogleFonts.nunito(
                color: _darkText.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lütfen e-posta adresinizi girin',
                      style: GoogleFonts.nunito(),
                    ),
                    backgroundColor: _energeticCoral,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
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
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Şifre sıfırlama linki gönderildi! 📧\nMail gelmezse spam klasörünü kontrol edin.',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: _turquoise,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Link gönderilemedi. E-postayı kontrol edin.',
                      style: GoogleFonts.nunito(),
                    ),
                    backgroundColor: _energeticCoral,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Gönder',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isSmallScreen) {
    return GestureDetector(
          onTapDown: (_) {
            _hapticLight();
            setState(() => _isButtonPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isButtonPressed = false);
            _handleLogin();
          },
          onTapCancel: () {
            setState(() => _isButtonPressed = false);
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 100),
            scale: _isButtonPressed ? 0.95 : 1.0,
            child: Container(
              width: double.infinity,
              height: isSmallScreen ? 52 : 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryPurple,
                    _primaryPurple.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withValues(alpha: 0.4),
                    blurRadius: _isButtonPressed ? 8 : 15,
                    offset: Offset(0, _isButtonPressed ? 2 : 6),
                  ),
                ],
              ),
              child: Center(
                child: _isLoading
                    ? SizedBox(
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
                          Text(
                            'Giriş Yap',
                            style: GoogleFonts.nunito(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('🚀', style: TextStyle(fontSize: 20)),
                        ],
                      ),
              ),
            ),
          ),
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _darkText.withValues(alpha: 0.2)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _darkText.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_darkText.withValues(alpha: 0.2), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 450.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildSocialButtons(bool isSmallScreen) {
    return Row(
          children: [
            // Google Button
            Expanded(
              child: _buildSocialButton(
                icon: 'G',
                label: 'Google',
                color: const Color(0xFFDB4437),
                onTap: () {
                  _hapticLight();
                  // context.read<AuthProvider>().signInWithGoogle();
                },
              ),
            ),
            const SizedBox(width: 14),
            // Apple Button
            Expanded(
              child: _buildSocialButton(
                icon: '',
                label: 'Apple',
                color: _darkText,
                onTap: () {
                  _hapticLight();
                  // context.read<AuthProvider>().signInWithApple();
                },
              ),
            ),
          ],
        )
        .animate(delay: 500.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon == 'G')
                  Text(
                    'G',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  )
                else
                  Icon(Icons.apple, color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabın yok mu? ',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _darkText.withValues(alpha: 0.6),
          ),
        ),
        GestureDetector(
          onTap: () {
            _hapticLight();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const RegisterScreen(),
                transitionDuration: const Duration(milliseconds: 400),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: Text(
            'Kayıt Ol',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _primaryPurple,
            ),
          ),
        ),
      ],
    ).animate(delay: 550.ms).fadeIn(duration: 400.ms);
  }
}

// Extension for sin function in shake animation
extension SinExtension on double {
  double sin() => math.sin(this);
}
