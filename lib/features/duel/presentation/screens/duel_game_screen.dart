import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/duel_controller.dart';
import '../../domain/entities/duel_entities.dart';
import '../widgets/duel_score_header.dart';
import '../widgets/duel_test_question.dart';
import '../widgets/duel_fill_blank_question.dart';
import '../widgets/duel_result_dialog.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ⚔️ NEON ARENA BATTLE - Düello Oyun Ekranı
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Cyberpunk Arena temalı 1v1 savaş deneyimi
/// - Neon ışık efektleri ve glow animasyonları
/// - Glassmorphism soru kartları
/// - Animasyonlu bot durumu
/// - Epic exit/result dialogs
/// ═══════════════════════════════════════════════════════════════════════════

class DuelGameScreen extends ConsumerStatefulWidget {
  const DuelGameScreen({super.key});

  @override
  ConsumerState<DuelGameScreen> createState() => _DuelGameScreenState();
}

class _DuelGameScreenState extends ConsumerState<DuelGameScreen>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _neonPink = Color(0xFFFF0080);
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _neonRed = Color(0xFFFF3131);
  static const Color _darkBg = Color(0xFF0D0D1A);
  static const Color _darkBg2 = Color(0xFF1A1A2E);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        backgroundColor: _darkBg,
        body: Stack(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // ANIMATED BACKGROUND
            // ═══════════════════════════════════════════════════════════════
            _buildAnimatedBackground(size),

            // ═══════════════════════════════════════════════════════════════
            // MAIN CONTENT
            // ═══════════════════════════════════════════════════════════════
            SafeArea(
              child: Column(
                children: [
                  // Score Header
                  _buildScoreHeader(
                    state,
                    controller,
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),

                  // Question Area
                  Expanded(
                    child: _buildQuestionCard(state, controller)
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                  ),

                  // Bot Status
                  _buildBotStatus(
                    state,
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
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
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [
                _neonPurple.withValues(alpha: 0.1 * _pulseAnimation.value),
                _darkBg2,
                _darkBg,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _GridPainter(color: _neonCyan.withValues(alpha: 0.05)),
          ),
        );
      },
    );
  }

  Widget _buildScoreHeader(DuelState state, DuelController controller) {
    final totalQuestions = state.gameType == DuelGameType.test
        ? controller.testQuestions.length
        : controller.fillBlankQuestions.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(state.currentQuestionIndex + 1, totalQuestions),

          const SizedBox(height: 12),

          // Score header with existing widget
          DuelScoreHeader(
            userScore: state.userScore,
            botScore: state.botScore,
            botProfile: state.botProfile,
            currentQuestion: state.currentQuestionIndex + 1,
            totalQuestions: totalQuestions,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int current, int total) {
    final progress = current / total;

    // ✅ Optimize edildi: Gereksiz Stack kaldırıldı
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_neonCyan, _neonPurple]),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: _neonCyan.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(DuelState state, DuelController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _neonCyan.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _neonPurple.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: state.gameType == DuelGameType.test
                ? _buildTestQuestion(state, controller)
                : _buildFillBlankQuestion(state, controller),
          ),
        ),
      ),
    );
  }

  Widget _buildTestQuestion(DuelState state, DuelController controller) {
    final question = controller.currentTestQuestion;
    if (question == null) {
      return _buildNoQuestionPlaceholder();
    }

    return DuelTestQuestion(
      question: question,
      userSelectedIndex: state.userSelectedIndex,
      botSelectedIndex: state.botSelectedIndex,
      isAnswered: state.userAnsweredCorrectly != null,
      onAnswerSelected: (index) {
        HapticFeedback.selectionClick();
        final isCorrect = index == question.correctIndex;
        controller.userAnswer(index, isCorrect);

        // Feedback haptic
        Future.delayed(const Duration(milliseconds: 200), () {
          if (isCorrect) {
            HapticFeedback.lightImpact();
          } else {
            HapticFeedback.heavyImpact();
          }
        });
      },
    );
  }

  Widget _buildFillBlankQuestion(DuelState state, DuelController controller) {
    final question = controller.currentFillBlankQuestion;
    if (question == null) {
      return _buildNoQuestionPlaceholder();
    }

    return DuelFillBlankQuestionWidget(
      question: question,
      userSelectedIndex: state.userSelectedIndex,
      botSelectedIndex: state.botSelectedIndex,
      isAnswered: state.userAnsweredCorrectly != null,
      onAnswerSelected: (index) {
        HapticFeedback.selectionClick();
        final isCorrect = question.options[index] == question.answer;
        controller.userAnswer(index, isCorrect);

        // Feedback haptic
        Future.delayed(const Duration(milliseconds: 200), () {
          if (isCorrect) {
            HapticFeedback.lightImpact();
          } else {
            HapticFeedback.heavyImpact();
          }
        });
      },
    );
  }

  Widget _buildNoQuestionPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_rounded,
            color: _neonCyan.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Soru yükleniyor...',
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotStatus(DuelState state) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBotStatusContent(state),
          ),
        );
      },
    );
  }

  Widget _buildBotStatusContent(DuelState state) {
    if (state.isBotAnswering) {
      return Container(
            key: const ValueKey('thinking'),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _neonCyan.withValues(alpha: 0.2),
                  _neonPurple.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _neonCyan.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_neonCyan),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${state.botProfile?.name ?? "Rakip"} düşünüyor...',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1500.ms, color: _neonCyan.withValues(alpha: 0.3));
    }

    if (state.botAnsweredCorrectly != null) {
      final isCorrect = state.botAnsweredCorrectly!;
      return Container(
        key: ValueKey('answered_$isCorrect'),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (isCorrect ? _neonGreen : _neonRed).withValues(alpha: 0.2),
              (isCorrect ? _neonGreen : _neonRed).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isCorrect ? _neonGreen : _neonRed).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: (isCorrect ? _neonGreen : _neonRed).withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isCorrect ? _neonGreen : _neonRed,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              '${state.botProfile?.name ?? "Rakip"} ${isCorrect ? "doğru" : "yanlış"} cevapladı',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
    }

    return const SizedBox.shrink(key: ValueKey('empty'));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS (PRESERVED LOGIC)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showExitConfirmation(BuildContext context) {
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
                      Icons.warning_amber_rounded,
                      color: _neonPink,
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Düellodan Çık',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Content
                  Text(
                    'Düellodan çıkmak istediğine emin misin?\nBu düello kaybedilmiş sayılacak.',
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
                            Navigator.pop(context); // Dialog'u kapat
                            Navigator.pop(context); // Ekrandan çık
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_neonPink, _neonRed],
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
          ref.read(duelControllerProvider.notifier).reset();
          Navigator.pop(context); // Dialog'u kapat
          Navigator.pop(context); // Oyun ekranından çık
        },
        onExit: () {
          ref.read(duelControllerProvider.notifier).reset();
          Navigator.pop(context); // Dialog'u kapat
          Navigator.pop(context); // Oyun ekranından çık
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GRID PAINTER FOR BACKGROUND
// ═══════════════════════════════════════════════════════════════════════════

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 40.0;

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
