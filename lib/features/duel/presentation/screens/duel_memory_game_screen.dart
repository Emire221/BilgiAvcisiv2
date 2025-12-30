import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/duel_controller.dart';
import '../../domain/entities/duel_entities.dart';
import '../widgets/duel_flip_card_widget.dart';
import '../widgets/duel_result_dialog.dart';
import '../widgets/duel_score_header.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🧠 DUEL BUL BAKALIM - 1v1 Hafıza Kartı Oyunu
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Cyberpunk Brain temalı sıra bazlı hafıza düellosu
/// - Mevcut memory game UI temeli
/// - DuelScoreHeader ve sıra göstergesi entegrasyonu
/// - Bot düşünme ve oynama animasyonları
/// ═══════════════════════════════════════════════════════════════════════════

class DuelMemoryGameScreen extends ConsumerStatefulWidget {
  const DuelMemoryGameScreen({super.key});

  @override
  ConsumerState<DuelMemoryGameScreen> createState() =>
      _DuelMemoryGameScreenState();
}

class _DuelMemoryGameScreenState extends ConsumerState<DuelMemoryGameScreen>
    with TickerProviderStateMixin {
  // Theme colors
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _neonPink = Color(0xFFFF0080);
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _neonYellow = Color(0xFFFFFF00);
  static const Color _neonOrange = Color(0xFFFF6B35);
  static const Color _darkBg = Color(0xFF0D0D1A);
  static const Color _darkBg2 = Color(0xFF1A1A2E);

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _resultShown = false;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(duelControllerProvider);
    final controller = ref.read(duelControllerProvider.notifier);
    final size = MediaQuery.of(context).size;

    // Oyun bittiğinde sonuç dialogunu göster
    if (state.status == DuelStatus.finished && !_resultShown) {
      _resultShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HapticFeedback.heavyImpact();
        _showResultDialog(context, controller.getResult(), state);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          HapticFeedback.mediumImpact();
          _showExitDialog();
        }
      },
      child: Scaffold(
        backgroundColor: _darkBg,
        body: Stack(
          children: [
            // Animated background
            _buildAnimatedBackground(size),

            // Floating particles
            ..._buildFloatingParticles(size),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Score header
                  _buildScoreHeader(
                    state,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

                  // Status indicator (turn + next expected)
                  _buildStatusIndicator(
                    state,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  // Card grid
                  Expanded(
                    child: _buildCardGrid(state)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                  ),

                  // Bottom message
                  _buildBottomMessage(state)
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
    return List.generate(10, (index) {
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

  Widget _buildScoreHeader(DuelState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DuelScoreHeader(
        userScore: state.userScore,
        botScore: state.botScore,
        botProfile: state.botProfile,
        currentQuestion: state.nextExpectedNumber > 10
            ? 10
            : state.nextExpectedNumber,
        totalQuestions: 10,
        hideQuestionCounter: true, // Memory oyununda soru sayısı gösterme
      ),
    );
  }

  Widget _buildStatusIndicator(DuelState state) {
    final isUserTurn = state.isUserMemoryTurn;
    final nextNumber = state.nextExpectedNumber;
    final matchedCount =
        state.memoryCards?.where((c) => c.isMatched).length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatBox(
            icon: Icons.person_rounded,
            label: 'Sıra',
            value: isUserTurn ? 'Sen' : (state.botProfile?.name ?? 'Rakip'),
            color: isUserTurn ? _neonGreen : _neonOrange,
          ),
          _buildStatBox(
            icon: Icons.filter_1_rounded,
            label: 'Aranan',
            value: nextNumber > 10 ? '✓' : '$nextNumber',
            color: _neonCyan,
          ),
          _buildStatBox(
            icon: Icons.check_circle_rounded,
            label: 'Bulunan',
            value: '$matchedCount/10',
            color: _neonPurple,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Icon(icon, color: color, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
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

  Widget _buildCardGrid(DuelState state) {
    final cards = state.memoryCards;
    if (cards == null || cards.isEmpty) {
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

    final isUserTurn = state.isUserMemoryTurn;
    final isProcessing = state.isProcessingMemoryTurn;

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
              if (index >= cards.length) {
                return const SizedBox();
              }

              final card = cards[index];

              return DuelFlipCardWidget(
                card: card,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(duelControllerProvider.notifier)
                      .flipMemoryCard(card.id);
                },
                // Disable if: not user's turn, processing, already matched/flipped
                disabled:
                    !isUserTurn ||
                    isProcessing ||
                    card.isMatched ||
                    card.isFlipped,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomMessage(DuelState state) {
    final message = state.memoryTurnMessage ?? '';
    final isUserTurn = state.isUserMemoryTurn;

    Color messageColor;
    IconData icon;

    if (state.isProcessingMemoryTurn && !isUserTurn) {
      // Bot düşünüyor
      messageColor = _neonOrange;
      icon = Icons.psychology_rounded;
    } else if (isUserTurn) {
      messageColor = _neonGreen;
      icon = Icons.touch_app_rounded;
    } else {
      messageColor = _neonYellow;
      icon = Icons.hourglass_empty_rounded;
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
                  Flexible(
                    child: Text(
                      message,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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

  void _showResultDialog(
    BuildContext context,
    DuelResult result,
    DuelState state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DuelResultDialog(
        result: result,
        userScore: state.userScore,
        botScore: state.botScore,
        botName: state.botProfile?.name ?? 'Rakip',
        onPlayAgain: () {
          Navigator.pop(context);
          ref.read(duelControllerProvider.notifier).reset();
          Navigator.pop(context);
        },
        onExit: () {
          Navigator.pop(context);
          ref.read(duelControllerProvider.notifier).reset();
          Navigator.pop(context);
        },
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
                    'Düellodan çıkmak istediğine emin misin?\nMaç kaybedilmiş sayılacak.',
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
                            ref.read(duelControllerProvider.notifier).reset();
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
