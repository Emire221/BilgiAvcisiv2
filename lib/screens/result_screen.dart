// ignore_for_file: deprecated_member_use
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';

import '../services/database_helper.dart';
import '../features/mascot/presentation/providers/mascot_provider.dart';
import '../features/mascot/domain/entities/mascot.dart';
import '../providers/repository_providers.dart';
import 'answer_key_screen.dart';
import 'main_screen.dart';

/// 🏆 ZAFER SAHNESİ - Result Screen
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Oyun/test bitiminde gösterilen kutlama ekranı
/// Konfeti efekti, animasyonlu skor sayacı, cam istatistik kartları
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ResultScreen extends ConsumerStatefulWidget {
  final int score;
  final int correctCount;
  final int wrongCount;
  final String topicId;
  final String topicName;
  final String? testId; // Yeni eklenen alan
  final List<Map<String, dynamic>> answeredQuestions;
  final bool isFlashcard;

  const ResultScreen({
    super.key,
    this.score = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.topicId = '',
    this.topicName = '',
    this.testId, // Constructor'a eklendi
    this.answeredQuestions = const [],
    this.isFlashcard = false,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // MANTIK DEĞİŞKENLERİ (KORUNUYOR)
  // ─────────────────────────────────────────────────────────────────────────
  bool _resultSaved = false;

  // ─────────────────────────────────────────────────────────────────────────
  // ANİMASYON DEĞİŞKENLERİ
  // ─────────────────────────────────────────────────────────────────────────
  late ConfettiController _confettiController;
  late AnimationController _scoreAnimationController;
  late Animation<int> _scoreAnimation;
  late AnimationController _shimmerController;

  // Yıldız partikülleri
  final List<_StarParticle> _stars = [];

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initStars();
    _initializeResults(); // MANTIK KORUNUYOR
  }

  void _initAnimations() {
    // Konfeti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    // Skor puanı >= 50 ise konfeti başlat
    if (widget.score >= 50) {
      _confettiController.play();
    }

    // Skor sayaç animasyonu
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.easeOutExpo,
      ),
    );

    // Shimmer efekti
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Sayacı başlat
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _scoreAnimationController.forward();
    });
  }

  void _initStars() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _stars.add(
        _StarParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 3 + 1,
          opacity: random.nextDouble() * 0.5 + 0.3,
          twinkleSpeed: random.nextDouble() * 2 + 1,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MANTIK FONKSİYONLARI (AYNEN KORUNUYOR)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _initializeResults() async {
    await _saveResult();
    await _addXpToMascot();
  }

  Future<void> _saveResult() async {
    // Çift kayıt önleme
    if (_resultSaved) return;
    _resultSaved = true;

    try {
      // Yerel veritabanına kaydet
      final dbHelper = DatabaseHelper();
      await dbHelper.saveGameResult(
        gameType: widget.isFlashcard ? 'flashcard' : 'test',
        score: widget.score,
        correctCount: widget.correctCount,
        wrongCount: widget.wrongCount,
        totalQuestions: widget.correctCount + widget.wrongCount,
        key: widget.isFlashcard ? widget.topicId : widget.testId,
      );
      debugPrint(
        'Sonuç kaydedildi: ${widget.isFlashcard ? "flashcard" : "test"} - Skor: ${widget.score}',
      );

      // 🔴 Progress provider'larını invalidate et - badge'ler güncellensin
      if (widget.topicId.isNotEmpty) {
        // Tüm modlar için invalidate
        ref.invalidate(
          topicProgressProvider((topicId: widget.topicId, mode: 'test')),
        );
        ref.invalidate(
          topicProgressProvider((topicId: widget.topicId, mode: 'flashcard')),
        );
        ref.invalidate(
          topicProgressProvider((topicId: widget.topicId, mode: 'all')),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Sonuç kaydetme hatası: $e');
    }
  }

  /// Maskota XP ekle - Her oyun/test bitiminde 1 XP
  Future<void> _addXpToMascot() async {
    try {
      final mascotRepository = ref.read(mascotRepositoryProvider);
      await mascotRepository.addXp(1);
      // Provider'ı yenile ki UI güncellensin
      ref.invalidate(activeMascotProvider);
    } catch (e) {
      if (kDebugMode) debugPrint('Maskot XP ekleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreAnimationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER METHODS
  // ─────────────────────────────────────────────────────────────────────────
  bool get _isHighScore => widget.score >= 70;

  List<Color> get _backgroundGradient {
    if (_isHighScore) {
      return const [
        Color(0xFF667eea), // Mavi
        Color(0xFF764ba2), // Mor
        Color(0xFFf093fb), // Pembe
      ];
    } else {
      return const [
        Color(0xFF4776E6), // Mavi
        Color(0xFF8E54E9), // Mor
        Color(0xFF9b5de5), // Açık Mor
      ];
    }
  }

  String get _titleText {
    if (widget.score >= 90) return '🏆 MÜKEMMELSİN!';
    if (widget.score >= 70) return '🌟 HARİKA İŞ!';
    if (widget.score >= 50) return '👍 İYİ GİDİYOR!';
    return '💪 DEVAM ET!';
  }

  String get _subtitleText {
    if (widget.score >= 90) return 'Gerçek bir şampiyon!';
    if (widget.score >= 70) return 'Bilgi ustası oldun!';
    if (widget.score >= 50) return 'Çalışmaya devam!';
    return 'Pratik mükemmelleştirir!';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mascotAsync = ref.watch(activeMascotProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _backgroundGradient,
          ),
        ),
        child: Stack(
          children: [
            // Yıldız partikülleri
            ..._buildStars(),

            // Ana içerik
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // A. Maskot Reaksiyonu
                      _buildMascotSection(mascotAsync)
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            curve: Curves.elasticOut,
                            duration: 800.ms,
                          ),

                      const SizedBox(height: 20),

                      // B. Başlık ve Skor
                      _buildTitleSection()
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 30),

                      // C. İstatistik Kartları
                      _buildStatsGrid().animate().fadeIn(
                        delay: 600.ms,
                        duration: 500.ms,
                      ),

                      const SizedBox(height: 30),

                      // Konu bilgisi
                      if (widget.topicName.isNotEmpty)
                        _buildTopicBadge().animate().fadeIn(
                          delay: 800.ms,
                          duration: 400.ms,
                        ),

                      const SizedBox(height: 30),

                      // D. Aksiyon Butonları
                      _buildActionButtons()
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 500.ms)
                          .slideY(begin: 0.5),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Konfeti efekti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFFfee440),
                  Color(0xFF00f5d4),
                  Color(0xFFf15bb5),
                  Color(0xFF00bbf9),
                  Color(0xFF9b5de5),
                  Colors.white,
                ],
                emissionFrequency: 0.03,
                numberOfParticles: 20,
                gravity: 0.2,
                maxBlastForce: 50,
                minBlastForce: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    return _stars.map((star) {
      return Positioned(
        left: star.x * MediaQuery.of(context).size.width,
        top: star.y * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            final twinkle =
                (math.sin(
                      _shimmerController.value *
                          math.pi *
                          2 *
                          star.twinkleSpeed,
                    ) +
                    1) /
                2;
            return Opacity(
              opacity: star.opacity * twinkle,
              child: Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: star.size * 8,
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildMascotSection(AsyncValue<Mascot?> mascotAsync) {
    // Animasyon boyutunu ekran yüksekliğinin %20'si ile sınırla (max 180)
    final screenHeight = MediaQuery.of(context).size.height;
    final mascotSize = (screenHeight * 0.20).clamp(120.0, 180.0);

    return mascotAsync.when(
      data: (mascot) {
        final lottiePath =
            mascot?.petType.getLottiePath() ??
            'assets/animation/kedi_mascot.json';

        return Container(
          height: mascotSize,
          width: mascotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
            boxShadow: [
              BoxShadow(
                color: _isHighScore
                    ? const Color(0xFFfee440).withOpacity(0.4)
                    : Colors.white.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            // ✅ Lottie optimize edildi
            child: Lottie.asset(
              lottiePath,
              fit: BoxFit.contain,
              animate: true,
              repeat: true,
              frameRate: FrameRate.max,
              options: LottieOptions(enableMergePaths: true),
            ),
          ),
        );
      },
      loading: () => Container(
        height: mascotSize,
        width: mascotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, __) => Container(
        height: mascotSize,
        width: mascotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: ClipOval(
          // ✅ Lottie optimize edildi
          child: Lottie.asset(
            'assets/animation/kedi_mascot.json',
            fit: BoxFit.contain,
            frameRate: FrameRate.max,
            options: LottieOptions(enableMergePaths: true),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        // Başlık
        AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment(-1 + _shimmerController.value * 3, 0),
                  end: Alignment(_shimmerController.value * 3, 0),
                  colors: const [Colors.white, Color(0xFFfee440), Colors.white],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              child: Text(
                _titleText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Alt başlık
        Text(
          _subtitleText,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // Animasyonlu skor sayacı
        AnimatedBuilder(
          animation: _scoreAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${_scoreAnimation.value}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFfee440).withOpacity(0.5),
                          blurRadius: 20,
                        ),
                        const Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'PUAN',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        // Doğru kutusu
        Expanded(
          child:
              _buildStatCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Doğru',
                    value: widget.correctCount.toString(),
                    color: const Color(0xFF00f5d4),
                    gradientColors: [
                      const Color(0xFF00f5d4).withOpacity(0.3),
                      const Color(0xFF00f5d4).withOpacity(0.1),
                    ],
                  )
                  .animate(delay: 700.ms)
                  .scale(
                    begin: const Offset(0, 0),
                    curve: Curves.elasticOut,
                    duration: 600.ms,
                  ),
        ),

        const SizedBox(width: 12),

        // Yanlış kutusu
        Expanded(
          child:
              _buildStatCard(
                    icon: Icons.cancel_rounded,
                    label: 'Yanlış',
                    value: widget.wrongCount.toString(),
                    color: const Color(0xFFf15bb5),
                    gradientColors: [
                      const Color(0xFFf15bb5).withOpacity(0.3),
                      const Color(0xFFf15bb5).withOpacity(0.1),
                    ],
                  )
                  .animate(delay: 800.ms)
                  .scale(
                    begin: const Offset(0, 0),
                    curve: Curves.elasticOut,
                    duration: 600.ms,
                  ),
        ),

        const SizedBox(width: 12),

        // XP kutusu
        Expanded(
          child:
              _buildStatCard(
                    icon: Icons.star_rounded,
                    label: 'XP',
                    value: '+1',
                    color: const Color(0xFFfee440),
                    gradientColors: [
                      const Color(0xFFfee440).withOpacity(0.3),
                      const Color(0xFFfee440).withOpacity(0.1),
                    ],
                  )
                  .animate(delay: 900.ms)
                  .scale(
                    begin: const Offset(0, 0),
                    curve: Curves.elasticOut,
                    duration: 600.ms,
                  ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isFlashcard ? Icons.style_rounded : Icons.quiz_rounded,
            color: Colors.white.withOpacity(0.9),
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.topicName,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Ana Menü butonu
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFfee440), Color(0xFFf9c74f)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFfee440).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.home_rounded,
                  color: Color(0xFF1a1a2e),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ana Menü',
                  style: TextStyle(
                    color: Color(0xFF1a1a2e),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ).animate().shimmer(
          delay: 1200.ms,
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.3),
        ),

        // Cevapları Gör butonu (Flashcard modunda gizli)
        if (!widget.isFlashcard) ...[
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnswerKeyScreen(
                    answeredQuestions: widget.answeredQuestions,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cevapları Gör',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER CLASSES
// ─────────────────────────────────────────────────────────────────────────────
class _StarParticle {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double twinkleSpeed;

  _StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
  });
}
