import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../features/games/fill_blanks/presentation/screens/level_selection_screen.dart';
import '../../features/games/guess/presentation/screens/guess_level_selection_screen.dart';
import '../../features/games/memory/presentation/screens/memory_game_screen.dart';
import '../../features/games/memory/presentation/screens/shape_game_screen.dart';
import '../../features/duel/presentation/screens/duel_game_selection_screen.dart';
import '../../providers/repository_providers.dart';

/// 🎮 Neon Arcade - Oyun Salonu
/// Bento Grid layout ile modern oyun kartları
class GamesTab extends ConsumerStatefulWidget {
  const GamesTab({super.key});

  @override
  ConsumerState<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends ConsumerState<GamesTab>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Oyun verileri - Navigasyon mantığı korunuyor
  late final List<_GameData> _games;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _games = [
      _GameData(
        id: 'duel',
        title: '1v1 Düello',
        subtitle: 'Rakibinle yarış!',
        description: 'Arkadaşınla veya rastgele rakiple bilgi yarışması',
        icon: FontAwesomeIcons.userGroup,
        lottiePath: 'assets/animation/1v1_animation.json',
        gradientColors: [const Color(0xFFFF6B35), const Color(0xFFFF3D00)],
        glowColor: const Color(0xFFFF6B35),
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const DuelGameSelectionScreen()),
        ).then((_) => _refreshGameProgress()),
        isHero: true,
      ),
      _GameData(
        id: 'memory',
        title: 'Hafıza Oyunu',
        subtitle: 'Hafıza testi!',
        description: 'Sıralı bul veya şekil eşleştir',
        icon: FontAwesomeIcons.brain,
        gradientColors: [const Color(0xFF00E676), const Color(0xFF00C853)],
        glowColor: const Color(0xFF00E676),
        onTap: (ctx) => _showMemoryGameModal(ctx),
      ),
      _GameData(
        id: 'fill_blanks',
        title: 'Cümle Tamamla',
        subtitle: 'Kelime ustası!',
        description: 'Boşluğa doğru kelimeyi sürükle',
        icon: FontAwesomeIcons.penToSquare,
        gradientColors: [const Color(0xFFAA00FF), const Color(0xFF7B1FA2)],
        glowColor: const Color(0xFFAA00FF),
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const LevelSelectionScreen()),
        ).then((_) => _refreshGameProgress()),
      ),
      _GameData(
        id: 'guess',
        title: 'Salla Bakalım',
        subtitle: 'Tahmin et!',
        description: 'Telefonu salla, sayıyı tahmin et',
        icon: FontAwesomeIcons.mobileScreenButton,
        gradientColors: [const Color(0xFFFFD600), const Color(0xFFFFC107)],
        glowColor: const Color(0xFFFFD600),
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const GuessLevelSelectionScreen()),
        ).then((_) => _refreshGameProgress()),
        isWide: true,
      ),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Oyundan geri dönüldüğünde badge'leri güncelle
  void _refreshGameProgress() {
    if (mounted) {
      ref.invalidate(gameProgressProvider('fill_blanks'));
      ref.invalidate(gameProgressProvider('guess'));
      setState(() {});
    }
  }

  /// Hafıza oyunu mod seçim modalı
  // Neon tema renkleri (Bildirimler ile uyumlu)
  static const Color _accentCyan = Color(0xFF00D9FF);
  static const Color _deepPurple = Color(0xFF1A0A2E);
  static const Color _darkBg = Color(0xFF0D0D1A);

  void _showMemoryGameModal(BuildContext ctx) {
    final screenHeight = MediaQuery.of(ctx).size.height;
    final screenWidth = MediaQuery.of(ctx).size.width;
    final isTablet = screenWidth > 600;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxWidth: screenWidth, minWidth: screenWidth),
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final modalHeight = screenHeight * 0.45;
            final isCompact = modalHeight < 300;
            final horizontalPadding = screenWidth * 0.05;

            return Container(
              width: isTablet ? 500 : double.infinity,
              height: modalHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_deepPurple, _darkBg],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: _accentCyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  left: BorderSide(
                    color: _accentCyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  right: BorderSide(
                    color: _accentCyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    children: [
                      // Başlık container
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact ? 12 : 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '🧠',
                                  style: TextStyle(fontSize: 26),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'HAFIZA OYUNU',
                                  style: GoogleFonts.poppins(
                                    fontSize: isCompact ? 20 : 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isCompact ? 4 : 8),
                            Text(
                              'Bir oyun modu seç',
                              style: GoogleFonts.poppins(
                                fontSize: isCompact ? 13 : 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Oyun mod butonları
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isCompact ? 12 : 16,
                          ),
                          child: Column(
                            children: [
                              // Sıralı Bulma Modu
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: _MemoryModeCard(
                                    icon: FontAwesomeIcons.sortNumericUp,
                                    title: 'Sıralı Bulma',
                                    subtitle: '1\'den 10\'a kadar sırayla bul',
                                    gradient: [
                                      const Color(0xFF667EEA),
                                      const Color(0xFF764BA2),
                                    ],
                                    isCompact: isCompact,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MemoryGameScreen(),
                                        ),
                                      ).then((_) => _refreshGameProgress());
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: isCompact ? 10 : 14),

                              // Şekil Eşleştirme Modu
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: _MemoryModeCard(
                                    icon: FontAwesomeIcons.shapes,
                                    title: 'Şekil Eşleştir',
                                    subtitle: 'Aynı şekilleri eşleştirerek bul',
                                    gradient: [
                                      const Color(0xFFFF6B9D),
                                      const Color(0xFFC44FFF),
                                    ],
                                    isCompact: isCompact,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        ctx,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ShapeGameScreen(),
                                        ),
                                      ).then((_) => _refreshGameProgress());
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 8 : 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Stack(
      children: [
        // Arka plan
        _buildBackground(isDarkMode),

        // İçerik
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Başlık
              SliverToBoxAdapter(child: _buildHeader(isDarkMode)),

              // Oyun kartları - Bento Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverToBoxAdapter(
                  child: isTablet
                      ? _buildTabletLayout(isDarkMode)
                      : _buildMobileLayout(isDarkMode),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Neon Arcade arka planı
  Widget _buildBackground(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF0D0D1A),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0D0D1A),
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
        painter: _NeonGridPainter(isDarkMode: isDarkMode),
        size: Size.infinite,
      ),
    );
  }

  /// Neon Glow başlık
  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Neon başlık - daha görünür gradient
          ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFF6B9D),
                    Color(0xFFC44FFF),
                  ],
                ).createShader(bounds),
                child: const Text(
                  '🎮 Oyun Salonu',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.3, end: 0, curve: Curves.easeOutBack),

          const SizedBox(height: 8),

          // Alt başlık
          Text(
                'Eğlenerek öğren, yarışarak kazan! 🏆',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  /// Mobil Bento Grid Layout
  Widget _buildMobileLayout(bool isDarkMode) {
    return Column(
      children: [
        // Hero Card - Düello (Tam genişlik)
        _buildArcadeCard(
          game: _games[0],
          isDarkMode: isDarkMode,
          height: 200,
          animationDelay: 0,
        ),

        const SizedBox(height: 16),

        // İkili Satır - Hafıza & Cümle Tamamla
        Row(
          children: [
            Expanded(
              child: _buildArcadeCard(
                game: _games[1],
                isDarkMode: isDarkMode,
                height: 180,
                animationDelay: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildArcadeCard(
                game: _games[2],
                isDarkMode: isDarkMode,
                height: 180,
                animationDelay: 200,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Geniş Kart - Salla Bakalım
        _buildArcadeCard(
          game: _games[3],
          isDarkMode: isDarkMode,
          height: 160,
          animationDelay: 300,
        ),
      ],
    );
  }

  /// Tablet Grid Layout
  Widget _buildTabletLayout(bool isDarkMode) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (int i = 0; i < _games.length; i++)
          SizedBox(
            width: _games[i].isHero
                ? double.infinity
                : (MediaQuery.of(context).size.width - 48) / 2,
            child: _buildArcadeCard(
              game: _games[i],
              isDarkMode: isDarkMode,
              height: _games[i].isHero ? 200 : 180,
              animationDelay: i * 100,
            ),
          ),
      ],
    );
  }

  /// Ana Oyun Kartı - Neon Arcade Stili
  Widget _buildArcadeCard({
    required _GameData game,
    required bool isDarkMode,
    required double height,
    required int animationDelay,
  }) {
    // Oyun için progress bilgisini al
    final progressAsync = ref.watch(gameProgressProvider(game.id));
    final badgeCount = progressAsync.valueOrNull ?? 0;

    return _ArcadeGameCard(
          game: game,
          isDarkMode: isDarkMode,
          height: height,
          badgeCount: badgeCount,
        )
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: animationDelay),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 500.ms,
          delay: Duration(milliseconds: animationDelay),
          curve: Curves.easeOutBack,
        );
  }
}

/// Oyun Verisi
class _GameData {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String? lottiePath;
  final List<Color> gradientColors;
  final Color glowColor;
  final void Function(BuildContext) onTap;
  final bool isHero;
  final bool isWide;

  const _GameData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.lottiePath,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
    this.isHero = false,
    this.isWide = false,
  });
}

/// Arcade Oyun Kartı Widget'ı
class _ArcadeGameCard extends StatefulWidget {
  final _GameData game;
  final bool isDarkMode;
  final double height;
  final int badgeCount;

  const _ArcadeGameCard({
    required this.game,
    required this.isDarkMode,
    required this.height,
    this.badgeCount = 0,
  });

  @override
  State<_ArcadeGameCard> createState() => _ArcadeGameCardState();
}

class _ArcadeGameCardState extends State<_ArcadeGameCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.mediumImpact();
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
    HapticFeedback.heavyImpact();
    // Küçük gecikme ile navigasyon
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      widget.game.onTap(context);
    });
  }

  /// Lottie yüklenemezse fallback ikon
  Widget _buildIconFallback() {
    return Container(
      width: widget.game.isHero ? 100 : 80,
      height: widget.game.isHero ? 100 : 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: FaIcon(
          widget.game.icon,
          size: widget.game.isHero ? 45 : 35,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  /// 🔴 Tamamlanmamış level sayısı badge'i (Animasyonlu)
  Widget _buildProgressBadge(int count) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30), // iOS Red
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3B30).withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // Neon glow efekti
                  BoxShadow(
                    color: widget.game.glowColor.withValues(
                      alpha: _isPressed ? 0.6 : 0.4,
                    ),
                    blurRadius: _isPressed ? 25 : 20,
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                  // Alt gölge
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
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
                          colors: widget.game.gradientColors,
                        ),
                      ),
                    ),

                    // Glass efekti
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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

                    // Dekoratif daireler (sadece lottie yoksa göster)
                    if (widget.game.lottiePath == null)
                      Positioned(
                        top: -30,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),

                    // Hero kart için tam ekran Lottie animasyonu
                    if (widget.game.lottiePath != null && widget.game.isHero)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: -3,
                        right: 0,
                        // ✅ Lottie optimize edildi
                        child: Lottie.asset(
                          widget.game.lottiePath!,
                          fit: BoxFit.cover,
                          animate: true,
                          frameRate: FrameRate.max,
                          options: LottieOptions(enableMergePaths: true),
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),

                    // Hero kart için koyu overlay (metin okunabilirliği için)
                    if (widget.game.lottiePath != null && widget.game.isHero)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),

                    // Sağ tarafta animasyonlu görsel (Hero olmayan kartlar için)
                    if (!widget.game.isHero || widget.game.lottiePath == null)
                      Positioned(
                        right: widget.game.isHero ? -10 : 5,
                        bottom: widget.game.isHero ? -10 : 15,
                        child: widget.game.lottiePath != null
                            // ✅ Lottie animasyonu - optimize edildi
                            ? SizedBox(
                                width: 100,
                                height: 100,
                                child: Lottie.asset(
                                  widget.game.lottiePath!,
                                  fit: BoxFit.contain,
                                  animate: true,
                                  frameRate: FrameRate.max,
                                  options: LottieOptions(
                                    enableMergePaths: true,
                                  ),
                                  errorBuilder: (_, __, ___) =>
                                      _buildIconFallback(),
                                ),
                              )
                            // Yoksa ikon kullan
                            : Container(
                                    width: widget.game.isHero ? 100 : 80,
                                    height: widget.game.isHero ? 100 : 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.game.glowColor
                                              .withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        widget.game.icon,
                                        size: widget.game.isHero ? 45 : 35,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .moveY(begin: 0, end: -8, duration: 1500.ms)
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.08, 1.08),
                                    duration: 1500.ms,
                                  ),
                      ),

                    // İçerik
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero badge
                          if (widget.game.isHero)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'POPÜLER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (widget.game.isHero) const SizedBox(height: 8),

                          // Başlık
                          Text(
                            widget.game.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: widget.game.isHero ? 26 : 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Alt başlık
                          Text(
                            widget.game.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Spacer(),

                          // Oyna butonu
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Oyna',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: widget.game.isHero ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Parlak kenar efekti (Border Gradient)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: _isPressed ? 0.5 : 0.3,
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔴 Tamamlanmamış level badge'i
            if (widget.badgeCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: _buildProgressBadge(widget.badgeCount),
              ),
          ],
        ),
      ),
    );
  }
}

/// Neon Grid arka plan çizici
class _NeonGridPainter extends CustomPainter {
  final bool isDarkMode;

  _NeonGridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isDarkMode) return;

    final paint = Paint()
      ..color = const Color(0xFF6C5CE7).withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Yatay çizgiler
    const spacing = 50.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Dikey çizgiler
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Köşe parlaklıkları
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFFF6B9D).withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: const Offset(50, 100), radius: 200),
          );
    canvas.drawCircle(const Offset(50, 100), 200, glowPaint);

    final glowPaint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF6C5CE7).withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width - 50, size.height - 200),
              radius: 250,
            ),
          );
    canvas.drawCircle(
      Offset(size.width - 50, size.height - 200),
      250,
      glowPaint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hafıza oyunu mod seçim kartı
class _MemoryModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool isCompact;

  const _MemoryModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 20,
            vertical: isCompact ? 8 : 12,
          ),
          child: Row(
            children: [
              // İkon
              Container(
                width: isCompact ? 44 : 56,
                height: isCompact ? 44 : 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: Colors.white,
                    size: isCompact ? 20 : 26,
                  ),
                ),
              ),
              SizedBox(width: isCompact ? 12 : 16),
              // Metin
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCompact ? 15 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isCompact ? 2 : 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: isCompact ? 12 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Ok ikonu
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: isCompact ? 18 : 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
