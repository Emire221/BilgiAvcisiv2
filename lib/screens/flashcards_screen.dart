// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:confetti/confetti.dart';

import '../models/flashcard_model.dart';
import '../services/database_helper.dart';
import '../providers/repository_providers.dart';
import 'result_screen.dart';

/// 🏯 Holografik Bilgi Dojo'su
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Deep Violet → Night Blue gradient arka plan
/// 3D Flip Card animasyonu ile ön/arka yüz
/// Swipe ile Tekrar (sol) / Ezberledim (sağ) mekanizması
/// Confetti + cam dialog ile tamamlanma kutlaması
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class FlashcardsScreen extends ConsumerStatefulWidget {
  final String? topicId;
  final String? topicName;
  final String? kartSetID; // Badge takibi için
  final List<FlashcardModel>? initialCards;

  const FlashcardsScreen({
    super.key,
    this.topicId,
    this.topicName,
    this.kartSetID,
    this.initialCards,
  });

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────────────────────────────────
  List<FlashcardModel> _allCards = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _isProcessing = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Flip card state
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Swipe animation
  late AnimationController _swipeController;
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;

  // Score animations
  late AnimationController _correctScaleController;
  late AnimationController _wrongScaleController;

  // Confetti
  late ConfettiController _confettiController;

  // Holographic shimmer
  late AnimationController _shimmerController;

  // Dojo particles
  final List<_DojoParticle> _particles = [];
  Timer? _particleTimer;

  // Motivasyon mesajları (JSON'dan yüklenecek)
  List<String> _dogruMesajlar = [];
  List<String> _yanlisMesajlar = [];

  // Mevcut motivasyon ve sonuç bilgisi
  String _currentMotivation = '';
  bool? _lastAnswerCorrect; // Son cevabın doğru olup olmadığı
  bool _showingResult = false; // Sonuç gösteriliyorsa true

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initParticles();
    _loadMotivationMessages();
    _loadCards();
  }

  /// JSON dosyalarından motivasyon mesajlarını yükle
  Future<void> _loadMotivationMessages() async {
    try {
      // Doğru cevap mesajlarını yükle
      final dogruJson = await rootBundle.loadString('assets/json/dogru.json');
      final dogruData = json.decode(dogruJson) as Map<String, dynamic>;
      _dogruMesajlar = List<String>.from(dogruData['mesajlar'] ?? []);

      // Yanlış cevap mesajlarını yükle
      final yanlisJson = await rootBundle.loadString('assets/json/yanlis.json');
      final yanlisData = json.decode(yanlisJson) as Map<String, dynamic>;
      _yanlisMesajlar = List<String>.from(yanlisData['mesajlar'] ?? []);
    } catch (e) {
      // Fallback mesajlar
      _dogruMesajlar = ['Harikasın! 🎉', 'Süper! ⭐', 'Mükemmel! 🏆'];
      _yanlisMesajlar = ['Bir Dahakine! 💫', 'Pes Etme! 🚀', 'Devam Et! 💪'];
    }
  }

  void _initAnimations() {
    // Flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    // Swipe animation
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Score scale animations
    _correctScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _wrongScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _DojoParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 4 + 2,
          speed: random.nextDouble() * 0.3 + 0.1,
          opacity: random.nextDouble() * 0.5 + 0.2,
          isKanji: random.nextBool(),
        ),
      );
    }
    _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) setState(() => _updateParticles());
    });
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.y -= p.speed * 0.01;
      if (p.y < -0.1) {
        p.y = 1.1;
        p.x = math.Random().nextDouble();
      }
    }
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.initialCards != null && widget.initialCards!.isNotEmpty) {
        _allCards = List.from(widget.initialCards!);
      }

      if (_allCards.isEmpty) {
        _errorMessage = 'Bu konu için kart bulunamadı.';
      } else {
        _allCards.shuffle();
      }
    } catch (e) {
      _errorMessage = 'Kartlar yüklenirken hata: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _swipeController.dispose();
    _correctScaleController.dispose();
    _wrongScaleController.dispose();
    _confettiController.dispose();
    _shimmerController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SWIPE & CARD LOGIC
  // ─────────────────────────────────────────────────────────────────────────

  /// Kartı ortaya geri getiren animasyonlu fonksiyon
  Future<void> _animateCardToCenter() async {
    const duration = Duration(milliseconds: 300);
    const steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;

    final startOffset = _dragOffset;
    final startRotation = _dragRotation;

    for (int i = 1; i <= steps; i++) {
      if (!mounted) return;
      final progress = Curves.easeOutCubic.transform(i / steps);
      setState(() {
        _dragOffset = Offset.lerp(startOffset, Offset.zero, progress)!;
        _dragRotation = startRotation * (1 - progress);
      });
      await Future.delayed(Duration(milliseconds: stepDuration));
    }

    // Tam olarak sıfırla
    if (mounted) {
      setState(() {
        _dragOffset = Offset.zero;
        _dragRotation = 0.0;
      });
    }
  }

  /// Sağa kaydır = "Doğru" dedi, Sola kaydır = "Yanlış" dedi
  void _handleSwipe(DismissDirection direction) async {
    if (_isProcessing || _allCards.isEmpty) return;
    setState(() => _isProcessing = true);

    HapticFeedback.mediumImpact();

    final currentCard = _allCards[_currentIndex];
    // Sağa kaydırma = kullanıcı "Doğru" diyor
    // Sola kaydırma = kullanıcı "Yanlış" diyor
    final userSaidTrue = direction == DismissDirection.startToEnd;

    // Kartın gerçek cevabı ile kullanıcının cevabını karşılaştır
    final isCorrectAnswer =
        (userSaidTrue && currentCard.dogruMu) ||
        (!userSaidTrue && !currentCard.dogruMu);

    // Sonucu kaydet
    _lastAnswerCorrect = isCorrectAnswer;

    if (isCorrectAnswer) {
      setState(() => _correctCount++);
      _correctScaleController.forward().then((_) {
        _correctScaleController.reverse();
      });
      // Doğru mesajlarından rastgele seç
      if (_dogruMesajlar.isNotEmpty) {
        _currentMotivation =
            _dogruMesajlar[math.Random().nextInt(_dogruMesajlar.length)];
      }
    } else {
      setState(() => _wrongCount++);
      _wrongScaleController.forward().then((_) {
        _wrongScaleController.reverse();
      });
      // Yanlış mesajlarından rastgele seç
      if (_yanlisMesajlar.isNotEmpty) {
        _currentMotivation =
            _yanlisMesajlar[math.Random().nextInt(_yanlisMesajlar.length)];
      }
    }

    // 1️⃣ Önce kartı ortaya geri getir (animasyonlu)
    await _animateCardToCenter();

    // 2️⃣ Kartı döndürüp sonucu göster
    setState(() => _showingResult = true);

    // Kart dönsün ve sonucu göstersin
    if (!_isFlipped) {
      _flipController.forward();
      _isFlipped = true;
    }

    // 3️⃣ Motivasyon mesajı ile birlikte sonucu göster (2 saniye)
    await Future.delayed(const Duration(milliseconds: 2000));

    // Kartı geri çevir
    if (_isFlipped) {
      _flipController.reverse();
      _isFlipped = false;
    }

    await Future.delayed(const Duration(milliseconds: 400));

    // Move to next card or finish
    if (_currentIndex < _allCards.length - 1) {
      setState(() {
        _currentIndex++;
        _isProcessing = false;
        _showingResult = false;
        _dragOffset = Offset.zero;
        _dragRotation = 0.0;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isProcessing) return;
    setState(() {
      _dragOffset += details.delta;
      _dragRotation = _dragOffset.dx * 0.001;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isProcessing) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25;

    if (_dragOffset.dx > threshold) {
      // Swipe right → Biliyorum
      _handleSwipe(DismissDirection.startToEnd);
    } else if (_dragOffset.dx < -threshold) {
      // Swipe left → Tekrar
      _handleSwipe(DismissDirection.endToStart);
    } else {
      // Return to center
      setState(() {
        _dragOffset = Offset.zero;
        _dragRotation = 0.0;
      });
    }
  }

  void _showCompletionDialog() {
    _confettiController.play();
    HapticFeedback.heavyImpact();

    // 🔴 Set tamamlandı, veritabanına kaydet
    _saveFlashcardSetViewed();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CompletionDialog(
        correctCount: _correctCount,
        wrongCount: _wrongCount,
        totalCards: _allCards.length,
        onContinue: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                score: _correctCount * 10,
                correctCount: _correctCount,
                wrongCount: _wrongCount,
                topicId: widget.topicId ?? '',
                topicName: widget.topicName ?? 'Bilgi Kartları',
                answeredQuestions: const [],
                isFlashcard: true,
              ),
            ),
          );
        },
        onRestart: () {
          Navigator.of(ctx).pop();
          setState(() {
            _currentIndex = 0;
            _correctCount = 0;
            _wrongCount = 0;
            _isProcessing = false;
            _allCards.shuffle();
          });
        },
      ),
    );
  }

  /// Flashcard seti görüntülendi olarak kaydet
  Future<void> _saveFlashcardSetViewed() async {
    if (widget.kartSetID != null && widget.topicId != null) {
      try {
        await DatabaseHelper().saveViewedFlashcardSet(
          widget.kartSetID!,
          widget.topicId!,
        );
        // Provider'ı invalidate et - badge güncellensin
        ref.invalidate(
          topicProgressProvider((topicId: widget.topicId!, mode: 'flashcard')),
        );
        ref.invalidate(
          topicProgressProvider((topicId: widget.topicId!, mode: 'all')),
        );
      } catch (e) {
        debugPrint('Flashcard set kaydı hatası: $e');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a0033), // Deep Violet
              Color(0xFF0d1b2a), // Night Blue
              Color(0xFF1b263b), // Dark Navy
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Dojo particles
            ..._buildParticles(),

            // Grid pattern overlay
            _buildGridPattern(),

            // Main content
            SafeArea(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                  ? _buildErrorState()
                  : _buildMainContent(),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF00f5d4),
                  Color(0xFF9b5de5),
                  Color(0xFFf15bb5),
                  Color(0xFFfee440),
                  Color(0xFF00bbf9),
                ],
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    return _particles.map((p) {
      return Positioned(
        left: p.x * MediaQuery.of(context).size.width,
        top: p.y * MediaQuery.of(context).size.height,
        child: Opacity(
          opacity: p.opacity,
          child: p.isKanji
              ? Text(
                  _getRandomKanji(),
                  style: TextStyle(
                    fontSize: p.size * 4,
                    color: const Color(0xFF9b5de5).withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00f5d4).withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00f5d4).withOpacity(0.5),
                        blurRadius: p.size * 2,
                        spreadRadius: p.size / 2,
                      ),
                    ],
                  ),
                ),
        ),
      );
    }).toList();
  }

  String _getRandomKanji() {
    const kanjis = ['道', '知', '学', '心', '力', '光', '星', '月', '火', '水'];
    return kanjis[math.Random().nextInt(kanjis.length)];
  }

  Widget _buildGridPattern() {
    return Opacity(
      opacity: 0.05,
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _GridPainter(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF00f5d4).withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '🏯 Dojo hazırlanıyor...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: const Color(0xFFf15bb5).withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Bir hata oluştu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCards,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9b5de5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Header with back button and title
        _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

        const SizedBox(height: 12),

        // Progress bar
        _buildProgressBar().animate().fadeIn(delay: 200.ms, duration: 400.ms),

        const SizedBox(height: 8),

        // Score HUD
        _buildScoreHUD().animate().fadeIn(delay: 300.ms, duration: 400.ms),

        const SizedBox(height: 16),

        // Motivation message
        _buildMotivationBanner().animate().fadeIn(
          delay: 400.ms,
          duration: 400.ms,
        ),

        // Card area
        Expanded(
          child: _buildCardArea()
              .animate()
              .fadeIn(delay: 500.ms, duration: 600.ms)
              .scale(begin: const Offset(0.9, 0.9)),
        ),

        // Control panel
        _buildControlPanel()
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms)
            .slideY(begin: 0.3),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00f5d4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.topicName ?? 'Bilgi Kartları',
                        style: TextStyle(
                          color: const Color(0xFF00f5d4),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00f5d4).withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Bilgi kartlarıyla pekiştir',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Card counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9b5de5).withOpacity(0.3),
                  const Color(0xFFf15bb5).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF9b5de5).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.style_rounded,
                  color: Color(0xFFf15bb5),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_currentIndex + 1}/${_allCards.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _allCards.isEmpty
        ? 0.0
        : (_currentIndex + 1) / _allCards.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LinearPercentIndicator(
        lineHeight: 8,
        percent: progress,
        backgroundColor: Colors.white.withOpacity(0.1),
        linearGradient: const LinearGradient(
          colors: [Color(0xFF00f5d4), Color(0xFF9b5de5), Color(0xFFf15bb5)],
        ),
        barRadius: const Radius.circular(10),
        animation: true,
        animationDuration: 300,
        animateFromLastPercent: true,
      ),
    );
  }

  Widget _buildScoreHUD() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Wrong counter
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(
                parent: _wrongScaleController,
                curve: Curves.elasticOut,
              ),
            ),
            child: _buildScoreBox(
              icon: Icons.close_rounded,
              label: 'Yanlış',
              count: _wrongCount,
              color: const Color(0xFFf15bb5),
              gradient: [
                const Color(0xFFf15bb5).withOpacity(0.2),
                const Color(0xFFf15bb5).withOpacity(0.1),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),

          // Correct counter
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(
                parent: _correctScaleController,
                curve: Curves.elasticOut,
              ),
            ),
            child: _buildScoreBox(
              icon: Icons.check_circle_outline_rounded,
              label: 'Doğru',
              count: _correctCount,
              color: const Color(0xFF00f5d4),
              gradient: [
                const Color(0xFF00f5d4).withOpacity(0.2),
                const Color(0xFF00f5d4).withOpacity(0.1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBox({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: color.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationBanner() {
    // Motivasyon rengi: doğru cevap yeşil, yanlış pembe, başlangıçta sarı
    Color motivationColor;
    if (_lastAnswerCorrect == true) {
      motivationColor = const Color(0xFF00f5d4);
    } else if (_lastAnswerCorrect == false) {
      motivationColor = const Color(0xFFf15bb5);
    } else {
      motivationColor = const Color(0xFFfee440);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _currentMotivation.isEmpty
            ? const SizedBox(height: 20)
            : Text(
                _currentMotivation,
                key: ValueKey(_currentMotivation),
                style: TextStyle(
                  color: motivationColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: motivationColor.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCardArea() {
    if (_allCards.isEmpty) return const SizedBox.shrink();

    final currentCard = _allCards[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate swipe feedback opacity
    final swipeProgress = (_dragOffset.dx / screenWidth).clamp(-1.0, 1.0);
    final showLeftOverlay = swipeProgress < -0.1;
    final showRightOverlay = swipeProgress > 0.1;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Swipe hint arrows
        if (!_isProcessing && !_showingResult) ...[
          // Left hint - Yanlış
          Positioned(
            left: 20,
            child: Opacity(
              opacity: 0.3,
              child: Column(
                children: [
                  Icon(
                    Icons.close_rounded,
                    color: const Color(0xFFf15bb5),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yanlış',
                    style: TextStyle(
                      color: const Color(0xFFf15bb5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right hint - Doğru
          Positioned(
            right: 20,
            child: Opacity(
              opacity: 0.3,
              child: Column(
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: const Color(0xFF00f5d4),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Doğru',
                    style: TextStyle(
                      color: const Color(0xFF00f5d4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // The card
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,

          // Tap to flip removed
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translate(_dragOffset.dx, _dragOffset.dy)
              ..rotateZ(_dragRotation),
            alignment: Alignment.center,
            child: Stack(
              children: [
                // Main flip card
                AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * math.pi;
                    final isBack = angle > math.pi / 2;

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isBack
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(math.pi),
                              alignment: Alignment.center,
                              child: _buildCardBack(currentCard),
                            )
                          : _buildCardFront(currentCard),
                    );
                  },
                ),

                // Swipe overlay - Left (red/pink)
                if (showLeftOverlay)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(
                          0xFFf15bb5,
                        ).withOpacity(swipeProgress.abs() * 0.4),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.replay_rounded,
                          color: Colors.white.withOpacity(swipeProgress.abs()),
                          size: 64,
                        ),
                      ),
                    ),
                  ),

                // Swipe overlay - Right (green/cyan)
                if (showRightOverlay)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(
                          0xFF00f5d4,
                        ).withOpacity(swipeProgress.abs() * 0.4),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white.withOpacity(swipeProgress.abs()),
                          size: 64,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardFront(FlashcardModel card) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1a2e).withOpacity(0.9),
                const Color(0xFF16213e).withOpacity(0.9),
                const Color(0xFF0f3460).withOpacity(0.9),
              ],
            ),
            border: Border.all(
              width: 2,
              color: Color.lerp(
                const Color(0xFF00f5d4),
                const Color(0xFF9b5de5),
                (_shimmerController.value * 2 - 1).abs(),
              )!.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00f5d4).withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFF9b5de5).withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(10, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Holographic shimmer effect
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment(-1 + _shimmerController.value * 3, -1),
                        end: Alignment(_shimmerController.value * 3, 1),
                        colors: const [
                          Colors.transparent,
                          Color(0x20FFFFFF),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Front indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00f5d4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00f5d4).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility_rounded,
                                color: Color(0xFF00f5d4),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ÖN YÜZ',
                                style: TextStyle(
                                  color: const Color(0xFF00f5d4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white.withOpacity(0.3),
                          size: 20,
                        ),
                      ],
                    ),

                    // Question content
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Text(
                            card.onyuz,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Swipe hint
                    Column(
                      children: [
                        Text(
                          '← Yanlış   |   Doğru →',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardBack(FlashcardModel card) {
    // Eğer sonuç gösteriliyorsa, kullanıcının doğru/yanlış cevabına göre renk belirle
    Color answerColor;
    String answerText;
    String motivationText;

    if (_showingResult && _lastAnswerCorrect != null) {
      // Kullanıcı cevap verdikten sonra sonuç gösteriliyor
      answerColor = _lastAnswerCorrect!
          ? const Color(0xFF00f5d4) // Doğru cevap - yeşil/cyan
          : const Color(0xFFf15bb5); // Yanlış cevap - pembe
      answerText = _lastAnswerCorrect! ? '✓ DOĞRU!' : '✗ YANLIŞ!';
      motivationText = _currentMotivation;
    } else {
      // Normal flip - kartın gerçek cevabını göster
      answerColor = card.dogruMu
          ? const Color(0xFF00f5d4)
          : const Color(0xFFf15bb5);
      answerText = card.dogruMu ? '✓ DOĞRU' : '✗ YANLIŞ';
      motivationText = '';
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            answerColor.withOpacity(0.15),
            const Color(0xFF1a1a2e).withOpacity(0.95),
            const Color(0xFF16213e).withOpacity(0.95),
          ],
        ),
        border: Border.all(width: 2, color: answerColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: answerColor.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Back indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: answerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: answerColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showingResult
                            ? Icons.emoji_events_rounded
                            : Icons.flip_rounded,
                        color: answerColor,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showingResult ? 'SONUÇ' : 'ARKA YÜZ',
                        style: TextStyle(
                          color: answerColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _lastAnswerCorrect == true
                      ? Icons.check_circle_rounded
                      : _lastAnswerCorrect == false
                      ? Icons.cancel_rounded
                      : card.dogruMu
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: answerColor,
                  size: 24,
                ),
              ],
            ),

            // Answer reveal with motivation
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Answer badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: answerColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: answerColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: answerColor.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Text(
                        answerText,
                        style: TextStyle(
                          color: answerColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: answerColor.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Motivasyon mesajı (sonuç gösteriliyorsa)
                    if (_showingResult && motivationText.isNotEmpty) ...[
                      Text(
                        motivationText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFfee440),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFfee440).withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ).animate().scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Original question (smaller)
                    Text(
                      card.onyuz,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Kartın gerçek cevabı (sonuç gösteriliyorsa)
                    if (_showingResult) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kartın Cevabı: ${card.dogruMu ? "DOĞRU" : "YANLIŞ"}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Swipe hint (sadece sonuç gösterilmiyorsa)
            if (!_showingResult)
              Text(
                '← Yanlış   |   Doğru →',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Yanlış button (Left - Sola kaydır)
          _buildControlButton(
            icon: Icons.close_rounded,
            label: 'Yanlış',
            color: const Color(0xFFf15bb5),
            onTap: () {
              HapticFeedback.mediumImpact();
              _handleSwipe(DismissDirection.endToStart);
            },
          ),

          // Doğru button (Right - Sağa kaydır)
          _buildControlButton(
            icon: Icons.check_rounded,
            label: 'Doğru',
            color: const Color(0xFF00f5d4),
            onTap: () {
              HapticFeedback.mediumImpact();
              _handleSwipe(DismissDirection.startToEnd);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    final size = isLarge ? 70.0 : 56.0;
    final iconSize = isLarge ? 32.0 : 24.0;

    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: Opacity(
        opacity: _isProcessing ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                ),
                border: Border.all(color: color.withOpacity(0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: iconSize),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPLETION DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class _CompletionDialog extends StatelessWidget {
  final int correctCount;
  final int wrongCount;
  final int totalCards;
  final VoidCallback onContinue;
  final VoidCallback onRestart;

  const _CompletionDialog({
    required this.correctCount,
    required this.wrongCount,
    required this.totalCards,
    required this.onContinue,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalCards > 0
        ? (correctCount / totalCards * 100).round()
        : 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e).withOpacity(0.95),
              const Color(0xFF16213e).withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00f5d4).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00f5d4).withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFfee440).withOpacity(0.3),
                        const Color(0xFFfee440).withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFfee440).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Text('🏆', style: TextStyle(fontSize: 48)),
                )
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .shimmer(duration: 1500.ms, color: const Color(0xFFfee440)),

            const SizedBox(height: 20),

            // Title
            Text(
              '🎉 Tebrikler!',
              style: TextStyle(
                color: const Color(0xFF00f5d4),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00f5d4).withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

            const SizedBox(height: 8),

            Text(
              'Dojo eğitimini tamamladın!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  '✓',
                  correctCount.toString(),
                  'Doğru',
                  const Color(0xFF00f5d4),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildStatColumn(
                  '✗',
                  wrongCount.toString(),
                  'Yanlış',
                  const Color(0xFFf15bb5),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildStatColumn(
                  '%',
                  percentage.toString(),
                  'Başarı',
                  const Color(0xFFfee440),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Restart button
                Expanded(
                  child: GestureDetector(
                    onTap: onRestart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9b5de5).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF9b5de5).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.replay_rounded,
                            color: Color(0xFF9b5de5),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tekrar',
                            style: TextStyle(
                              color: const Color(0xFF9b5de5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Continue button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onContinue,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00f5d4), Color(0xFF9b5de5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00f5d4).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Sonuçları Gör',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: 20, color: color)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 10)],
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER CLASSES
// ─────────────────────────────────────────────────────────────────────────────
class _DojoParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  bool isKanji;

  _DojoParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.isKanji,
  });
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
