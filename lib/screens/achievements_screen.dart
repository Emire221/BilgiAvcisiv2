import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import '../services/database_helper.dart';
import 'lesson_selection_screen.dart';
import 'main_screen.dart';
import 'progress_analytics_screen.dart';

/// 🏆 Macera Günlüğü - Başarılar Ekranı
/// Tüm oyun sonuçları ve başarılar burada sergilenir
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<int> _currentTabIndex = ValueNotifier(0); // FAB görünürlüğü için
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Tab verileri
  final List<_TabData> _tabs = [
    _TabData(
      id: 'weekly_exam',
      title: 'Deneme',
      icon: FontAwesomeIcons.earthAmericas,
      gradientColors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      glowColor: const Color(0xFF11998e),
    ),
    _TabData(
      id: 'test',
      title: 'Testler',
      icon: FontAwesomeIcons.clipboardCheck,
      gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      glowColor: const Color(0xFF667eea),
    ),
    _TabData(
      id: 'flashcard',
      title: 'Kartlar',
      icon: FontAwesomeIcons.layerGroup,
      gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      glowColor: const Color(0xFFf093fb),
    ),
    _TabData(
      id: 'fill_blanks',
      title: 'Cümle',
      icon: FontAwesomeIcons.penToSquare,
      gradientColors: [const Color(0xFFAA00FF), const Color(0xFF7B1FA2)],
      glowColor: const Color(0xFFAA00FF),
    ),
    _TabData(
      id: 'guess',
      title: 'Salla',
      icon: FontAwesomeIcons.mobileScreenButton,
      gradientColors: [const Color(0xFFFFD600), const Color(0xFFFFC107)],
      glowColor: const Color(0xFFFFD600),
    ),
    _TabData(
      id: 'memory',
      title: 'Bul',
      icon: FontAwesomeIcons.brain,
      gradientColors: [const Color(0xFF00E676), const Color(0xFF00C853)],
      glowColor: const Color(0xFF00E676),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        _currentTabIndex.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDarkMode),
      body: Stack(
        children: [
          // Arka plan
          _buildBackground(isDarkMode),

          // İçerik
          SafeArea(
            child: TabBarView(
              controller: _tabController,
            children: _tabs.map((tab) {
                if (tab.id == 'guess') {
                  return _buildGuessResultList(tab);
                } else if (tab.id == 'memory') {
                  return _buildMemoryResultList(tab);
                } else if (tab.id == 'weekly_exam') {
                  return _buildWeeklyExamResultList(tab);
                }
                return _buildResultList(tab);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: _currentTabIndex,
        builder: (context, index, child) {
          return _shouldShowFab(index) ? _buildAnalyticsFab(index) : Container();
        },
      ),
    );
  }

  /// FAB sadece 'weekly_exam' ve 'test' sekmelerinde gösterilsin
  bool _shouldShowFab(int index) {
    final currentTab = _tabs[index];
    return currentTab.id == 'weekly_exam' || currentTab.id == 'test';
  }

  Widget _buildAnalyticsFab(int index) {
    final currentTab = _tabs[index];
    final isDenemTab = currentTab.id == 'weekly_exam';
    
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        if (isDenemTab) {
          _showDenemeTrendGraph();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProgressAnalyticsScreen(),
            ),
          );
        }
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDenemTab 
                ? [const Color(0xFF11998e), const Color(0xFF38ef7d)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (isDenemTab ? const Color(0xFF11998e) : const Color(0xFF667eea))
                  .withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              isDenemTab ? FontAwesomeIcons.chartColumn : FontAwesomeIcons.chartLine,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isDenemTab ? 'Gelişim Trendi' : 'Gelişim Grafiği',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0);
  }

  /// Deneme trend grafiği göster
  void _showDenemeTrendGraph() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DenemeTrendModal(dbHelper: _dbHelper),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.trophy,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.amber, Color(0xFFFFD700), Colors.orange],
              ).createShader(bounds),
              child: const Text(
                'Macera Günlüğü',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildTabBar(isDarkMode),
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.3),
                  Colors.orange.withValues(alpha: 0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelPadding: EdgeInsets.symmetric(horizontal: isNarrow ? 4 : 8),
            labelStyle: TextStyle(
              fontSize: isNarrow ? 9 : 11,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: isNarrow ? 9 : 11,
              fontWeight: FontWeight.w500,
            ),
            tabs: _tabs.map((tab) {
              return Tab(
                child: isNarrow
                    ? FaIcon(tab.icon, size: 14)
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(tab.icon, size: 12),
                            const SizedBox(width: 4),
                            Text(tab.title),
                          ],
                        ),
                      ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBackground(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF0f0c29),
                  const Color(0xFF302b63),
                  const Color(0xFF24243e),
                ]
              : [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  const Color(0xFFf093fb),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Parıltı efektleri
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Boş durum widget'ı - Dedektif animasyonu ile
  Widget _buildEmptyState(_TabData tab) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxHeight < 500;
        final animSize = isSmall ? 120.0 : 180.0;
        final titleSize = isSmall ? 20.0 : 24.0;
        final subtitleSize = isSmall ? 14.0 : 16.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isSmall ? 16 : 32,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dedektif animasyonu
                SizedBox(
                      width: animSize,
                      height: animSize,
                      child: Lottie.asset(
                        'assets/animation/dedective.json',
                        fit: BoxFit.contain,
                        animate: true,
                        errorBuilder: (_, __, ___) => Container(
                          width: animSize * 0.6,
                          height: animSize * 0.6,
                          decoration: BoxDecoration(
                            color: tab.glowColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.magnifyingGlass,
                              size: animSize * 0.25,
                              color: tab.glowColor,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -10, duration: 2000.ms),

                SizedBox(height: isSmall ? 16 : 24),

                // Başlık
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: tab.gradientColors,
                  ).createShader(bounds),
                  child: Text(
                    'Henüz Bir Macera Yok!',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: isSmall ? 8 : 12),

                // Alt başlık
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _getEmptyMessage(tab.id),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: isSmall ? 20 : 32),

                // Başla butonu
                GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _navigateToScreen(tab.id);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 24 : 32,
                          vertical: isSmall ? 12 : 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: tab.gradientColors),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: tab.glowColor.withValues(alpha: 0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.play,
                              color: Colors.white,
                              size: isSmall ? 14 : 16,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Maceraya Başla',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmall ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 500.ms);
  }

  String _getEmptyMessage(String tabId) {
    switch (tabId) {
      case 'test':
        return 'Test çözerek bilgini sına ve başarılarını burada takip et! 📝';
      case 'flashcard':
        return 'Bilgi kartlarıyla öğren, sonuçlarını burada gör! 🃏';
      case 'fill_blanks':
        return 'Cümle tamamlama oyunuyla kelime hazineni geliştir! ✍️';
      case 'guess':
        return 'Telefonu salla, sayıları tahmin et ve rekorlarını kır! 📱';
      case 'memory':
        return 'Hafıza oyunuyla beynini çalıştır, en iyi skorunu yap! 🧠';
      default:
        return 'Oynamaya başla ve başarılarını burada gör!';
    }
  }

  /// Sekmeye göre doğru ekrana yönlendirme
  void _navigateToScreen(String tabId) {
    switch (tabId) {
      case 'test':
        // Test sekmesi -> Ders seçim ekranı (test modu)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LessonSelectionScreen(mode: 'test'),
          ),
        );
        break;
      case 'flashcard':
        // Bilgi Kartları -> Ders seçim ekranı (flashcard modu)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LessonSelectionScreen(mode: 'flashcard'),
          ),
        );
        break;
      case 'fill_blanks':
      case 'guess':
      case 'memory':
        // Oyun sekmeleri -> Oyunlar Tab'ına git
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialTabIndex: 2),
          ),
        );
        break;
      case 'weekly_exam':
        // Deneme sekmesi -> Dersler Tab'ına git (test çözmeye başla)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialTabIndex: 0),
          ),
        );
        break;
      default:
        // Varsayılan: Geri dön
        Navigator.pop(context);
        break;
    }
  }

  Widget _buildResultList(_TabData tab) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbHelper.getGameResults(tab.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(tab);
        }

        if (snapshot.hasError) {
          return _buildErrorState(tab, snapshot.error.toString());
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return _buildEmptyState(tab);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return _AchievementCard(result: result, tab: tab, index: index);
          },
        );
      },
    );
  }

  Widget _buildGuessResultList(_TabData tab) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbHelper.getGameResults('guess'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(tab);
        }

        if (snapshot.hasError) {
          return _buildErrorState(tab, snapshot.error.toString());
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return _buildEmptyState(tab);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return _GuessResultCard(result: result, tab: tab, index: index);
          },
        );
      },
    );
  }

  Widget _buildMemoryResultList(_TabData tab) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbHelper.getGameResults('memory'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(tab);
        }

        if (snapshot.hasError) {
          return _buildErrorState(tab, snapshot.error.toString());
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return _buildEmptyState(tab);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return _MemoryResultCard(result: result, tab: tab, index: index);
          },
        );
      },
    );
  }

  Widget _buildLoadingState(_TabData tab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(tab.glowColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Yükleniyor...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(_TabData tab, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: 48,
            color: Colors.red.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyExamResultList(_TabData tab) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dbHelper.getWeeklyExamResults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(tab);
        }

        if (snapshot.hasError) {
          return _buildErrorState(tab, snapshot.error.toString());
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return _buildEmptyState(tab);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return _WeeklyExamResultCard(result: result, tab: tab, index: index);
          },
        );
      },
    );
  }
}

/// Tab verisi
class _TabData {
  final String id;
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;

  const _TabData({
    required this.id,
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
  });
}

/// Genel başarı kartı
class _AchievementCard extends StatefulWidget {
  final Map<String, dynamic> result;
  final _TabData tab;
  final int index;

  const _AchievementCard({
    required this.result,
    required this.tab,
    required this.index,
  });

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard> {
  bool _isExpanded = false;

  String _getGameTitle(String tabId) {
    switch (tabId) {
      case 'test':
        return 'Test Sonucu';
      case 'flashcard':
        return 'Bilgi Kartları';
      case 'fill_blanks':
        return 'Cümle Tamamla';
      default:
        return 'Oyun Sonucu';
    }
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
    bool isCompact = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          icon,
          size: isCompact ? 12 : 14,
          color: color ?? Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: isCompact ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isCompact ? 9 : 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.result['score'] as int? ?? 0;
    final correctCount = widget.result['correctCount'] as int? ?? 0;
    final wrongCount = widget.result['wrongCount'] as int? ?? 0;
    final totalQuestions = widget.result['totalQuestions'] as int? ?? 0;
    final dateStr = widget.result['completedAt'] as String? ?? '';

    final percentage = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
    // Her 2 doğru 1 yıldız, maksimum 5 yıldız
    final starCount = (correctCount / 2).floor().clamp(0, 5);

    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.tab.glowColor.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.tab.gradientColors[0].withValues(alpha: 0.8),
                    widget.tab.gradientColors[1].withValues(alpha: 0.6),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Üst kısım: İkon, başlık ve yıldızlar
                    Row(
                      children: [
                        // İkon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FaIcon(
                            widget.tab.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Başlık
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.result['dersAdi'] != null &&
                                        widget.result['konuAdi'] != null
                                    ? '${widget.result['dersAdi']} - ${widget.result['konuAdi']}'
                                    : (widget.result['testAdi'] ?? _getGameTitle(widget.tab.id)),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: _isExpanded ? null : 1,
                                overflow: _isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              Text(
                                '${date.day}.${date.month}.${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Yıldızlar
                        Row(
                          children: List.generate(5, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Icon(
                                i < starCount
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 22,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // İstatistikler - Responsive
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 280;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: _buildStatItem(
                                'Skor',
                                '$score',
                                FontAwesomeIcons.star,
                                isCompact: isNarrow,
                              ),
                            ),
                            Flexible(
                              child: _buildStatItem(
                                'Doğru',
                                '$correctCount',
                                FontAwesomeIcons.check,
                                color: Colors.greenAccent,
                                isCompact: isNarrow,
                              ),
                            ),
                            Flexible(
                              child: _buildStatItem(
                                'Yanlış',
                                '$wrongCount',
                                FontAwesomeIcons.xmark,
                                color: Colors.redAccent,
                                isCompact: isNarrow,
                              ),
                            ),
                            Flexible(
                              child: _buildStatItem(
                                'Başarı',
                                '${(percentage * 100).round()}%',
                                FontAwesomeIcons.percent,
                                isCompact: isNarrow,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: widget.index < 5 ? 100 * widget.index : 0))
        .slideX(begin: 0.2, end: 0);
  }
}

/// Salla Bakalım sonuç kartı
class _GuessResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final _TabData tab;
  final int index;

  const _GuessResultCard({
    required this.result,
    required this.tab,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final score = result['score'] as int? ?? 0;
    final correctCount = result['correctCount'] as int? ?? 0;
    final totalQuestions = result['totalQuestions'] as int? ?? 0;
    final dateStr = result['completedAt'] as String? ?? '';
    final details = result['details'] as String?;

    String levelTitle = 'Bilinmeyen Seviye';
    int difficulty = 1;
    if (details != null && details.isNotEmpty) {
      try {
        final titleMatch = RegExp(
          r'"levelTitle":\s*"([^"]+)"',
        ).firstMatch(details);
        final diffMatch = RegExp(r'"difficulty":\s*(\d+)').firstMatch(details);
        if (titleMatch != null) levelTitle = titleMatch.group(1)!;
        if (diffMatch != null) difficulty = int.parse(diffMatch.group(1)!);
      } catch (_) {}
    }

    final percentage = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
    final starCount = percentage >= 1.0
        ? 3
        : (percentage >= 0.7 ? 2 : (percentage >= 0.4 ? 1 : 0));

    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    final difficultyText = difficulty == 1
        ? 'Kolay'
        : (difficulty == 2 ? 'Orta' : 'Zor');
    final difficultyColor = difficulty == 1
        ? Colors.green
        : (difficulty == 2 ? Colors.orange : Colors.red);

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tab.gradientColors[0].withValues(alpha: 0.8),
                      tab.gradientColors[1].withValues(alpha: 0.6),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tab.glowColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Üst kısım
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.mobileScreenButton,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  levelTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: difficultyColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        difficultyText,
                                        style: TextStyle(
                                          color: difficultyColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${date.day}.${date.month}.${date.year}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: List.generate(3, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Icon(
                                  i < starCount
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // İstatistikler - Responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 280;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: _buildStatItem(
                                  'Skor',
                                  '$score',
                                  FontAwesomeIcons.star,
                                  isCompact: isNarrow,
                                ),
                              ),
                              Flexible(
                                child: _buildStatItem(
                                  'Doğru',
                                  '$correctCount/$totalQuestions',
                                  FontAwesomeIcons.bullseye,
                                  color: Colors.greenAccent,
                                  isCompact: isNarrow,
                                ),
                              ),
                              Flexible(
                                child: _buildStatItem(
                                  'Başarı',
                                  '${(percentage * 100).round()}%',
                                  FontAwesomeIcons.chartLine,
                                  isCompact: isNarrow,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index < 5 ? 100 * index : 0))
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
    bool isCompact = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          icon,
          size: isCompact ? 12 : 14,
          color: color ?? Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: isCompact ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isCompact ? 9 : 11,
          ),
        ),
      ],
    );
  }
}

/// Bul Bakalım (Memory) sonuç kartı
class _MemoryResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final _TabData tab;
  final int index;

  const _MemoryResultCard({
    required this.result,
    required this.tab,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final score = result['score'] as int? ?? 0;
    final wrongCount = result['wrongCount'] as int? ?? 0;
    final dateStr = result['completedAt'] as String? ?? '';
    final details = result['details'] as String?;

    int moves = 0;
    int seconds = 0;
    if (details != null && details.isNotEmpty) {
      try {
        final movesMatch = RegExp(r'"moves":\s*(\d+)').firstMatch(details);
        final secondsMatch = RegExp(r'"seconds":\s*(\d+)').firstMatch(details);
        if (movesMatch != null) moves = int.parse(movesMatch.group(1)!);
        if (secondsMatch != null) seconds = int.parse(secondsMatch.group(1)!);
      } catch (_) {}
    }

    int starCount;
    if (wrongCount == 0) {
      starCount = 3;
    } else if (wrongCount <= 2) {
      starCount = 2;
    } else if (wrongCount <= 5) {
      starCount = 1;
    } else {
      starCount = 0;
    }

    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tab.gradientColors[0].withValues(alpha: 0.8),
                      tab.gradientColors[1].withValues(alpha: 0.6),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tab.glowColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Üst kısım
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.brain,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bul Bakalım',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${date.day}.${date.month}.${date.year}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: List.generate(3, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Icon(
                                  i < starCount
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // İstatistikler - Responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 280;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: _buildStatItem(
                                  'Skor',
                                  '$score',
                                  FontAwesomeIcons.star,
                                  isCompact: isNarrow,
                                ),
                              ),
                              Flexible(
                                child: _buildStatItem(
                                  'Süre',
                                  timeStr,
                                  FontAwesomeIcons.stopwatch,
                                  isCompact: isNarrow,
                                ),
                              ),
                              Flexible(
                                child: _buildStatItem(
                                  'Hamle',
                                  '$moves',
                                  FontAwesomeIcons.hand,
                                  isCompact: isNarrow,
                                ),
                              ),
                              Flexible(
                                child: _buildStatItem(
                                  'Hata',
                                  '$wrongCount',
                                  FontAwesomeIcons.xmark,
                                  color: wrongCount == 0
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  isCompact: isNarrow,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index < 5 ? 100 * index : 0))
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
    bool isCompact = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          icon,
          size: isCompact ? 12 : 14,
          color: color ?? Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: isCompact ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isCompact ? 9 : 11,
          ),
        ),
      ],
    );
  }
}

/// Haftalık Sınav Sonuç Kartı
class _WeeklyExamResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final _TabData tab;
  final int index;

  const _WeeklyExamResultCard({
    required this.result,
    required this.tab,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final dogru = result['dogru'] as int? ?? 0;
    final yanlis = result['yanlis'] as int? ?? 0;
    final bos = result['bos'] as int? ?? 0;
    final puan = result['puan'] as int? ?? 0;
    final siralama = result['siralama'] as int? ?? 0;
    final toplamKatilimci = result['toplamKatilimci'] as int? ?? 0;
    final odaIsmi = result['odaIsmi'] as String? ?? 'Deneme Sınavı';
    final dateStr = result['completedAt'] as String? ?? '';

    final totalQuestions = dogru + yanlis + bos;
    final percentage = totalQuestions > 0 ? dogru / totalQuestions : 0.0;
    final starCount = percentage >= 0.9
        ? 3
        : (percentage >= 0.7 ? 2 : (percentage >= 0.5 ? 1 : 0));

    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tab.gradientColors[0].withValues(alpha: 0.8),
                  tab.gradientColors[1].withValues(alpha: 0.6),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: tab.glowColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Üst kısım
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FaIcon(
                          tab.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              odaIsmi,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${date.day}.${date.month}.${date.year}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Yıldızlar
                      Row(
                        children: List.generate(3, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Icon(
                              i < starCount ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 22,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sıralama Bilgisi
                  if (siralama > 0 && toplamKatilimci > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.trophy,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$siralama. / $toplamKatilimci kişi',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // İstatistikler
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 280;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: _buildStatItem(
                              'Puan',
                              '$puan',
                              FontAwesomeIcons.star,
                              isCompact: isNarrow,
                            ),
                          ),
                          Flexible(
                            child: _buildStatItem(
                              'Doğru',
                              '$dogru',
                              FontAwesomeIcons.check,
                              color: Colors.greenAccent,
                              isCompact: isNarrow,
                            ),
                          ),
                          Flexible(
                            child: _buildStatItem(
                              'Yanlış',
                              '$yanlis',
                              FontAwesomeIcons.xmark,
                              color: yanlis == 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              isCompact: isNarrow,
                            ),
                          ),
                          Flexible(
                            child: _buildStatItem(
                              'Boş',
                              '$bos',
                              FontAwesomeIcons.minus,
                              color: bos == 0
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                              isCompact: isNarrow,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index < 5 ? 100 * index : 0))
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
    bool isCompact = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          icon,
          size: isCompact ? 12 : 14,
          color: color ?? Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: isCompact ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isCompact ? 9 : 11,
          ),
        ),
      ],
    );
  }
}

/// Deneme Trend Grafiği Modal'ı
class _DenemeTrendModal extends StatelessWidget {
  final DatabaseHelper dbHelper;
  
  const _DenemeTrendModal({required this.dbHelper});
  
  static const Color _primaryGreen = Color(0xFF11998e);
  static const Color _secondaryGreen = Color(0xFF38ef7d);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_primaryGreen, _secondaryGreen]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FaIcon(FontAwesomeIcons.chartColumn, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Deneme Geçmişin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Chart
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.getWeeklyExamResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }
                
                final results = snapshot.data!.reversed.toList(); // Eski -> Yeni
                return _buildTrendChart(results);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.chartLine,
            size: 60,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz deneme çözmedin',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haftalık denemelere katılarak\ngelişimini takip et!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrendChart(List<Map<String, dynamic>> results) {
    // Maximum 10 sonuç göster
    final displayResults = results.length > 10 
        ? results.sublist(results.length - 10) 
        : results;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          // Chart
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayResults.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 500,
                  lineBarsData: [
                    LineChartBarData(
                      spots: displayResults.asMap().entries.map((entry) {
                        final puan = (entry.value['puan'] as int?) ?? 0;
                        return FlSpot(entry.key.toDouble(), puan.toDouble());
                      }).toList(),
                      isCurved: true,
                      gradient: const LinearGradient(colors: [_primaryGreen, _secondaryGreen]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: _secondaryGreen,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _primaryGreen.withValues(alpha: 0.3),
                            _primaryGreen.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final result = displayResults[spot.spotIndex];
                          final odaIsmi = result['odaIsmi'] as String? ?? '';
                          return LineTooltipItem(
                            '$odaIsmi\n${spot.y.toInt()} puan',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Summary
          _buildTrendSummary(displayResults),
        ],
      ),
    );
  }
  
  Widget _buildTrendSummary(List<Map<String, dynamic>> results) {
    if (results.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Daha fazla deneme çözerek trendini görebilirsin!',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    final firstScore = (results.first['puan'] as int?) ?? 0;
    final lastScore = (results.last['puan'] as int?) ?? 0;
    final diff = lastScore - firstScore;
    final isImproving = diff > 0;
    final average = results.map((r) => (r['puan'] as int?) ?? 0).reduce((a, b) => a + b) / results.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isImproving 
              ? [_primaryGreen.withValues(alpha: 0.2), _secondaryGreen.withValues(alpha: 0.1)]
              : [Colors.red.withValues(alpha: 0.2), Colors.orange.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isImproving ? _primaryGreen.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          FaIcon(
            isImproving ? FontAwesomeIcons.arrowTrendUp : FontAwesomeIcons.arrowTrendDown,
            color: isImproving ? _secondaryGreen : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isImproving ? 'Harika gidiyorsun! 🎉' : 'Biraz daha çalış! 💪',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Son ${results.length} deneme ortalaması: ${average.toStringAsFixed(0)} puan',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                if (diff.abs() > 0)
                  Text(
                    '${isImproving ? '+' : ''}$diff puan değişim',
                    style: TextStyle(
                      color: isImproving ? _secondaryGreen : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


