import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/duel_controller.dart';
import '../../domain/entities/duel_entities.dart';
import '../../data/connectivity_service.dart';
import '../../../mascot/presentation/providers/mascot_provider.dart';
import 'matchmaking_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎮 NEON ARENA SELECTION - Düello Seçim Modal
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Cyberpunk Arena temalı oyun modu seçim ekranı
/// - Glassmorphism bottom sheet
/// - Neon ışık efektleri
/// - Animated game type cards
/// - Haptic feedback
/// ═══════════════════════════════════════════════════════════════════════════

class DuelSelectionSheet extends ConsumerStatefulWidget {
  const DuelSelectionSheet({super.key});

  @override
  ConsumerState<DuelSelectionSheet> createState() => _DuelSelectionSheetState();
}

class _DuelSelectionSheetState extends ConsumerState<DuelSelectionSheet>
    with SingleTickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _neonPink = Color(0xFFFF0080);
  static const Color _neonBlue = Color(0xFF0080FF);
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Tamamen opak arka plan
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E), // Koyu lacivert
            Color(0xFF0D0D1A), // Daha koyu
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: _neonCyan, width: 3),
          left: BorderSide(color: _neonCyan.withValues(alpha: 0.5), width: 2),
          right: BorderSide(
            color: _neonPurple.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HANDLE BAR
          // ═══════════════════════════════════════════════════════════════
          _buildHandleBar(),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // HEADER
          // ═══════════════════════════════════════════════════════════════
          _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

          const SizedBox(height: 8),

          // ═══════════════════════════════════════════════════════════════
          // SUBTITLE
          // ═══════════════════════════════════════════════════════════════
          _buildSubtitle().animate().fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 28),

          // ═══════════════════════════════════════════════════════════════
          // GAME TYPE CARDS
          // ═══════════════════════════════════════════════════════════════
          _buildGameTypeCard(
            title: 'Test Çözme',
            description: '4 şıklı sorularla yarış',
            icon: Icons.quiz_rounded,
            emoji: '🎯',
            primaryColor: _neonBlue,
            secondaryColor: _neonCyan,
            gameType: DuelGameType.test,
            delay: 200,
          ),

          const SizedBox(height: 16),

          _buildGameTypeCard(
            title: 'Cümle Tamamlama',
            description: 'Boşlukları doğru kelimeyle doldur',
            icon: Icons.edit_note_rounded,
            emoji: '📝',
            primaryColor: _neonPurple,
            secondaryColor: _neonPink,
            gameType: DuelGameType.fillBlanks,
            delay: 300,
          ),

          const SizedBox(height: 28),

          // ═══════════════════════════════════════════════════════════════
          // FOOTER INFO
          // ═══════════════════════════════════════════════════════════════
          _buildFooterInfo().animate().fadeIn(duration: 400.ms, delay: 400.ms),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHandleBar() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _neonCyan.withValues(alpha: _glowAnimation.value),
                _neonPurple.withValues(alpha: _glowAnimation.value),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _neonCyan.withValues(alpha: 0.3 * _glowAnimation.value),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Icon container with glow
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _neonPink.withValues(alpha: 0.3),
                    _neonPurple.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _neonPink.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _neonPink.withValues(
                      alpha: 0.3 * _glowAnimation.value,
                    ),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text('⚔️', style: TextStyle(fontSize: 28)),
            );
          },
        ),

        const SizedBox(width: 16),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1v1 DÜELLO',
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: _neonCyan.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _neonCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _neonCyan.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '🎮 ARENA MODU',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _neonCyan,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.white.withValues(alpha: 0.6),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Rakibinle yarış! Hangi oyun türünde mücadele etmek istersin?',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTypeCard({
    required String title,
    required String description,
    required IconData icon,
    required String emoji,
    required Color primaryColor,
    required Color secondaryColor,
    required DuelGameType gameType,
    required int delay,
  }) {
    return GestureDetector(
          onTap: () => _onGameTypeSelected(context, ref, gameType),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withValues(alpha: 0.15),
                      secondaryColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withValues(
                      alpha: 0.4 + (0.2 * _glowAnimation.value),
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                        alpha: 0.15 * _glowAnimation.value,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.3),
                            secondaryColor.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow icon
                    Container(
                      padding: const EdgeInsets.all(10),
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
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: delay),
        )
        .slideX(begin: 0.1);
  }

  Widget _buildFooterInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_rounded,
          color: Colors.white.withValues(alpha: 0.4),
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          'Online bağlantı gerektirir',
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUSINESS LOGIC (PRESERVED)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _onGameTypeSelected(
    BuildContext context,
    WidgetRef ref,
    DuelGameType gameType,
  ) async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Modal'ı kapat
    Navigator.pop(context);

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
      // Haptic feedback for error
      HapticFeedback.heavyImpact();
      // İnternet yok hatası göster
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
                  border: Border.all(color: _neonPink.withValues(alpha: 0.5)),
                ),
                child: Icon(Icons.wifi_off_rounded, color: _neonPink, size: 32),
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
                    gradient: LinearGradient(colors: [_neonCyan, _neonPurple]),
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
    );
  }
}

/// Düello seçim modal'ını göster
void showDuelSelectionSheet(BuildContext context) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D0D1A), // Opak koyu arka plan
    barrierColor: Colors.black.withValues(alpha: 0.7), // Koyu barrier
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.6,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => const DuelSelectionSheet(),
  );
}
