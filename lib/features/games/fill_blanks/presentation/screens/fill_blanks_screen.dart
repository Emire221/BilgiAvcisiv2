import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/fill_blanks_level.dart';
import '../../domain/entities/fill_blanks_question.dart';
import '../../../../../services/database_helper.dart';
import '../../../../../providers/repository_providers.dart';
import '../../../../mascot/presentation/providers/mascot_provider.dart';

/// "Sky Journey" - Cümle Tamamlama Oyunu
/// Gökyüzünde bulutların arasında kelime yakalama macerası
class FillBlanksScreen extends ConsumerStatefulWidget {
  final FillBlanksLevel level;

  const FillBlanksScreen({super.key, required this.level});

  @override
  ConsumerState<FillBlanksScreen> createState() => _FillBlanksScreenState();
}

class _FillBlanksScreenState extends ConsumerState<FillBlanksScreen>
    with TickerProviderStateMixin {
  // Oyun durumu
  late List<FillBlanksQuestion> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _showIntro = true;

  // Animasyon controller'ları
  late AnimationController _cloudController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Sky Journey renk paleti
  static const Color _skyTop = Color(0xFF4FACFE);
  static const Color _skyBottom = Color(0xFF00F2FE);
  
  // Night Mode (Dark) Renk Paleti - Bright Night
  static const Color _nightTop = Color(0xFF2B32B2);
  static const Color _nightMid = Color(0xFF1488CC);
  static const Color _nightBottom = Color(0xFF00C6FF);
  
  // Koyu yeşil (okunabilir)
  static const Color _correctGreen = Color(0xFF1B5E20);
  static const Color _wrongRed = Color(0xFFFF5E62);
  static const Color _goldStar = Color(0xFFFFD700);
  static const Color _purpleAccent = Color(0xFF9B59B6);
  static const Color _orangeAccent = Color(0xFFFF9966);

  // Motivasyon mesajları
  List<String> _dogruMesajlar = [];
  List<String> _yanlisMesajlar = [];
  String _currentFeedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _questions = widget.level.questions;
    _loadMotivationMessages();

    // Bulut animasyonu
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    // Pulse animasyonu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Shake animasyonu (yanlış cevap için)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Intro animasyonunu kapat
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _showIntro = false);
      }
    });
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// JSON dosyalarından motivasyon mesajlarını yükle
  Future<void> _loadMotivationMessages() async {
    try {
      final dogruJson = await rootBundle.loadString('assets/json/dogru.json');
      final dogruData = json.decode(dogruJson) as Map<String, dynamic>;
      _dogruMesajlar = List<String>.from(dogruData['mesajlar'] ?? []);

      final yanlisJson = await rootBundle.loadString('assets/json/yanlis.json');
      final yanlisData = json.decode(yanlisJson) as Map<String, dynamic>;
      _yanlisMesajlar = List<String>.from(yanlisData['mesajlar'] ?? []);
    } catch (e) {
      _dogruMesajlar = ['Harikastn! 🎉', 'Süper! ⭐', 'Mükemmel! 🏆'];
      _yanlisMesajlar = ['Bir Dahakine! 💫', 'Pes Etme! 🚀', 'Devam Et! 💪'];
    }
  }

  String _getRandomMessage(bool isCorrect) {
    final messages = isCorrect ? _dogruMesajlar : _yanlisMesajlar;
    if (messages.isEmpty) {
      return isCorrect ? 'Doğru! 🎉' : 'Yanlış! 💪';
    }
    return messages[Random().nextInt(messages.length)];
  }

  void _onAnswerDropped(String answer) {
    if (_showFeedback) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == _questions[_currentQuestionIndex].answer;
      _currentFeedbackMessage = _getRandomMessage(_isCorrect);
      _showFeedback = true;

      if (_isCorrect) {
        _score++;
        HapticFeedback.lightImpact();
      } else {
        _shakeController.forward().then((_) => _shakeController.reset());
        HapticFeedback.heavyImpact();
      }
    });

    // 1.8 saniye sonra sonraki soruya geç
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _showFeedback = false;
        });
      } else {
        _showResultScreen();
      }
    });
  }

  void _showResultScreen() {
    _saveResults();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Result',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return _ResultOverlay(
          score: _score,
          totalQuestions: _questions.length,
          levelTitle: widget.level.title,
          onClose: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          onReplay: () {
            Navigator.pop(context);
            setState(() {
              _questions = widget.level.questions;
              _currentQuestionIndex = 0;
              _score = 0;
              _selectedAnswer = null;
              _showFeedback = false;
            });
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    final currentQuestion = _questions[_currentQuestionIndex];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Oyun sırasında geri tuşu devre dışı
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Gökyüzü Gradient Arka Plan
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark 
                      ? [_nightTop, _nightMid, _nightBottom] 
                      : [_skyTop, _skyBottom],
                ),
              ),
            ),

            // 2. Akan Bulutlar
            ..._buildFloatingClouds(screenSize),

            // 3. Ana Oyun İçeriği
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(safePadding),

                  // Progress Bar
                  _buildProgressBar(),

                  // Oyun Alanı
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        final shakeOffset =
                            sin(_shakeAnimation.value * 4 * pi) * 10;
                        return Transform.translate(
                          offset: Offset(
                            _showFeedback && !_isCorrect ? shakeOffset : 0,
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Soru Kartı
                            _buildQuestionCard(currentQuestion),

                            const SizedBox(height: 20),

                            // Bilgilendirme ipucu
                            if (!_showFeedback) _buildInstructionHint(),

                            const SizedBox(height: 16),

                            // Seçenekler veya Feedback
                            if (!_showFeedback)
                              _buildOptions(currentQuestion)
                            else
                              _buildFeedback(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Intro Overlay
            if (_showIntro) _buildIntroOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(EdgeInsets safePadding) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Boş alan (simetri için)
          const SizedBox(width: 44),

          const SizedBox(width: 12),

          // Seviye Başlığı - Responsive Fix
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.level.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Soru ${_currentQuestionIndex + 1} / ${_questions.length}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Skor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_goldStar, Color(0xFFFFB347)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _goldStar.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$_score',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildProgressBar() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 8,
      width: double.infinity, // LayoutBuilder için genişlik zorunlu
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_orangeAccent, _wrongRed],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _orangeAccent.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(FillBlanksQuestion question) {
    // Cümleyi boşluktan ayır
    final parts = question.question.split('____');
    final beforeBlank = parts.isNotEmpty ? parts[0] : '';
    final afterBlank = parts.length > 1 ? parts[1] : '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF0F2027).withValues(alpha: 0.8) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final placeholderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final placeholderTextColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    // Responsive Drop Fix: Tüm kartı DragTarget yap
    return DragTarget<String>(
      onAcceptWithDetails: (data) => _onAnswerDropped(data.data),
      builder: (context, cardCandidates, _) {
        final isCardHovering = cardCandidates.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              if (isCardHovering) // Kart üzerindeyken glow efekti
                BoxShadow(
                  color: _purpleAccent.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
            ],
            border: isCardHovering 
                ? Border.all(color: _purpleAccent.withValues(alpha: 0.5), width: 2)
                : null,
          ),
          child: Column(
            children: [
              // Soru ikonu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_skyTop, _skyBottom]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(height: 20),

              // Cümle ve boşluk
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (beforeBlank.isNotEmpty)
                    Text(
                      beforeBlank,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  // Boşluk alanı (Drop Target)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DragTarget<String>(
                      onAcceptWithDetails: (data) =>
                          _onAnswerDropped(data.data),
                      builder: (context, innerCandidates, _) {
                        // Kart veya kutu üzerinde ise hover efekti göster
                        final isHovering = isCardHovering || innerCandidates.isNotEmpty;

                        return AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulseScale =
                                _selectedAnswer == null && !_showFeedback
                                ? 1.0 + (_pulseController.value * 0.03)
                                : 1.0;

                            return Transform.scale(
                              scale: pulseScale,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 120,
                                ),
                                decoration: BoxDecoration(
                                  gradient: _showFeedback
                                      ? LinearGradient(
                                          colors: _isCorrect
                                              ? [
                                                  _correctGreen,
                                                  _correctGreen.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                ]
                                              : [
                                                  _wrongRed,
                                                  _wrongRed.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                ],
                                        )
                                      : isHovering
                                      ? const LinearGradient(
                                          colors: [
                                            _purpleAccent,
                                            Color(0xFF8E44AD),
                                          ],
                                        )
                                      : null,
                                  color: !_showFeedback && !isHovering
                                      ? placeholderColor
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _showFeedback
                                        ? (_isCorrect
                                              ? _correctGreen
                                              : _wrongRed)
                                        : isHovering
                                        ? _purpleAccent
                                        : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                    width: 2,
                                  ),
                                  boxShadow: isHovering || _showFeedback
                                      ? [
                                          BoxShadow(
                                            color:
                                                (_showFeedback
                                                        ? (_isCorrect
                                                              ? _correctGreen
                                                              : _wrongRed)
                                                        : _purpleAccent)
                                                    .withValues(alpha: 0.4),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  _selectedAnswer ?? '____',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedAnswer != null || isHovering
                                        ? Colors.white
                                        : placeholderTextColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  if (afterBlank.isNotEmpty)
                    Text(
                      afterBlank,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildOptions(FillBlanksQuestion question) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        return Draggable<String>(
              data: option,
              feedback: Material(
                color: Colors.transparent,
                child: Transform.rotate(
                  angle: 0.05,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_purpleAccent, Color(0xFF8E44AD)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _purpleAccent.withValues(alpha: 0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      option,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.4,
                child: _buildOptionBubble(option, index),
              ),
              child: _buildOptionBubble(option, index),
            )
            .animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
      }).toList(),
    );
  }

  Widget _buildOptionBubble(String option, int index) {
    // Her seçenek için farklı renk
    final colors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
    ];
    final colorPair = colors[index % colors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorPair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorPair[0].withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        option,
        style: GoogleFonts.nunito(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Büyük ikon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isCorrect
                ? _correctGreen.withValues(alpha: 0.15)
                : _wrongRed.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            color: _isCorrect ? _correctGreen : _wrongRed,
            size: 80,
          ),
        ).animate().scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 600.ms,
        ),

        const SizedBox(height: 16),

        // Mesaj
        Text(
          _currentFeedbackMessage,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _isCorrect ? _correctGreen : _wrongRed,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),

        if (!_isCorrect) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _correctGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _correctGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Doğru cevap: ',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  _questions[_currentQuestionIndex].answer,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _correctGreen,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ],
    );
  }

  Widget _buildIntroOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Seviye ikonu
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_skyTop, _skyBottom]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _skyTop.withValues(alpha: 0.5),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(Icons.edit_note, color: Colors.white, size: 60),
            ).animate().scale(
              begin: const Offset(0, 0),
              curve: Curves.elasticOut,
              duration: 800.ms,
            ),

            const SizedBox(height: 24),

            Text(
              widget.level.title,
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 8),

            Text(
              '${_questions.length} Soru',
              style: GoogleFonts.nunito(fontSize: 18, color: Colors.white70),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 16),

            Text(
              'Kelimeleri sürükleyip boşluğa bırak!',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: _goldStar,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 40),

            // Zorluk yıldızları
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                      index < widget.level.difficulty
                          ? Icons.star
                          : Icons.star_border,
                      color: _goldStar,
                      size: 32,
                    )
                    .animate(delay: Duration(milliseconds: 900 + (index * 100)))
                    .scale(begin: const Offset(0, 0), curve: Curves.elasticOut);
              }),
            ),
          ],
        ),
      ),
    ).animate().fadeOut(delay: 1800.ms, duration: 200.ms);
  }

  List<Widget> _buildFloatingClouds(Size screenSize) {
    return [
      // Bulut 1
      AnimatedBuilder(
        animation: _cloudController,
        builder: (context, child) {
          return Positioned(
            top: screenSize.height * 0.08,
            left: screenSize.width * (1 - _cloudController.value * 1.5),
            child: _buildCloud(70, 0.25),
          );
        },
      ),
      // Bulut 2
      AnimatedBuilder(
        animation: _cloudController,
        builder: (context, child) {
          final offset = (_cloudController.value + 0.4) % 1.0;
          return Positioned(
            top: screenSize.height * 0.35,
            left: screenSize.width * (1.2 - offset * 1.5),
            child: _buildCloud(90, 0.2),
          );
        },
      ),
      // Bulut 3
      AnimatedBuilder(
        animation: _cloudController,
        builder: (context, child) {
          final offset = (_cloudController.value + 0.7) % 1.0;
          return Positioned(
            top: screenSize.height * 0.6,
            left: screenSize.width * (1.3 - offset * 1.5),
            child: _buildCloud(80, 0.15),
          );
        },
      ),
    ];
  }

  Widget _buildCloud(double size, double opacity) {
    return IgnorePointer(
      child: Icon(
        Icons.cloud,
        size: size,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }





  /// Bilgilendirici ipucu widget'ı
  Widget _buildInstructionHint() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2D2D2D) : Colors.white.withValues(alpha: 0.95);
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _purpleAccent.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _purpleAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.touch_app, color: _purpleAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            'Doğru cevabı kutucuğa sürükle 👆',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Future<void> _saveResults() async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.saveGameResult(
        gameType: 'fill_blanks',
        score: _score * 10,
        correctCount: _score,
        wrongCount: _questions.length - _score,
        totalQuestions: _questions.length,
        details: widget.level.title,
      );

      // 🔴 Game progress provider'ı invalidate et - badge güncellensin
      ref.invalidate(gameProgressProvider('fill_blanks'));

      // Maskota XP ekle
      await _addXpToMascot();
    } catch (e) {
      if (kDebugMode) debugPrint('Sonuç kaydetme hatası: $e');
    }
  }

  Future<void> _addXpToMascot() async {
    try {
      final mascotRepository = ref.read(mascotRepositoryProvider);
      await mascotRepository.addXp(1);
      ref.invalidate(activeMascotProvider);
      if (kDebugMode) debugPrint('Fill Blanks oyunu - Maskota 1 XP eklendi');
    } catch (e) {
      if (kDebugMode) debugPrint('Maskot XP ekleme hatası: $e');
    }
  }
}

/// Sonuç Ekranı Overlay'i
class _ResultOverlay extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String levelTitle;
  final VoidCallback onClose;
  final VoidCallback onReplay;

  const _ResultOverlay({
    required this.score,
    required this.totalQuestions,
    required this.levelTitle,
    required this.onClose,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final stars = _calculateStars();

    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _FillBlanksScreenState._skyTop.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Text(
                '🎊 Oyun Bitti!',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                levelTitle,
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              // Yıldızlar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final filled = index < stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child:
                        Icon(
                              filled ? Icons.star : Icons.star_border,
                              color: _FillBlanksScreenState._goldStar,
                              size: 48,
                            )
                            .animate(
                              delay: Duration(
                                milliseconds: 200 + (index * 150),
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

              const SizedBox(height: 24),

              // Skor
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _FillBlanksScreenState._skyTop,
                      _FillBlanksScreenState._skyBottom,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score / $totalQuestions',
                      style: GoogleFonts.nunito(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '%$percentage Başarı',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Motivasyon mesajı
              Text(
                _getMotivationMessage(),
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _FillBlanksScreenState._correctGreen,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onClose,
                      icon: const Icon(Icons.home),
                      label: Text(
                        'Ana Sayfa',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: _FillBlanksScreenState._skyTop,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReplay,
                      icon: const Icon(Icons.replay, color: Colors.white),
                      label: Text(
                        'Tekrar',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _FillBlanksScreenState._orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
    );
  }

  int _calculateStars() {
    final percentage = score / totalQuestions;
    if (percentage >= 0.9) return 3;
    if (percentage >= 0.7) return 2;
    if (percentage >= 0.5) return 1;
    return 0;
  }

  String _getMotivationMessage() {
    final percentage = score / totalQuestions;
    if (percentage >= 0.9) return 'Muhteşem! Süpersin! 🌟';
    if (percentage >= 0.7) return 'Harika iş! Çok iyisin! 🎉';
    if (percentage >= 0.5) return 'İyi gidiyorsun! 💪';
    return 'Pratik yapmaya devam et! 📚';
  }
}
