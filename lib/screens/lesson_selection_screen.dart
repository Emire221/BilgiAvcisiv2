import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_helper.dart';
import 'topic_selection_screen.dart';

/// 🎴 Holografik Yetenek Kartları - Ders Seçim Ekranı
class LessonSelectionScreen extends StatefulWidget {
  final String mode; // 'test', 'video', 'flashcard'

  const LessonSelectionScreen({super.key, this.mode = 'all'});

  @override
  State<LessonSelectionScreen> createState() => _LessonSelectionScreenState();
}

class _LessonSelectionScreenState extends State<LessonSelectionScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = true;
  late AnimationController _bgController;

  // Ders ikonları
  IconData _getIconForLesson(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'book':
      case 'turkce':
        return FontAwesomeIcons.bookOpen;
      case 'calculate':
      case 'matematik':
        return FontAwesomeIcons.calculator;
      case 'science':
      case 'fen':
        return FontAwesomeIcons.flask;
      case 'public':
      case 'sosyal':
        return FontAwesomeIcons.earthAmericas;
      case 'language':
      case 'ingilizce':
        return FontAwesomeIcons.language;
      case 'history_edu':
      case 'din':
        return FontAwesomeIcons.handsPraying;
      case 'palette':
      case 'sanat':
        return FontAwesomeIcons.palette;
      case 'music':
      case 'muzik':
        return FontAwesomeIcons.music;
      case 'code':
      case 'bilisim':
        return FontAwesomeIcons.code;
      case 'sports':
      case 'beden':
        return FontAwesomeIcons.personRunning;
      default:
        return FontAwesomeIcons.graduationCap;
    }
  }

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _loadLessons();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _loadLessons() async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> maps = await db.query('Dersler');

      if (mounted) {
        setState(() {
          _lessons = maps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Dersler yüklenirken hata: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case 'test':
        return 'Test Çöz';
      case 'video':
        return 'Video İzle';
      case 'flashcard':
        return 'Kartlarla Öğren';
      default:
        return 'Ders Seç';
    }
  }

  String _getModeEmoji() {
    switch (widget.mode) {
      case 'test':
        return '📝';
      case 'video':
        return '🎬';
      case 'flashcard':
        return '🃏';
      default:
        return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Arka plan
          _buildBackground(isDarkMode),

          // İçerik
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom AppBar
                _buildCustomAppBar(isDarkMode),

                // Ders Listesi
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _lessons.isEmpty
                      ? _buildEmptyState()
                      : isTablet
                      ? _buildTabletGrid(isDarkMode)
                      : _buildMobileList(isDarkMode),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hareketli arka plan
  Widget _buildBackground(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Color.lerp(
                        const Color(0xFF0D0D1A),
                        const Color(0xFF1A0D2E),
                        _bgController.value,
                      )!,
                      const Color(0xFF1A1A2E),
                      Color.lerp(
                        const Color(0xFF16213E),
                        const Color(0xFF0D1A2E),
                        _bgController.value,
                      )!,
                    ]
                  : [
                      Color.lerp(
                        const Color(0xFFf12711),
                        const Color(0xFFFF6B35),
                        _bgController.value,
                      )!,
                      const Color(0xFFf5af19),
                      Color.lerp(
                        const Color(0xFFFFD93D),
                        const Color(0xFFF5AF19),
                        _bgController.value,
                      )!,
                    ],
            ),
          ),
          child: CustomPaint(
            painter: _HolographicPatternPainter(
              isDarkMode: isDarkMode,
              animation: _bgController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// Modern AppBar
  Widget _buildCustomAppBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          // Geri butonu
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Başlık
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      '${_getModeEmoji()} ${_getModeTitle()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.2, end: 0),
                const SizedBox(height: 4),
                Text(
                      'Hangi derse çalışalım?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .slideX(begin: -0.2, end: 0),
              ],
            ),
          ),

          // Ders sayısı badge
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${_lessons.length} Ders',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        ],
      ),
    );
  }

  /// Boş durum
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.folderOpen,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz ders yüklenmemiş',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İçerikler yükleniyor...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Mobil liste görünümü
  Widget _buildMobileList(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _lessons.length,
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        return _buildHolographicCard(
          lesson: lesson,
          isDarkMode: isDarkMode,
          index: index,
        );
      },
    );
  }

  /// Tablet grid görünümü
  Widget _buildTabletGrid(bool isDarkMode) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemCount: _lessons.length,
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        return _buildHolographicCard(
          lesson: lesson,
          isDarkMode: isDarkMode,
          index: index,
          isGridItem: true,
        );
      },
    );
  }

  /// Holografik Ders Kartı
  Widget _buildHolographicCard({
    required Map<String, dynamic> lesson,
    required bool isDarkMode,
    required int index,
    bool isGridItem = false,
  }) {
    final lessonId = lesson['dersID'] as String;
    final lessonName = lesson['dersAdi'] as String;
    final iconName = lesson['ikon'] as String? ?? 'book';
    final colorValue = lesson['renk'] as String? ?? '0xFF6C5CE7';
    final lessonColor = Color(int.parse(colorValue));
    final progress = (lesson['progress'] as num?)?.toDouble() ?? 0.0;
    final isLocked = lesson['isLocked'] as bool? ?? false;
    final topicCount = lesson['topicCount'] as int? ?? 0;

    return Padding(
          padding: EdgeInsets.only(bottom: isGridItem ? 0 : 16),
          child: _HolographicLessonCard(
            lessonId: lessonId,
            lessonName: lessonName,
            iconName: iconName,
            lessonColor: lessonColor,
            progress: progress,
            isLocked: isLocked,
            topicCount: topicCount,
            mode: widget.mode,
            isDarkMode: isDarkMode,
            resolvedIcon: _getIconForLesson(iconName),
          ),
        )
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: 100 + index * 80),
        )
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 500.ms,
          delay: Duration(milliseconds: 100 + index * 80),
          curve: Curves.easeOutBack,
        );
  }
}

/// Holografik Ders Kartı Widget'ı
class _HolographicLessonCard extends StatefulWidget {
  final String lessonId;
  final String lessonName;
  final String iconName;
  final Color lessonColor;
  final double progress;
  final bool isLocked;
  final int topicCount;
  final String mode;
  final bool isDarkMode;
  final IconData resolvedIcon;

  const _HolographicLessonCard({
    required this.lessonId,
    required this.lessonName,
    required this.iconName,
    required this.lessonColor,
    required this.progress,
    required this.isLocked,
    required this.topicCount,
    required this.mode,
    required this.isDarkMode,
    required this.resolvedIcon,
  });

  @override
  State<_HolographicLessonCard> createState() => _HolographicLessonCardState();
}

class _HolographicLessonCardState extends State<_HolographicLessonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLocked) return;
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _onTap() {
    if (widget.isLocked) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock, color: Colors.white),
              SizedBox(width: 12),
              Text('Bu ders henüz kilitli! 🔒'),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    // ✅ NAVIGASYON KORUNUYOR - Orijinal yapı
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicSelectionScreen(
          lessonId: widget.lessonId,
          lessonName: widget.lessonName,
          lessonColor: widget.lessonColor,
          mode: widget.mode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // Neon glow
              BoxShadow(
                color: widget.isLocked
                    ? Colors.grey.withValues(alpha: 0.2)
                    : widget.lessonColor.withValues(
                        alpha: _isPressed ? 0.5 : 0.35,
                      ),
                blurRadius: _isPressed ? 25 : 20,
                spreadRadius: _isPressed ? 2 : 0,
              ),
              // Alt gölge
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Gradient arka plan
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isLocked
                          ? [Colors.grey.shade600, Colors.grey.shade800]
                          : [
                              widget.lessonColor,
                              widget.lessonColor.withValues(alpha: 0.7),
                            ],
                    ),
                  ),
                ),

                // Glass overlay
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                // Watermark ikon (arka plan)
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Opacity(
                    opacity: 0.15,
                    child: _buildIcon(size: 150, isBackground: true),
                  ),
                ),

                // Dekoratif daireler
                Positioned(
                  top: -20,
                  left: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),

                // Ana içerik
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Sol - İkon
                      _buildIconSection(),

                      const SizedBox(width: 20),

                      // Orta - Bilgiler
                      Expanded(child: _buildInfoSection()),

                      // Sağ - Aksiyon
                      _buildActionSection(),
                    ],
                  ),
                ),

                // Kilitli overlay
                if (widget.isLocked)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                // Parlak kenar
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: _isPressed ? 0.5 : 0.25,
                        ),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection() {
    return Stack(
      children: [
        // Glow efekti
        if (!widget.isLocked)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.lessonColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        // İkon container
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(child: _buildIcon(size: 40)),
        ),
      ],
    );
  }

  Widget _buildIcon({required double size, bool isBackground = false}) {
    return FaIcon(
      widget.resolvedIcon,
      size: size * 0.6,
      color: Colors.white.withValues(alpha: isBackground ? 1.0 : 1.0),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ders adı
        Text(
          widget.lessonName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),

        // Alt bilgi (konu sayısı)
        Row(
          children: [
            if (widget.topicCount > 0) ...[
              FaIcon(
                FontAwesomeIcons.layerGroup,
                size: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.topicCount} Konu',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              FaIcon(
                FontAwesomeIcons.wandMagicSparkles,
                size: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                'Keşfet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // İlerleme barı
        if (widget.progress > 0 && !widget.isLocked) ...[
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFFFD700)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '%${(widget.progress * 100).toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionSection() {
    if (widget.isLocked) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.lock, color: Colors.white54, size: 20),
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 10),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

/// Holografik desen çizici
class _HolographicPatternPainter extends CustomPainter {
  final bool isDarkMode;
  final double animation;

  _HolographicPatternPainter({
    required this.isDarkMode,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Işık parçacıkları
    final particlePaint = Paint()
      ..color = Colors.white.withValues(alpha: isDarkMode ? 0.08 : 0.15);

    final random = [0.1, 0.3, 0.5, 0.7, 0.9, 0.2, 0.4, 0.6, 0.8, 0.15];
    for (int i = 0; i < 20; i++) {
      final x =
          (random[i % 10] * size.width + i * 47 + animation * 30) % size.width;
      final y = (random[(i + 5) % 10] * size.height + i * 31) % size.height;
      final radius = 1.5 + (i % 4) * 0.8;
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    // Diagonal ışık çizgileri
    if (isDarkMode) {
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.03)
        ..strokeWidth = 1;

      for (double i = -size.height; i < size.width + size.height; i += 80) {
        canvas.drawLine(
          Offset(i, 0),
          Offset(i + size.height, size.height),
          linePaint,
        );
      }
    }

    // Köşe glow efektleri
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              (isDarkMode ? const Color(0xFFFF6B9D) : Colors.white).withValues(
                alpha: 0.1 + animation * 0.05,
              ),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.1, size.height * 0.2),
              radius: 200,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      200,
      glowPaint,
    );

    final glowPaint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              (isDarkMode ? const Color(0xFF6C5CE7) : const Color(0xFFFFD700))
                  .withValues(alpha: 0.08 + (1 - animation) * 0.04),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.9, size.height * 0.7),
              radius: 250,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      250,
      glowPaint2,
    );
  }

  @override
  bool shouldRepaint(covariant _HolographicPatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
