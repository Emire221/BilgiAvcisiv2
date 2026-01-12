import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../logic/duel_controller.dart';
import '../../domain/entities/duel_entities.dart';
import '../../data/connectivity_service.dart';
import '../../../mascot/presentation/providers/mascot_provider.dart';
import 'matchmaking_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎮 DUEL GAME SELECTION - Düello Oyun Seçim Ekranı (Tam Ekran)
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Cyberpunk Arena temalı tam ekran oyun seçim sayfası
/// - Modal yerine tam ekran deneyimi
/// - Tüm düello oyunlarını listeler
/// - Neon ışık efektleri ve animasyonlar
/// ═══════════════════════════════════════════════════════════════════════════

class DuelGameSelectionScreen extends ConsumerStatefulWidget {
  const DuelGameSelectionScreen({super.key});

  @override
  ConsumerState<DuelGameSelectionScreen> createState() =>
      _DuelGameSelectionScreenState();
}

class _DuelGameSelectionScreenState
    extends ConsumerState<DuelGameSelectionScreen>
    with SingleTickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _neonPink = Color(0xFFFF0080);
  static const Color _neonBlue = Color(0xFF0080FF);
  static const Color _neonOrange = Color(0xFFFF6B35);
  static const Color _neonYellow = Color(0xFFFFD700);
  static const Color _darkBg = Color(0xFF0D0D1A);
  static const Color _darkBg2 = Color(0xFF1A1A2E);

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Grid overlay
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _GridPainter(color: _neonCyan.withValues(alpha: 0.03)),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.3),

                const SizedBox(height: 24),

                // Header
                _buildHeader().animate().fadeIn(
                  duration: 400.ms,
                  delay: 100.ms,
                ),

                const SizedBox(height: 32),

                // Game Cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Test Çözme
                        _buildGameCard(
                              title: 'Test Çözme',
                              description:
                                  '4 şıklı sorularla yarış! Rakibinden önce doğru cevabı bul.',
                              icon: FontAwesomeIcons.clipboardQuestion,
                              emoji: '🎯',
                              primaryColor: _neonBlue,
                              secondaryColor: _neonCyan,
                              gameType: DuelGameType.test,
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideX(begin: -0.1),

                        const SizedBox(height: 16),

                        // Cümle Tamamlama
                        _buildGameCard(
                              title: 'Cümle Tamamlama',
                              description:
                                  'Boşlukları doğru kelimeyle doldur, puan kazan!',
                              icon: FontAwesomeIcons.penToSquare,
                              emoji: '📝',
                              primaryColor: _neonPurple,
                              secondaryColor: _neonPink,
                              gameType: DuelGameType.fillBlanks,
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 300.ms)
                            .slideX(begin: 0.1),

                        const SizedBox(height: 16),

                        // Salla Bakalım
                        _buildGameCard(
                              title: 'Salla Bakalım',
                              description:
                                  'Sayıları tahmin et! Telefonu salla ve rakibini yen!',
                              icon: FontAwesomeIcons.mobileScreenButton,
                              emoji: '📱',
                              primaryColor: _neonOrange,
                              secondaryColor: _neonYellow,
                              gameType: DuelGameType.guess,
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 400.ms)
                            .slideX(begin: -0.1),

                        const SizedBox(height: 16),

                        // Bul Bakalım
                        _buildGameCard(
                              title: 'Bul Bakalım',
                              description:
                                  'Kartları sırayla bul! Yanlış yaparsan sıra rakibe geçer.',
                              icon: FontAwesomeIcons.brain,
                              emoji: '🧠',
                              primaryColor: const Color(
                                0xFF39FF14,
                              ), // neonGreen
                              secondaryColor: _neonCyan,
                              gameType: DuelGameType.findCards,
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 500.ms)
                            .slideX(begin: 0.1),

                        const SizedBox(height: 32),

                        // Footer Info
                        _buildFooterInfo().animate().fadeIn(
                          duration: 400.ms,
                          delay: 500.ms,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                _neonPurple.withValues(alpha: 0.15 * _glowAnimation.value),
                _darkBg2,
                _darkBg,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const Spacer(),

          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _neonPink.withValues(alpha: 0.2),
                  _neonPurple.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _neonPink.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'ARENA',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Placeholder for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Title
          Text(
            '1v1 DÜELLO',
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(color: _neonCyan.withValues(alpha: 0.5), blurRadius: 15),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              'Rakibinle yarış! Hangi oyun türünde mücadele etmek istersin?',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String description,
    required IconData icon,
    required String emoji,
    required Color primaryColor,
    required Color secondaryColor,
    required DuelGameType gameType,
  }) {
    return GestureDetector(
      onTap: () => _onGameTypeSelected(context, ref, gameType),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withValues(alpha: 0.15),
                  secondaryColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: primaryColor.withValues(
                  alpha: 0.4 + (0.2 * _glowAnimation.value),
                ),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(
                    alpha: 0.15 * _glowAnimation.value,
                  ),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withValues(alpha: 0.4),
                        secondaryColor.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 32)),
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_rounded,
            color: Colors.white.withValues(alpha: 0.5),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Online bağlantı gerektirir',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUSINESS LOGIC
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _onGameTypeSelected(
    BuildContext context,
    WidgetRef ref,
    DuelGameType gameType,
  ) async {
    HapticFeedback.mediumImpact();

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _darkBg.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _neonCyan.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: _neonCyan,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bağlanıyor...',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // İnternet kontrolü
    final hasInternet = await ConnectivityService.hasInternetConnection();

    // Loading'i kapat
    if (context.mounted) {
      Navigator.pop(context);
    }

    if (!hasInternet) {
      HapticFeedback.heavyImpact();
      if (context.mounted) {
        _showNoInternetDialog(context);
      }
      return;
    }

    // Kullanıcı seviyesini al (mascot level)
    final mascotAsync = ref.read(activeMascotProvider);
    final userLevel = mascotAsync.asData?.value?.level ?? 1;

    // Oyun türünü seç
    ref
        .read(duelControllerProvider.notifier)
        .selectGameType(gameType, userLevel: userLevel);

    // Matchmaking ekranına git
    if (context.mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MatchmakingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _darkBg2.withValues(alpha: 0.95),
                    _darkBg.withValues(alpha: 0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonPink.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _neonPink.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _neonPink.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      color: _neonPink,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Bağlantı Hatası',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Content
                  Text(
                    'Düello oynayabilmek için internet bağlantısı gereklidir. Lütfen bağlantınızı kontrol edin ve tekrar deneyin.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_neonCyan, _neonPurple],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _neonCyan.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Tamam',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GRID PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 50.0;

    // Vertical lines
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
