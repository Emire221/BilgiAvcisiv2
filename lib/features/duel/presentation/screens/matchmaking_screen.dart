import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../mascot/domain/entities/mascot.dart';
import '../../logic/duel_controller.dart';
import '../../domain/entities/duel_entities.dart';
import 'duel_game_screen.dart';
import 'duel_guess_game_screen.dart';
import 'duel_memory_game_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎮 NEON ARENA MATCHMAKING - Rakip Arama Ekranı
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Cyberpunk Arena temalı rakip arama deneyimi
/// - Neon ışık efektleri ve pulse animasyonları
/// - match_macking.json Lottie animasyonu
/// - Glassmorphism kartlar
/// - Dinamik durum mesajları
/// ═══════════════════════════════════════════════════════════════════════════

class MatchmakingScreen extends ConsumerStatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  ConsumerState<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends ConsumerState<MatchmakingScreen>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION CONTROLLERS
  // ═══════════════════════════════════════════════════════════════════════════
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _foundController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ═══════════════════════════════════════════════════════════════════════════
  String _statusText = 'Rakip Aranıyor...';
  bool _isFound = false;
  final Random _random = Random();
  late final PetType _botMascot; // Bot için rastgele maskot

  // ═══════════════════════════════════════════════════════════════════════════
  // THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _neonPink = Color(0xFFFF0080);
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _darkBg = Color(0xFF0D0D1A);
  static const Color _darkBg2 = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Bot için rastgele maskot seç
    _botMascot = PetType.values[_random.nextInt(PetType.values.length)];
    _startMatchmaking();
  }

  void _initializeAnimations() {
    // Pulse animasyonu - Daha yavaş ve smooth
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Glow animasyonu
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Found animasyonu (bounce effect)
    _foundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _foundController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MATCHMAKING LOGIC (PRESERVED)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _startMatchmaking() async {
    // Haptic feedback at start
    HapticFeedback.mediumImpact();

    // Soruları yükle
    final success = await ref
        .read(duelControllerProvider.notifier)
        .loadQuestions();

    if (!success) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sorular yüklenemedi, tekrar deneyin',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: _neonPink.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Rastgele bekleme süresi (3-5 saniye)
    final waitTime = 3000 + _random.nextInt(2000);

    // Durum mesajlarını değiştir
    _updateStatusMessages();

    // Bekleme süresi
    await Future.delayed(Duration(milliseconds: waitTime));

    if (!mounted) return;

    // Haptic feedback - found!
    HapticFeedback.heavyImpact();

    // Rakip bulundu
    setState(() {
      _isFound = true;
      _statusText = 'Rakip Bulundu!';
    });

    // Found animasyonunu başlat
    _foundController.forward();

    // Kısa bir bekleme ve oyuna geç
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Oyunu başlat
    ref.read(duelControllerProvider.notifier).startGame();

    // Oyun ekranına git - oyun türüne göre doğru ekrana yönlendir
    final gameType = ref.read(duelControllerProvider).gameType;
    Widget targetScreen;

    if (gameType == DuelGameType.guess) {
      targetScreen = const DuelGuessGameScreen();
    } else if (gameType == DuelGameType.findCards) {
      targetScreen = const DuelMemoryGameScreen();
    } else {
      targetScreen = const DuelGameScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _updateStatusMessages() async {
    final messages = [
      'Rakip Aranıyor...',
      'Arena taranıyor...',
      'Uygun rakip bulunuyor...',
      'Eşleştirme yapılıyor...',
      'Neredeyse tamam...',
    ];

    for (int i = 0; i < messages.length && mounted && !_isFound; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted && !_isFound) {
        HapticFeedback.selectionClick();
        setState(() {
          _statusText = messages[i % messages.length];
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD METHOD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(duelControllerProvider);
    final botProfile = state.botProfile;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // ANIMATED BACKGROUND
          // ═══════════════════════════════════════════════════════════════════
          _buildAnimatedBackground(size),

          // ═══════════════════════════════════════════════════════════════════
          // FLOATING PARTICLES
          // ═══════════════════════════════════════════════════════════════════
          ..._buildFloatingParticles(size),

          // ═══════════════════════════════════════════════════════════════════
          // MAIN CONTENT (📱 UX Faz 3.2: Responsive Layout - No Scroll)
          // ═══════════════════════════════════════════════════════════════════
          SafeArea(
            child: Column(
              children: [
                // Back button
                _buildTopBar(state),

                // Main matchmaking area - Esnek yerleşim
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lottie Animation
                      _buildLottieAnimation(),

                      SizedBox(height: size.height * 0.02),

                      // VS Badge or Avatar
                      Flexible(child: _buildMatchmakingVisual(botProfile)),

                      SizedBox(height: size.height * 0.03),

                      // Status Text - Sadece aranırken göster
                      if (!_isFound) _buildStatusText(),

                      SizedBox(height: size.height * 0.015),

                      // Bot info (when found)
                      if (_isFound && botProfile != null)
                        _buildBotInfo(botProfile),

                      // Progress indicator
                      if (!_isFound) _buildProgressIndicator(),

                      SizedBox(height: size.height * 0.03),

                      // Cancel button
                      if (!_isFound) _buildCancelButton(),

                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                _neonPurple.withValues(alpha: 0.15 * _glowAnimation.value),
                _darkBg2,
                _darkBg,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingParticles(Size size) {
    return List.generate(15, (index) {
      final random = Random(index);
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final particleSize = 2.0 + random.nextDouble() * 4;
      final duration = 15 + random.nextInt(20);
      final color = [_neonCyan, _neonPurple, _neonPink, _neonGreen][index % 4];

      return Positioned(
        left: startX,
        top: startY,
        child:
            Container(
                  width: particleSize,
                  height: particleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                  begin: 0,
                  end: -100,
                  duration: Duration(seconds: duration),
                  curve: Curves.easeInOut,
                )
                .fadeOut(begin: 1, duration: Duration(seconds: duration)),
      );
    });
  }

  Widget _buildTopBar(DuelState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Game type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _neonPurple.withValues(alpha: 0.3),
                  _neonCyan.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _neonCyan.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _neonCyan.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.gameType == DuelGameType.test
                      ? Icons.quiz_rounded
                      : state.gameType == DuelGameType.fillBlanks
                      ? Icons.edit_note_rounded
                      : state.gameType == DuelGameType.findCards
                      ? Icons.psychology_rounded
                      : Icons.vibration_rounded,
                  color: _neonCyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  state.gameType == DuelGameType.test
                      ? 'Test Çözme'
                      : state.gameType == DuelGameType.fillBlanks
                      ? 'Cümle Tamamlama'
                      : state.gameType == DuelGameType.findCards
                      ? 'Bul Bakalım'
                      : 'Salla Bakalım',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.3),

          // Arena badge
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _neonPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _neonPink.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚔️', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'ARENA',
                      style: GoogleFonts.orbitron(
                        color: _neonPink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideX(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildLottieAnimation() {
    // 📱 UX Faz 3.2: Animasyon ekranın max %30'unu kaplamalı
    final screenHeight = MediaQuery.of(context).size.height;
    final animationSize = (screenHeight * 0.25).clamp(120.0, 200.0);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isFound ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: animationSize,
            height: animationSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isFound ? _neonGreen : _neonCyan).withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            // ✅ Lottie optimize edildi
            child: Lottie.asset(
              'assets/animation/match_macking.json',
              fit: BoxFit.contain,
              repeat: !_isFound,
              frameRate: FrameRate.max,
              options: LottieOptions(enableMergePaths: true),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5));
  }

  Widget _buildMatchmakingVisual(dynamic botProfile) {
    if (_isFound && botProfile != null) {
      // Found - Show VS with bot avatar
      return _buildFoundVisual(botProfile)
          .animate(controller: _foundController)
          .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut)
          .fadeIn();
    }

    // Searching - Show pulse ring
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _neonCyan.withValues(alpha: 0.3),
                _neonPurple.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _neonCyan.withValues(alpha: _glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _neonCyan.withValues(alpha: 0.3 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPulsingDot(0),
                const SizedBox(width: 8),
                _buildPulsingDot(200),
                const SizedBox(width: 8),
                _buildPulsingDot(400),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  Widget _buildPulsingDot(int delayMs) {
    return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _neonCyan,
            boxShadow: [
              BoxShadow(
                color: _neonCyan.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          delay: Duration(milliseconds: delayMs),
        )
        .fadeIn(delay: Duration(milliseconds: delayMs));
  }

  Widget _buildFoundVisual(dynamic botProfile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rakip Bulundu! başlığı
        Text(
          'Rakip Bulundu!',
          style: GoogleFonts.nunito(
            color: _neonGreen,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: _neonGreen.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Hazırlanıyor animasyonu
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: _neonGreen,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              'Hazırlanıyor...',
              style: GoogleFonts.nunito(
                color: _neonGreen.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn()
        .then()
        .fadeOut(duration: 800.ms),
        
        const SizedBox(height: 16),

        // VS Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_neonPink, _neonPurple]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _neonPink.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Text(
            '⚔️ VS ⚔️',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Bot Avatar Card
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonGreen.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _neonGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _neonPurple.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(color: _neonGreen, width: 3),
                    ),
                    child: ClipOval(
                      child: Lottie.asset(
                        _botMascot.getLottiePath(),
                        fit: BoxFit.cover,
                        repeat: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Name
                  Text(
                    botProfile.name,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _neonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _neonGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, color: _neonGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Seviye ${botProfile.level}',
                          style: GoogleFonts.nunito(
                            color: _neonGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey(_statusText),
        children: [
          Text(
            _statusText,
            style: GoogleFonts.nunito(
              color: _isFound ? _neonGreen : Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: (_isFound ? _neonGreen : _neonCyan).withValues(
                    alpha: 0.5,
                  ),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          if (_isFound)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child:
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: _neonGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hazırlanıyor...',
                            style: GoogleFonts.nunito(
                              color: _neonGreen.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn()
                      .then()
                      .fadeOut(duration: 800.ms),
            ),
        ],
      ),
    );
  }

  Widget _buildBotInfo(dynamic botProfile) {
    // Konu adını al
    final controller = ref.read(duelControllerProvider.notifier);
    final topicName = controller.currentTopicName ?? 'Genel Konu';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _neonGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Yarışma Konumuz
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.topic_rounded, color: _neonCyan, size: 20),
              const SizedBox(width: 10),
              Text(
                'Yarışma Konumuz:',
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Konu adı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _neonCyan.withValues(alpha: 0.2),
                  _neonPurple.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _neonCyan.withValues(alpha: 0.4)),
            ),
            child: Text(
              topicName,
              style: GoogleFonts.nunito(
                color: _neonCyan,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Oyun başlıyor
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_esports_rounded, color: _neonGreen, size: 20),
              const SizedBox(width: 10),
              Text(
                'Oyun başlıyor!',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3);
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          width: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _neonCyan.withValues(alpha: 0.8),
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Online oyuncular taranıyor...',
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(duelControllerProvider.notifier).reset();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.close_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'İptal Et',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideY(begin: 0.3);
  }
}
