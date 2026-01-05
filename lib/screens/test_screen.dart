import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../features/test/providers/test_provider.dart';
import '../features/test/models/test_state.dart';
import '../models/question_model.dart';
import 'result_screen.dart';

/// 🎮 Cyber Quiz Arena - Test Ekranı
/// Neon vurgulu, koyu modlu yarışma ekranı
class TestScreen extends ConsumerStatefulWidget {
  final String? topicId;
  final String? topicName;
  final String? testId;
  final Map<String, dynamic>? testData;

  const TestScreen({
    super.key,
    this.topicId,
    this.topicName,
    this.testId,
    this.testData,
  });

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen>
    with TickerProviderStateMixin {
  // Seçilen cevap için animasyon
  int? _selectedOptionIndex;
  bool _isAnswering = false;

  // Animasyon controller'ları
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Pulse animasyonu (timer için)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Glow animasyonu
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Test başlat - MANTIK KORUNUYOR + testId eklendi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.testData != null) {
        final questions = widget.testData!['sorular'] as List<dynamic>? ?? [];
        final questionModels = questions
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList();

        // testId'yi widget'tan al veya testData'dan çek
        final testId = widget.testId ?? widget.testData!['testID'] as String?;

        ref
            .read(testControllerProvider.notifier)
            .initializeTest(questionModels, testId: testId);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testControllerProvider);
    final controller = ref.read(testControllerProvider.notifier);

    // Test tamamlandığında result ekranına git - MANTIK KORUNUYOR
    ref.listen<bool>(isTestCompletedProvider, (previous, isCompleted) {
      if (isCompleted && mounted) {
        final currentState = ref.read(testControllerProvider);
        _navigateToResult(currentState);
      }
    });

    // Timer pulse kontrolü
    if (testState.timeLeft <= 10 && testState.timeLeft > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // Loading durumu
    if (testState.status == TestStatus.loading || testState.questions.isEmpty) {
      return _buildLoadingScreen();
    }

    final currentQuestion = testState.currentQuestion;
    if (currentQuestion == null) {
      return _buildErrorScreen();
    }

    return PopScope(
      canPop: false, // Android geri tuşunu devre dışı bırak - MANTIK KORUNUYOR
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF000428), Color(0xFF001f54), Color(0xFF004e92)],
            ),
          ),
          child: Stack(
            children: [
              // Animasyonlu arka plan parçacıkları
              ..._buildBackgroundParticles(),

              // Ana içerik
              SafeArea(
                child: Column(
                  children: [
                    // HUD - Heads Up Display
                    _buildHUD(testState),

                    // Soru ve Cevaplar
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slideIn = Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation);

                          final slideOut = Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation);

                          // Yeni widget için slideIn, eski için slideOut
                          return SlideTransition(
                            position:
                                animation.status == AnimationStatus.reverse
                                ? slideOut
                                : slideIn,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: _buildQuestionContent(
                          key: ValueKey(testState.currentQuestionIndex),
                          question: currentQuestion,
                          controller: controller,
                          questionIndex: testState.currentQuestionIndex,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Arka plan parçacıkları
  List<Widget> _buildBackgroundParticles() {
    return List.generate(15, (index) {
      final random = math.Random(index);
      final size = 4.0 + random.nextDouble() * 6;
      final left = random.nextDouble() * 400;
      final top = random.nextDouble() * 800;
      final duration = 3000 + random.nextInt(4000);

      return Positioned(
            left: left,
            top: top,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyan.withValues(
                      alpha: 0.1 + (_glowController.value * 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withValues(
                          alpha: 0.3 * _glowController.value,
                        ),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
          )
          .animate(
            onPlay: (c) => c.repeat(reverse: true),
            delay: Duration(milliseconds: index * 200),
          )
          .moveY(
            begin: 0,
            end: -30,
            duration: Duration(milliseconds: duration),
          );
    });
  }

  /// HUD - Heads Up Display
  Widget _buildHUD(TestState testState) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: _GlassContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Soru Sayacı (sol tarafta)
              _buildQuestionCounter(
                testState.currentQuestionIndex + 1,
                testState.questions.length,
              ),

              const Spacer(),

              // Timer
              _buildTimer(testState.timeLeft),

              const Spacer(),

              // Boş alan (simetri için)
              const SizedBox(width: 60),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0);
  }





  /// Timer widget'ı
  Widget _buildTimer(int timeLeft) {
    final totalTime = 60; // Toplam süre
    final percent = timeLeft / totalTime;
    final isLowTime = timeLeft <= 10;

    // Renk geçişi
    Color timerColor;
    if (percent > 0.5) {
      timerColor = Colors.greenAccent;
    } else if (percent > 0.25) {
      timerColor = Colors.amber;
    } else {
      timerColor = Colors.redAccent;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isLowTime ? 1.0 + (_pulseController.value * 0.1) : 1.0;

        return Transform.scale(
          scale: scale,
          child: CircularPercentIndicator(
            radius: 35,
            lineWidth: 6,
            percent: percent.clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.clock, color: timerColor, size: 14),
                const SizedBox(height: 2),
                Text(
                  '$timeLeft',
                  style: TextStyle(
                    color: timerColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            progressColor: timerColor,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            circularStrokeCap: CircularStrokeCap.round,
            animation: false,
          ),
        );
      },
    );
  }

  /// Soru sayacı
  Widget _buildQuestionCounter(int current, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.cyan.withValues(alpha: 0.3),
            Colors.blue.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(FontAwesomeIcons.listOl, color: Colors.cyan, size: 14),
          const SizedBox(width: 8),
          Text(
            '$current / $total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Soru içeriği
  Widget _buildQuestionContent({
    required Key key,
    required QuestionModel question,
    required dynamic controller,
    required int questionIndex,
  }) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          // Hologram Soru Kartı
          _HoloQuestionCard(
                questionText: question.soruMetni,
                questionNumber: questionIndex + 1,
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 32),

          // Cevap Seçenekleri
          ...question.secenekler.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final label = String.fromCharCode(65 + index);

            return _GameOptionButton(
                  label: label,
                  optionText: option,
                  index: index,
                  isSelected: _selectedOptionIndex == index,
                  isDisabled: _isAnswering,
                  onTap: () => _handleAnswer(option, index, controller),
                )
                .animate(delay: Duration(milliseconds: 100 + (index * 100)))
                .fadeIn()
                .slideY(begin: 0.3, end: 0);
          }),
        ],
      ),
    );
  }

  /// Cevap seçme işlemi
  Future<void> _handleAnswer(
    String answer,
    int index,
    dynamic controller,
  ) async {
    if (_isAnswering) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _selectedOptionIndex = index;
      _isAnswering = true;
    });

    // Kısa bir gecikme ile seçimi göster
    await Future.delayed(const Duration(milliseconds: 400));

    // Cevabı değerlendir ve sonuç bilgisini al
    final result = controller.answerQuestion(answer);

    if (!mounted) return;

    // 🎯 POPUP DIALOG GÖSTER
    await showDialog<void>(
      context: context,
      barrierDismissible: true, // Kullanıcı isteğine göre kapatılabilir
      barrierColor: Colors.black87,
      builder: (dialogContext) => _AnswerResultDialog(
        isCorrect: result.isCorrect,
        correctAnswer: result.correctAnswer,
        aciklama: result.aciklama,
        onContinue: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );

    // Popup kapandıktan sonra sonraki soruya geç
    if (mounted) {
      await controller.proceedToNextOrFinish();

      setState(() {
        _selectedOptionIndex = null;
        _isAnswering = false;
      });
    }
  }





  /// Loading ekranı
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000428), Color(0xFF004e92)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Neon loading indicator
              SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.cyan.withValues(alpha: 0.8),
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1500.ms, color: Colors.cyan),
              const SizedBox(height: 24),
              const Text(
                    'Arena Hazırlanıyor...',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn()
                  .then()
                  .fadeOut(duration: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }

  /// Hata ekranı
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000428), Color(0xFF004e92)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.circleExclamation,
                color: Colors.amber,
                size: 60,
              ),
              const SizedBox(height: 24),
              const Text(
                'Soru Bulunamadı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Geri Dön',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Result ekranına geç - MANTIK KORUNUYOR
  void _navigateToResult(TestState state) {
    final answeredQuestions = <Map<String, dynamic>>[];
    state.userAnswers.forEach((index, userAnswer) {
      if (index < state.questions.length) {
        answeredQuestions.add({
          'question': state.questions[index].toJson(),
          'userAnswer': userAnswer,
          'questionNumber': index + 1,
        });
      }
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: state.score,
          correctCount: state.correctCount,
          wrongCount: state.wrongCount,
          topicId: widget.topicId ?? '',
          topicName: widget.topicName ?? '',
          testId: widget.testId ?? widget.testData?['testID'] as String?,
          answeredQuestions: answeredQuestions,
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM WIDGETS
// ============================================================================

/// Glass Container - Cam efektli konteyner
class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Hologram Soru Kartı
class _HoloQuestionCard extends StatelessWidget {
  final String questionText;
  final int questionNumber;

  const _HoloQuestionCard({
    required this.questionText,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.withValues(alpha: 0.15),
            Colors.blue.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soru numarası badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.cyan, Colors.blue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(
                  FontAwesomeIcons.question,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 6),
                Text(
                  'Soru $questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Soru metni
          Text(
            questionText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Game Option Button - Oyun tarzı seçenek butonu
class _GameOptionButton extends StatefulWidget {
  final String label;
  final String optionText;
  final int index;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _GameOptionButton({
    required this.label,
    required this.optionText,
    required this.index,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  State<_GameOptionButton> createState() => _GameOptionButtonState();
}

class _GameOptionButtonState extends State<_GameOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  // Her şık için farklı renk
  static const List<List<Color>> _optionColors = [
    [Color(0xFF00D9FF), Color(0xFF00A8CC)], // A - Cyan
    [Color(0xFFFF6B6B), Color(0xFFEE5A5A)], // B - Red
    [Color(0xFF4ECDC4), Color(0xFF3CB4AC)], // C - Teal
    [Color(0xFFFFE66D), Color(0xFFF4D35E)], // D - Yellow
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _optionColors[widget.index % _optionColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTapDown: widget.isDisabled
            ? null
            : (_) {
                setState(() => _isPressed = true);
                _controller.forward();
              },
        onTapUp: widget.isDisabled
            ? null
            : (_) {
                setState(() => _isPressed = false);
                _controller.reverse();
              },
        onTapCancel: widget.isDisabled
            ? null
            : () {
                setState(() => _isPressed = false);
                _controller.reverse();
              },
        onTap: widget.isDisabled ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: widget.isSelected
                        ? [
                            Colors.amber.withValues(alpha: 0.4),
                            Colors.orange.withValues(alpha: 0.3),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.04),
                          ],
                  ),
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.amber
                        : _isPressed
                        ? colors[0]
                        : Colors.white.withValues(alpha: 0.2),
                    width: widget.isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ]
                      : _isPressed
                      ? [
                          BoxShadow(
                            color: colors[0].withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Label Circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isSelected
                              ? [Colors.amber, Colors.orange]
                              : colors,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (widget.isSelected ? Colors.amber : colors[0])
                                    .withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Option Text
                    Expanded(
                      child: Text(
                        widget.optionText,
                        style: TextStyle(
                          color: widget.isSelected
                              ? Colors.amber
                              : Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: widget.isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),

                    // Selected indicator
                    if (widget.isSelected)
                      Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          )
                          .animate()
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                          )
                          .fadeIn(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// ANSWER RESULT DIALOG - Animasyonlu Cevap Sonucu Popup'ı
// ============================================================================

/// 🎯 Cevap Sonrası Açıklamalı Popup Dialog
/// Doğru/Yanlış bilgisi, açıklama ve sonraki soruya geçiş butonu içerir.
class _AnswerResultDialog extends StatefulWidget {
  final bool isCorrect;
  final String correctAnswer;
  final String? aciklama;
  final VoidCallback onContinue;

  const _AnswerResultDialog({
    required this.isCorrect,
    required this.correctAnswer,
    this.aciklama,
    required this.onContinue,
  });

  @override
  State<_AnswerResultDialog> createState() => _AnswerResultDialogState();
}

class _AnswerResultDialogState extends State<_AnswerResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Haptic feedback
    if (widget.isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.isCorrect;
    final primaryColor = isCorrect ? Colors.greenAccent : Colors.redAccent;
    final gradientColors = isCorrect
        ? [const Color(0xFF00C853), const Color(0xFF00E676)]
        : [const Color(0xFFFF1744), const Color(0xFFFF5252)];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: 400,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
                  ),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.6),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ═══ HEADER - Sonuç Bildirimi ═══
                        _buildHeader(isCorrect, primaryColor, gradientColors),

                        // ═══ CONTENT ═══
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Yanlış cevap ise doğru cevabı göster
                                if (!isCorrect) ...[
                                  _buildCorrectAnswerSection(),
                                  const SizedBox(height: 20),
                                ],

                                // Açıklama
                                if (widget.aciklama != null &&
                                    widget.aciklama!.isNotEmpty)
                                  _buildExplanationSection(primaryColor),
                              ],
                            ),
                          ),
                        ),

                        // ═══ FOOTER - Devam Butonu ═══
                        _buildContinueButton(gradientColors, primaryColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Header - Doğru/Yanlış sonuç bildirimi
  Widget _buildHeader(
    bool isCorrect,
    Color primaryColor,
    List<Color> gradientColors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withValues(alpha: 0.25),
            gradientColors[1].withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Column(
        children: [
          // İkon
          Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: FaIcon(
                    isCorrect ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              )
              .animate(onPlay: (c) => c.forward())
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 16),

          // Başlık
          Text(
            isCorrect ? 'Doğru Cevap!' : 'Yanlış Cevap',
            style: TextStyle(
              color: primaryColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

          if (isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Harika! Devam et! 🎉',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ],
      ),
    );
  }

  /// Doğru cevap gösterimi (yanlış cevap durumunda)
  Widget _buildCorrectAnswerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.greenAccent.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.greenAccent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.lightbulb,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doğru Cevap',
                  style: TextStyle(
                    color: Colors.greenAccent.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.correctAnswer,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0);
  }

  /// Açıklama bölümü
  Widget _buildExplanationSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.circleInfo,
              color: primaryColor.withValues(alpha: 0.8),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Açıklama',
              style: TextStyle(
                color: primaryColor.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Text(
            widget.aciklama!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0);
  }

  /// Devam butonu
  Widget _buildContinueButton(List<Color> gradientColors, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onContinue();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sıradaki Soruya Geç',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 12),
                const FaIcon(
                  FontAwesomeIcons.arrowRight,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
      ),
    );
  }
}
