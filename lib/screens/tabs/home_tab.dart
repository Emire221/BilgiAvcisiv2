import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

// Import yollarını kendi projene göre kontrol et
import '../../widgets/glass_container.dart';
import '../../services/daily_fact_service.dart';
import '../../core/providers/user_provider.dart';
import '../../features/mascot/presentation/providers/mascot_provider.dart';
import '../../features/mascot/presentation/widgets/interactive_mascot_widget.dart';
import '../../features/mascot/domain/entities/mascot.dart';
import '../lesson_selection_screen.dart';
import '../achievements_screen.dart';

class HomeTab extends ConsumerStatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeTab({super.key, this.onNavigateToTab});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _bubbleController;

  String _typedText = '';
  bool _isTyping = false;
  DailyFact? _dailyFact;
  bool _isSpeechBubbleExpanded = false;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _loadDailyFact();
  }

  Future<void> _loadDailyFact() async {
    try {
      final fact = await DailyFactService.getRandomFact();
      if (mounted) {
        if (fact != null) {
          setState(() => _dailyFact = fact);
          _startTypingAnimation(fact.fact);
        } else {
          _setFallbackFact();
        }
      }
    } catch (e) {
      if (mounted) _setFallbackFact();
    }
  }

  void _setFallbackFact() {
    const fallbackFact = DailyFact(
      dayOfYear: 1,
      title: 'İlginç Bilgi',
      fact: 'Dünya, Güneş etrafındaki turunu tam 365 gün 6 saatte tamamlar!',
    );
    setState(() => _dailyFact = fallbackFact);
    _startTypingAnimation(fallbackFact.fact);
  }

  void _startTypingAnimation(String text) async {
    setState(() {
      _isTyping = true;
      _typedText = '';
    });

    for (int i = 0; i < text.length && mounted; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() => _typedText = text.substring(0, i + 1));
      }
    }

    if (mounted) {
      setState(() => _isTyping = false);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final userProfileAsync = ref.watch(userProfileProvider);
    final mascotAsync = ref.watch(activeMascotProvider);

    return Stack(
      children: [
        _buildAnimatedBackground(isDarkMode),
        _buildFloatingElements(isDarkMode),
        SafeArea(
          // Bottom padding'i kendimiz yönetiyoruz (Dock için)
          bottom: false,
          child: isTablet
              ? _buildTabletLayout(
                  isDarkMode,
                  userProfileAsync,
                  mascotAsync,
                  screenSize,
                )
              : _buildPhoneLayout(
                  isDarkMode,
                  userProfileAsync,
                  mascotAsync,
                  screenSize,
                ),
        ),
      ],
    );
  }

  /// Tablet Layout
  Widget _buildTabletLayout(
    bool isDarkMode,
    AsyncValue<Map<String, dynamic>?> userProfileAsync,
    AsyncValue<Mascot?> mascotAsync,
    Size screenSize,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildHeader(isDarkMode, userProfileAsync, mascotAsync),
              Expanded(
                child: _buildMascotStage(
                  isDarkMode,
                  mascotAsync,
                  screenSize.height * 0.5,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildActionDeck(isDarkMode, isVertical: true),
          ),
        ),
      ],
    );
  }

  /// Phone Layout - FIX UYGULANDI
  Widget _buildPhoneLayout(
    bool isDarkMode,
    AsyncValue<Map<String, dynamic>?> userProfileAsync,
    AsyncValue<Mascot?> mascotAsync,
    Size screenSize,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // GÜNCELLEME: Boşluğu minimize ettik - kartlar dock'un hemen üstünde
    // Dock yüksekliği (~60px) + minimum margin
    final dockReservedSpace = 30.0 + bottomPadding;

    return Padding(
      // Bu padding tüm içeriği Dock'un hemen üzerinde bitmeye zorlar
      padding: EdgeInsets.only(bottom: dockReservedSpace),
      child: Column(
        // Elementleri dikeyde yayar (Üst - Orta - Alt)
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. HEADER & BALON
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: _buildHeader(isDarkMode, userProfileAsync, mascotAsync)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.3, end: 0),
              ),
              if (_dailyFact != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSpeechBubbleCard(isDarkMode, mascotAsync)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: -0.2, end: 0),
                ),
            ],
          ),

          // 2. MASKOT (Expanded ile taşmayı önler)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child:
                      _buildMascotStage(
                            isDarkMode,
                            mascotAsync,
                            constraints.maxHeight,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                          ),
                );
              },
            ),
          ),

          // 3. KARTLAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                _buildActionDeck(
                      isDarkMode,
                      isVertical: false,
                      isSmallScreen: screenSize.height < 700,
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms)
                    .slideY(begin: 0.3, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Color.lerp(
                        const Color(0xFF1a1a2e),
                        const Color(0xFF16213e),
                        _floatController.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF16213e),
                        const Color(0xFF0f3460),
                        _floatController.value,
                      )!,
                      const Color(0xFF0f0f23),
                    ]
                  : [
                      Color.lerp(
                        const Color(0xFFE8F5E9),
                        const Color(0xFFE3F2FD),
                        _floatController.value,
                      )!,
                      Color.lerp(
                        const Color(0xFFB2DFDB),
                        const Color(0xFFBBDEFB),
                        _floatController.value,
                      )!,
                      const Color(0xFF80CBC4),
                    ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingElements(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 60 + _floatController.value * 20,
              left: 20,
              child: _buildCloud(isDarkMode, size: 80),
            ),
            Positioned(
              top: 120 + (1 - _floatController.value) * 15,
              right: 30,
              child: _buildCloud(isDarkMode, size: 60),
            ),
            Positioned(
              top: 200 + _floatController.value * 10,
              left: 60,
              child: _buildCloud(isDarkMode, size: 50),
            ),
            ..._buildSparkles(isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildCloud(bool isDarkMode, {required double size}) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size),
        gradient: RadialGradient(
          colors: isDarkMode
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.6),
                  Colors.white.withValues(alpha: 0.2),
                ],
        ),
      ),
    );
  }

  List<Widget> _buildSparkles(bool isDarkMode) {
    final random = math.Random(42);
    return List.generate(8, (index) {
      return Positioned(
        top: 100 + random.nextDouble() * 300,
        left: 30 + random.nextDouble() * 300,
        child:
            Icon(
                  Icons.star,
                  size: 8 + random.nextDouble() * 8,
                  color: isDarkMode
                      ? Colors.yellow.withValues(
                          alpha: 0.3 + random.nextDouble() * 0.3,
                        )
                      : Colors.amber.withValues(
                          alpha: 0.4 + random.nextDouble() * 0.3,
                        ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.2, 1.2),
                  duration: Duration(milliseconds: 1000 + random.nextInt(1000)),
                )
                .fadeIn(duration: 500.ms),
      );
    });
  }

  /// Sınıf bilgisini formatlı göster
  String _formatGrade(String? grade) {
    if (grade == null || grade.isEmpty) return '';
    if (grade.contains('. Sınıf')) return grade;
    final match = RegExp(r'(\d+)_?[Ss]inif').firstMatch(grade);
    if (match != null) return '${match.group(1)}. Sınıf';
    // Sadece sayı ise
    final numMatch = RegExp(r'^(\d+)$').firstMatch(grade);
    if (numMatch != null) return '${numMatch.group(1)}. Sınıf';
    return grade;
  }

  Widget _buildHeader(
    bool isDarkMode,
    AsyncValue<Map<String, dynamic>?> userProfileAsync,
    AsyncValue<Mascot?> mascotAsync,
  ) {
    final userName = userProfileAsync.asData?.value?['name'] ?? 'Bilgi Avcısı';
    final grade = userProfileAsync.asData?.value?['grade'] ?? 
                  userProfileAsync.asData?.value?['classLevel'] ?? '';
    final formattedGrade = _formatGrade(grade);
    final mascot = mascotAsync.asData?.value;
    final level = mascot?.level ?? 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Row(
        children: [
          // Sol taraf: İsim ve Sınıf bilgisi (ikon yok)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Merhaba, $userName! 👋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (formattedGrade.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      formattedGrade,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode 
                            ? Colors.white70 
                            : Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Sağ taraf: Seri ve Seviye badge'leri
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.fire,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mascot?.petType.color ?? Colors.purple,
                      (mascot?.petType.color ?? Colors.purple).withValues(
                        alpha: 0.7,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Lv.$level',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubbleCard(
    bool isDarkMode,
    AsyncValue<Mascot?> mascotAsync,
  ) {
    final mascot = mascotAsync.asData?.value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isSpeechBubbleExpanded = !_isSpeechBubbleExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: GlassContainer(
          blur: 10,
          opacity: isDarkMode ? 0.15 : 0.6,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb,
                  size: 20,
                  color: Colors.amber[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Bunu biliyor musun? 💡',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _isSpeechBubbleExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.expand_more,
                            size: 18,
                            color: isDarkMode ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '💬 Maskota basarak konuşabilirsin',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white54 : Colors.black45,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedCrossFade(
                      firstChild: Text(
                        _typedText,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(
                        _dailyFact?.fact ?? _typedText,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      crossFadeState: _isSpeechBubbleExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    if (!_isSpeechBubbleExpanded &&
                        _dailyFact != null &&
                        _dailyFact!.fact.length > 100 &&
                        !_isTyping)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Devamını görmek için dokun ↓',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        mascot?.petType.color ?? Colors.purple,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascotStage(
    bool isDarkMode,
    AsyncValue<Mascot?> mascotAsync,
    double availableHeight,
  ) {
    // Maskot boyutunu dinamik ayarla ama min 120px koru
    final mascotHeight = math.max(availableHeight * 0.9, 120.0);

    return mascotAsync.when(
      data: (mascot) {
        if (mascot == null) {
          return SizedBox(
            height: availableHeight,
            child: _buildNoMascotState(isDarkMode),
          );
        }
        return SizedBox(
          height: availableHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveMascotWidget(
                height: mascotHeight,
                enableVoiceInteraction: true,
              ),
              Positioned(
                bottom: 0,
                child: _buildMascotNameBadge(isDarkMode, mascot),
              ),
            ],
          ),
        );
      },
      loading: () => SizedBox(
        height: availableHeight,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => SizedBox(
        height: availableHeight,
        child: _buildNoMascotState(isDarkMode),
      ),
    );
  }

  Widget _buildNoMascotState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: isDarkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bir maskotun yok!',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotNameBadge(bool isDarkMode, Mascot mascot) {
    return GlassContainer(
      blur: 8,
      opacity: isDarkMode ? 0.2 : 0.5,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: mascot.petType.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            mascot.petName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          FaIcon(FontAwesomeIcons.heart, size: 12, color: Colors.red[400]),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms);
  }

  Widget _buildActionDeck(
    bool isDarkMode, {
    required bool isVertical,
    bool isSmallScreen = false,
  }) {
    // Kart yüksekliği
    final double cardHeight = isVertical
        ? 100.0
        : (isSmallScreen ? 110.0 : 125.0);

    final cards = [
      _ActionCard(
        icon: FontAwesomeIcons.clipboardQuestion,
        title: 'Test Çöz',
        subtitle: 'Bilgini test et',
        gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LessonSelectionScreen(mode: 'test'),
          ),
        ),
      ),
      _ActionCard(
        icon: FontAwesomeIcons.checkDouble,
        title: 'Doğru/Yanlış',
        subtitle: 'Bilgi kartları',
        gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const LessonSelectionScreen(mode: 'flashcard'),
          ),
        ),
      ),
      _ActionCard(
        icon: FontAwesomeIcons.medal,
        title: 'Başarılarım',
        subtitle: 'Rozetlerini gör',
        gradient: const [Color(0xFFFFB347), Color(0xFFFFCC33)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AchievementsScreen()),
        ),
      ),
    ];

    if (isVertical) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            height: 90,
            child: _buildActionCard(
              cards[index],
              isDarkMode,
              index,
              isSmallScreen: isSmallScreen,
              height: 90,
            ),
          );
        },
      );
    }

    const cardSpacing = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            '🚀 Hızlı Başlat',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(cards.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : cardSpacing / 2,
                    right: index == cards.length - 1 ? 0 : cardSpacing / 2,
                    bottom: 0, // Alt boşluğu kaldırdık
                  ),
                  child: _buildActionCard(
                    cards[index],
                    isDarkMode,
                    index,
                    isSmallScreen: isSmallScreen,
                    height: cardHeight,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    _ActionCard card,
    bool isDarkMode,
    int index, {
    bool isSmallScreen = false,
    required double height,
  }) {
    final iconSize = height * 0.32;
    final iconInnerSize = iconSize * 0.5;

    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            card.onTap();
          },
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: card.gradient,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: card.gradient[0].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(
                      card.icon,
                      color: Colors.white,
                      size: iconInnerSize,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 10,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.15, end: 0);
  }
}

class _ActionCard {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}
