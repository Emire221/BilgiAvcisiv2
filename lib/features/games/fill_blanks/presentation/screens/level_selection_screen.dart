import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/fill_blanks_level.dart';
import 'fill_blanks_screen.dart';
import '../../../../../services/database_helper.dart';
import '../../../../../providers/repository_providers.dart';

/// "Sky Journey" - Gökyüzü Yolculuğu
/// Çocuklar için tasarlanmış, bulutların üzerinde ilerleyen sihirli bir seviye haritası
/// Cümle Tamamlama oyunu seviye seçim ekranı
class LevelSelectionScreen extends ConsumerStatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  ConsumerState<LevelSelectionScreen> createState() =>
      _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends ConsumerState<LevelSelectionScreen>
    with TickerProviderStateMixin {
  // Veritabanı ve veri yönetimi
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<FillBlanksLevel>? _levels;
  bool _isLoading = true;
  String? _errorMessage;

  // Kullanıcı ilerleme verisi (SharedPreferences veya DB'den gelebilir)
  // Her seviye için: tamamlandı mı, kaç yıldız kazanıldı
  final Map<String, int> _completedLevels = {}; // levelId -> stars (0-3)

  // Scroll ve Animasyon Controller'ları
  late ScrollController _scrollController;
  late AnimationController _pulseController;
  late AnimationController _cloudController;
  late AnimationController _bounceController;

  // Renk paleti - Sky Journey
  static const Color _skyTop = Color(0xFF4FACFE);
  static const Color _skyBottom = Color(0xFF00F2FE);

  // Dark Mode Colors
  static const Color _darkSkyTop = Color(0xFF0F2027);
  static const Color _darkSkyBottom = Color(0xFF2C5364);

  static const Color _activeOrange = Color(0xFFFF9966);
  static const Color _activeRed = Color(0xFFFF5E62);
  static const Color _completedGreen = Color(0xFF56AB2F);
  static const Color _goldStar = Color(0xFFFFD700);
  static const Color _pathColor = Colors.white;

  // Sabitler
  static const double _nodeSize = 70.0;
  static const double _activeNodeScale = 1.2;
  static const double _verticalSpacing = 130.0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    // Pulse animasyonu (aktif seviye için nabız efekti)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Bulut animasyonu
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Bounce animasyonu (play ikonu için)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Verileri yükle
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Veritabanından seviyeleri yükle
      final levelsData = await _dbHelper.getFillBlanksLevels();

      if (levelsData.isEmpty) {
        throw Exception('Henüz seviye verisi yüklenmemiş');
      }

      // Map<String, dynamic> listesini FillBlanksLevel listesine dönüştür
      final levels = levelsData.map((data) {
        // questions alanı JSON string olarak kaydedilmiş, parse et
        final levelMap = Map<String, dynamic>.from(data);
        if (levelMap['questions'] is String) {
          levelMap['questions'] = json.decode(levelMap['questions']);
        }
        return FillBlanksLevel.fromJson(levelMap);
      }).toList();

      setState(() {
        _levels = levels;
        _isLoading = false;
      });

      // Build sonrası scroll pozisyonunu ayarla
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentLevel();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Seviye yükleme hatası: $e');
      setState(() {
        _errorMessage =
            'Seviyeler yüklenemedi.\n'
            'Lütfen önce veri senkronizasyonunu yapın.';
        _isLoading = false;
      });
    }
  }

  /// Aktif (oynanacak) seviye indexini bul
  int get _currentLevelIndex {
    if (_levels == null || _levels!.isEmpty) return 0;

    for (int i = 0; i < _levels!.length; i++) {
      final level = _levels![i];
      final stars = _completedLevels[level.id] ?? 0;

      // Eğer bu seviye tamamlanmamışsa (0 yıldız), bu aktif seviye
      if (stars == 0) {
        return i;
      }
    }

    // Tüm seviyeler tamamlandıysa son seviyeye git
    return _levels!.length - 1;
  }

  /// Seviyenin kilitli olup olmadığını kontrol et
  /// Tüm seviyeler açık - kilitleme yok
  bool _isLevelLocked(int index) {
    // Tüm seviyeler açık - hiçbiri kilitli değil
    return false;
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients || _levels == null) return;

    final double targetPosition =
        _currentLevelIndex * _verticalSpacing -
        MediaQuery.of(context).size.height / 3;

    _scrollController.animateTo(
      targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    _cloudController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onLevelTap(int index) {
    if (_levels == null) return;

    final level = _levels![index];
    final isLocked = _isLevelLocked(index);

    if (isLocked) {
      // Kilitli seviye - Haptic feedback ve SnackBar
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Önceki seviyeyi tamamla!',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Açık seviye - Oyun ekranına git
      HapticFeedback.selectionClick();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FillBlanksScreen(level: level)),
      ).then((_) {
        // Oyun oynanınca badge'leri güncelle
        if (mounted) {
          ref.invalidate(
            isLevelCompletedProvider((
              gameType: 'fill_blanks',
              levelTitle: level.title,
            )),
          );
        }
      });
    }
  }

  /// Seviyenin ekrandaki yatay pozisyonunu hesapla (zigzag efekti için)
  double _getLevelPosition(int index) {
    // Zigzag pattern: sağ, sol, sağ, sol...
    // Biraz rastgelelik ekle ama tutarlı olsun (index bazlı)
    final random = Random(index * 42); // Seed ile tutarlı rastgelelik
    final basePosition = index % 2 == 0 ? 0.25 : 0.75;
    final variation = (random.nextDouble() - 0.5) * 0.3;
    return (basePosition + variation).clamp(0.15, 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Gökyüzü Gradient Arka Plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark 
                    ? [_darkSkyTop, _darkSkyBottom] 
                    : [_skyTop, _skyBottom],
              ),
            ),
          ),

          // 2. Akan Bulutlar
          ..._buildFloatingClouds(screenSize),

          // 3. Ana İçerik
          _buildMainContent(screenSize, safePadding),

          // 4. Üst Başlık Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(safePadding.top),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(Size screenSize, EdgeInsets safePadding) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child:
            Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Seviyeler yükleniyor...',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 1500.ms,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadLevels,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Tekrar Dene',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
      );
    }

    if (_levels == null || _levels!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 80,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz seviye bulunmuyor',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Ana seviye listesi
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Üst boşluk
        SliverToBoxAdapter(child: SizedBox(height: safePadding.top + 100)),

        // Seviye haritası
        SliverToBoxAdapter(
          child: SizedBox(
            height: _levels!.length * _verticalSpacing + 150,
            child: Stack(
              children: [
                // Yol çizgisi (CustomPainter)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(
                      levelCount: _levels!.length,
                      nodeSize: _nodeSize,
                      verticalSpacing: _verticalSpacing,
                      screenWidth: screenSize.width,
                      getPosition: _getLevelPosition,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Seviye düğümleri
                ..._buildLevelNodes(screenSize.width),
              ],
            ),
          ),
        ),

        // Alt boşluk
        SliverToBoxAdapter(child: SizedBox(height: 100 + safePadding.bottom)),
      ],
    );
  }

  Widget _buildHeader(double topPadding) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
          padding: EdgeInsets.only(
            top: topPadding + 12,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [_darkSkyTop, _darkSkyTop.withValues(alpha: 0)]
                  : [_skyTop, _skyTop.withValues(alpha: 0)],
            ),
          ),
          child: Row(
            children: [
              // Geri butonu
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

              const Spacer(),

              // Başlık
              Column(
                children: [
                  Text(
                    '🌤️ Cümle Tamamla',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  if (_levels != null)
                    Text(
                      '${_levels!.length} Seviye',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // Yenile butonu
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _loadLevels();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0, curve: Curves.easeOutCubic);
  }

  List<Widget> _buildFloatingClouds(Size screenSize) {
    return [
      // Bulut 1
      AnimatedBuilder(
        animation: _cloudController,
        builder: (context, child) {
          return Positioned(
            top: screenSize.height * 0.1,
            left: screenSize.width * (1 - _cloudController.value * 1.5),
            child: _buildCloud(80, 0.3),
          );
        },
      ),
      // Bulut 2
      AnimatedBuilder(
        animation: _cloudController,
        builder: (context, child) {
          final offset = (_cloudController.value + 0.3) % 1.0;
          return Positioned(
            top: screenSize.height * 0.25,
            left: screenSize.width * (1.2 - offset * 1.5),
            child: _buildCloud(120, 0.25),
          );
        },
      ),
      // Bulut 3
      AnimatedBuilder(
        animation: _cloudController,
        builder: (context, child) {
          final offset = (_cloudController.value + 0.6) % 1.0;
          return Positioned(
            top: screenSize.height * 0.45,
            left: screenSize.width * (1.3 - offset * 1.5),
            child: _buildCloud(100, 0.2),
          );
        },
      ),
      // Bulut 4
      AnimatedBuilder(
        animation: _cloudController,
        builder: (context, child) {
          final offset = (_cloudController.value + 0.15) % 1.0;
          return Positioned(
            top: screenSize.height * 0.65,
            left: screenSize.width * (1.1 - offset * 1.5),
            child: _buildCloud(90, 0.22),
          );
        },
      ),
      // Bulut 5
      AnimatedBuilder(
        animation: _cloudController,
        builder: (context, child) {
          final offset = (_cloudController.value + 0.45) % 1.0;
          return Positioned(
            top: screenSize.height * 0.8,
            left: screenSize.width * (1.4 - offset * 1.5),
            child: _buildCloud(110, 0.18),
          );
        },
      ),
    ];
  }

  Widget _buildCloud(double size, double opacity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: Icon(
        Icons.cloud,
        size: size,
        color: Colors.white.withValues(alpha: isDark ? opacity * 0.5 : opacity),
      ),
    );
  }

  List<Widget> _buildLevelNodes(double screenWidth) {
    if (_levels == null) return [];

    final List<Widget> nodes = [];
    const double horizontalPadding = 40;
    final double availableWidth =
        screenWidth - horizontalPadding * 2 - _nodeSize;

    for (int i = 0; i < _levels!.length; i++) {
      final level = _levels![i];
      final bool isLocked = _isLevelLocked(i);
      final bool isActive = i == _currentLevelIndex;
      final int stars = _completedLevels[level.id] ?? 0;
      final bool isCompleted = stars > 0;

      final double position = _getLevelPosition(i);
      final double leftPosition = horizontalPadding + position * availableWidth;
      final double topPosition = i * _verticalSpacing + 50;

      nodes.add(
        Positioned(
          left: leftPosition,
          top: topPosition,
          child: _LevelNode(
            key: ValueKey('level_${level.id}'),
            level: level,
            index: i,
            isActive: isActive,
            isCompleted: isCompleted,
            isLocked: isLocked,
            stars: stars,
            nodeSize: _nodeSize,
            pulseController: _pulseController,
            bounceController: _bounceController,
            onTap: () => _onLevelTap(i),
            animationDelay: i * 80,
          ),
        ),
      );
    }

    return nodes;
  }
}

/// Seviye Düğümü Widget'ı - YENİ/OYNANDI badge içerir
class _LevelNode extends ConsumerStatefulWidget {
  final FillBlanksLevel level;
  final int index;
  final bool isActive;
  final bool isCompleted;
  final bool isLocked;
  final int stars;
  final double nodeSize;
  final AnimationController pulseController;
  final AnimationController bounceController;
  final VoidCallback onTap;
  final int animationDelay;

  const _LevelNode({
    super.key,
    required this.level,
    required this.index,
    required this.isActive,
    required this.isCompleted,
    required this.isLocked,
    required this.stars,
    required this.nodeSize,
    required this.pulseController,
    required this.bounceController,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  ConsumerState<_LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends ConsumerState<_LevelNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isLocked) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    // Veritabanından level tamamlanma durumunu kontrol et
    final isCompletedAsync = ref.watch(
      isLevelCompletedProvider((
        gameType: 'fill_blanks',
        levelTitle: widget.level.title,
      )),
    );
    final isCompletedFromDb = isCompletedAsync.maybeWhen(
      data: (completed) => completed,
      orElse: () => false,
    );

    return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final shakeOffset = sin(_shakeAnimation.value * 4 * pi) * 8;
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _handleTap,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ana düğüm
                    _buildNode(),
                    // Seviye bilgisi (küçük etiket)
                    const SizedBox(height: 6),
                    _buildLevelLabel(),
                    // Yıldızlar (tamamlanmış seviyeler için)
                    if (widget.isCompleted || isCompletedFromDb) ...[
                      const SizedBox(height: 4),
                      _buildStars(),
                    ],
                  ],
                ),
                // 🔴 YENİ badge - Sağ üstte
                if (!isCompletedFromDb && !widget.isLocked)
                  Positioned(
                    top: -5,
                    right: -15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'YENİ',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: widget.animationDelay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack);
  }

  Widget _buildNode() {
    if (widget.isLocked) {
      return _buildLockedNode();
    } else if (widget.isActive) {
      return _buildActiveNode();
    } else {
      return _buildCompletedNode();
    }
  }

  Widget _buildLevelLabel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: widget.isLocked ? 0.5 : 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.level.title.length > 12
            ? '${widget.level.title.substring(0, 12)}...'
            : widget.level.title,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark
              ? Colors.white70
              : (widget.isLocked ? Colors.grey : Colors.black87),
        ),
      ),
    );
  }

  /// Kilitli seviye düğümü
  Widget _buildLockedNode() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: widget.nodeSize,
      height: widget.nodeSize,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.lock,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        size: 30,
      ),
    );
  }

  /// Aktif seviye düğümü (nabız efekti ile)
  Widget _buildActiveNode() {
    return AnimatedBuilder(
      animation: widget.pulseController,
      builder: (context, child) {
        final pulseValue = widget.pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Dış halka (pulse efekti)
            Container(
              width:
                  widget.nodeSize *
                      _LevelSelectionScreenState._activeNodeScale +
                  30 +
                  (pulseValue * 20),
              height:
                  widget.nodeSize *
                      _LevelSelectionScreenState._activeNodeScale +
                  30 +
                  (pulseValue * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _LevelSelectionScreenState._activeOrange.withValues(
                  alpha: 0.3 - (pulseValue * 0.2),
                ),
              ),
            ),
            // İkinci halka
            Container(
              width:
                  widget.nodeSize *
                      _LevelSelectionScreenState._activeNodeScale +
                  15 +
                  (pulseValue * 10),
              height:
                  widget.nodeSize *
                      _LevelSelectionScreenState._activeNodeScale +
                  15 +
                  (pulseValue * 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _LevelSelectionScreenState._activeOrange.withValues(
                  alpha: 0.4 - (pulseValue * 0.2),
                ),
              ),
            ),
            // Ana düğüm
            Transform.scale(
              scale: _LevelSelectionScreenState._activeNodeScale,
              child: Container(
                width: widget.nodeSize,
                height: widget.nodeSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _LevelSelectionScreenState._activeOrange,
                      _LevelSelectionScreenState._activeRed,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _LevelSelectionScreenState._activeOrange
                          .withValues(alpha: 0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: widget.bounceController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -4 * widget.bounceController.value),
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Tamamlanmış seviye düğümü
  Widget _buildCompletedNode() {
    // Zorluk seviyesine göre renk
    final colors = _getDifficultyColors(widget.level.difficulty);

    return Container(
      width: widget.nodeSize,
      height: widget.nodeSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: _LevelSelectionScreenState._goldStar,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${widget.index + 1}',
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  List<Color> _getDifficultyColors(int difficulty) {
    switch (difficulty) {
      case 1:
        return [
          _LevelSelectionScreenState._completedGreen,
          _LevelSelectionScreenState._completedGreen.withValues(alpha: 0.8),
        ];
      case 2:
        return [Colors.orange.shade500, Colors.orange.shade700];
      case 3:
        return [Colors.red.shade500, Colors.red.shade700];
      default:
        return [Colors.blue.shade500, Colors.blue.shade700];
    }
  }

  /// Yıldız gösterimi
  Widget _buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final bool filled = index < widget.stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child:
              Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: filled
                        ? _LevelSelectionScreenState._goldStar
                        : Colors.grey[400],
                    size: 16,
                  )
                  .animate(
                    delay: Duration(
                      milliseconds: widget.animationDelay + (index * 100),
                    ),
                  )
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(),
        );
      }),
    );
  }
}

/// Yol çizen CustomPainter
class _PathPainter extends CustomPainter {
  final int levelCount;
  final double nodeSize;
  final double verticalSpacing;
  final double screenWidth;
  final double Function(int) getPosition;
  final bool isDark;

  _PathPainter({
    required this.levelCount,
    required this.nodeSize,
    required this.verticalSpacing,
    required this.screenWidth,
    required this.getPosition,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.15)
          : _LevelSelectionScreenState._pathColor.withValues(alpha: 0.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double horizontalPadding = 40;
    final double availableWidth =
        screenWidth - horizontalPadding * 2 - nodeSize;

    for (int i = 0; i < levelCount - 1; i++) {
      final currentPosition = getPosition(i);
      final nextPosition = getPosition(i + 1);

      // Başlangıç noktası
      final double x1 =
          horizontalPadding + currentPosition * availableWidth + nodeSize / 2;
      final double y1 = i * verticalSpacing + 50 + nodeSize / 2;

      // Bitiş noktası
      final double x2 =
          horizontalPadding + nextPosition * availableWidth + nodeSize / 2;
      final double y2 = (i + 1) * verticalSpacing + 50 + nodeSize / 2;

      // Bezier kontrol noktaları
      final double controlY = (y1 + y2) / 2;

      final path = Path()
        ..moveTo(x1, y1)
        ..cubicTo(x1, controlY, x2, controlY, x2, y2);

      // Kesik çizgi efekti için
      _drawDashedPath(canvas, path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      const double dashLength = 12;
      const double gapLength = 8;

      while (distance < metric.length) {
        final double endDistance = distance + dashLength;
        if (endDistance > metric.length) {
          final extractPath = metric.extractPath(distance, metric.length);
          canvas.drawPath(extractPath, paint);
        } else {
          final extractPath = metric.extractPath(distance, endDistance);
          canvas.drawPath(extractPath, paint);
        }
        distance = endDistance + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
