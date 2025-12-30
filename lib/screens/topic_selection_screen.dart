import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import '../widgets/glass_container.dart';
import '../services/data_service.dart';
import '../providers/repository_providers.dart';
import '../main.dart' show routeObserver;
import 'test_list_screen.dart';
import 'flashcard_set_selection_screen.dart';
import '../core/providers/user_provider.dart';

/// 🗺️ Konu Yolculuğu - Level Map Style Topic Selection
class TopicSelectionScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String lessonName;
  final Color lessonColor;
  final String mode;

  const TopicSelectionScreen({
    super.key,
    required this.lessonId,
    required this.lessonName,
    required this.lessonColor,
    this.mode = 'all',
  });

  @override
  ConsumerState<TopicSelectionScreen> createState() =>
      _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends ConsumerState<TopicSelectionScreen>
    with TickerProviderStateMixin, RouteAware {
  final DataService _dataService = DataService();
  List<dynamic> _topics = [];
  bool _isLoading = true;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _loadTopics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteObserver'a abone ol
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _bgController.dispose();
    super.dispose();
  }

  /// Başka bir ekrandan bu ekrana geri dönüldüğünde çağrılır
  @override
  void didPopNext() {
    super.didPopNext();
    // Tüm topic progress provider'larını invalidate et
    _invalidateAllTopicProgress();
  }

  /// Tüm konuların progress bilgisini yenile
  void _invalidateAllTopicProgress() {
    for (final topic in _topics) {
      final topicId = topic['konuID'] as String? ?? '';
      if (topicId.isNotEmpty) {
        ref.invalidate(
          topicProgressProvider((topicId: topicId, mode: widget.mode)),
        );
      }
    }
    // Widget tree'yi rebuild et
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadTopics() async {
    final userProfile = ref.read(userProfileProvider);
    final userGrade = userProfile.value?['grade'] ?? '3. Sınıf';

    final topics = await _dataService.getTopics(userGrade, widget.lessonId);
    if (mounted) {
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    }
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case 'test':
        return 'Test Konuları';
      case 'flashcard':
        return 'Kart Konuları';
      default:
        return 'Hangi Konu?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                _buildCustomAppBar(),

                // Ders bilgi kartı
                _buildLessonInfoCard(),

                // Konu Listesi
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _topics.isEmpty
                      ? _buildEmptyState()
                      : _buildTopicList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dinamik arka plan
  Widget _buildBackground(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(
                  widget.lessonColor,
                  widget.lessonColor.withValues(alpha: 0.9),
                  _bgController.value,
                )!,
                Color.lerp(
                  widget.lessonColor.withValues(alpha: 0.8),
                  _darkenColor(widget.lessonColor, 0.2),
                  _bgController.value,
                )!,
                _darkenColor(widget.lessonColor, 0.4),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _LevelMapPatternPainter(
              color: widget.lessonColor,
              animation: _bgController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Color _darkenColor(Color color, double factor) {
    return Color.fromARGB(
      (color.a * 255).round(),
      (color.r * 255 * (1 - factor)).round(),
      (color.g * 255 * (1 - factor)).round(),
      (color.b * 255 * (1 - factor)).round(),
    );
  }

  /// Custom AppBar
  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          // Geri butonu - Glass Container
          GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(width: 8),

          // Başlık
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      _getModeTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.2, end: 0),
                const SizedBox(height: 2),
                Text(
                      '${widget.lessonName} dersi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .slideX(begin: -0.2, end: 0),
              ],
            ),
          ),

          // Konu sayısı
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.mapLocationDot,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_topics.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        ],
      ),
    );
  }

  /// Ders bilgi kartı
  Widget _buildLessonInfoCard() {
    return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: GlassContainer(
            blur: 15,
            opacity: 0.15,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // İkon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: FaIcon(
                      _getModeIcon(),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Bilgi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lessonName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getModeDescription(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rozet
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.trophy,
                        color: Color(0xFFFFD700),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_topics.length} Konu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 150.ms)
        .slideY(begin: -0.2, end: 0);
  }

  IconData _getModeIcon() {
    switch (widget.mode) {
      case 'test':
        return FontAwesomeIcons.fileLines;
      case 'flashcard':
        return FontAwesomeIcons.layerGroup;
      default:
        return FontAwesomeIcons.rocket;
    }
  }

  String _getModeDescription() {
    switch (widget.mode) {
      case 'test':
        return 'Test çözerek bilgini pekiştir';
      case 'flashcard':
        return 'Kartlarla hızlı öğren';
      default:
        return 'Konuları keşfet ve öğren';
    }
  }

  /// Yükleme durumu
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animasyon (varsa) veya CircularProgressIndicator
          SizedBox(
            width: 120,
            height: 120,
            child: Lottie.asset(
              'assets/animation/loading-kum.json',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Konular yükleniyor...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
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
          FaIcon(
            FontAwesomeIcons.mapLocationDot,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz konu eklenmemiş',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu ders için içerik hazırlanıyor',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Konu listesi
  Widget _buildTopicList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        final isLast = index == _topics.length - 1;

        return _TopicMissionCard(
              topic: topic,
              index: index,
              isLast: isLast,
              lessonName: widget.lessonName,
              lessonColor: widget.lessonColor,
              mode: widget.mode,
            )
            .animate()
            .fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: index < 5 ? 100 + index * 50 : 0),
            )
            .slideX(
              begin: index.isEven ? -0.2 : 0.2,
              end: 0,
              duration: 300.ms,
              delay: Duration(milliseconds: index < 5 ? 100 + index * 50 : 0),
              curve: Curves.easeOut,
            );
      },
    );
  }
}

/// Mission Kart Widget'ı
class _TopicMissionCard extends ConsumerStatefulWidget {
  final dynamic topic;
  final int index;
  final bool isLast;
  final String lessonName;
  final Color lessonColor;
  final String mode;

  const _TopicMissionCard({
    required this.topic,
    required this.index,
    required this.isLast,
    required this.lessonName,
    required this.lessonColor,
    required this.mode,
  });

  @override
  ConsumerState<_TopicMissionCard> createState() => _TopicMissionCardState();
}

class _TopicMissionCardState extends ConsumerState<_TopicMissionCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // Progress provider'dan tamamlanmamış içerik sayısını al
    final topicId = widget.topic['konuID'] as String? ?? '';
    final progressAsync = ref.watch(
      topicProgressProvider((topicId: topicId, mode: widget.mode)),
    );
    final uncompletedCount = progressAsync.valueOrNull ?? 0;

    return Column(
      children: [
        // Bağlantı çizgisi (ilk değilse)
        if (widget.index > 0) _buildConnector(),

        // Ana kart - Stack ile badge ekleniyor
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale: _isPressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.lessonColor.withValues(
                          alpha: _isPressed ? 0.4 : 0.25,
                        ),
                        blurRadius: _isPressed ? 20 : 15,
                        spreadRadius: _isPressed ? 2 : 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: _isPressed ? 0.4 : 0.25,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Üst kısım - Rozet ve Konu adı
                            Row(
                              children: [
                                // Level Rozeti
                                _buildLevelBadge(),
                                const SizedBox(width: 16),
                                // Konu bilgisi
                                Expanded(child: _buildTopicInfo()),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Alt kısım - Aksiyon butonları
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 🔴 Tamamlanmamış içerik badge'i
            if (uncompletedCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: _buildProgressBadge(uncompletedCount),
              ),
          ],
        ),
      ],
    );
  }

  /// 🔴 Tamamlanmamış içerik sayısı badge'i
  Widget _buildProgressBadge(int count) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30), // iOS Red
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Bağlantı çizgisi
  Widget _buildConnector() {
    return Container(
      width: 3,
      height: 24,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Level rozeti
  Widget _buildLevelBadge() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.lessonColor.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${widget.topic['sira']}',
          style: TextStyle(
            color: widget.lessonColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Konu bilgisi
  Widget _buildTopicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.topic['konuAdi'] ?? 'Konu',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.play,
              size: 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Başlamak için tıkla',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Aksiyon butonları
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Test butonu
        if (widget.mode == 'test' || widget.mode == 'all')
          Expanded(
            child: _ActionButton(
              icon: FontAwesomeIcons.fileLines,
              label: 'Test Çöz',
              color: widget.lessonColor,
              isPrimary: true,
              onTap: () {
                HapticFeedback.mediumImpact();
                // ✅ NAVİGASYON KORUNUYOR + Geri dönüşte refresh
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestListScreen(
                      topicId: widget.topic['konuID'],
                      topicName: widget.topic['konuAdi'],
                      lessonName: widget.lessonName,
                      color: widget.lessonColor,
                    ),
                  ),
                ).then((_) {
                  // Geri dönüldüğünde progress'i yenile
                  final topicId = widget.topic['konuID'] as String? ?? '';
                  ref.invalidate(
                    topicProgressProvider((
                      topicId: topicId,
                      mode: widget.mode,
                    )),
                  );
                });
              },
            ),
          ),

        if ((widget.mode == 'test' || widget.mode == 'all') &&
            (widget.mode == 'flashcard' || widget.mode == 'all'))
          const SizedBox(width: 10),

        // Kart butonu
        if (widget.mode == 'flashcard' || widget.mode == 'all')
          Expanded(
            child: _ActionButton(
              icon: FontAwesomeIcons.layerGroup,
              label: 'Kartlar',
              color: const Color(0xFFFF9500),
              isPrimary: false,
              onTap: () {
                HapticFeedback.mediumImpact();
                // ✅ NAVİGASYON KORUNUYOR + Geri dönüşte refresh
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardSetSelectionScreen(
                      topicId: widget.topic['konuID'],
                      topicName: widget.topic['konuAdi'],
                      lessonName: widget.lessonName,
                    ),
                  ),
                ).then((_) {
                  // Geri dönüldüğünde progress'i yenile
                  final topicId = widget.topic['konuID'] as String? ?? '';
                  ref.invalidate(
                    topicProgressProvider((
                      topicId: topicId,
                      mode: widget.mode,
                    )),
                  );
                });
              },
            ),
          ),
      ],
    );
  }
}

/// Aksiyon Butonu Widget'ı
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.95),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: 0.85),
                    ],
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (widget.isPrimary ? widget.color : widget.color)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                widget.icon,
                size: 14,
                color: widget.isPrimary ? widget.color : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isPrimary ? widget.color : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Level Map Pattern Painter
class _LevelMapPatternPainter extends CustomPainter {
  final Color color;
  final double animation;

  _LevelMapPatternPainter({required this.color, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Dalgalı çizgiler
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final startY = size.height * (0.1 + i * 0.2);
      path.moveTo(0, startY);

      for (double x = 0; x < size.width; x += 20) {
        final y =
            startY +
            25 * (animation * 2 - 1) * (i.isEven ? 1 : -1) * (x / size.width);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }

    // Parıltılar
    final sparkPaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    final random = [0.15, 0.35, 0.55, 0.75, 0.25, 0.45, 0.65, 0.85];

    for (int i = 0; i < 15; i++) {
      final x =
          (random[i % 8] * size.width + i * 47 + animation * 20) % size.width;
      final y = (random[(i + 3) % 8] * size.height + i * 31) % size.height;
      final radius = 1.5 + (i % 3) * 0.7;
      canvas.drawCircle(Offset(x, y), radius, sparkPaint);
    }

    // Köşe glow
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1 + animation * 0.05),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.9, size.height * 0.1),
              radius: 150,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      150,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LevelMapPatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
