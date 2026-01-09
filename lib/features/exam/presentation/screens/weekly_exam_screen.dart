// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/models/weekly_exam.dart';
import '../../data/weekly_exam_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🏆 GOLD CLASS EXAM - Haftalık Sınav Boss Stage
/// ═══════════════════════════════════════════════════════════════════════════
/// Standart test ekranından daha ciddi ve "premium" bir atmosfer.
/// Derin okyanus mavisi gradient, altın vurgular ve glass efektleri.
/// ═══════════════════════════════════════════════════════════════════════════

class WeeklyExamScreen extends StatefulWidget {
  final WeeklyExam exam;

  const WeeklyExamScreen({super.key, required this.exam});

  @override
  State<WeeklyExamScreen> createState() => _WeeklyExamScreenState();
}

class _WeeklyExamScreenState extends State<WeeklyExamScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // CONTROLLERS & STATE (KORUNAN MANTIK)
  // ─────────────────────────────────────────────────────────────────────────
  final PageController _pageController = PageController();
  final WeeklyExamService _examService = WeeklyExamService();
  final Map<String, String> _answers = {};

  late int _remainingSeconds;
  Timer? _timer;
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;

  // ─────────────────────────────────────────────────────────────────────────
  // ANİMASYON KONTROLCÜLERİ
  // ─────────────────────────────────────────────────────────────────────────
  late AnimationController _timerShakeController;
  late AnimationController _introController;
  bool _showIntro = true;

  // ─────────────────────────────────────────────────────────────────────────
  // RENK PALETİ - GOLD CLASS
  // ─────────────────────────────────────────────────────────────────────────
  static const Color _deepOcean = Color(0xFF0F2027);
  static const Color _darkSea = Color(0xFF203A43);
  static const Color _midSea = Color(0xFF2C5364);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _danger = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    // ⚡ Sınav sırasında ekranın kapanmasını engelle
    WakelockPlus.enable();
    _remainingSeconds = widget.exam.duration * 60;

    // Timer shake animasyonu
    _timerShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // İntro animasyonu
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Önce kullanıcının sınavı tamamlayıp tamamlamadığını kontrol et
    _checkIfAlreadyCompleted();

    // İntro animasyonunu başlat
    _introController.forward().then((_) {
      if (mounted) {
        setState(() => _showIntro = false);
      }
    });
  }

  /// Kullanıcı sınavı zaten tamamladıysa geri gönder
  Future<void> _checkIfAlreadyCompleted() async {
    final hasCompleted = await _examService.hasUserCompletedExam(
      widget.exam.examId,
    );

    if (hasCompleted && mounted) {
      // Kullanıcı zaten sınavı tamamlamış, geri gönder
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bu sınavı zaten tamamladınız! Sonuçlar açıklanınca görebilirsiniz.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Tamamlanmadıysa timer'ı başlat
    _startTimer();
  }

  @override
  void dispose() {
    // ⚡ Ekran kapanmasına izin ver
    WakelockPlus.disable();
    _timer?.cancel();
    _pageController.dispose();
    _timerShakeController.dispose();
    _introController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TIMER MANTIĞI (KORUNAN)
  // ─────────────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;

          // Son %20 sürede shake efekti
          final totalSeconds = widget.exam.duration * 60;
          if (_remainingSeconds < totalSeconds * 0.2 &&
              _remainingSeconds % 10 == 0) {
            _timerShakeController.forward().then((_) {
              _timerShakeController.reverse();
            });
          }
        } else {
          _finishExam();
        }
      });
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CEVAP SEÇİMİ (KORUNAN)
  // ─────────────────────────────────────────────────────────────────────────
  void _selectAnswer(String questionId, String answer) {
    HapticFeedback.selectionClick();
    setState(() {
      _answers[questionId] = answer;
    });

    // Otomatik geçiş - 500ms sonra sonraki soruya geç
    final isLastQuestion =
        _currentQuestionIndex == widget.exam.questions.length - 1;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (isLastQuestion) {
        // Son soruysa bitir dialogunu göster
        _showFinishDialog();
      } else {
        // Sonraki soruya geç
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SINAVI BİTİRME (KORUNAN)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _finishExam() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _timer?.cancel();

    try {
      // Boş bırakılan soruları "EMPTY" olarak işaretle
      final allAnswers = <String, String>{};
      for (var i = 0; i < widget.exam.questions.length; i++) {
        final questionId = (i + 1).toString();
        allAnswers[questionId] = _answers[questionId] ?? 'EMPTY';
      }

      // Sonucu kaydet
      await _examService.saveExamResult(
        examId: widget.exam.examId,
        answers: allAnswers,
        exam: widget.exam,
      );

      if (!mounted) return;

      // Kullanıcıyı bilgilendir ve ana sayfaya dön
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cevapların kaydedildi! Sonuçlar Pazar 20:00\'da açıklanacak.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: _gold.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      _isSubmitting = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e'), backgroundColor: _danger),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // Sınav esnasında geri tuşu devre dışı
        // Kullanıcı sınavı tamamlayana kadar çıkamaz
        return;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ═══ ARKA PLAN ═══
            _buildBackground(),

            // ═══ ANA İÇERİK ═══
            SafeArea(
              child: Column(
                children: [
                  // The HUD (Üst Bar)
                  _buildHUD(),

                  // Progress Indicator
                  _buildProgressBar(),

                  // Soru Alanı
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _currentQuestionIndex = index;
                        });
                      },
                      itemCount: widget.exam.questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionPage(index);
                      },
                    ),
                  ),

                  // Kontrol Paneli
                  _buildControlPanel(),
                ],
              ),
            ),

            // ═══ İNTRO OVERLAY ═══
            if (_showIntro) _buildIntroOverlay(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ARKA PLAN
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepOcean, _darkSea, _midSea],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Dekoratif daireler
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_gold.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_gold.withOpacity(0.05), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // THE HUD (ÜST BAR)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHUD() {
    final totalSeconds = widget.exam.duration * 60;
    final isLowTime = _remainingSeconds < totalSeconds * 0.2;
    final isCritical = _remainingSeconds < totalSeconds * 0.1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Geri butonu kaldırıldı - sınav esnasında çıkış yasak
          const SizedBox(width: 48),

          const Spacer(),

          // Timer (Merkez) - Glass Container
          AnimatedBuilder(
            animation: _timerShakeController,
            builder: (context, child) {
              final shake = _timerShakeController.value * 10;
              return Transform.translate(
                offset: Offset(
                  shake *
                      ((_timerShakeController.value * 10).toInt() % 2 == 0
                          ? 1
                          : -1),
                  0,
                ),
                child: child,
              );
            },
            child: _buildGlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              borderColor: isCritical
                  ? _danger
                  : (isLowTime
                        ? _danger.withOpacity(0.7)
                        : _gold.withOpacity(0.3)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: isCritical ? _danger : (isLowTime ? _danger : _gold),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      color: isCritical ? _danger : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(target: isLowTime ? 1 : 0).shake(duration: 500.ms, hz: 4),

          const Spacer(),

          // Soru sayısı badge
          _buildGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              '${_currentQuestionIndex + 1}/${widget.exam.questions.length}',
              style: const TextStyle(
                color: _gold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROGRESS BAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white.withOpacity(0.1),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (_currentQuestionIndex + 1) / widget.exam.questions.length,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(colors: [_goldDark, _gold]),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SORU SAYFASI (THE GOLDEN CARD)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuestionPage(int index) {
    final question = widget.exam.questions[index];
    final questionId = (index + 1).toString();
    final selectedAnswer = _answers[questionId];

    final options = [
      ('A', question.optionA),
      ('B', question.optionB),
      ('C', question.optionC),
      ('D', question.optionD),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ═══ THE GOLDEN CARD ═══
          _buildGoldenQuestionCard(index, question.questionText),

          const SizedBox(height: 24),

          // ═══ CEVAP ŞIKLARI ═══
          ...options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final letter = option.$1;
            final text = option.$2;
            final isSelected = selectedAnswer == letter;

            return _buildOptionButton(
                  letter: letter,
                  text: text,
                  isSelected: isSelected,
                  onTap: () => _selectAnswer(questionId, letter),
                )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 * optionIndex))
                .slideX(
                  begin: 0.1,
                  delay: Duration(milliseconds: 100 * optionIndex),
                );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOLDEN QUESTION CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGoldenQuestionCard(int index, String questionText) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Ana kart
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _gold.withOpacity(0.3), width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                questionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // Soru numarası rozeti (Kartın üstünde)
        Positioned(
          top: -14,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_goldDark, _gold]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Soru ${index + 1}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CEVAP ŞIKKI BUTONU
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOptionButton({
    required String letter,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _gold : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              gradient: isSelected
                  ? const LinearGradient(colors: [_gold, _goldDark])
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _gold.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Şık harfi
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black.withOpacity(0.3)
                          : _gold.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: isSelected ? Colors.black87 : _gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Şık metni
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.black87 : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),

                // Seçim ikonu
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KONTROL PANELİ (ALT)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildControlPanel() {
    final isLastQuestion =
        _currentQuestionIndex == widget.exam.questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, _deepOcean.withOpacity(0.8)],
        ),
      ),
      child: Row(
        children: [
          // Önceki butonu
          if (_currentQuestionIndex > 0)
            _buildNavigationButton(
              icon: Icons.chevron_left,
              onTap: () {
                HapticFeedback.lightImpact();
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          else
            const SizedBox(width: 48),

          const Spacer(),

          // Cevaplanmış soru sayısı
          _buildGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: _gold, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_answers.length}/${widget.exam.questions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bitir butonu (sadece son soruda görünür, diğer sorularda boşluk)
          isLastQuestion ? _buildFinishButton() : const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _buildGlassButton(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SINAVI TAMAMLA BUTONU
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFinishButton() {
    return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showFinishDialog();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_goldDark, _gold]),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'BİTİR',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DİALOGLAR
  // ─────────────────────────────────────────────────────────────────────────
  void _showFinishDialog() {
    final unanswered = widget.exam.questions.length - _answers.length;
    final remainingMinutes = (_remainingSeconds / 60).floor();

    // Komik/samimi mesajlar
    String friendlyMessage;
    if (unanswered > 0) {
      friendlyMessage =
          'Yavaş ol dostum! 🤔\n\n'
          'Henüz $unanswered soru boş bıraktın. '
          'Kalan $remainingMinutes dakikanı değerlendir, '
          'belki aklına gelir! 💡\n\n'
          'Yoksa gerçekten bitirmek mi istiyorsun?';
    } else {
      if (remainingMinutes > 10) {
        friendlyMessage =
            'Vay be şampiyon! 🌟\n\n'
            'Tüm soruları cevapladın ama daha $remainingMinutes dakikan var! '
            'İstersen cevaplarını bir gözden geçir, '
            'bazen acele etmek fena oluyor! 😊\n\n'
            'Yine de bitirmek istersen tabii ki senin kararın!';
      } else if (remainingMinutes > 5) {
        friendlyMessage =
            'Bravo! 🎯\n\n'
            'Tamamladın ama acele etme! '
            'Daha $remainingMinutes dakikan var, '
            'cevaplarına bir göz at istersen. 👀\n\n'
            'Yoksa hızlı bitirip kahramanlık mı yapacaksın? 😄';
      } else {
        friendlyMessage =
            'Süper! 🚀\n\n'
            'Tüm soruları hallettiniz efendim! '
            'Son bir kontrol yapacak mısın yoksa '
            'süper güvenli misin cevaplarına? 💪';
      }
    }

    showDialog(
      context: context,
      builder: (context) => _buildGlassDialog(
        title: unanswered > 0 ? '⏳ Dur Bir Dakika!' : '🎉 Tamamdır!',
        content: friendlyMessage,
        confirmText: unanswered > 0 ? 'Evet, Bitir' : 'Eminim, Bitir',
        cancelText: unanswered > 0 ? 'Gözden Geçireyim' : 'Kontrol Edeyim',
        onConfirm: () {
          Navigator.of(context).pop();
          _finishExam();
        },
      ),
    );
  }

  Widget _buildGlassDialog({
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    bool isDestructive = false,
    VoidCallback? onConfirm,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _gold.withOpacity(0.3), width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _deepOcean.withOpacity(0.9),
                  _darkSea.withOpacity(0.9),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            onConfirm ?? () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDestructive ? _danger : _gold,
                          foregroundColor: isDestructive
                              ? Colors.white
                              : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // İNTRO OVERLAY
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildIntroOverlay() {
    return AnimatedBuilder(
      animation: _introController,
      builder: (context, child) {
        return Opacity(
          opacity: 1 - _introController.value,
          child: Container(
            color: _deepOcean,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 20),
                  Text(
                    widget.exam.title,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.exam.questions.length} Soru • ${widget.exam.duration} Dakika',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI WIDGET'LAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(12),
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.2),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
