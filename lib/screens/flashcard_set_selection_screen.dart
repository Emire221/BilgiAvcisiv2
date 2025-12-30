import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/repository_providers.dart';
import '../core/providers/user_provider.dart';
import 'flashcards_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🃏 BİLGİ KARTLARI SEÇİM - Modern Neon Tema
/// ═══════════════════════════════════════════════════════════════════════════
class FlashcardSetSelectionScreen extends ConsumerStatefulWidget {
  final String topicId;
  final String topicName;
  final String lessonName;

  const FlashcardSetSelectionScreen({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.lessonName,
  });

  @override
  ConsumerState<FlashcardSetSelectionScreen> createState() =>
      _FlashcardSetSelectionScreenState();
}

class _FlashcardSetSelectionScreenState
    extends ConsumerState<FlashcardSetSelectionScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _flashcardSets = [];

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Tema renkleri - Yeşil/Turkuaz tema
  static const Color _neonGreen = Color(0xFF10B981);
  static const Color _neonCyan = Color(0xFF00D4FF);
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

    _loadFlashcardSets();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcardSets() async {
    try {
      final userProfile = ref.read(userProfileProvider);
      final userGrade = userProfile.value?['grade'] ?? '3. Sınıf';
      final repository = ref.read(flashcardRepositoryProvider);

      final sets = await repository.getFlashcards(
        userGrade,
        widget.lessonName,
        widget.topicId,
      );

      if (mounted) {
        setState(() {
          _flashcardSets = sets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Bilgi kartları yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                _neonGreen.withValues(alpha: 0.15 * _glowAnimation.value),
                _neonCyan.withValues(alpha: 0.1 * _glowAnimation.value),
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
      final colors = [_neonGreen, _neonCyan, _neonPurple];
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
                    Icon(Icons.style_rounded, color: _neonGreen, size: 24),
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
                              color: _neonGreen.withValues(alpha: 0.5),
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
                    color: _neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _neonGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'BİLGİ KARTLARIYLA PEKİŞTİR',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _neonGreen,
                      letterSpacing: 1,
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
                color: _neonGreen,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bilgi kartları yükleniyor...',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    if (_flashcardSets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _neonGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _neonGreen.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.style_outlined, size: 48, color: _neonGreen),
            ),
            const SizedBox(height: 24),
            Text(
              'Bu konuda henüz bilgi kartı bulunmuyor',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _flashcardSets.length,
      itemBuilder: (context, index) {
        return _FlashcardSetCard(
              flashcardSet: _flashcardSets[index],
              index: index,
              topicId: widget.topicId,
              glowAnimation: _glowAnimation,
            )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: Duration(milliseconds: index < 10 ? 80 * index : 0),
            )
            .slideX(begin: 0.1);
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Bilgi Kartı Seti Widget'ı - Modern Glassmorphism
/// ═══════════════════════════════════════════════════════════════════════════
class _FlashcardSetCard extends ConsumerWidget {
  final dynamic flashcardSet;
  final int index;
  final String topicId;
  final Animation<double> glowAnimation;

  static const Color _neonGreen = Color(0xFF10B981);

  const _FlashcardSetCard({
    required this.flashcardSet,
    required this.index,
    required this.topicId,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kartSetID = flashcardSet.kartSetID as String;
    final isViewedAsync = ref.watch(isFlashcardViewedProvider(kartSetID));
    final isViewed = isViewedAsync.maybeWhen(
      data: (viewed) => viewed,
      orElse: () => false,
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashcardsScreen(
              topicId: topicId,
              topicName: flashcardSet.kartAdi,
              kartSetID: kartSetID,
              initialCards: flashcardSet.kartlar,
            ),
          ),
        ).then((_) {
          ref.invalidate(isFlashcardViewedProvider(kartSetID));
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
                      color: isViewed
                          ? Colors.green.withValues(alpha: 0.5)
                          : _neonGreen.withValues(
                              alpha: 0.3 + (0.2 * glowAnimation.value),
                            ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _neonGreen.withValues(
                          alpha: 0.15 * glowAnimation.value,
                        ),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Set number badge
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: isViewed
                              ? LinearGradient(
                                  colors: [
                                    Colors.green,
                                    Colors.green.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    _neonGreen,
                                    _neonGreen.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: isViewed
                                  ? Colors.green.withValues(alpha: 0.4)
                                  : _neonGreen.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: isViewed
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Set info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    flashcardSet.kartAdi,
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
                                if (!isViewed)
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
                                          Icons.visibility,
                                          color: Colors.green,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'GÖRÜNTÜLENDI',
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
                            const SizedBox(height: 8),
                            // Kart sayısı
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.style,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${flashcardSet.kartlar.length} Kart',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                              _neonGreen.withValues(alpha: 0.3),
                              _neonGreen.withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _neonGreen.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Icon(
                          isViewed
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
}
