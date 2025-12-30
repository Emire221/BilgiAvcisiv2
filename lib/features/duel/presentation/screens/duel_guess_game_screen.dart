import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:shake/shake.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../logic/duel_controller.dart';
import '../../domain/entities/duel_entities.dart';
import '../widgets/duel_result_dialog.dart';
import '../widgets/duel_score_header.dart';
import '../../../../../services/shake_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📱 DUEL SALLA BAKALIM - 1v1 Sayı Tahmin Oyunu
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Shake Wave temalı 1v1 tahmin düellosu
/// - Mevcut Salla Bakalım UI korundu
/// - Bot rakip ve skor sistemi eklendi
/// - Termometre ve sıcaklık göstergeleri
/// ═══════════════════════════════════════════════════════════════════════════

class DuelGuessGameScreen extends ConsumerStatefulWidget {
  const DuelGuessGameScreen({super.key});

  @override
  ConsumerState<DuelGuessGameScreen> createState() =>
      _DuelGuessGameScreenState();
}

class _DuelGuessGameScreenState extends ConsumerState<DuelGuessGameScreen>
    with TickerProviderStateMixin {
  final TextEditingController _guessController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  ShakeDetector? _shakeDetector;
  bool _resultShown = false;

  // Shake Wave Teması Renkleri
  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _accentCyan = Color(0xFF00D9FF);
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _neonRed = Color(0xFFFF3131);
  static const Color _deepPurple = Color(0xFF1A0A2E);
  static const Color _darkBg = Color(0xFF0D0D1A);

  @override
  void initState() {
    super.initState();

    // Ana sayfa ShakeService'i duraklat
    ShakeService.pause();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _initShakeDetector();
  }

  void _initShakeDetector() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (_) {
        _onShakeDetected();
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 300,
      shakeCountResetTime: 1500,
      shakeThresholdGravity: 1.8,
    );
  }

  void _onShakeDetected() {
    final text = _guessController.text.trim();
    if (text.isEmpty) {
      HapticFeedback.mediumImpact();
      return;
    }

    final guess = int.tryParse(text);
    if (guess != null) {
      HapticFeedback.heavyImpact();
      ref.read(duelControllerProvider.notifier).userGuessAnswer(guess);
      _guessController.clear();
    }
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _guessController.dispose();
    _focusNode.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    ShakeService.resume();
    super.dispose();
  }

  void _submitGuess() {
    final text = _guessController.text.trim();
    if (text.isEmpty) return;

    final guess = int.tryParse(text);
    if (guess == null) return;

    HapticFeedback.mediumImpact();
    ref.read(duelControllerProvider.notifier).userGuessAnswer(guess);
    _guessController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(duelControllerProvider);
    final controller = ref.read(duelControllerProvider.notifier);

    // Oyun bittiğinde sonuç dialogunu göster
    if (state.status == DuelStatus.finished && !_resultShown) {
      _resultShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HapticFeedback.heavyImpact();
        _showResultDialog(context, controller.getResult(), state);
      });
    }

    // Kullanıcı doğru bulduğunda konfeti
    if (state.userGuessCorrect == true) {
      _confettiController.play();
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
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Animasyonlu arka plan
            _buildAnimatedBackground(state),

            // Floating partiküller
            ..._buildFloatingParticles(),

            // Wave efekti
            _buildWaveEffect(),

            // Ana içerik
            SafeArea(
              child: Column(
                children: [
                  // Skor header - Doğal boyutunda
                  _buildScoreHeader(
                    state,
                    controller,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

                  // İçerik - Kalan tüm alan
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 12),

                                  // Soru kartı
                                  _buildQuestionCard(state, controller)
                                      .animate()
                                      .fadeIn(delay: 100.ms, duration: 500.ms)
                                      .scale(begin: const Offset(0.9, 0.9)),

                                  const SizedBox(height: 12),

                                  // Orta alan: Tahminler + Sonuç
                                  _buildMiddleSection(state).animate().fadeIn(
                                    delay: 200.ms,
                                    duration: 500.ms,
                                  ),

                                  const SizedBox(height: 12),

                                  // Input alanı (henüz tahmin yapılmadıysa)
                                  if (state.userGuess == null)
                                    _buildInputSection(state)
                                        .animate()
                                        .fadeIn(delay: 300.ms, duration: 500.ms)
                                        .slideY(begin: 0.2),

                                  // Her iki taraf da tahmin ettikten sonra sonuç göster
                                  if (state.userGuess != null &&
                                      state.botGuess != null)
                                    _buildRoundResultSection(state)
                                        .animate()
                                        .fadeIn(duration: 500.ms)
                                        .scale(begin: const Offset(0.8, 0.8)),

                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bot durumu - Doğal boyutunda
                  _buildBotStatus(
                    state,
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                ],
              ),
            ),

            // Konfeti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  _primaryOrange,
                  _accentCyan,
                  Colors.pink,
                  Colors.amber,
                  Colors.purple,
                  Colors.green,
                ],
                numberOfParticles: 30,
                gravity: 0.3,
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

  Widget _buildAnimatedBackground(DuelState state) {
    final tempColors = _getTemperatureColors(state.userTemperature);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tempColors,
        ),
      ),
    );
  }

  List<Color> _getTemperatureColors(String? temp) {
    switch (temp) {
      case 'freezing':
        return [const Color(0xFF0A1628), const Color(0xFF1E3A5F)];
      case 'cold':
        return [const Color(0xFF0D1B2A), const Color(0xFF1B4D6E)];
      case 'cool':
        return [const Color(0xFF0F2027), const Color(0xFF2C5364)];
      case 'warm':
        return [const Color(0xFF1A1A2E), const Color(0xFF7B4B2A)];
      case 'hot':
        return [const Color(0xFF1A0A2E), const Color(0xFF8B3A3A)];
      case 'boiling':
        return [const Color(0xFF2D0A0A), const Color(0xFFB94545)];
      case 'correct':
        return [const Color(0xFF0A2E1A), const Color(0xFF2D8B57)];
      default:
        return [_deepPurple, _darkBg];
    }
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(8, (index) {
      final random = math.Random(index);
      return Positioned(
        left: random.nextDouble() * MediaQuery.of(context).size.width,
        top: random.nextDouble() * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_pulseController.value * math.pi * 2 + index) * 15,
                math.cos(_pulseController.value * math.pi * 2 + index) * 15,
              ),
              child: child,
            );
          },
          child: Container(
            width: 6 + random.nextDouble() * 8,
            height: 6 + random.nextDouble() * 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (index.isEven ? _primaryOrange : _accentCyan).withValues(
                alpha: 0.15 + random.nextDouble() * 0.15,
              ),
              boxShadow: [
                BoxShadow(
                  color: (index.isEven ? _primaryOrange : _accentCyan)
                      .withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWaveEffect() {
    return Positioned(
      bottom: -50,
      left: -50,
      right: -50,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            size: Size(MediaQuery.of(context).size.width + 100, 150),
            painter: _WavePainter(
              animation: _waveController.value,
              color: _primaryOrange.withValues(alpha: 0.1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreHeader(DuelState state, DuelController controller) {
    final totalQuestions = controller.guessQuestions.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(state.currentQuestionIndex + 1, totalQuestions),

          const SizedBox(height: 12),

          // Skor header
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
    final progress = total > 0 ? current / total : 0.0;

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryOrange, _accentCyan],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: _primaryOrange.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(DuelState state, DuelController controller) {
    final question = controller.currentGuessQuestion;
    if (question == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value *
                (state.userGuessCorrect == true ? 0 : 1) *
                ((_shakeController.value * 10).toInt() % 2 == 0 ? 1 : -1),
            0,
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
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
                color: _accentCyan.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accentCyan.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Soru ikonu
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentCyan.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _accentCyan.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    FontAwesomeIcons.question,
                    color: _accentCyan,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    question.question,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // İpucu her zaman göster
                if (question.hint != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          FontAwesomeIcons.lightbulb,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '💡 ${question.hint!}',
                            style: GoogleFonts.nunito(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleSection(DuelState state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Motivasyon mesajı
          if (state.userTemperature != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getTemperatureColor(
                  state.userTemperature,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getTemperatureColor(
                    state.userTemperature,
                  ).withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                _getTemperatureMessage(state.userTemperature),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: _getTemperatureColor(
                        state.userTemperature,
                      ).withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),

          // Yön ipucu (yukarı/aşağı)
          if (state.userGuess != null &&
              state.userGuessCorrect != true &&
              state.userTemperature != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _shouldGoUp(state)
                        ? FontAwesomeIcons.arrowUp
                        : FontAwesomeIcons.arrowDown,
                    color: _shouldGoUp(state) ? _primaryOrange : _accentCyan,
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _shouldGoUp(state) ? '⬆️ Yukarı çık!' : '⬇️ Aşağı in!',
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Tahmin kartları satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Kullanıcı tahmini
              _buildPlayerGuessCard(
                title: 'Sen',
                guess: state.userGuess,
                temperature: state.userTemperature,
                isCorrect: state.userGuessCorrect,
                isUser: true,
              ),

              // Termometre
              _buildSimpleThermometer(state.userTemperature),

              // Bot tahmini
              _buildPlayerGuessCard(
                title: state.botProfile?.name ?? 'Rakip',
                guess: state.botGuess,
                temperature: state.botTemperature,
                isCorrect: state.botGuessCorrect,
                isUser: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _shouldGoUp(DuelState state) {
    final controller = ref.read(duelControllerProvider.notifier);
    final question = controller.currentGuessQuestion;
    if (question == null || state.userGuess == null) return true;
    return state.userGuess! < question.answer;
  }

  String _getTemperatureMessage(String? temp) {
    switch (temp) {
      case 'freezing':
        return 'Buz gibi soğuk! 🥶';
      case 'cold':
        return 'Soğuk... ❄️';
      case 'cool':
        return 'Biraz serin 🌬️';
      case 'warm':
        return 'Ilık, yaklaşıyorsun! 🌤️';
      case 'hot':
        return 'Sıcak! Çok yakınsın! 🔥';
      case 'boiling':
        return 'KAYNIYOR! Neredeyse buldun! 🌋';
      case 'correct':
        return 'DOĞRU! 🎉';
      default:
        return '';
    }
  }

  Widget _buildPlayerGuessCard({
    required String title,
    required int? guess,
    required String? temperature,
    required bool? isCorrect,
    required bool isUser,
  }) {
    Color borderColor = Colors.white.withValues(alpha: 0.3);
    Color bgColor = Colors.white.withValues(alpha: 0.1);

    if (isCorrect == true) {
      borderColor = _neonGreen;
      bgColor = _neonGreen.withValues(alpha: 0.2);
    } else if (guess != null && isCorrect == false) {
      borderColor = _getTemperatureColor(temperature);
      bgColor = borderColor.withValues(alpha: 0.2);
    }

    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (guess != null)
            Text(
              guess.toString(),
              style: GoogleFonts.poppins(
                color: borderColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (!isUser)
            Text(
              '?',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              '-',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (temperature != null && guess != null) ...[
            const SizedBox(height: 4),
            Text(
              _getTemperatureEmoji(temperature),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleThermometer(String? temperature) {
    final level = _getTemperatureLevel(temperature);
    final color = _getTemperatureColor(temperature);

    return SizedBox(
      width: 40,
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Arka plan
          Container(
            width: 20,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Doluluk
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            width: 16,
            height: 126 * level,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Alt balon
          Positioned(
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(String? temp) {
    switch (temp) {
      case 'freezing':
        return const Color(0xFF0D47A1);
      case 'cold':
        return const Color(0xFF1565C0);
      case 'cool':
        return const Color(0xFF42A5F5);
      case 'warm':
        return const Color(0xFFFFB300);
      case 'hot':
        return const Color(0xFFFF6F00);
      case 'boiling':
        return const Color(0xFFE53935);
      case 'correct':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  double _getTemperatureLevel(String? temp) {
    switch (temp) {
      case 'freezing':
        return 0.1;
      case 'cold':
        return 0.25;
      case 'cool':
        return 0.4;
      case 'warm':
        return 0.55;
      case 'hot':
        return 0.75;
      case 'boiling':
        return 0.9;
      case 'correct':
        return 1.0;
      default:
        return 0.3;
    }
  }

  String _getTemperatureEmoji(String? temp) {
    switch (temp) {
      case 'freezing':
        return '🥶';
      case 'cold':
        return '❄️';
      case 'cool':
        return '🌬️';
      case 'warm':
        return '🌤️';
      case 'hot':
        return '🔥';
      case 'boiling':
        return '🌋';
      case 'correct':
        return '🎉';
      default:
        return '';
    }
  }

  Widget _buildInputSection(DuelState state) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input alanı
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _primaryOrange.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _guessController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tahminin?',
                          hintStyle: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        onSubmitted: (_) => _submitGuess(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: _submitGuess,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primaryOrange, Color(0xFFFF8F5C)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryOrange.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Tahmin Et',
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

          const SizedBox(height: 16),

          // Salla ipucu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryOrange.withValues(alpha: 0.2),
                  _accentCyan.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                      FontAwesomeIcons.mobileScreenButton,
                      color: _primaryOrange,
                      size: 18,
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shake(duration: 800.ms, hz: 3),
                const SizedBox(width: 10),
                Text(
                  'Telefonu sallayarak tahmin gönder!',
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tur sonunda kazananı ve uzaklıkları gösteren kart
  Widget _buildRoundResultSection(DuelState state) {
    final controller = ref.read(duelControllerProvider.notifier);
    final question = controller.currentGuessQuestion;
    if (question == null) return const SizedBox.shrink();

    final userGuess = state.userGuess ?? 0;
    final botGuess = state.botGuess ?? 0;
    final correctAnswer = question.answer;

    final userDistance = (userGuess - correctAnswer).abs();
    final botDistance = (botGuess - correctAnswer).abs();

    final userWon = state.userGuessCorrect == true;
    final botWon = state.botGuessCorrect == true;
    final isDraw = !userWon && !botWon;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (userWon ? _neonGreen : (isDraw ? _accentCyan : _neonRed))
                        .withValues(alpha: 0.3),
                    (userWon ? _neonGreen : (isDraw ? _accentCyan : _neonRed))
                        .withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: userWon
                      ? _neonGreen
                      : (isDraw ? _accentCyan : _neonRed),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kazanan ikonu ve mesaj - tek satırda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        userWon
                            ? FontAwesomeIcons.trophy
                            : (isDraw
                                  ? FontAwesomeIcons.handshake
                                  : FontAwesomeIcons.faceSadTear),
                        color: userWon
                            ? _neonGreen
                            : (isDraw ? _accentCyan : _neonRed),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        userWon
                            ? 'KAZANDIN! 🎉'
                            : (isDraw ? 'BERABERE! 🤝' : 'Rakip Kazandı'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Doğru cevap
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _neonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _neonGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Doğru Cevap: ${question.answer}',
                      style: GoogleFonts.poppins(
                        color: _neonGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Uzaklık karşılaştırması
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Kullanıcı uzaklığı
                      _buildDistanceChip(
                        label: 'Senin tahminin',
                        guess: userGuess,
                        distance: userDistance,
                        isWinner: userWon,
                      ),

                      // VS
                      Text(
                        'vs',
                        style: GoogleFonts.orbitron(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),

                      // Bot uzaklığı
                      _buildDistanceChip(
                        label: state.botProfile?.name ?? 'Rakip',
                        guess: botGuess,
                        distance: botDistance,
                        isWinner: botWon,
                      ),
                    ],
                  ),

                  // Bilgi
                  if (question.info != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      question.info!,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceChip({
    required String label,
    required int guess,
    required int distance,
    required bool isWinner,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isWinner ? _neonGreen : Colors.white).withValues(
              alpha: 0.2,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isWinner
                  ? _neonGreen
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                guess.toString(),
                style: GoogleFonts.poppins(
                  color: isWinner ? _neonGreen : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$distance uzakta',
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        if (isWinner) const Text('👑', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBotStatus(DuelState state) {
    return AnimatedBuilder(
      animation: _pulseController,
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
                  _accentCyan.withValues(alpha: 0.2),
                  _primaryOrange.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentCyan.withValues(alpha: 0.4)),
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
                    valueColor: AlwaysStoppedAnimation<Color>(_accentCyan),
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
          .shimmer(
            duration: 1500.ms,
            color: _accentCyan.withValues(alpha: 0.3),
          );
    }

    if (state.botGuess != null) {
      final isCorrect = state.botGuessCorrect == true;
      return Container(
        key: ValueKey('answered_$isCorrect'),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (isCorrect
                      ? _neonGreen
                      : _getTemperatureColor(state.botTemperature))
                  .withValues(alpha: 0.2),
              (isCorrect
                      ? _neonGreen
                      : _getTemperatureColor(state.botTemperature))
                  .withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                (isCorrect
                        ? _neonGreen
                        : _getTemperatureColor(state.botTemperature))
                    .withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getTemperatureEmoji(state.botTemperature),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Text(
              '${state.botProfile?.name ?? "Rakip"}: ${state.botGuess}',
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
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

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
                    _darkBg.withValues(alpha: 0.95),
                    _deepPurple.withValues(alpha: 0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _neonRed.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _neonRed.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: _neonRed,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Düellodan Çık',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Düellodan çıkmak istediğine emin misin?\nBu düello kaybedilmiş sayılacak.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
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
                                colors: [_neonRed, const Color(0xFFFF5555)],
                              ),
                              borderRadius: BorderRadius.circular(14),
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
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onExit: () {
          ref.read(duelControllerProvider.notifier).reset();
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WAVE PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  _WavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (var x = 0.0; x < size.width; x++) {
      final y =
          math.sin((x / size.width * 4 * math.pi) + (animation * 2 * math.pi)) *
              20 +
          size.height / 2;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      animation != oldDelegate.animation;
}
