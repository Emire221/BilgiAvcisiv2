import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import '../topic_selection_screen.dart';
import '../../services/database_helper.dart';
import '../../features/exam/presentation/widgets/weekly_exam_card.dart';
import '../../widgets/motivation_progress_bar.dart';
import '../../providers/repository_providers.dart';

/// Macera Haritası Dersleri - Veritabanından okunan dersler
class LessonsTab extends ConsumerStatefulWidget {
  final bool isActive;
  const LessonsTab({super.key, this.isActive = false});

  @override
  ConsumerState<LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends ConsumerState<LessonsTab>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  List<_LessonNode> _lessons = [];
  bool _isLoading = true;
  int _progressBarRebuildKey = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadLessons();
  }

  @override
  void didUpdateWidget(LessonsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Tab aktif hale geldiğinde progress bar'ı yeniden oluştur
      setState(() {
        _progressBarRebuildKey++;
      });
    }
  }

  Future<void> _loadLessons() async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> maps = await db.query('Dersler');

      setState(() {
        _lessons = maps.asMap().entries.map((entry) {
          final index = entry.key;
          final lesson = entry.value;
          return _LessonNode(
            id: index + 1,
            dersId: lesson['dersID'] ?? '',
            title: lesson['dersAdi'] ?? 'Ders',
            icon: _getIconForLesson(lesson['ikon']),
            color: _parseColor(lesson['renk']),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Dersler yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) {
      return const Color(0xFF6C5CE7);
    }
    try {
      // "0xFF..." formatı
      if (colorStr.startsWith('0x') || colorStr.startsWith('0X')) {
        return Color(int.parse(colorStr));
      }
      // "#RRGGBB" formatı
      if (colorStr.startsWith('#')) {
        final hex = colorStr.replaceFirst('#', '');
        if (hex.length == 6) {
          return Color(int.parse('0xFF$hex'));
        } else if (hex.length == 8) {
          return Color(int.parse('0x$hex'));
        }
      }
      // Sadece hex değeri
      return Color(int.parse(colorStr));
    } catch (e) {
      return const Color(0xFF6C5CE7);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Stack(
      children: [
        // Arka plan - Gradient
        _buildBackground(isDarkMode),

        // Tüm içerik tek ScrollView içinde
        SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(isDarkMode)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: -0.3, end: 0),
                    ),

                    // 🚀 Motivasyonel Progress Bar - Header ile WeeklyExam arasında
                    SliverToBoxAdapter(
                      child: MotivationProgressBar(key: ValueKey(_progressBarRebuildKey)),
                    ),

                    // Haftalık Sınav Kartı
                    SliverToBoxAdapter(
                      child:
                          Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16,
                                ),
                                child: const WeeklyExamCard(),
                              )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideY(begin: 0.2, end: 0),
                    ),

                    // Macera Haritası veya Empty State
                    _lessons.isEmpty
                        ? SliverFillRemaining(child: _buildEmptyState())
                        : _buildAdventureMapSliver(isDarkMode, isTablet),

                    // Alt boşluk
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
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
            'Ayarlardan sınıf içeriği indirebilirsin',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF1a1a2e),
                  const Color(0xFF16213e),
                  const Color(0xFF0f3460),
                  const Color(0xFF1a1a2e),
                ]
              : [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                  const Color(0xFFF093FB),
                  const Color(0xFF667EEA),
                ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _StarsPainter(isDarkMode: isDarkMode),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🗺️ Macera Haritası',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Zirveye ulaşmak için tırman!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // İlerleme göstergesi
          _buildProgressBadge(),
        ],
      ),
    );
  }

  Widget _buildProgressBadge() {
    final total = _lessons.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB347).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.graduationCap,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            '$total Ders',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdventureMapSliver(bool isDarkMode, bool isTablet) {
    final pathWidth = isTablet ? 0.6 : 0.85;
    final horizontalPadding =
        MediaQuery.of(context).size.width * (1 - pathWidth) / 2;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final lesson = _lessons[index];
          final isEven = index % 2 == 0;
          final isLast = index == _lessons.length - 1;

          return Column(
            children: [
              // Zigzag hizalı ders düğümü
              Row(
                mainAxisAlignment: isEven
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  // Sol boşluk (tek indexler için)
                  if (!isEven) const Spacer(flex: 1),

                  // Ders düğümü
                  _buildLessonNode(lesson, index, isDarkMode)
                      .animate(delay: Duration(milliseconds: index < 5 ? 100 * index : 0))
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                      ),

                  // Sağ boşluk (çift indexler için)
                  if (isEven) const Spacer(flex: 1),
                ],
              ),

              // Bağlantı yolu (son eleman hariç)
              if (!isLast)
                _buildConnectionPath(isEven, isDarkMode, index)
                    .animate(delay: Duration(milliseconds: index < 5 ? 100 * index + 50 : 50))
                    .fadeIn(duration: 300.ms),
            ],
          );
        }, childCount: _lessons.length),
      ),
    );
  }

  Widget _buildLessonNode(_LessonNode lesson, int index, bool isDarkMode) {
    const nodeSize = 85.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _navigateToLesson(lesson);
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Ana düğüm
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getNodeColors(lesson),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: lesson.color.withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: FaIcon(lesson.icon, color: Colors.white, size: 32),
            ),
          ),



          // Ders başlığı
          Positioned(
            bottom: -30,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                lesson.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getNodeColors(_LessonNode lesson) {
    // Her dersin kendi rengini kullan
    final baseColor = lesson.color;
    final lighterColor = Color.lerp(baseColor, Colors.white, 0.3)!;
    return [lighterColor, baseColor];
  }

  Widget _buildConnectionPath(bool isFromLeft, bool isDarkMode, int index) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _DashedPathPainter(
          isFromLeft: isFromLeft,
          color: Colors.white.withValues(alpha: 0.4),
        ),
        size: const Size(double.infinity, 60),
      ),
    );
  }

  void _navigateToLesson(_LessonNode lesson) {
    _showModeSelectionDialog(lesson);
  }

  void _showModeSelectionDialog(_LessonNode lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lesson.color.withValues(alpha: 0.95),
              lesson.color.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(lesson.icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ne yapmak istersin?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                // Options
                Row(
                  children: [
                    Expanded(
                      child: _buildModeOption(
                        icon: FontAwesomeIcons.clipboardQuestion,
                        title: 'Test Çöz',
                        subtitle: 'Bilgini test et',
                        color: const Color(0xFF6C5CE7),
                        onTap: () {
                          Navigator.pop(context);
                          _goToTopicSelection(lesson, 'test');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModeOption(
                        icon: FontAwesomeIcons.layerGroup,
                        title: 'Bilgi Kartları',
                        subtitle: 'Konuyu öğren',
                        color: const Color(0xFF00B894),
                        onTap: () {
                          Navigator.pop(context);
                          _goToTopicSelection(lesson, 'flashcard');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: FaIcon(icon, color: Colors.white, size: 24)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToTopicSelection(_LessonNode lesson, String mode) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TopicSelectionScreen(
              lessonId: lesson.dersId,
              lessonName: lesson.title,
              lessonColor: lesson.color,
              mode: mode,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    ).then((_) => _refreshLessonProgress());
  }

  /// Dersten geri dönüldüğünde progress bar'ı güncelle
  void _refreshLessonProgress() {
    if (mounted) {
      // Provider'ları yenile - refresh kullanarak anında güncelle
      // ignore: unused_result
      ref.refresh(totalContentCountProvider);
      // ignore: unused_result
      ref.refresh(completedContentCountProvider);
      // Widget'ı yeniden oluştur ve animasyonu tetikle
      setState(() {
        _progressBarRebuildKey++;
      });
    }
  }
}

/// Ders düğümü veri modeli
class _LessonNode {
  final int id;
  final String dersId;
  final String title;
  final IconData icon;
  final Color color;

  const _LessonNode({
    required this.id,
    required this.dersId,
    required this.title,
    required this.icon,
    required this.color,
  });
}

/// Yıldızlı arka plan painter
class _StarsPainter extends CustomPainter {
  final bool isDarkMode;

  _StarsPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: isDarkMode ? 0.15 : 0.2);

    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kesik çizgili yol painter
class _DashedPathPainter extends CustomPainter {
  final bool isFromLeft;
  final Color color;

  _DashedPathPainter({required this.isFromLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = isFromLeft ? size.width * 0.25 : size.width * 0.75;
    final endX = isFromLeft ? size.width * 0.75 : size.width * 0.25;

    path.moveTo(startX, 0);
    path.quadraticBezierTo(size.width / 2, size.height / 2, endX, size.height);

    // Kesik çizgi efekti
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
