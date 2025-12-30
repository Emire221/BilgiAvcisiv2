import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import '../services/database_helper.dart';
import 'lesson_selection_screen.dart';
import 'main_screen.dart';

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
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Tab verileri
  final List<_TabData> _tabs = [
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
                }
                return _buildResultList(tab);
              }).toList(),
            ),
          ),
        ],
      ),
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
class _AchievementCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final _TabData tab;
  final int index;

  const _AchievementCard({
    required this.result,
    required this.tab,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final score = result['score'] as int? ?? 0;
    final correctCount = result['correctCount'] as int? ?? 0;
    final wrongCount = result['wrongCount'] as int? ?? 0;
    final totalQuestions = result['totalQuestions'] as int? ?? 0;
    final dateStr = result['completedAt'] as String? ?? '';

    final percentage = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
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
                              tab.icon,
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
                                  _getGameTitle(tab.id),
                                  style: const TextStyle(
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

                          // Yıldızlar
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
