import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:ui';
import '../providers/theme_provider.dart'; // ✅ Riverpod themeProvider
import '../core/providers/user_provider.dart';
import '../services/database_helper.dart';
import '../features/mascot/presentation/providers/mascot_provider.dart';
import 'tabs/home_tab.dart';
import 'tabs/lessons_tab.dart';
import 'tabs/games_tab.dart';
import 'tabs/profile_tab.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

/// Uygulamanın ana iskeleti - Floating Glass Dock ile 4 tab yönetimi
class MainScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  bool _isNotificationSheetOpen = false;

  // Animasyon controller'ları
  late AnimationController _glowController;
  late AnimationController _bounceController;

  // Navigation items
  final List<_NavItem> _navItems = [
    _NavItem(
      icon: FontAwesomeIcons.house,
      activeIcon: FontAwesomeIcons.houseMedical,
      label: 'Ana Sayfa',
      gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
    ),
    _NavItem(
      icon: FontAwesomeIcons.bookOpen,
      activeIcon: FontAwesomeIcons.bookBookmark,
      label: 'Dersler',
      gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
    ),
    _NavItem(
      icon: FontAwesomeIcons.gamepad,
      activeIcon: FontAwesomeIcons.chess,
      label: 'Oyunlar',
      gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
    ),
    _NavItem(
      icon: FontAwesomeIcons.userAstronaut,
      activeIcon: FontAwesomeIcons.userNinja,
      label: 'Profil',
      gradient: const [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    ),
  ];

  @override
  void initState() {
    super.initState();

    // ⚡ Uygulama ön planda olduğu sürece ekran açık kalacak (UX Faz 1.2)
    WakelockPlus.enable();

    // İnitial tab index'i ayarla
    _currentIndex = widget.initialTabIndex;

    // Animasyon controller'ları
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Bildirim servisini başlat (izin kontrolü + zamanlanmış bildirimler)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().ensureInitialized();
      _loadStreak();
    });
  }

  // Streak (seri) değeri
  int _streak = 0;

  /// Streak hesapla ve yükle
  Future<void> _loadStreak() async {
    try {
      final dbHelper = DatabaseHelper();
      const int minSecondsPerDay = 60; // 1 dakika
      int streak = 0;
      DateTime checkDate = DateTime.now();

      // Bugün kontrol et
      String todayStr = _formatDateForDB(checkDate);
      int todaySeconds = await dbHelper.getDailyTime(todayStr);

      // Bugün henüz 1 dakika kullanım yoksa, dünden başla
      if (todaySeconds < minSecondsPerDay) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Geriye doğru ardışık günleri say
      while (true) {
        String dateStr = _formatDateForDB(checkDate);
        int seconds = await dbHelper.getDailyTime(dateStr);

        if (seconds >= minSecondsPerDay) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }

        if (streak >= 365) break;
      }

      if (mounted) {
        setState(() => _streak = streak);
      }
    } catch (e) {
      debugPrint('Streak hesaplama hatası: $e');
    }
  }

  String _formatDateForDB(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Belirtilen tab'a geçiş yapar
  void _navigateToTab(int index) {
    if (index >= 0 && index < 4) {
      // _tabs.length yerine sabit 4
      HapticFeedback.lightImpact();
      _bounceController.forward(from: 0);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void dispose() {
    // ⚡ Ana ekrandan çıkıldığında wakelock'u kapat
    WakelockPlus.disable();
    _glowController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Riverpod themeProvider ile tema değişikliğini dinle
    final currentMode = ref.watch(themeProvider);
    final Brightness platformBrightness = MediaQuery.platformBrightnessOf(
      context,
    );
    final bool isSystemDark = platformBrightness == Brightness.dark;

    final bool isDarkMode;
    if (currentMode == ThemeMode.system) {
      isDarkMode = isSystemDark;
    } else {
      isDarkMode = currentMode == ThemeMode.dark;
    }

    return PopScope(
      canPop: false, // Geri butonunu devre dışı bırak
      child: Scaffold(
        extendBody: true, // İçerik navigasyon barın arkasına uzansın
        extendBodyBehindAppBar: true,
        appBar: _currentIndex == 0 ? _buildAppBar(context, isDarkMode) : null,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeTab(onNavigateToTab: _navigateToTab),
            LessonsTab(isActive: _currentIndex == 1),
            const GamesTab(),
            ProfileTab(isActive: _currentIndex == 3),
          ],
        ),
        bottomNavigationBar: _buildFloatingGlassDock(isDarkMode),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF1a1a2e).withValues(alpha: 0.9),
                        const Color(0xFF16213e).withValues(alpha: 0.9),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.85),
                        const Color(0xFFE8F5E9).withValues(alpha: 0.85),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      title: userProfileAsync.when(
        data: (profile) {
          final name = profile?['name'] ?? 'Öğrenci';
          final grade = profile?['grade'] ?? '3. Sınıf';

          return Row(
            children: [
              // Profil fotoğrafı kaldırıldı - kullanıcı isteği
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  const Color(
                                    0xFF11998E,
                                  ).withValues(alpha: 0.3),
                                  const Color(
                                    0xFF38EF7D,
                                  ).withValues(alpha: 0.3),
                                ]
                              : [
                                  const Color(
                                    0xFF11998E,
                                  ).withValues(alpha: 0.2),
                                  const Color(
                                    0xFF38EF7D,
                                  ).withValues(alpha: 0.2),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$grade 🎓',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? const Color(0xFF38EF7D)
                              : const Color(0xFF11998E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      actions: [
        // Seri Badge
        _buildStreakBadge(isDarkMode),
        const SizedBox(width: 6),
        // Seviye Badge
        _buildLevelBadge(isDarkMode),
        const SizedBox(width: 8),
        // Theme Toggle - Modern pill design
        _buildThemeToggleButton(context, isDarkMode),
        const SizedBox(width: 8),
        // Notifications - Modern badge
        _buildNotificationButton(context, isDarkMode),
        const SizedBox(width: 12),
      ],
    );
  }

  /// Seri (Streak) Badge Widget
  Widget _buildStreakBadge(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.fire,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            '$_streak',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  /// Seviye (Level) Badge Widget
  Widget _buildLevelBadge(bool isDarkMode) {
    final mascotAsync = ref.watch(activeMascotProvider);
    final mascot = mascotAsync.asData?.value;
    final level = mascot?.level ?? 1;
    final color = mascot?.petType.color ?? Colors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
    ).animate().fadeIn(duration: 400.ms, delay: 50.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildThemeToggleButton(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  Colors.grey[800]!.withValues(alpha: 0.6),
                  Colors.grey[700]!.withValues(alpha: 0.6),
                ]
              : [
                  Colors.grey[200]!.withValues(alpha: 0.8),
                  Colors.grey[100]!.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _themeButton(
            context,
            FontAwesomeIcons.sun,
            !isDarkMode,
            () => ref.read(themeProvider.notifier).toggleTheme(false),
            const Color(0xFFFFB347),
          ),
          _themeButton(
            context,
            FontAwesomeIcons.moon,
            isDarkMode,
            () => ref.read(themeProvider.notifier).toggleTheme(true),
            const Color(0xFF667EEA),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _themeButton(
    BuildContext context,
    IconData icon,
    bool isSelected,
    VoidCallback onPressed,
    Color activeColor,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    activeColor.withValues(alpha: 0.3),
                    activeColor.withValues(alpha: 0.1),
                  ],
                )
              : null,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              blurRadius: isSelected ? 8 : 0,
              offset: isSelected ? const Offset(0, 2) : Offset.zero,
            ),
          ],
        ),
        child: FaIcon(
          icon,
          size: 14,
          color: isSelected
              ? activeColor
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[500]
                    : Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, bool isDarkMode) {
    return GestureDetector(
          onTap: () {
            // Prevent duplicate sheet opening
            if (_isNotificationSheetOpen) return;

            HapticFeedback.lightImpact();
            _isNotificationSheetOpen = true;

            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => _buildNotificationSheet(isDarkMode),
            ).whenComplete(() {
              _isNotificationSheetOpen = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        const Color(0xFFF093FB).withValues(alpha: 0.2),
                        const Color(0xFFF5576C).withValues(alpha: 0.2),
                      ]
                    : [
                        const Color(0xFFF093FB).withValues(alpha: 0.15),
                        const Color(0xFFF5576C).withValues(alpha: 0.15),
                      ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF093FB).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FaIcon(
                  FontAwesomeIcons.bell,
                  color: isDarkMode ? Colors.white70 : const Color(0xFFF5576C),
                  size: 18,
                ),
                // Notification badge
                ValueListenableBuilder<int>(
                  valueListenable: NotificationService().unreadCountNotifier,
                  builder: (context, count, child) {
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode
                                ? const Color(0xFF1a1a2e)
                                : Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFF6B6B,
                              ).withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildNotificationSheet(bool isDarkMode) {
    return const NotificationsList();
  }

  /// Floating Glass Dock - Ana navigasyon barı
  Widget _buildFloatingGlassDock(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 700;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Tablet için maksimum genişlik 400px
    final dockWidth = isTablet ? 400.0 : screenWidth - 40;
    // Küçük ekranlar için daha kısa yükseklik
    final dockHeight = isSmallScreen ? 60.0 : 70.0;

    return Container(
          margin: EdgeInsets.only(
            left: isTablet ? (screenWidth - dockWidth) / 2 : 20,
            right: isTablet ? (screenWidth - dockWidth) / 2 : 20,
            bottom: (isSmallScreen ? 8 : 12) + bottomPadding,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    height: dockHeight,
                    decoration: BoxDecoration(
                      // Glassmorphism arka plan
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 24 : 28,
                      ),
                      // Gradient border
                      border: Border.all(
                        width: 1.5,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      // Animated gradient border effect
                      boxShadow: [
                        // Ana gölge
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        // Renkli glow efekti
                        BoxShadow(
                          color: _navItems[_currentIndex].gradient[0]
                              .withValues(
                                alpha: 0.2 + _glowController.value * 0.15,
                              ),
                          blurRadius: 25,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: _buildNavItemsRow(isDarkMode),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack);
  }

  /// Navigasyon öğelerinin satırı
  Widget _buildNavItemsRow(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      // Gradient border overlay
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_navItems.length, (index) {
          return _buildNavItem(index, isDarkMode);
        }),
      ),
    );
  }

  /// Tek bir navigasyon öğesi
  Widget _buildNavItem(int index, bool isDarkMode) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateToTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // İkon ve glow efekti
              Flexible(
                child: _buildAnimatedIcon(
                  item,
                  isSelected,
                  isDarkMode,
                  isSmallScreen,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              // Label
              _buildLabel(item.label, isSelected, isDarkMode, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  /// Animasyonlu ikon widget'ı
  Widget _buildAnimatedIcon(
    _NavItem item,
    bool isSelected,
    bool isDarkMode,
    bool isSmallScreen,
  ) {
    // Responsive boyutlar
    final activeSize = isSmallScreen ? 36.0 : 44.0;
    final inactiveSize = isSmallScreen ? 30.0 : 36.0;
    final glowBaseSize = isSmallScreen ? 34.0 : 42.0;
    final iconActiveSize = isSmallScreen ? 16.0 : 20.0;
    final iconInactiveSize = isSmallScreen ? 14.0 : 17.0;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow efekti (sadece aktif için)
            if (isSelected)
              Container(
                width: glowBaseSize + _glowController.value * 8,
                height: glowBaseSize + _glowController.value * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      item.gradient[0].withValues(alpha: 0.4),
                      item.gradient[1].withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            // İkon container
            AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? activeSize : inactiveSize,
                  height: isSelected ? activeSize : inactiveSize,
                  transform: Matrix4.identity()
                    ..setTranslationRaw(
                      0.0,
                      isSelected ? (isSmallScreen ? -2.0 : -4.0) : 0.0,
                      0.0,
                    ),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: item.gradient,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDarkMode
                              ? Colors.grey[800]!.withValues(alpha: 0.5)
                              : Colors.grey[200]!.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? item.gradient[0].withValues(alpha: 0.4)
                            : Colors.transparent,
                        blurRadius: isSelected
                            ? (isSmallScreen ? 8.0 : 12.0)
                            : 0.01,
                        spreadRadius: isSelected
                            ? (isSmallScreen ? 1.0 : 2.0)
                            : 0.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        if (isSelected) {
                          return const LinearGradient(
                            colors: [Colors.white, Colors.white],
                          ).createShader(bounds);
                        }
                        return LinearGradient(
                          colors: isDarkMode
                              ? [Colors.grey[400]!, Colors.grey[500]!]
                              : [Colors.grey[600]!, Colors.grey[700]!],
                        ).createShader(bounds);
                      },
                      child: FaIcon(
                        isSelected ? item.activeIcon : item.icon,
                        size: isSelected ? iconActiveSize : iconInactiveSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 200.ms,
                  curve: Curves.easeOutBack,
                )
                .moveY(
                  begin: 0,
                  end: -2,
                  duration: 200.ms,
                  curve: Curves.easeOutCubic,
                ),
          ],
        );
      },
    );
  }

  /// Label widget'ı
  Widget _buildLabel(
    String label,
    bool isSelected,
    bool isDarkMode,
    bool isSmallScreen,
  ) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: isSmallScreen ? (isSelected ? 9 : 8) : (isSelected ? 11 : 10),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected
            ? (isDarkMode ? Colors.white : Colors.black87)
            : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
        letterSpacing: isSelected ? 0.3 : 0,
      ),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

/// Navigasyon öğesi veri modeli
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final List<Color> gradient;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.gradient,
  });
}
