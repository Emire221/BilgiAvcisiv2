import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/guess_level.dart';
import 'guess_game_screen.dart';
import '../../../../../services/database_helper.dart';
import '../../../../../providers/repository_providers.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📳 SHAKE WAVE SELECTION - Salla Bakalım Seviye Seçim Ekranı
/// ═══════════════════════════════════════════════════════════════════════════
/// Design: Vibrant Wave temalı seviye seçim deneyimi
/// - Gradient wave arka plan (Light/Dark Mode destekli)
/// - Glassmorphism seviye kartları
/// - Animated difficulty indicators
/// - Haptic feedback
/// ═══════════════════════════════════════════════════════════════════════════

class GuessLevelSelectionScreen extends ConsumerStatefulWidget {
  const GuessLevelSelectionScreen({super.key});

  @override
  ConsumerState<GuessLevelSelectionScreen> createState() =>
      _GuessLevelSelectionScreenState();
}

class _GuessLevelSelectionScreenState
    extends ConsumerState<GuessLevelSelectionScreen>
    with TickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // DARK MODE THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color _darkNeonCyan = Color(0xFF00F5FF);
  static const Color _darkNeonPurple = Color(0xFFBF40FF);
  static const Color _darkNeonPink = Color(0xFFFF0080);
  static const Color _darkNeonGreen = Color(0xFF39FF14);
  static const Color _darkNeonOrange = Color(0xFFFF6B35);
  static const Color _darkBg = Color(0xFF0D0D1A);
  static const Color _darkBg2 = Color(0xFF1A1A2E);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color _lightAccentCyan = Color(0xFF0EA5E9);
  static const Color _lightAccentPurple = Color(0xFF8B5CF6);
  static const Color _lightAccentPink = Color(0xFFEC4899);
  static const Color _lightAccentGreen = Color(0xFF10B981);
  static const Color _lightAccentOrange = Color(0xFFF97316);
  static const Color _lightBgStart = Color(0xFFF8FAFC);
  static const Color _lightBgEnd = Color(0xFFE2E8F0);
  static const Color _lightTextPrimary = Color(0xFF1E293B);
  static const Color _lightTextSecondary = Color(0xFF64748B);

  bool _isDarkMode = true;

  // Dinamik renkler için getter'lar
  Color get _neonCyan => _isDarkMode ? _darkNeonCyan : _lightAccentCyan;
  Color get _neonPurple => _isDarkMode ? _darkNeonPurple : _lightAccentPurple;
  Color get _neonPink => _isDarkMode ? _darkNeonPink : _lightAccentPink;
  Color get _neonGreen => _isDarkMode ? _darkNeonGreen : _lightAccentGreen;
  Color get _neonOrange => _isDarkMode ? _darkNeonOrange : _lightAccentOrange;
  Color get _textPrimary => _isDarkMode ? Colors.white : _lightTextPrimary;
  Color get _textSecondary => _isDarkMode 
      ? Colors.white.withValues(alpha: 0.7) 
      : _lightTextSecondary;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<GuessLevel>? _levels;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _loadLevels();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadLevels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Veritabanından seviyeleri yükle
      final levelsData = await _dbHelper.getGuessLevels();

      if (levelsData.isEmpty) {
        throw Exception('Henüz seviye verisi yüklenmemiş');
      }

      // Map<String, dynamic> listesini GuessLevel listesine dönüştür
      final levels = levelsData.map((data) {
        // questions alanı JSON string olarak kaydedilmiş, parse et
        final levelMap = Map<String, dynamic>.from(data);
        if (levelMap['questions'] is String) {
          levelMap['questions'] = json.decode(levelMap['questions']);
        }
        return GuessLevel.fromJson(levelMap);
      }).toList();

      setState(() {
        _levels = levels;
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _isDarkMode ? _darkBg : _lightBgStart,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // ANIMATED BACKGROUND
          // ═══════════════════════════════════════════════════════════════════
          _buildAnimatedBackground(size),

          // ═══════════════════════════════════════════════════════════════════
          // FLOATING PARTICLES
          // ═══════════════════════════════════════════════════════════════════
          ..._buildFloatingParticles(size),

          // ═══════════════════════════════════════════════════════════════════
          // MAIN CONTENT
          // ═══════════════════════════════════════════════════════════════════
          SafeArea(
            child: Column(
              children: [
                _buildHeader(
                  context,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        if (_isDarkMode) {
          // Dark mode: Neon glow gradient
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  _darkNeonOrange.withValues(alpha: 0.15 * _glowAnimation.value),
                  _darkNeonPurple.withValues(alpha: 0.1 * _glowAnimation.value),
                  _darkBg2,
                  _darkBg,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          );
        } else {
          // Light mode: Soft pastel gradient
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _lightBgStart,
                  _lightAccentOrange.withValues(alpha: 0.08 * _glowAnimation.value),
                  _lightBgEnd,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          );
        }
      },
    );
  }

  List<Widget> _buildFloatingParticles(Size size) {
    final particleOpacity = _isDarkMode ? 0.5 : 0.25;
    final glowOpacity = _isDarkMode ? 0.3 : 0.15;

    return List.generate(10, (index) {
      final random = index * 654321;
      final startX = (random % size.width.toInt()).toDouble();
      final startY = (random % size.height.toInt()).toDouble();
      final particleSize = 2.0 + (index % 4);
      final duration = 18 + (index % 12);
      final colors = [_neonCyan, _neonPurple, _neonPink, _neonOrange];
      final color = colors[index % colors.length];

      return Positioned(
        left: startX,
        top: startY,
        child:
            Container(
                  width: particleSize,
                  height: particleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: particleOpacity),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: glowOpacity),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                  begin: 0,
                  end: -70,
                  duration: Duration(seconds: duration),
                )
                .fadeOut(duration: Duration(seconds: duration)),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final headerBgColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.8);
    final headerBorderColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.2)
        : _lightAccentOrange.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: headerBorderColor),
                boxShadow: _isDarkMode ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: _textPrimary,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _waveController.value * 0.3 - 0.15,
                          child: child,
                        );
                      },
                      child: const Text('📳', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Salla Bakalım',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                        shadows: _isDarkMode ? [
                          Shadow(
                            color: _darkNeonOrange.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ] : [],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _neonOrange.withValues(alpha: _isDarkMode ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _neonOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'SEVİYE SEÇ',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _neonOrange,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Refresh button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _loadLevels();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _neonCyan.withValues(alpha: _isDarkMode ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _neonCyan.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.refresh_rounded, color: _neonCyan, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: _neonOrange,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Seviyeler yükleniyor...',
              style: GoogleFonts.nunito(
                color: _textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_levels == null || _levels!.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _levels!.length,
      itemBuilder: (context, index) {
        return _GuessLevelCard(
              level: _levels![index],
              index: index,
              glowAnimation: _glowAnimation,
              getLevelColors: _getLevelColors,
              isDarkMode: _isDarkMode,
              textPrimary: _textPrimary,
              textSecondary: _textSecondary,
            )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: Duration(milliseconds: 100 * index),
            )
            .slideX(begin: 0.1);
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _neonPink.withValues(alpha: _isDarkMode ? 0.15 : 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _neonPink.withValues(alpha: 0.3)),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: _neonPink,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              'Tekrar Dene',
              Icons.refresh_rounded,
              _neonCyan,
              _loadLevels,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _neonPurple.withValues(alpha: _isDarkMode ? 0.15 : 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _neonPurple.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.vibration_rounded, size: 48, color: _neonPurple),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz seviye bulunmuyor',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Veri senkronizasyonunu yapın',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            'Yenile',
            Icons.refresh_rounded,
            _neonCyan,
            _loadLevels,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: _isDarkMode ? 0.4 : 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getLevelColors(int difficulty) {
    switch (difficulty) {
      case 1:
        return [_neonGreen, _neonGreen.withValues(alpha: 0.7)];
      case 2:
        return [_neonOrange, _neonOrange.withValues(alpha: 0.7)];
      case 3:
        return [_neonPink, _neonPink.withValues(alpha: 0.7)];
      default:
        return [_neonCyan, _neonPurple];
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Level Kartı Widget'ı - YENİ/OYNANDI badge içerir (Light/Dark Mode destekli)
/// ═══════════════════════════════════════════════════════════════════════════
class _GuessLevelCard extends ConsumerWidget {
  final GuessLevel level;
  final int index;
  final Animation<double> glowAnimation;
  final List<Color> Function(int) getLevelColors;
  final bool isDarkMode;
  final Color textPrimary;
  final Color textSecondary;

  const _GuessLevelCard({
    required this.level,
    required this.index,
    required this.glowAnimation,
    required this.getLevelColors,
    required this.isDarkMode,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = getLevelColors(level.difficulty);

    // Level tamamlanmış mı kontrol et
    final isCompletedAsync = ref.watch(
      isLevelCompletedProvider((gameType: 'guess', levelTitle: level.title)),
    );
    final isCompleted = isCompletedAsync.maybeWhen(
      data: (completed) => completed,
      orElse: () => false,
    );

    // Kart arka plan renkleri
    final cardGradientColors = isDarkMode
        ? [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ]
        : [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ];

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                GuessGameScreen(level: level),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ).then((_) {
          // Oyun oynanınca provider'ı invalidate et
          ref.invalidate(
            isLevelCompletedProvider((
              gameType: 'guess',
              levelTitle: level.title,
            )),
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedBuilder(
              animation: glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: cardGradientColors,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.5)
                          : colors[0].withValues(
                              alpha: isDarkMode 
                                  ? 0.3 + (0.2 * glowAnimation.value)
                                  : 0.25,
                            ),
                      width: 1.5,
                    ),
                    boxShadow: isDarkMode
                        ? [
                            BoxShadow(
                              color: colors[0].withValues(
                                alpha: 0.15 * glowAnimation.value,
                              ),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: colors[0].withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      // Level number badge
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: isCompleted
                              ? LinearGradient(
                                  colors: [
                                    Colors.green,
                                    Colors.green.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isCompleted
                                  ? Colors.green.withValues(alpha: isDarkMode ? 0.4 : 0.3)
                                  : colors[0].withValues(alpha: isDarkMode ? 0.4 : 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Level info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    level.title,
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                // 🔴 YENİ veya OYNANDI badge
                                if (!isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B6B),
                                          Color(0xFFFF5252),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'YENİ',
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'OYNANDI',
                                          style: GoogleFonts.nunito(
                                            color: Colors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              level.description,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildDifficultyStars(level.difficulty),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors[0].withValues(alpha: isDarkMode ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colors[0].withValues(alpha: isDarkMode ? 0.4 : 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    level.difficultyText,
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : colors[0],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${level.questions.length} Soru',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Play icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors[0].withValues(alpha: isDarkMode ? 0.3 : 0.2),
                              colors[1].withValues(alpha: isDarkMode ? 0.2 : 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors[0].withValues(alpha: isDarkMode ? 0.5 : 0.3),
                          ),
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.replay_rounded
                              : Icons.play_arrow_rounded,
                          color: isDarkMode ? Colors.white : colors[0],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyStars(int difficulty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isEarned = index < difficulty;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16,
            color: isEarned
                ? const Color(0xFFFFD700)
                : (isDarkMode 
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.4)),
          ),
        );
      }),
    );
  }
}
