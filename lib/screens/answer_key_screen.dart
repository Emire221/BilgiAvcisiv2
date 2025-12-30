import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Cevap Anahtarı Ekranı - Neon Review Teması
class AnswerKeyScreen extends StatefulWidget {
  final List<Map<String, dynamic>> answeredQuestions;

  const AnswerKeyScreen({super.key, required this.answeredQuestions});

  @override
  State<AnswerKeyScreen> createState() => _AnswerKeyScreenState();
}

class _AnswerKeyScreenState extends State<AnswerKeyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showIntro = true;

  // Neon Review Teması Renkleri
  static const Color _primaryPurple = Color(0xFF9C27B0);
  static const Color _accentCyan = Color(0xFF00D9FF);
  static const Color _successGreen = Color(0xFF00E676);
  static const Color _errorRed = Color(0xFFFF5252);
  static const Color _deepPurple = Color(0xFF1A0A2E);
  static const Color _darkBg = Color(0xFF0D0D1A);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Intro overlay'i kapat
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _showIntro = false);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int get _correctCount {
    int count = 0;
    for (final item in widget.answeredQuestions) {
      final question = item['question'] as Map<String, dynamic>?;
      if (question != null) {
        final userAnswer = item['userAnswer']?.toString() ?? '';
        final correctAnswer = question['dogruCevap']?.toString() ?? '';
        if (userAnswer == correctAnswer) count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
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

                // İstatistik özeti
                _buildSummarySection()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                // Soru listesi
                Expanded(
                  child: widget.answeredQuestions.isEmpty
                      ? _buildEmptyState()
                      : _buildQuestionsList(),
                ),
              ],
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
                      Icon(
                            FontAwesomeIcons.clipboardCheck,
                            color: _accentCyan,
                            size: 64,
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.1, 1.1),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepPurple, _darkBg, Color(0xFF150520)],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(10, (index) {
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
              child: Opacity(
                opacity: 0.2 + (_pulseController.value * 0.2),
                child: child,
              ),
            );
          },
          child: Container(
            width: 6 + random.nextDouble() * 10,
            height: 6 + random.nextDouble() * 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (index.isEven ? _primaryPurple : _accentCyan).withValues(
                alpha: 0.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (index.isEven ? _primaryPurple : _accentCyan)
                      .withValues(alpha: 0.4),
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
                icon: FontAwesomeIcons.arrowLeft,
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.clipboardCheck,
                    color: _accentCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CEVAP ANAHTARI',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
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
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildSummarySection() {
    final total = widget.answeredQuestions.length;
    final correct = _correctCount;
    final wrong = total - correct;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  icon: FontAwesomeIcons.circleCheck,
                  value: '$correct',
                  label: 'Doğru',
                  color: _successGreen,
                ),
                _buildSummaryDivider(),
                _buildSummaryItem(
                  icon: FontAwesomeIcons.circleXmark,
                  value: '$wrong',
                  label: 'Yanlış',
                  color: _errorRed,
                ),
                _buildSummaryDivider(),
                _buildSummaryItem(
                  icon: FontAwesomeIcons.listCheck,
                  value: '$total',
                  label: 'Toplam',
                  color: _accentCyan,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 50,
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

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
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
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.inbox,
              color: Colors.white.withValues(alpha: 0.5),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hiç soru cevaplanmadı',
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildQuestionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.answeredQuestions.length,
      itemBuilder: (context, index) {
        return _buildQuestionCard(index)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 + (index * 50)))
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildQuestionCard(int index) {
    try {
      final item = widget.answeredQuestions[index];
      final question = item['question'] as Map<String, dynamic>?;

      if (question == null) {
        return _buildErrorCard(index);
      }

      final userAnswer = item['userAnswer']?.toString() ?? '-';
      final correctAnswer = question['dogruCevap']?.toString() ?? '';
      final questionNumber =
          item['questionNumber']?.toString() ?? '${index + 1}';
      final isCorrect = userAnswer == correctAnswer;
      final questionText =
          question['soruMetni']?.toString() ?? 'Soru metni bulunamadı';

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (isCorrect ? _successGreen : _errorRed).withValues(
                      alpha: 0.15,
                    ),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isCorrect ? _successGreen : _errorRed).withValues(
                    alpha: 0.4,
                  ),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst kısım: Soru numarası + Sonuç ikonu
                  Row(
                    children: [
                      // Sonuç ikonu
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isCorrect ? _successGreen : _errorRed)
                              .withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isCorrect ? _successGreen : _errorRed)
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isCorrect
                              ? FontAwesomeIcons.check
                              : FontAwesomeIcons.xmark,
                          color: isCorrect ? _successGreen : _errorRed,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Soru $questionNumber',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              isCorrect ? 'Doğru cevapladın!' : 'Yanlış cevap',
                              style: GoogleFonts.nunito(
                                color: (isCorrect ? _successGreen : _errorRed)
                                    .withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Soru metni
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      questionText,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Cevaplar
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnswerChip(
                          label: 'Doğru Cevap',
                          value: correctAnswer,
                          color: _successGreen,
                          icon: FontAwesomeIcons.circleCheck,
                        ),
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildAnswerChip(
                            label: 'Senin Cevabın',
                            value: userAnswer,
                            color: _errorRed,
                            icon: FontAwesomeIcons.circleXmark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return _buildErrorCard(index);
    }
  }

  Widget _buildAnswerChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: color.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.amber.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Soru #${index + 1} verisi okunamadı',
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
