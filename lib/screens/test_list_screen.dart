import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_service.dart';
import '../providers/repository_providers.dart';
import 'test_screen.dart';
import '../core/providers/user_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📝 TEST LİSTESİ - Modern Neon Tema
/// ═══════════════════════════════════════════════════════════════════════════
class TestListScreen extends ConsumerStatefulWidget {
  final String topicId;
  final String topicName;
  final String lessonName;
  final Color color;

  const TestListScreen({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.lessonName,
    required this.color,
  });

  @override
  ConsumerState<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends ConsumerState<TestListScreen>
    with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  List<dynamic> _tests = [];
  bool _isLoading = true;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Tema renkleri
  static const Color _neonBlue = Color(0xFF00D4FF);
  static const Color _neonPurple = Color(0xFFBF40FF);
  static const Color _darkBg = Color(0xFF0D0D1A);
  static const Color _darkBg2 = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _loadTests();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadTests() async {
    final userProfile = ref.read(userProfileProvider);
    final userGrade = userProfile.value?['grade'] ?? '3. Sınıf';

    final tests = await _dataService.getTests(
      userGrade,
      widget.lessonName,
      widget.topicId,
    );
    if (mounted) {
      setState(() {
        _tests = tests;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Floating Particles
          ..._buildFloatingParticles(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.3),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
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
                widget.color.withValues(alpha: 0.15 * _glowAnimation.value),
                _neonPurple.withValues(alpha: 0.1 * _glowAnimation.value),
                _darkBg2,
                _darkBg,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingParticles() {
    final size = MediaQuery.of(context).size;
    return List.generate(8, (index) {
      final random = index * 654321;
      final startX = (random % size.width.toInt()).toDouble();
      final startY = (random % size.height.toInt()).toDouble();
      final particleSize = 2.0 + (index % 4);
      final duration = 18 + (index % 12);
      final colors = [_neonBlue, _neonPurple, widget.color];
      final color = colors[index % colors.length];

      return Positioned(
        left: startX,
        top: startY,
        child:
            Container(
                  width: particleSize,
                  height: particleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                  begin: 0,
                  end: -70,
                  duration: Duration(seconds: duration),
                )
                .fadeOut(duration: Duration(seconds: duration)),
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
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
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_rounded, color: widget.color, size: 24),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.topicName,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: widget.color.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'TESTLER',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: widget.color,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Testler yükleniyor...',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    if (_tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: widget.color.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.quiz_outlined, size: 48, color: widget.color),
            ),
            const SizedBox(height: 24),
            Text(
              'Bu konuda henüz test bulunmuyor',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tests.length,
      itemBuilder: (context, index) {
        return _TestCard(
              test: _tests[index],
              index: index,
              topicId: widget.topicId,
              topicName: widget.topicName,
              accentColor: widget.color,
              glowAnimation: _glowAnimation,
            )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: Duration(milliseconds: index < 5 ? 80 * index : 0),
            )
            .slideX(begin: 0.1);
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Test Kartı Widget'ı - Modern Glassmorphism
/// ═══════════════════════════════════════════════════════════════════════════
class _TestCard extends ConsumerWidget {
  final dynamic test;
  final int index;
  final String topicId;
  final String topicName;
  final Color accentColor;
  final Animation<double> glowAnimation;

  const _TestCard({
    required this.test,
    required this.index,
    required this.topicId,
    required this.topicName,
    required this.accentColor,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testId = test['testID'] as String;
    final isSolvedAsync = ref.watch(isTestSolvedProvider(testId));
    final isSolved = isSolvedAsync.maybeWhen(
      data: (solved) => solved,
      orElse: () => false,
    );

    final difficulty = test['zorluk'] as int;
    final difficultyColors = _getDifficultyColors(difficulty);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestScreen(
              topicId: topicId,
              topicName: topicName,
              testData: test,
            ),
          ),
        ).then((_) {
          ref.invalidate(isTestSolvedProvider(testId));
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedBuilder(
              animation: glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSolved
                          ? Colors.green.withValues(alpha: 0.5)
                          : difficultyColors[0].withValues(
                              alpha: 0.3 + (0.2 * glowAnimation.value),
                            ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: difficultyColors[0].withValues(
                          alpha: 0.15 * glowAnimation.value,
                        ),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Test number badge
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: isSolved
                              ? LinearGradient(
                                  colors: [
                                    Colors.green,
                                    Colors.green.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: difficultyColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isSolved
                                  ? Colors.green.withValues(alpha: 0.4)
                                  : difficultyColors[0].withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: isSolved
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Test info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    test['testAdi'],
                                    style: GoogleFonts.nunito(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Badge
                                if (!isSolved)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B6B),
                                          Color(0xFFFF5252),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'YENİ',
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ÇÖZÜLDÜ',
                                          style: GoogleFonts.nunito(
                                            color: Colors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                // Soru sayısı
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.help_outline,
                                        size: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${test['sorular'].length} Soru',
                                        style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Zorluk
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: difficultyColors[0].withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: difficultyColors[0].withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _getDifficultyText(difficulty),
                                    style: GoogleFonts.nunito(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Play icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              difficultyColors[0].withValues(alpha: 0.3),
                              difficultyColors[1].withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: difficultyColors[0].withValues(alpha: 0.5),
                          ),
                        ),
                        child: Icon(
                          isSolved
                              ? Icons.replay_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getDifficultyColors(int difficulty) {
    switch (difficulty) {
      case 1:
        return [
          const Color(0xFF39FF14),
          const Color(0xFF39FF14).withValues(alpha: 0.7),
        ]; // Kolay - Yeşil
      case 2:
        return [
          const Color(0xFFFF6B35),
          const Color(0xFFFF6B35).withValues(alpha: 0.7),
        ]; // Orta - Turuncu
      case 3:
        return [
          const Color(0xFFFF0080),
          const Color(0xFFFF0080).withValues(alpha: 0.7),
        ]; // Zor - Pembe
      default:
        return [const Color(0xFF00D4FF), const Color(0xFFBF40FF)]; // Varsayılan
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Kolay';
      case 2:
        return 'Orta';
      case 3:
        return 'Zor';
      default:
        return 'Bilinmiyor';
    }
  }
}
