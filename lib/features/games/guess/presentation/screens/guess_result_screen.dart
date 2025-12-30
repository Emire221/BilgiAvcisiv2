import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/entities/guess_level.dart';
import '../../../../../services/database_helper.dart';
import '../../../../../providers/repository_providers.dart';

/// Salla Bakalım Sonuç Ekranı - Shake Wave Victory Teması
class GuessResultScreen extends ConsumerStatefulWidget {
  final GuessLevel level;
  final int correctCount;
  final int totalQuestions;
  final int totalScore;

  const GuessResultScreen({
    super.key,
    required this.level,
    required this.correctCount,
    required this.totalQuestions,
    required this.totalScore,
  });

  @override
  ConsumerState<GuessResultScreen> createState() => _GuessResultScreenState();
}

class _GuessResultScreenState extends ConsumerState<GuessResultScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  late AnimationController _starController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  bool _showIntro = true;

  // Shake Wave Victory Teması Renkleri
  static const Color _primaryOrange = Color(0xFFFF6B35);
  static const Color _accentCyan = Color(0xFF00D9FF);
  static const Color _successGreen = Color(0xFF00E676);
  static const Color _goldColor = Color(0xFFFFD700);
  static const Color _deepPurple = Color(0xFF1A0A2E);
  static const Color _darkBg = Color(0xFF0D0D1A);

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.totalScore.toDouble(),
    ).animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOut));

    _starController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Intro overlay'i kapat
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _showIntro = false);
      }
    });

    // Animasyonları başlat ve sonucu kaydet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scoreController.forward();
      _starController.forward();
      HapticFeedback.mediumImpact();

      // Başarılıysa konfeti göster
      if (_getStarCount() >= 2) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }

      // Sonucu veritabanına kaydet
      _saveResult();
    });
  }

  Future<void> _saveResult() async {
    try {
      await DatabaseHelper().saveGuessResult(
        score: widget.totalScore,
        correctCount: widget.correctCount,
        totalQuestions: widget.totalQuestions,
        levelTitle: widget.level.title,
        difficulty: widget.level.difficulty,
        totalAttempts: 0, // Controller'dan gelmediği için şimdilik 0
      );

      // 🔴 Game progress provider'ı invalidate et - badge güncellensin
      ref.invalidate(gameProgressProvider('guess'));
    } catch (e) {
      if (kDebugMode) debugPrint('Salla Bakalım sonucu kaydedilemedi: $e');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreController.dispose();
    _starController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  int _getStarCount() {
    final percentage = widget.correctCount / widget.totalQuestions;
    if (percentage >= 1.0) return 3;
    if (percentage >= 0.7) return 2;
    if (percentage >= 0.4) return 1;
    return 0;
  }

  String _getResultMessage() {
    final starCount = _getStarCount();
    switch (starCount) {
      case 3:
        return 'Mükemmel!';
      case 2:
        return 'Harika!';
      case 1:
        return 'İyi Deneme!';
      default:
        return 'Daha Çalışmalısın';
    }
  }

  String _getResultEmoji() {
    final starCount = _getStarCount();
    switch (starCount) {
      case 3:
        return '🏆';
      case 2:
        return '🎉';
      case 1:
        return '👍';
      default:
        return '📚';
    }
  }

  Color _getResultColor() {
    final starCount = _getStarCount();
    switch (starCount) {
      case 3:
        return _goldColor;
      case 2:
        return _successGreen;
      case 1:
        return _accentCyan;
      default:
        return _primaryOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final starCount = _getStarCount();

    return Scaffold(
      body: Stack(
        children: [
          // Animasyonlu arka plan
          _buildAnimatedBackground(),

          // Floating partiküller
          ..._buildFloatingParticles(),

          // Ana içerik
          SafeArea(
            child: Column(
              children: [
                // Üst bar
                _buildTopBar()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.3, end: 0),

                // Ana içerik
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Başarı rozeti
                        _buildResultBadge(starCount)
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .scale(begin: const Offset(0.5, 0.5)),

                        const SizedBox(height: 24),

                        // Sonuç mesajı
                        _buildResultMessage().animate().fadeIn(
                          delay: 400.ms,
                          duration: 500.ms,
                        ),

                        const SizedBox(height: 32),

                        // İstatistikler
                        _buildStatsSection()
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 500.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 24),

                        // Seviye bilgisi
                        _buildLevelInfo()
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 500.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 32),

                        // Butonlar
                        _buildActionButtons()
                            .animate()
                            .fadeIn(delay: 1000.ms, duration: 500.ms)
                            .slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  ),
                ),
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
                _successGreen,
                _goldColor,
                Colors.pink,
                Colors.purple,
              ],
              numberOfParticles: 50,
              gravity: 0.2,
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
                  child:
                      Icon(FontAwesomeIcons.trophy, color: _goldColor, size: 64)
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                          )
                          .then()
                          .shimmer(color: Colors.white.withValues(alpha: 0.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _deepPurple,
            _darkBg,
            _getResultColor().withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(12, (index) {
      final random = math.Random(index);
      return Positioned(
        left: random.nextDouble() * MediaQuery.of(context).size.width,
        top: random.nextDouble() * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                math.sin(_pulseController.value * math.pi * 2 + index) * 20,
                math.cos(_pulseController.value * math.pi * 2 + index) * 20,
              ),
              child: Opacity(
                opacity: 0.3 + (_pulseController.value * 0.3),
                child: child,
              ),
            );
          },
          child: Container(
            width: 8 + random.nextDouble() * 12,
            height: 8 + random.nextDouble() * 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  (index % 3 == 0
                          ? _primaryOrange
                          : index % 3 == 1
                          ? _accentCyan
                          : _goldColor)
                      .withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color:
                      (index % 3 == 0
                              ? _primaryOrange
                              : index % 3 == 1
                              ? _accentCyan
                              : _goldColor)
                          .withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
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
              _buildGlassIconButton(
                icon: FontAwesomeIcons.xmark,
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                'SONUÇLAR',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildResultBadge(int starCount) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getResultColor().withValues(
                  alpha: 0.3 + (_glowController.value * 0.3),
                ),
                blurRadius: 30 + (_glowController.value * 20),
                spreadRadius: 5 + (_glowController.value * 10),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: _getResultColor().withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Yıldızlar
                AnimatedBuilder(
                  animation: _starController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _starController.value,
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isEarned = index < starCount;
                      final isMiddle = index == 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child:
                            Icon(
                                  isEarned
                                      ? FontAwesomeIcons.solidStar
                                      : FontAwesomeIcons.star,
                                  color: isEarned
                                      ? _goldColor
                                      : Colors.grey.withValues(alpha: 0.3),
                                  size: isMiddle ? 48 : 32,
                                )
                                .animate(
                                  delay: Duration(
                                    milliseconds: 300 + (index * 150),
                                  ),
                                )
                                .scale(
                                  begin: const Offset(0, 0),
                                  curve: Curves.elasticOut,
                                  duration: 600.ms,
                                ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 12),

                // Skor
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Text(
                      '${_scoreAnimation.value.toInt()}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: _getResultColor().withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                Text(
                  'puan',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultMessage() {
    return Column(
      children: [
        Text(
          _getResultEmoji(),
          style: const TextStyle(fontSize: 48),
        ).animate().scale(
          begin: const Offset(0, 0),
          duration: 500.ms,
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [_getResultColor(), _accentCyan],
          ).createShader(bounds),
          child: Text(
            _getResultMessage(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return ClipRRect(
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
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: FontAwesomeIcons.circleCheck,
                color: _successGreen,
                value: '${widget.correctCount}',
                label: 'Doğru',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: FontAwesomeIcons.circleXmark,
                color: const Color(0xFFFF5252),
                value: '${widget.totalQuestions - widget.correctCount}',
                label: 'Yanlış',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: FontAwesomeIcons.listCheck,
                color: _accentCyan,
                value: '${widget.totalQuestions}',
                label: 'Toplam',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelInfo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryOrange.withValues(alpha: 0.3),
                      _accentCyan.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _primaryOrange.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  FontAwesomeIcons.mobileScreenButton,
                  color: _primaryOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.level.title,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.level.description,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _getDifficultyColor().withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _getDifficultyText(),
                  style: GoogleFonts.nunito(
                    color: _getDifficultyColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyText() {
    switch (widget.level.difficulty) {
      case 1:
        return 'Kolay';
      case 2:
        return 'Orta';
      case 3:
        return 'Zor';
      default:
        return 'Orta';
    }
  }

  Color _getDifficultyColor() {
    switch (widget.level.difficulty) {
      case 1:
        return _successGreen;
      case 2:
        return _primaryOrange;
      case 3:
        return const Color(0xFFFF5252);
      default:
        return _primaryOrange;
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Ana sayfa butonu
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getResultColor(),
                  _getResultColor().withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getResultColor().withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.house,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ana Sayfa',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Tekrar oyna butonu
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getResultColor().withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.rotateRight,
                      color: _getResultColor(),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tekrar Oyna',
                      style: GoogleFonts.nunito(
                        color: _getResultColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
