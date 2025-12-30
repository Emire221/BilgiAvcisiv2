import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/memory_game_controller.dart';
import '../../domain/entities/memory_game_state.dart';
import '../widgets/flip_card_widget.dart';
import 'memory_result_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🧠 NEON BRAIN MEMORY - Bul Bakalım Ana Oyun Ekranı
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Cyberpunk Brain temalı hafıza oyunu deneyimi
/// - Neon glow efektleri ve pulse animasyonları
/// - Glassmorphism stat kartları
/// - Animasyonlu mesaj göstergesi
/// - Haptic feedback
/// ═══════════════════════════════════════════════════════════════════════════

class MemoryGameScreen extends ConsumerStatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _neonPink = Color(0xFFFF0080);
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _neonYellow = Color(0xFFFFFF00);
  static const Color _neonRed = Color(0xFFFF3131);
  static const Color _darkBg = Color(0xFF0D0D1A);
  static const Color _darkBg2 = Color(0xFF1A1A2E);

  Timer? _timer;
  int _elapsedSeconds = 0;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryGameProvider.notifier).startGame();
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoryGameProvider);
    final size = MediaQuery.of(context).size;

    // Oyun bittiğinde sonuç ekranına git
    ref.listen<MemoryGameState>(memoryGameProvider, (previous, next) {
      if (next.isCompleted && !(previous?.isCompleted ?? false)) {
        _timer?.cancel();
        HapticFeedback.heavyImpact();

        // Navigator'u async gap öncesi yakala
        final navigator = Navigator.of(context);
        final resultScreen = MemoryResultScreen(
          moves: next.moves,
          mistakes: next.mistakes,
          elapsedSeconds: next.elapsedSeconds,
          score: next.score,
          starCount: next.starCount,
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            navigator.pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    resultScreen,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        });
      }

      // Yanlış cevapta haptic feedback
      if (next.isChecking && !(previous?.isChecking ?? false)) {
        HapticFeedback.mediumImpact();
      }
    });

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
          // MAIN CONTENT
          // ═══════════════════════════════════════════════════════════════════
          SafeArea(
            child: Column(
              children: [
                // Üst bar
                _buildTopBar(
                  state,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

                // Durum göstergesi
                _buildStatusIndicator(
                  state,
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                // Kart grid'i
                Expanded(
                  child: _buildCardGrid(state)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .scale(begin: const Offset(0.95, 0.95)),
                ),

                // Alt bilgi
                _buildBottomInfo(state)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.3),
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
              center: Alignment.topCenter,
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
    return List.generate(12, (index) {
      final random = index * 1234567;
      final startX = (random % size.width.toInt()).toDouble();
      final startY = (random % size.height.toInt()).toDouble();
      final particleSize = 2.0 + (index % 4);
      final duration = 20 + (index % 15);
      final colors = [_neonCyan, _neonPurple, _neonPink, _neonGreen];
      final color = colors[index % colors.length];

      return Positioned(
        left: startX,
        top: startY,
        child:
            Container(
                  width: particleSize,
                  height: particleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                  begin: 0,
                  end: -80,
                  duration: Duration(seconds: duration),
                  curve: Curves.easeInOut,
                )
                .fadeOut(begin: 1, duration: Duration(seconds: duration)),
      );
    });
  }

  Widget _buildTopBar(MemoryGameState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Geri butonu
          _buildIconButton(icon: Icons.close_rounded, onTap: _showExitDialog),

          const Spacer(),

          // Süre göstergesi
          _buildTimerWidget(),

          const Spacer(),

          // Yeniden başlat
          _buildIconButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(memoryGameProvider.notifier).restartGame();
              _startTimer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTimerWidget() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _neonCyan.withValues(alpha: 0.2),
                _neonPurple.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _neonCyan.withValues(alpha: 0.4 * _pulseAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _neonCyan.withValues(alpha: 0.2 * _pulseAnimation.value),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_rounded, color: _neonCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                _formatTime(_elapsedSeconds),
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(MemoryGameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatBox(
            icon: Icons.filter_1_rounded,
            label: 'Sıradaki',
            value: state.nextExpectedNumber > 10
                ? '✓'
                : '${state.nextExpectedNumber}',
            color: _neonGreen,
          ),
          _buildStatBox(
            icon: Icons.touch_app_rounded,
            label: 'Hamle',
            value: '${state.moves}',
            color: _neonCyan,
          ),
          _buildStatBox(
            icon: Icons.close_rounded,
            label: 'Hata',
            value: '${state.mistakes}',
            color: _neonRed,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(
                    alpha: 0.4 + (0.2 * _glowAnimation.value),
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15 * _glowAnimation.value),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardGrid(MemoryGameState state) {
    if (state.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: _neonCyan,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kartlar hazırlanıyor...',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              // 4x3 grid için padding (10 kart var, 2 boşluk)
              // İlk 4, sonra 4, sonra 2 (ortada)
              int cardIndex;
              if (index < 4) {
                cardIndex = index;
              } else if (index < 8) {
                cardIndex = index;
              } else {
                // Son satırda 2 kart ortada
                if (index == 8) {
                  cardIndex = 8;
                } else if (index == 9) {
                  cardIndex = 9;
                } else {
                  return const SizedBox();
                }
              }

              if (cardIndex >= state.cards.length) {
                return const SizedBox();
              }

              final card = state.cards[cardIndex];

              return FlipCardWidget(
                card: card,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(memoryGameProvider.notifier).flipCard(card.id);
                },
                disabled: state.isChecking || card.isMatched,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(MemoryGameState state) {
    String message;
    Color messageColor;
    IconData icon;

    if (state.isChecking) {
      message = 'Yanlış! Kartlar kapanıyor...';
      messageColor = _neonRed;
      icon = Icons.close_rounded;
    } else if (state.matchedCount > 0) {
      message = '${state.matchedCount}/10 kart bulundu';
      messageColor = _neonGreen;
      icon = Icons.check_circle_rounded;
    } else {
      message = '1\'den başlayarak sırayla bul!';
      messageColor = _neonYellow;
      icon = Icons.lightbulb_rounded;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ClipRRect(
          key: ValueKey(message),
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    messageColor.withValues(alpha: 0.15),
                    messageColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: messageColor.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: messageColor.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: messageColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  void _showExitDialog() {
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
                      Icons.exit_to_app_rounded,
                      color: _neonPink,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Oyundan Çık',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Content
                  Text(
                    'Oyundan çıkmak istediğine emin misin?\nİlerlemen kaydedilmeyecek.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'İptal',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Exit button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_neonPink, _neonPurple],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _neonPink.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Çık',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
