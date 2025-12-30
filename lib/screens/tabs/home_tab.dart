import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import '../../widgets/glass_container.dart';
import '../../services/daily_fact_service.dart';
import '../../core/providers/user_provider.dart';
import '../../features/mascot/presentation/providers/mascot_provider.dart';
import '../../features/mascot/presentation/widgets/interactive_mascot_widget.dart';
import '../../features/mascot/domain/entities/mascot.dart';
import '../lesson_selection_screen.dart';
import '../achievements_screen.dart';

/// Ana sayfa tab'ı - "Maskotun Evi" konseptinde immersive deneyim
class HomeTab extends ConsumerStatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeTab({super.key, this.onNavigateToTab});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with TickerProviderStateMixin {
  // Animasyon controller'ları
  late AnimationController _floatController;
  late AnimationController _bubbleController;

  // Günlük bilgi state'i
  String _typedText = '';
  bool _isTyping = false;
  DailyFact? _dailyFact;

  @override
  void initState() {
    super.initState();

    // Floating animasyon (bulutlar için)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Bubble animasyon
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Günlük bilgiyi yükle ve typing animasyonu başlat
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
          // Fallback: JSON yüklenemezse varsayılan bilgi göster
          const fallbackFact = DailyFact(
            dayOfYear: 1,
            title: 'İlginç Bilgi',
            fact:
                'Dünya, Güneş etrafındaki turunu tam 365 gün 6 saatte tamamlar!',
          );
          setState(() => _dailyFact = fallbackFact);
          _startTypingAnimation(fallbackFact.fact);
        }
      }
    } catch (e) {
      // Hata durumunda da fallback göster
      if (mounted) {
        const fallbackFact = DailyFact(
          dayOfYear: 1,
          title: 'İlginç Bilgi',
          fact:
              'Dünya, Güneş etrafındaki turunu tam 365 gün 6 saatte tamamlar!',
        );
        setState(() => _dailyFact = fallbackFact);
        _startTypingAnimation(fallbackFact.fact);
      }
    }
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
        // Katman 1: Animated Background
        _buildAnimatedBackground(isDarkMode),

        // Katman 2: Floating Clouds/Shapes
        _buildFloatingElements(isDarkMode),

        // Katman 3: Main Content
        SafeArea(
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

  /// Tablet Layout - Yatay düzen
  Widget _buildTabletLayout(
    bool isDarkMode,
    AsyncValue<Map<String, dynamic>?> userProfileAsync,
    AsyncValue<Mascot?> mascotAsync,
    Size screenSize,
  ) {
    return Row(
      children: [
        // Sol taraf - Maskot Alanı
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildHeader(isDarkMode, userProfileAsync, mascotAsync),
              Expanded(
                child: _buildMascotStage(isDarkMode, mascotAsync, screenSize),
              ),
            ],
          ),
        ),
        // Sağ taraf - Kartlar
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

  /// Phone Layout - Dikey düzen
  Widget _buildPhoneLayout(
    bool isDarkMode,
    AsyncValue<Map<String, dynamic>?> userProfileAsync,
    AsyncValue<Mascot?> mascotAsync,
    Size screenSize,
  ) {
    final isSmallScreen = screenSize.height < 700;
    final mascotHeight = isSmallScreen
        ? screenSize.height * 0.35
        : screenSize.height * 0.40;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              screenSize.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(
              isDarkMode,
              userProfileAsync,
              mascotAsync,
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0),

            // Speech Bubble - Header altında
            if (_dailyFact != null)
              Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildSpeechBubbleCard(isDarkMode, mascotAsync),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: -0.2, end: 0),

            // Mascot Stage - Daha büyük
            SizedBox(
                  height: mascotHeight,
                  child: _buildMascotStage(isDarkMode, mascotAsync, screenSize),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

            // Action Deck
            Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    isSmallScreen ? 90 : 110,
                  ),
                  child: _buildActionDeck(
                    isDarkMode,
                    isVertical: false,
                    isSmallScreen: isSmallScreen,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  /// Animated gradient background
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

  /// Floating decorative elements
  Widget _buildFloatingElements(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: [
            // Cloud 1
            Positioned(
              top: 60 + _floatController.value * 20,
              left: 20,
              child: _buildCloud(isDarkMode, size: 80),
            ),
            // Cloud 2
            Positioned(
              top: 120 + (1 - _floatController.value) * 15,
              right: 30,
              child: _buildCloud(isDarkMode, size: 60),
            ),
            // Cloud 3
            Positioned(
              top: 200 + _floatController.value * 10,
              left: 60,
              child: _buildCloud(isDarkMode, size: 50),
            ),
            // Sparkles
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

  /// Header with greeting and stats
  Widget _buildHeader(
    bool isDarkMode,
    AsyncValue<Map<String, dynamic>?> userProfileAsync,
    AsyncValue<Mascot?> mascotAsync,
  ) {
    final userName = userProfileAsync.asData?.value?['name'] ?? 'Bilgi Avcısı';
    final mascot = mascotAsync.asData?.value;
    final level = mascot?.level ?? 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Sol - Kullanıcı adı
          Flexible(
            child: Text(
              'Merhaba, $userName! 👋',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Sağ - Streak ve Level (kompakt)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Streak Badge
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
              // Level Badge
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

  /// Speech Bubble Card - Header altında gösterilecek
  Widget _buildSpeechBubbleCard(
    bool isDarkMode,
    AsyncValue<Mascot?> mascotAsync,
  ) {
    final mascot = mascotAsync.asData?.value;

    return GlassContainer(
      blur: 10,
      opacity: isDarkMode ? 0.15 : 0.6,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lightbulb, size: 20, color: Colors.amber[600]),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bunu biliyor musun? 💡',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
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
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showFullFactDialog(context, isDarkMode),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typedText,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_dailyFact != null &&
                          _dailyFact!.fact.length > 60 &&
                          !_isTyping)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Devamını oku...',
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
    );
  }

  /// Günlük bilginin tamamını gösteren dialog
  void _showFullFactDialog(BuildContext context, bool isDarkMode) {
    if (_dailyFact == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1a1a2e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lightbulb, color: Colors.amber[600], size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Bunu Biliyor Musun?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            _dailyFact!.fact,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Kapat',
              style: TextStyle(
                color: Colors.blue[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mascot Stage - İnteraktif maskot alanı (Talking Tom benzeri)
  Widget _buildMascotStage(
    bool isDarkMode,
    AsyncValue<Mascot?> mascotAsync,
    Size screenSize,
  ) {
    final isSmallScreen = screenSize.height < 700;
    final mascotHeight = isSmallScreen
        ? screenSize.height * 0.32
        : screenSize.height * 0.38;

    return mascotAsync.when(
      data: (mascot) {
        if (mascot == null) {
          return _buildNoMascotState(isDarkMode);
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            // InteractiveMascotWidget - Basılı tutup konuşma özelliği
            InteractiveMascotWidget(
              height: mascotHeight,
              enableVoiceInteraction: true,
            ),
            // Mascot name badge
            Positioned(
              bottom: 0,
              child: _buildMascotNameBadge(isDarkMode, mascot),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildNoMascotState(isDarkMode),
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

  /// Action Deck - Hızlı işlem kartları
  Widget _buildActionDeck(
    bool isDarkMode, {
    required bool isVertical,
    bool isSmallScreen = false,
  }) {
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
        icon: FontAwesomeIcons.gamepad,
        title: 'Oyun Odası',
        subtitle: 'Eğlenerek öğren',
        gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
        onTap: () => widget.onNavigateToTab?.call(2),
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
          return _buildActionCard(
            cards[index],
            isDarkMode,
            index,
            isSmallScreen: isSmallScreen,
          );
        },
      );
    }

    final cardHeight = isSmallScreen ? 110.0 : 125.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '🚀 Hızlı Başlat',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _buildActionCard(
                cards[index],
                isDarkMode,
                index,
                isSmallScreen: isSmallScreen,
              );
            },
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
  }) {
    final cardWidth = isSmallScreen ? 130.0 : 145.0;
    final iconSize = isSmallScreen ? 32.0 : 38.0;
    final iconInnerSize = isSmallScreen ? 16.0 : 18.0;

    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            card.onTap();
          },
          child: Container(
            width: cardWidth,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: card.gradient,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: card.gradient[0].withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: isSmallScreen ? 8 : 10),
                Text(
                  card.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  card.subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 9 : 10,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

/// Action Card data model
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
