import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/shape_game_controller.dart';
import '../../domain/entities/shape_game_state.dart';
import '../widgets/shape_flip_card_widget.dart';
import 'memory_result_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎨 SHAPE MATCH - Şekil Eşleştirme Oyunu
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Cyberpunk temalı şekil eşleştirme deneyimi
/// - 5 farklı okul figürü (cetvel, kalem, kitap, hesap makinesi, palet)
/// - Her şekilden 2 adet = 10 kart
/// - Ardışık aynı şekilleri eşleştir
/// ═══════════════════════════════════════════════════════════════════════════

class ShapeGameScreen extends ConsumerStatefulWidget {
  const ShapeGameScreen({super.key});

  @override
  ConsumerState<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends ConsumerState<ShapeGameScreen>
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
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shapeGameProvider.notifier).startGame();
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
    final state = ref.watch(shapeGameProvider);
    final size = MediaQuery.of(context).size;

    // Oyun bittiğinde sonuç ekranına git
    ref.listen<ShapeGameState>(shapeGameProvider, (previous, next) {
      if (next.isCompleted && !(previous?.isCompleted ?? false)) {
        _timer?.cancel();
        HapticFeedback.heavyImpact();

        final navigator = Navigator.of(context);
        final resultScreen = MemoryResultScreen(
          moves: next.moves,
          mistakes: next.mistakes,
          elapsedSeconds: next.elapsedSeconds,
          score: next.score,
          starCount: next.starCount,
          gameType: 'shape_match', // Şekil eşleştirme
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

      // Doğru eşleşmede haptic feedback
      if (next.matches > (previous?.matches ?? 0)) {
        HapticFeedback.mediumImpact();
      }
    });

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: _darkBg,
        body: Stack(
          children: [
            // Animated Background
            _buildAnimatedBackground(size),
            
            // Floating Particles
            ..._buildFloatingParticles(size),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Üst bar
                  _buildTopBar(state)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.3),

                  // Durum göstergesi
                  _buildStatusIndicator(state)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms),

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
      ),
    );
  }

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
                _neonPink.withValues(alpha: 0.15 * _glowAnimation.value),
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
        child: Container(
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

  Widget _buildTopBar(ShapeGameState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Çıkış butonu
          _buildIconButton(
            icon: FontAwesomeIcons.arrowLeft,
            onTap: () => Navigator.of(context).pop(),
          ),

          const Spacer(),

          // Süre göstergesi
          _buildTimerWidget(),

          const Spacer(),

          // Yeniden başlat
          _buildIconButton(
            icon: FontAwesomeIcons.arrowRotateRight,
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(shapeGameProvider.notifier).restartGame();
              _startTimer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: FaIcon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _neonCyan.withValues(alpha: 0.3)),
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
              Icon(Icons.timer_rounded, color: _neonCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                _formatTime(_elapsedSeconds),
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ShapeGameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatChip(
            icon: FontAwesomeIcons.handPointer,
            value: state.moves.toString(),
            label: 'Hamle',
            color: _neonCyan,
          ),
          const SizedBox(width: 16),
          _buildStatChip(
            icon: FontAwesomeIcons.circleCheck,
            value: '${state.matches}/5',
            label: 'Eşleşme',
            color: _neonGreen,
          ),
          const SizedBox(width: 16),
          _buildStatChip(
            icon: FontAwesomeIcons.circleXmark,
            value: state.mistakes.toString(),
            label: 'Hata',
            color: _neonRed,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
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

  Widget _buildCardGrid(ShapeGameState state) {
    if (state.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _neonPink),
            const SizedBox(height: 16),
            Text(
              'Kartlar hazırlanıyor...',
              style: TextStyle(
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
              if (index >= state.cards.length) {
                return const SizedBox();
              }

              final card = state.cards[index];

              return ShapeFlipCardWidget(
                card: card,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(shapeGameProvider.notifier).flipCard(card.id);
                },
                disabled: state.isChecking || card.isMatched,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(ShapeGameState state) {
    String message;
    Color messageColor;
    IconData icon;

    if (state.isChecking) {
      message = 'Kontrol ediliyor...';
      messageColor = _neonYellow;
      icon = Icons.hourglass_bottom_rounded;
    } else if (state.matches > 0) {
      message = '${state.matches}/5 eşleşme bulundu';
      messageColor = _neonGreen;
      icon = Icons.check_circle_rounded;
    } else {
      message = 'Aynı şekilleri eşleştir!';
      messageColor = _neonPink;
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
}
