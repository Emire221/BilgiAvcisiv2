// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../../domain/models/weekly_exam.dart';
import '../../data/weekly_exam_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🏆 THE GRAND REVEAL - Haftalık Sınav Sonuç Ekranı
/// ═══════════════════════════════════════════════════════════════════════════
/// Premium sonuç ekranı - Konfeti, animasyonlar ve altın vurgular.
/// Lacivert/Altın renk paleti ile şampiyonluk kutlaması.
/// ═══════════════════════════════════════════════════════════════════════════

class WeeklyExamResultScreen extends StatefulWidget {
  final WeeklyExam exam;
  final WeeklyExamResult? result;

  const WeeklyExamResultScreen({super.key, required this.exam, this.result});

  @override
  State<WeeklyExamResultScreen> createState() => _WeeklyExamResultScreenState();
}

class _WeeklyExamResultScreenState extends State<WeeklyExamResultScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // SERVİS & STATE (KORUNAN MANTIK)
  // ─────────────────────────────────────────────────────────────────────────
  final WeeklyExamService _examService = WeeklyExamService();

  // ─────────────────────────────────────────────────────────────────────────
  // ANİMASYON KONTROLCÜLERİ
  // ─────────────────────────────────────────────────────────────────────────
  late ConfettiController _confettiController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  // ─────────────────────────────────────────────────────────────────────────
  // RENK PALETİ - THE GRAND REVEAL
  // ─────────────────────────────────────────────────────────────────────────
  static const Color _deepOcean = Color(0xFF0F2027);
  static const Color _darkSea = Color(0xFF203A43);
  static const Color _midSea = Color(0xFF2C5364);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _success = Color(0xFF10B981);
  static const Color _danger = Color(0xFFEF4444);
  static const Color _neutral = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();

    // Konfeti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Skor animasyon controller
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation =
        Tween<double>(
          begin: 0,
          end: (widget.result?.puan ?? 0).toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _scoreAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Sonuçlar açıksa konfeti ve animasyonu başlat
    final weekStart = _examService.getThisWeekMonday();
    if (_examService.areResultsAvailable(weekStart) && widget.result != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
        _scoreAnimationController.forward();
      });
    }

    // Geri sayım timer'ı başlat
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    final weekStart = _examService.getThisWeekMonday();
    _remainingTime = _examService.getTimeRemaining(
      weekStart,
      ExamRoomStatus.kapali,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _remainingTime = _examService.getTimeRemaining(
            weekStart,
            ExamRoomStatus.kapali,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreAnimationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final weekStart = _examService.getThisWeekMonday();
    final areResultsAvailable = _examService.areResultsAvailable(weekStart);

    return Scaffold(
      body: Stack(
        children: [
          // ═══ ARKA PLAN ═══
          _buildBackground(),

          // ═══ ANA İÇERİK ═══
          SafeArea(
            child: Column(
              children: [
                // Üst bar
                _buildTopBar(),

                // İçerik
                Expanded(
                  child: areResultsAvailable
                      ? _buildResultsContent()
                      : _buildWaitingContent(),
                ),
              ],
            ),
          ),

          // ═══ KONFETİ ═══
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                _gold,
                _goldDark,
                Colors.white,
                Color(0xFFFFC107),
                Color(0xFFFF9800),
              ],
              numberOfParticles: 30,
              emissionFrequency: 0.05,
              gravity: 0.2,
            ),
          ),
        ],
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
  // ÜST BAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    final weekStart = _examService.getThisWeekMonday();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildGlassButton(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  _examService.generateRoomName(weekStart),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'Sonuç Ekranı',
                  style: TextStyle(
                    color: _gold.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BEKLEME İÇERİĞİ (Sonuçlar Açıklanmadan Önce)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWaitingContent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kilit / Kum saati animasyonu
            _buildGlassContainer(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Lottie yerine animasyonlu ikon
                      TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(seconds: 2),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 6.28 * 0.1,
                                child: Icon(
                                  Icons.hourglass_top,
                                  size: 100,
                                  color: _gold.withOpacity(0.8),
                                ),
                              );
                            },
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .rotate(duration: 3000.ms, begin: 0, end: 0.05)
                          .then()
                          .rotate(duration: 3000.ms, begin: 0.05, end: 0),

                      const SizedBox(height: 24),

                      // Başlık
                      const Text(
                        '🔮 Büyük An Geliyor!',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Sonuçlar Pazar 20:00\'da açıklanacak',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 32),

            // Geri sayım
            _buildCountdownTimer()
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.2),

            // Kullanıcının cevap özeti (varsa)
            if (widget.result != null) ...[
              const SizedBox(height: 32),
              _buildAnswerSummary()
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return _buildGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      borderColor: _gold.withOpacity(0.3),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, color: _gold, size: 24),
              const SizedBox(width: 12),
              Text(
                _formatDuration(_remainingTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sonuçlara kalan süre',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSummary() {
    return Column(
      children: [
        Text(
          'Senin Cevapların',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMiniStatCard(
              'Doğru',
              widget.result?.dogru?.toString() ?? '-',
              _success,
            ),
            const SizedBox(width: 12),
            _buildMiniStatCard(
              'Yanlış',
              widget.result?.yanlis?.toString() ?? '-',
              _danger,
            ),
            const SizedBox(width: 12),
            _buildMiniStatCard(
              'Boş',
              widget.result?.bos?.toString() ?? '-',
              _neutral,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String value, Color color) {
    return _buildGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SONUÇ İÇERİĞİ (Sonuçlar Açıklandıktan Sonra)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildResultsContent() {
    if (widget.result == null) {
      return _buildNoParticipationContent();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Skor Kartı
          _buildScoreCard()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3),

          const SizedBox(height: 20),

          // Sıralama Kartı
          _buildRankingCard()
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.3),

          const SizedBox(height: 20),

          // İstatistikler
          _buildStatsGrid()
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3),

          const SizedBox(height: 20),

          // Detaylı Cevaplar
          _buildDetailedAnswers()
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.3),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNoParticipationContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _buildGlassContainer(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bu sınava katılmadın',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Gelecek hafta seni bekliyoruz! 💪',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SKOR KARTI (The Scoreboard)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildScoreCard() {
    final maxPuan = widget.exam.questions.length * 25; // Her soru 25 puan

    return _buildGlassContainer(
      padding: const EdgeInsets.all(24),
      borderColor: _gold.withOpacity(0.3),
      child: Column(
        children: [
          // Lottie Trophy animasyonu
          SizedBox(
            height: 100,
            width: 100,
            child: Lottie.asset(
              'assets/animation/card_thoropy.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Puanın',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          // Animasyonlu puan sayacı
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_scoreAnimation.value.toInt()}',
                    style: TextStyle(
                      color: _getScoreColor(widget.result?.puan ?? 0),
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4),
                    child: Text(
                      '/ $maxPuan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getScoreColor(widget.result?.puan ?? 0).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getScoreMessage(widget.result?.puan ?? 0),
              style: TextStyle(
                color: _getScoreColor(widget.result?.puan ?? 0),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SIRALAMA KARTI (The Ranking - ÖNEMLİ!)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRankingCard() {
    final siralama = widget.result?.siralama;
    final toplamKatilimci = widget.result?.toplamKatilimci;

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_goldDark, _gold, _goldDark],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🇹🇷', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Text(
                    'Türkiye Sıralaması',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (siralama != null && toplamKatilimci != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '#$siralama',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 8),
                      child: Text(
                        '/ $toplamKatilimci',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRankingMessage(siralama, toplamKatilimci),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Sıralama hesaplanıyor...',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.3));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // İSTATİSTİKLER GRID
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Doğru',
            widget.result?.dogru?.toString() ?? '-',
            _success,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Yanlış',
            widget.result?.yanlis?.toString() ?? '-',
            _danger,
            Icons.cancel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Boş',
            widget.result?.bos?.toString() ?? '-',
            _neutral,
            Icons.remove_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return _buildGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DETAYLI CEVAPLAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDetailedAnswers() {
    return _buildGlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: _gold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Cevap Anahtarı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...widget.exam.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final questionId = (index + 1).toString();
            final userAnswer = widget.result?.cevaplar[questionId];
            final isCorrect = userAnswer == question.correctAnswer;
            final isEmpty = userAnswer == null || userAnswer == 'EMPTY';

            return _buildAnswerRow(
              questionId: questionId,
              userAnswer: isEmpty ? '-' : userAnswer,
              correctAnswer: question.correctAnswer,
              isCorrect: isCorrect,
              isEmpty: isEmpty,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnswerRow({
    required String questionId,
    required String userAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required bool isEmpty,
  }) {
    final bgColor = isEmpty
        ? Colors.white.withOpacity(0.05)
        : isCorrect
        ? _success.withOpacity(0.15)
        : _danger.withOpacity(0.15);

    final iconColor = isEmpty ? _neutral : (isCorrect ? _success : _danger);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Soru numarası
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                questionId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Senin cevabın
          Expanded(
            child: Row(
              children: [
                Text(
                  'Sen: ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                Text(
                  userAnswer,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Doğru cevap
          Row(
            children: [
              Text(
                'Doğru: ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              Text(
                correctAnswer,
                style: TextStyle(
                  color: _success,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // İkon
          Icon(
            isEmpty
                ? Icons.remove_circle_outline
                : isCorrect
                ? Icons.check_circle
                : Icons.cancel,
            color: iconColor,
            size: 18,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI WIDGET'LAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI METODLAR (KORUNAN MANTIK)
  // ─────────────────────────────────────────────────────────────────────────
  Color _getScoreColor(int score) {
    final maxPuan = widget.exam.questions.length * 25;
    final percentage = score / maxPuan * 100;

    if (percentage >= 80) return _success;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return _danger;
  }

  String _getScoreMessage(int score) {
    final maxPuan = widget.exam.questions.length * 25;
    final percentage = score / maxPuan * 100;

    if (percentage >= 90) return 'Mükemmel! 🌟';
    if (percentage >= 80) return 'Harika! 🎉';
    if (percentage >= 70) return 'Çok iyi! 👏';
    if (percentage >= 60) return 'İyi! 👍';
    if (percentage >= 50) return 'Fena değil 😊';
    if (percentage >= 40) return 'Geliştirebilirsin 💪';
    return 'Daha çok çalışmalısın 📚';
  }

  String _getRankingMessage(int rank, int total) {
    final percentage = (rank / total * 100);
    if (percentage <= 1) return 'İlk %1\'desin! Süpersin! 🏆';
    if (percentage <= 5) return 'İlk %5\'tesin! Harika! 🥇';
    if (percentage <= 10) return 'İlk %10\'dasın! Çok iyi! 🥈';
    if (percentage <= 25) return 'İlk %25\'tesin! Başarılı! 🥉';
    if (percentage <= 50) return 'Üst yarıdasın! İyi gidiyorsun! 👍';
    return 'Gelişmeye devam et! 💪';
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return '$days gün ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
