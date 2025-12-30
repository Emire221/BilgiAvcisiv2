import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../services/database_helper.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🏆 NEON VICTORY CELEBRATION - Bul Bakalım Sonuç Ekranı
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Cyberpunk Zafer Sahnesi temalı sonuç deneyimi
/// - Neon glow efektleri ve confetti
/// - Glassmorphism stat kartları
/// - Animasyonlu skor gösterimi
/// - Epic yıldız reveal animasyonu
/// ═══════════════════════════════════════════════════════════════════════════

class MemoryResultScreen extends StatefulWidget {
  final int moves;
  final int mistakes;
  final int elapsedSeconds;
  final int score;
  final int starCount;

  const MemoryResultScreen({
    super.key,
    required this.moves,
    required this.mistakes,
    required this.elapsedSeconds,
    required this.score,
    required this.starCount,
  });

  @override
  State<MemoryResultScreen> createState() => _MemoryResultScreenState();
}

class _MemoryResultScreenState extends State<MemoryResultScreen>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _neonPink = Color(0xFFFF0080);
  static const Color _neonGreen = Color(0xFF39FF14);
  static const Color _neonGold = Color(0xFFFFD700);
  static const Color _neonRed = Color(0xFFFF3131);
  static const Color _darkBg = Color(0xFF0D0D1A);
  static const Color _darkBg2 = Color(0xFF1A1A2E);

  late ConfettiController _confettiController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  late AnimationController _starController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(begin: 0, end: widget.score.toDouble())
        .animate(
          CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
        );

    _starController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.heavyImpact();
      _starController.forward();

      Future.delayed(const Duration(milliseconds: 500), () {
        _scoreController.forward();
      });

      if (widget.starCount >= 2) {
        _confettiController.play();
      }

      _saveResult();
    });
  }

  Future<void> _saveResult() async {
    try {
      await DatabaseHelper().saveGameResult(
        gameType: 'memory',
        score: widget.score,
        correctCount: 10, // 10 kart bulundu
        wrongCount: widget.mistakes,
        totalQuestions: 10,
        details:
            '{"moves": ${widget.moves}, "mistakes": ${widget.mistakes}, "seconds": ${widget.elapsedSeconds}}',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Bul Bakalım sonucu kaydedilemedi: $e');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreController.dispose();
    _starController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getResultMessage() {
    switch (widget.starCount) {
      case 3:
        return 'Mükemmel Hafıza!';
      case 2:
        return 'Harika İş!';
      case 1:
        return 'İyi Deneme!';
      default:
        return 'Tekrar Dene!';
    }
  }

  String _getResultEmoji() {
    switch (widget.starCount) {
      case 3:
        return '🧠';
      case 2:
        return '🎉';
      case 1:
        return '👍';
      default:
        return '💪';
    }
  }

  Color _getResultColor() {
    switch (widget.starCount) {
      case 3:
        return _neonGold;
      case 2:
        return _neonGreen;
      case 1:
        return _neonCyan;
      default:
        return _neonPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final resultColor = _getResultColor();

    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // ANIMATED BACKGROUND
          // ═══════════════════════════════════════════════════════════════════
          AnimatedBuilder(
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
                      resultColor.withValues(alpha: 0.2 * _glowAnimation.value),
                      _darkBg2,
                      _darkBg,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // ═══════════════════════════════════════════════════════════════════
          // FLOATING PARTICLES
          // ═══════════════════════════════════════════════════════════════════
          ..._buildFloatingParticles(size, resultColor),

          // ═══════════════════════════════════════════════════════════════════
          // MAIN CONTENT
          // ═══════════════════════════════════════════════════════════════════
          SafeArea(
            child: Column(
              children: [
                // Üst bar
                _buildTopBar()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.3),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildResultBadge(resultColor)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(begin: const Offset(0.5, 0.5)),

                        const SizedBox(height: 24),

                        _buildResultMessage(resultColor)
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 200.ms)
                            .slideY(begin: 0.2),

                        const SizedBox(height: 32),

                        _buildStatsSection(resultColor)
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 400.ms)
                            .slideY(begin: 0.2),

                        const SizedBox(height: 32),

                        _buildActionButtons(resultColor)
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 600.ms)
                            .slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════════════════════════════
          // CONFETTI
          // ═══════════════════════════════════════════════════════════════════
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                _neonCyan,
                _neonPurple,
                _neonPink,
                _neonGreen,
                _neonGold,
              ],
              numberOfParticles: 60,
              gravity: 0.15,
              emissionFrequency: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingParticles(Size size, Color baseColor) {
    return List.generate(10, (index) {
      final random = index * 987654;
      final startX = (random % size.width.toInt()).toDouble();
      final startY = (random % size.height.toInt()).toDouble();
      final particleSize = 2.0 + (index % 4);
      final duration = 15 + (index % 10);

      return Positioned(
        left: startX,
        top: startY,
        child:
            Container(
                  width: particleSize,
                  height: particleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor.withValues(alpha: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                  begin: 0,
                  end: -60,
                  duration: Duration(seconds: duration),
                )
                .fadeOut(duration: Duration(seconds: duration)),
      );
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _neonPurple.withValues(alpha: 0.3),
                  _neonCyan.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _neonCyan.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'SONUÇLAR',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildResultBadge(Color resultColor) {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (_starController.value * 0.5),
          child: Opacity(opacity: _starController.value, child: child),
        );
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  resultColor.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: resultColor.withValues(
                  alpha: 0.5 + (0.3 * _glowAnimation.value),
                ),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: resultColor.withValues(
                    alpha: 0.3 * _glowAnimation.value,
                  ),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Yıldızlar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isEarned = index < widget.starCount;
                          final isMiddle = index == 1;
                          return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: Icon(
                                  isEarned
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: isEarned
                                      ? _neonGold
                                      : Colors.white.withValues(alpha: 0.3),
                                  size: isMiddle ? 52 : 38,
                                  shadows: isEarned
                                      ? [
                                          Shadow(
                                            color: _neonGold.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: 15,
                                          ),
                                        ]
                                      : null,
                                ),
                              )
                              .animate(
                                delay: Duration(
                                  milliseconds: 400 + (index * 150),
                                ),
                              )
                              .scale(
                                begin: const Offset(0, 0),
                                curve: Curves.elasticOut,
                              )
                              .fadeIn();
                        }),
                      ),
                      const SizedBox(height: 12),
                      // Skor
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return Text(
                            '${_scoreAnimation.value.toInt()}',
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: resultColor.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Text(
                        'PUAN',
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultMessage(Color resultColor) {
    return Column(
      children: [
        Text(_getResultEmoji(), style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          _getResultMessage(),
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: resultColor.withValues(alpha: 0.5), blurRadius: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(Color resultColor) {
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
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: resultColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    icon: Icons.timer_rounded,
                    color: _neonCyan,
                    value: _formatTime(widget.elapsedSeconds),
                    label: 'Süre',
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  _buildStatItem(
                    icon: Icons.touch_app_rounded,
                    color: _neonPurple,
                    value: '${widget.moves}',
                    label: 'Hamle',
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  _buildStatItem(
                    icon: Icons.close_rounded,
                    color: _neonRed,
                    value: '${widget.mistakes}',
                    label: 'Hata',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Performans mesajı
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      resultColor.withValues(alpha: 0.15),
                      resultColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: resultColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      color: resultColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.mistakes == 0
                          ? 'Hiç hata yapmadın!'
                          : widget.mistakes == 1
                          ? 'Sadece 1 hata!'
                          : '${widget.mistakes} hata yaptın',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 15,
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

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color resultColor) {
    return Column(
      children: [
        // Ana Sayfa butonu
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [resultColor, resultColor.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: resultColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Ana Sayfa',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Tekrar Oyna butonu
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: resultColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.replay_rounded, color: resultColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Tekrar Oyna',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
