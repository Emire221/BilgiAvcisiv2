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
import '../controllers/guess_controller.dart';
import '../../domain/entities/temperature.dart';
import '../../domain/entities/guess_level.dart';
import '../widgets/thermometer_widget.dart';
import 'guess_result_screen.dart';

/// Salla Bakalım Oyun Ekranı - Shake Wave Teması
class GuessGameScreen extends ConsumerStatefulWidget {
  final GuessLevel? level;
  final int? difficulty;

  const GuessGameScreen({super.key, this.level, this.difficulty});

  @override
  ConsumerState<GuessGameScreen> createState() => _GuessGameScreenState();
}

class _GuessGameScreenState extends ConsumerState<GuessGameScreen>
    with TickerProviderStateMixin {
  final TextEditingController _guessController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  ShakeDetector? _shakeDetector;
  bool _showIntro = true;
  bool _showHint = false;

  // Shake Wave Teması Renkleri
  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _accentCyan = Color(0xFF00D9FF);
  static const Color _deepPurple = Color(0xFF1A0A2E);
  static const Color _darkBg = Color(0xFF0D0D1A);

  @override
  void initState() {
    super.initState();

    // Konfeti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Shake animasyonu
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Pulse animasyonu
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Wave animasyonu
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Shake detection başlat
    _initShakeDetector();

    // Intro overlay'i kapat
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showIntro = false);
      }
    });

    // Oyunu başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(guessControllerProvider.notifier)
          .startGame(level: widget.level, difficulty: widget.difficulty);
    });
  }

  void _initShakeDetector() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (_) {
        _onShakeDetected();
      },
      minimumShakeCount: 1, // 2'den 1'e düşürüldü - tek sallama yeterli
      shakeSlopTimeMS: 300, // 500'den 300'e - daha hızlı tepki
      shakeCountResetTime: 1500, // 2000'den 1500'e
      shakeThresholdGravity: 1.8, // 2.5'ten 1.8'e - daha hassas algılama
    );
  }

  void _onShakeDetected() {
    // Eğer text input boş değilse tahmin gönder
    final text = _guessController.text.trim();
    if (text.isEmpty) {
      // Boşsa sadece haptic feedback ver
      HapticFeedback.mediumImpact();
      return;
    }

    // Giriş değerini kontrol et ve gönder
    final guess = int.tryParse(text);
    if (guess != null) {
      HapticFeedback.heavyImpact();
      ref.read(guessControllerProvider.notifier).submitGuess(guess);
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
    super.dispose();
  }

  void _submitGuess() {
    final text = _guessController.text.trim();
    if (text.isEmpty) return;

    final guess = int.tryParse(text);
    if (guess == null) return;

    HapticFeedback.mediumImpact();
    ref.read(guessControllerProvider.notifier).submitGuess(guess);
    _guessController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guessControllerProvider);

    // Durum değişikliklerini dinle
    ref.listen<GuessState>(guessControllerProvider, (previous, next) {
      // Doğru cevap
      if (next.isCorrect && !(previous?.isCorrect ?? false)) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }
      // Yanlış cevap - shake ve haptic
      else if (next.currentGuess != null &&
          !next.isCorrect &&
          previous?.currentGuess != next.currentGuess) {
        _shakeController.forward().then((_) => _shakeController.reset());
        _triggerHaptic(next.temperature);
      }
      // Oyun bitti
      if (next.isGameOver && !(previous?.isGameOver ?? false)) {
        _navigateToResult(next);
      }
    });

    if (state.isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_deepPurple, _darkBg],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                      FontAwesomeIcons.mobileScreenButton,
                      color: _primaryOrange,
                      size: 48,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shake(duration: 600.ms, hz: 3)
                    .then()
                    .shimmer(color: _accentCyan.withValues(alpha: 0.3)),
                const SizedBox(height: 24),
                Text(
                  'Yükleniyor...',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_deepPurple, _darkBg],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.circleExclamation,
                  color: _primaryOrange,
                  size: 64,
                ).animate().shake(duration: 500.ms),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.error!,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                _buildNeonButton(
                  text: 'Geri Dön',
                  icon: FontAwesomeIcons.arrowLeft,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: true, // Oyun sırasında geri tuşu aktif
      child: GestureDetector(
        onTap: () {
          // Ekrana tıklayınca klavyeyi kapat
          FocusScope.of(context).unfocus();
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

            // Ana içerik (📱 UX Faz 3.3: No-Scroll Layout)
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final isSmallScreen = availableHeight < 600;

                  return Column(
                    children: [
                      // Üst bar - Sabit
                      _buildTopBar(state)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.3, end: 0),

                      // İçerik - Esnek, scroll yok
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                          child: Column(
                            children: [
                              // Soru alanı - Daha fazla yer
                              Flexible(
                                flex: 35,
                                child: _buildQuestionCard(state)
                                    .animate()
                                    .fadeIn(delay: 100.ms, duration: 500.ms)
                                    .scale(begin: const Offset(0.9, 0.9)),
                              ),

                              // İpucu Butonu - Soru kartının DIŞINDA (Kompakt)
                              if (!state.isCorrect && state.attempts > 2 && state.currentQuestion?.hint != null)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _showHint = true);
                                      // 3 saniye sonra otomatik kapat
                                      Future.delayed(const Duration(seconds: 3), () {
                                        if (mounted) setState(() => _showHint = false);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.amber.withValues(alpha: 0.3),
                                            Colors.orange.withValues(alpha: 0.2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(FontAwesomeIcons.lightbulb, color: Colors.amber, size: 14),
                                          const SizedBox(width: 8),
                                          Text(
                                            'İpucu Göster 💡',
                                            style: GoogleFonts.nunito(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn(duration: 400.ms),
                                ),

                              SizedBox(height: isSmallScreen ? 4 : 8),

                              // Orta alan: Maskot + Termometre - Kompakt
                              Expanded(
                                flex: state.attempts > 2 && state.currentQuestion?.hint != null ? 25 : 30,
                                child: _buildMiddleSection(state)
                                    .animate()
                                    .fadeIn(delay: 200.ms, duration: 500.ms),
                              ),

                              SizedBox(height: isSmallScreen ? 8 : 12),

                              // Input alanı - Sabit yükseklik
                              if (!state.isCorrect)
                                Flexible(
                                  flex: 35,
                                  child: _buildInputSection(state)
                                      .animate()
                                      .fadeIn(delay: 300.ms, duration: 500.ms)
                                      .slideY(begin: 0.2, end: 0),
                                ),

                              // Doğru cevap olduğunda input gizlenir, overlay gösterilir
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
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

            // Intro overlay
            if (_showIntro)
              AnimatedOpacity(
                opacity: _showIntro ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: _darkBg,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                              FontAwesomeIcons.mobileScreenButton,
                              color: _primaryOrange,
                              size: 64,
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .shake(duration: 500.ms, hz: 4),
                        const SizedBox(height: 16),
                        Text(
                          'SALLA!',
                          style: GoogleFonts.poppins(
                            color: _primaryOrange,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ).animate().fadeIn().then().shimmer(color: _accentCyan),
                      ],
                    ),
                  ),
                ),
              ),

            // 🎉 Doğru Cevap Popup Overlay
            if (state.isCorrect)
              _buildCorrectAnswerSection(state),

            // İpucu Popup Overlay
            if (_showHint)
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(guessControllerProvider);
                  final hint = state.currentQuestion?.hint;
                  if (hint == null) return const SizedBox.shrink();
                  
                  return Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 32),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.amber.withValues(alpha: 0.4),
                                    Colors.orange.withValues(alpha: 0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // İkon
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.lightbulb,
                                      color: Colors.amber,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Başlık
                                  Text(
                                    '💡 İPUCU',
                                    style: GoogleFonts.poppins(
                                      color: Colors.amber,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // İpucu metni
                                  Text(
                                    hint,
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms);
                },
              ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(GuessState state) {
    // Sıcaklık değerine göre renk geçişi
    final tempColors = _getTemperatureColors(state.temperature);

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

  List<Color> _getTemperatureColors(Temperature temp) {
    switch (temp) {
      case Temperature.freezing:
        return [const Color(0xFF0A1628), const Color(0xFF1E3A5F)];
      case Temperature.cold:
        return [const Color(0xFF0D1B2A), const Color(0xFF1B4D6E)];
      case Temperature.cool:
        return [const Color(0xFF0F2027), const Color(0xFF2C5364)];
      case Temperature.warm:
        return [const Color(0xFF1A1A2E), const Color(0xFF7B4B2A)];
      case Temperature.hot:
        return [const Color(0xFF1A0A2E), const Color(0xFF8B3A3A)];
      case Temperature.boiling:
        return [const Color(0xFF2D0A0A), const Color(0xFFB94545)];
      case Temperature.correct:
        return [const Color(0xFF0A2E1A), const Color(0xFF2D8B57)];
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

  Widget _buildTopBar(GuessState state) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              // Çıkış butonu
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.arrowLeft,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              const Spacer(),

              // Soru sayacı
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryOrange.withValues(alpha: 0.3),
                      _accentCyan.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _primaryOrange.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Soru ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),

              // Skor
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      FontAwesomeIcons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.totalScore}',
                      style: GoogleFonts.poppins(
                        color: Colors.amber,
                        fontSize: 16,
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
    );
  }

  Widget _buildQuestionCard(GuessState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value *
                (state.isCorrect ? 0 : 1) *
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
            padding: const EdgeInsets.all(24),
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Soru ikonu
                  Container(
                    padding: const EdgeInsets.all(12),
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
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleSection(GuessState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Feedback alanı
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Feedback mesajı
              if (state.feedbackMessage.isNotEmpty) ...[
                Text(
                  state.feedbackMessage,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: state.temperature.color.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!state.isCorrect && state.currentGuess != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.goUp
                              ? FontAwesomeIcons.arrowUp
                              : FontAwesomeIcons.arrowDown,
                          color: state.goUp ? _primaryOrange : _accentCyan,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.temperature.directionHint(state.goUp),
                          style: GoogleFonts.nunito(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              // Deneme sayısı
              if (state.attempts > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.attempts} deneme',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Termometre
        ThermometerWidget(temperature: state.temperature, height: 180),
      ],
    );
  }

  Widget _buildTemperatureIcon(Temperature temp) {
    IconData icon;
    Color color;

    switch (temp) {
      case Temperature.freezing:
        icon = FontAwesomeIcons.snowflake;
        color = const Color(0xFF4FC3F7);
      case Temperature.cold:
        icon = FontAwesomeIcons.temperatureLow;
        color = const Color(0xFF29B6F6);
      case Temperature.cool:
        icon = FontAwesomeIcons.wind;
        color = const Color(0xFF26C6DA);
      case Temperature.warm:
        icon = FontAwesomeIcons.temperatureHalf;
        color = const Color(0xFFFFCA28);
      case Temperature.hot:
        icon = FontAwesomeIcons.temperatureHigh;
        color = const Color(0xFFFF7043);
      case Temperature.boiling:
        icon = FontAwesomeIcons.fire;
        color = const Color(0xFFFF5722);
      case Temperature.correct:
        icon = FontAwesomeIcons.check;
        color = const Color(0xFF66BB6A);
    }

    return Container(
          key: ValueKey(temp),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 48),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 800.ms,
        );
  }

  Widget _buildInputSection(GuessState state) {
    return Column(
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
                boxShadow: [
                  BoxShadow(
                    color: _primaryOrange.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
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

        // 3 Yanlış tahminden sonra Soruyu Geç butonu
        if (state.attempts >= 3) ...[
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(guessControllerProvider.notifier).skipQuestion();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.8),
                    Colors.deepOrange.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Soruyu Geç',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    FontAwesomeIcons.forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ],
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// 🎨 DOĞRU CEVAP POPUP - Ekran Ortasında Overlay
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildCorrectAnswerSection(GuessState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {}, // Arka plana tıklamayı engelle
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.85),
                _deepPurple.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive değerler hesaplama
                final availableHeight = constraints.maxHeight;
                final availableWidth = constraints.maxWidth;
                final isCompact = availableHeight < 600;
                
                // Dinamik boyutlar
                final iconSize = isCompact ? 24.0 : 32.0;
                final titleSize = isCompact ? 20.0 : 26.0;
                final answerSize = isCompact ? 32.0 : 44.0;
                final subTextSize = isCompact ? 11.0 : 13.0;
                final cardPadding = isCompact ? 16.0 : 24.0;
                final spacing = isCompact ? 12.0 : 16.0;
                final horizontalPadding = availableWidth * 0.05;
                
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: availableHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: spacing,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  // ═══ ANA BAŞARI KARTI ═══
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF00E676).withValues(alpha: 0.25),
                              const Color(0xFF00D9FF).withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF00E676).withValues(alpha: 0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Başarı İkonu
                            Container(
                              padding: EdgeInsets.all(isCompact ? 12 : 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF00E676).withValues(alpha: 0.4),
                                    const Color(0xFF00E676).withValues(alpha: 0.1),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E676).withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Icon(
                                FontAwesomeIcons.check,
                                color: const Color(0xFF00E676),
                                size: iconSize,
                              ),
                            )
                                .animate()
                                .scale(
                                  begin: const Offset(0, 0),
                                  duration: 500.ms,
                                  curve: Curves.elasticOut,
                                )
                                .then()
                                .shimmer(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  duration: 1500.ms,
                                ),

                            SizedBox(height: spacing),

                            // DOĞRU yazısı
                            Text(
                              '🎉 DOĞRU!',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                shadows: [
                                  const Shadow(
                                    color: Color(0xFF00E676),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: spacing * 1.5),

                            // Doğru Cevap Değeri
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: isCompact ? 12 : 16,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'CEVAP',
                                    style: GoogleFonts.nunito(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: subTextSize * 0.9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${question.answer}',
                                      style: GoogleFonts.orbitron(
                                        color: const Color(0xFF00E676),
                                        fontSize: answerSize,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFF00E676).withValues(alpha: 0.5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .shimmer(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.3),
                                  delay: 500.ms,
                                  duration: 1500.ms,
                                ),

                            SizedBox(height: spacing),

                            // Deneme sayısı
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.bullseye,
                                    color: _accentCyan,
                                    size: subTextSize,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${state.attempts} denemede buldun!',
                                    style: GoogleFonts.nunito(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: subTextSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).scale(
                        begin: const Offset(0.9, 0.9),
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),

                  // ═══ BİLGİ KARTI ═══
                  if (question.info != null) ...[
                    SizedBox(height: spacing * 1.5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isCompact ? 12 : 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.amber.withValues(alpha: 0.15),
                                Colors.orange.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.lightbulb,
                                      color: Colors.amber,
                                      size: isCompact ? 14 : 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Biliyor muydun?',
                                    style: GoogleFonts.nunito(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isCompact ? 14 : 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing),
                              Text(
                                question.info!,
                                style: GoogleFonts.nunito(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: isCompact ? 13 : 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  ],

                  SizedBox(height: spacing * 2),

                  // ═══ DEVAM BUTONU ═══
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref.read(guessControllerProvider.notifier).nextQuestion();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact ? 14 : 18,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primaryOrange, _accentCyan],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryOrange.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.currentQuestionIndex + 1 >= state.totalQuestions
                                  ? 'Sonuçları Gör'
                                  : 'Sonraki Soru',
                              style: GoogleFonts.nunito(
                                fontSize: isCompact ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              FontAwesomeIcons.arrowRight,
                              color: Colors.white,
                              size: isCompact ? 14 : 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          ),
        );
      },
    ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms);
  }

  Widget _buildNeonButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryOrange, Color(0xFFFF8F5C)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryOrange.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerHaptic(Temperature temperature) {
    switch (temperature) {
      case Temperature.freezing:
      case Temperature.cold:
        HapticFeedback.heavyImpact();
        break;
      case Temperature.cool:
      case Temperature.warm:
        HapticFeedback.mediumImpact();
        break;
      case Temperature.hot:
      case Temperature.boiling:
        HapticFeedback.lightImpact();
        break;
      case Temperature.correct:
        HapticFeedback.vibrate();
        break;
    }
  }

  void _navigateToResult(GuessState state) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GuessResultScreen(
          level: state.level!,
          correctCount: state.correctCount,
          totalQuestions: state.totalQuestions,
          totalScore: state.totalScore,
        ),
      ),
    );
  }
}

/// Wave Painter for background effect
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

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 +
            math.sin(
                  (i / size.width * 2 * math.pi) + (animation * 2 * math.pi),
                ) *
                20 +
            math.sin(
                  (i / size.width * 4 * math.pi) + (animation * 2 * math.pi),
                ) *
                10,
      );
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
