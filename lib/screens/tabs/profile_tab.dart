import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/glass_container.dart';
import '../../core/providers/user_provider.dart';
import '../../features/mascot/presentation/providers/mascot_provider.dart';
import '../../features/mascot/domain/entities/mascot.dart';
import '../../core/gamification/mascot_logic.dart';
import '../../services/database_helper.dart';
import '../../services/time_tracking_service.dart';
import '../login_screen.dart';
import '../time_analytics_screen.dart';

/// 🏆 Kahraman Profili - RPG Style Profile Tab
class ProfileTab extends ConsumerStatefulWidget {
  final bool isActive;
  const ProfileTab({super.key, this.isActive = false});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  // ... existing variables ...

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Eğer tab aktif duruma geldiyse (başka tabdan buraya geçildiyse)
    if (widget.isActive && !oldWidget.isActive) {
      debugPrint('ProfileTab: Tab became active -> Resetting animation');
      _hasAnimatedXp = false;
      // Mevcut datayı kullanarak animasyonu tekrar tetikle
      if (_userData != null) {
        // Force re-build or re-trigger logic will happen in build
        setState(() {});
      }
    }
  }

  bool _isLoading = true;
  late AnimationController _floatController;

  // XP Bar Animasyonları
  late AnimationController _fillController;
  late AnimationController _returnController;
  late Animation<double> _fillAnimation;
  late Animation<double> _returnAnimation;
  double _targetXpProgress = 0.0;
  bool _hasAnimatedXp = false;

  // Gerçek kullanıcı istatistikleri
  int _totalCorrect = 0;
  int _totalWrong = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserStats();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // XP Bar Animasyonlarını Hazırla
    _initXpAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Her tab geçişinde animasyonu sıfırla
    _hasAnimatedXp = false;
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fillController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  void _initXpAnimations() {
    // Fill animasyonu (0 -> 100%) - Hızlandırıldı
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Return animasyonu (100% -> gerçek değer) - Hızlandırıldı
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );

    _returnAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _returnController, curve: Curves.easeInOutCubic),
    );

    // Fill bittikten sonra return başlasın
    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _returnController.forward(from: 0.0);
      }
    });

    // Her sayfa açıldığında animasyonun çalışması için
    // didChangeDependencies içinde logic ekleyeceğiz
  }

  void _startXpAnimation(double progress) {
    // Eğer animasyon zaten yapıldıysa ve hedef değişmediyse işlem yapma.
    // Ancak _hasAnimatedXp false ise (örn: tab değişimi sonrası) animasyonu tekrar başlat.
    if (_hasAnimatedXp && _targetXpProgress == progress) return;

    _targetXpProgress = progress;

    // Eğer zaten animasyon oynuyorsa, sadece hedefi güncellemiş olduk.
    // Animasyon (return kısmı) yeni hedefe göre devam edecek.
    // Eğer animasyon oynamıyorsa (veya bitmişse), baştan başlat.
    if (!_fillController.isAnimating && !_returnController.isAnimating) {
      _fillController.reset();
      _returnController.reset();
      _fillController.forward(from: 0.0);
    }
    _hasAnimatedXp = true;
  }

  double _getCurrentXpProgress() {
    if (_fillController.isAnimating) {
      // Fill aşaması: 0 -> 100%
      return _fillAnimation.value;
    } else if (_returnController.isAnimating) {
      // Return aşaması: 100% -> gerçek değer
      final returnValue = _returnAnimation.value;
      return _targetXpProgress + (1.0 - _targetXpProgress) * returnValue;
    } else if (_hasAnimatedXp) {
      return _targetXpProgress;
    }
    // Safety net: Eğer animasyon başlamadıysa bile 0 yerine hedeflenen değeri göster.
    return _targetXpProgress;
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final data = await ref
          .read(userRepositoryProvider)
          .getUserProfile(userId);
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Veritabanından gerçek kullanıcı istatistiklerini yükle
  Future<void> _loadUserStats() async {
    try {
      final dbHelper = DatabaseHelper();

      // Test sonuçlarını al
      final db = await dbHelper.database;
      final testResults = await db.query('TestResults');

      int totalCorrect = 0;
      int totalWrong = 0;

      // Sadece test sonuçlarını hesapla (doğruluk oranı için)
      for (final result in testResults) {
        totalCorrect += (result['correct'] as int?) ?? 0;
        totalWrong += (result['wrong'] as int?) ?? 0;
      }

      // Streak hesapla (basit: ardışık günler)
      final userId = FirebaseAuth.instance.currentUser?.uid;
      int streak = 0;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        streak = userDoc.data()?['loginStreak'] ?? 0;
      }

      if (mounted) {
        setState(() {
          _totalCorrect = totalCorrect;
          _totalWrong = totalWrong;
          _streak = streak;
        });
      }
    } catch (e) {
      debugPrint('İstatistik yükleme hatası: $e');
    }
  }

  /// Doğruluk oranı hesapla
  int get _accuracyPercent {
    final total = _totalCorrect + _totalWrong;
    if (total == 0) return 0;
    return ((_totalCorrect / total) * 100).round();
  }

  String _formatGrade(String grade) {
    if (grade.contains('. Sınıf')) return grade;
    final match = RegExp(r'(\d+)_?[Ss]inif').firstMatch(grade);
    if (match != null) return '${match.group(1)}. Sınıf';
    return grade;
  }

  String _getLevelTitle(int level) {
    switch (level) {
      case 1:
        return 'Çırak';
      case 2:
        return 'Öğrenci';
      case 3:
        return 'Bilgin';
      case 4:
        return 'Araştırmacı';
      case 5:
        return 'Uzman';
      case 6:
        return 'Üstat';
      case 7:
        return 'Büyücü';
      case 8:
        return 'Usta';
      case 9:
        return 'Dahi';
      case 10:
        return 'Efsane';
      default:
        return 'Kahraman';
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    HapticFeedback.mediumImpact();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildGlassDialog(
        title: 'Çıkış Yap',
        message: 'Hesabından çıkış yapmak istediğine emin misin?',
        confirmText: 'Çıkış Yap',
        confirmColor: Colors.orange,
        icon: FontAwesomeIcons.doorOpen,
      ),
    );

    if (result == true) {
      await _signOut();
    }
  }

  Future<void> _deleteAccount() async {
    HapticFeedback.heavyImpact();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Hesabı Sil', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bu işlem geri alınamaz! Tüm verileriniz silinecek.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Şifrenizi Girin',
                  labelStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performAccountDeletion(passwordController.text);
    }
  }

  Future<void> _performAccountDeletion(String password) async {
    try {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        await user.delete();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hesabınız başarıyla silindi.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        String errorMessage = e.code == 'wrong-password'
            ? 'Şifre yanlış!'
            : 'Bir hata oluştu.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildGlassDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İkon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: confirmColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(icon, color: confirmColor, size: 32),
                ),
                const SizedBox(height: 20),
                // Başlık
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Mesaj
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          'İptal',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final mascotAsync = ref.watch(activeMascotProvider);

    return Stack(
      children: [
        // Arka plan
        _buildBackground(isDarkMode),

        // İçerik
        SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : isTablet
              ? _buildTabletLayout(isDarkMode, mascotAsync)
              : _buildMobileLayout(isDarkMode, mascotAsync),
        ),
      ],
    );
  }

  Widget _buildBackground(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      Color.lerp(
                        const Color(0xFF0D0D1A),
                        const Color(0xFF1A0D2E),
                        _floatController.value,
                      )!,
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
            painter: _ProfileBackgroundPainter(
              isDarkMode: isDarkMode,
              animation: _floatController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(bool isDarkMode, AsyncValue<Mascot?> mascotAsync) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Section - Maskot + Profil Kartı
            _buildHeroSection(isDarkMode, mascotAsync),

            const SizedBox(height: 24),

            // Stats Grid
            _buildStatsGrid(isDarkMode, mascotAsync),

            const SizedBox(height: 24),

            // Menu Options
            _buildMenuOptions(isDarkMode),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(bool isDarkMode, AsyncValue<Mascot?> mascotAsync) {
    return Row(
      children: [
        // Sol - Hero Section
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildHeroSection(isDarkMode, mascotAsync),
          ),
        ),
        // Sağ - Stats ve Menu
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildStatsGrid(isDarkMode, mascotAsync),
                const SizedBox(height: 24),
                _buildMenuOptions(isDarkMode),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Hero Section - Maskot + Profil Kartı
  Widget _buildHeroSection(bool isDarkMode, AsyncValue<Mascot?> mascotAsync) {
    return Column(
      children: [
        // Maskot Animasyonu
        mascotAsync
            .when(
              data: (mascot) {
                if (mascot == null) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.userNinja,
                        size: 80,
                        color: Colors.white30,
                      ),
                    ),
                  );
                }
                return _buildMascotDisplay(mascot, isDarkMode);
              },
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(height: 200),
            )
            .animate()
            .fadeIn(duration: 800.ms)
            .slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack),

        const SizedBox(height: 16),

        // Profil Kartı
        _buildProfileCard(isDarkMode, mascotAsync)
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildMascotDisplay(Mascot mascot, bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow efekti
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: mascot.petType.color.withValues(alpha: 0.4),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
        // ✅ Lottie Maskot - Optimize edildi
        SizedBox(
          height: 220,
          child: Lottie.asset(
            mascot.petType.getLottiePath(),
            fit: BoxFit.contain,
            animate: true,
            frameRate: FrameRate.max,
            options: LottieOptions(enableMergePaths: true),
          ),
        ),
        // Seviye Badge
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mascot.petType.color,
                  mascot.petType.color.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: mascot.petType.color.withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(
                  FontAwesomeIcons.star,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Seviye ${mascot.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(bool isDarkMode, AsyncValue<Mascot?> mascotAsync) {
    final userName = _userData?['name'] ?? 'Kahraman';
    final grade = _userData?['grade'] ?? _userData?['classLevel'] ?? '';
    final schoolName = _userData?['schoolName'] ?? '';

    return GlassContainer(
      blur: 15,
      opacity: isDarkMode ? 0.15 : 0.25,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Kullanıcı Adı
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
            ),
          ),

          const SizedBox(height: 8),

          // Unvan
          mascotAsync.when(
            data: (mascot) {
              final level = mascot?.level ?? 1;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.3),
                      const Color(0xFFFFA500).withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.crown,
                      color: Color(0xFFFFD700),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Seviye $level ${_getLevelTitle(level)}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 12),

          // Okul ve Sınıf
          if (grade.isNotEmpty || schoolName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                [
                  if (schoolName.isNotEmpty) schoolName,
                  if (grade.isNotEmpty) _formatGrade(grade),
                ].join(' • '),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 20),

          // XP Bar
          mascotAsync.when(
            data: (mascot) {
              if (mascot == null) return const SizedBox.shrink();
              // Level bilgisini XP'den hesapla (veri tutarlılığı için)
              final calculatedLevel = MascotLogic.calculateLevel(
                mascot.currentXp,
              );

              final progress = MascotLogic.getLevelProgress(
                mascot.currentXp,
                calculatedLevel,
              );

              // Animasyonu başlat

              // Animasyonu başlat
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted &&
                    !_fillController.isAnimating &&
                    !_returnController.isAnimating) {
                  _startXpAnimation(progress);
                }
              });

              final xpToNext = MascotLogic.xpToNextLevel(
                mascot.currentXp,
                mascot.level,
              );

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${mascot.currentXp} XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'Sonraki: $xpToNext XP',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // XP Progress Bar - LayoutBuilder ile responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _fillController,
                                _returnController,
                              ]),
                              builder: (context, child) {
                                final animatedProgress =
                                    _getCurrentXpProgress();
                                return Container(
                                  width:
                                      (constraints.maxWidth * animatedProgress)
                                          .clamp(0.0, constraints.maxWidth),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        mascot.petType.color,
                                        mascot.petType.color.withValues(
                                          alpha: 0.7,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Stats Grid - Bento Box Style
  Widget _buildStatsGrid(bool isDarkMode, AsyncValue<Mascot?> mascotAsync) {
    final mascot = mascotAsync.asData?.value;

    final stats = [
      _StatItem(
        icon: FontAwesomeIcons.fire,
        label: 'Seri',
        value: '$_streak Gün',
        color: const Color(0xFFFF6B35),
        delay: 0,
      ),
      _StatItem(
        icon: FontAwesomeIcons.bullseye,
        label: 'Doğruluk',
        value: '%$_accuracyPercent',
        color: const Color(0xFF00E676),
        delay: 100,
      ),
      _StatItem(
        icon: FontAwesomeIcons.trophy,
        label: 'Toplam XP',
        value: '${mascot?.currentXp ?? 0}',
        color: const Color(0xFFFFD700),
        delay: 200,
      ),
      // Bugün kartı - özel işaretli
      _StatItem(
        icon: FontAwesomeIcons.clock,
        label: 'Bugün',
        value:
            '__LIVE_TIME__', // Özel işaret - StreamBuilder ile değiştirilecek
        color: const Color(0xFF6C5CE7),
        delay: 300,
      ),
    ];

    // Responsive grid - ekran genişliğine göre childAspectRatio ayarla
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // padding + spacing
    final cardHeight = cardWidth * 0.8; // Daha kısa kartlar
    final aspectRatio = cardWidth / cardHeight;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio.clamp(1.0, 1.6),
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];

        // Bugün kartı için özel StreamBuilder kullan
        if (stat.value == '__LIVE_TIME__') {
          return StreamBuilder<int>(
            stream: TimeTrackingService().timeStream,
            initialData: TimeTrackingService().todaySeconds,
            builder: (context, snapshot) {
              final seconds = snapshot.data ?? 0;
              final liveValue = TimeTrackingService.formatDurationLong(seconds);
              final liveStat = _StatItem(
                icon: stat.icon,
                label: stat.label,
                value: liveValue,
                color: stat.color,
                delay: stat.delay,
              );
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TimeAnalyticsScreen(),
                    ),
                  );
                },
                child: _buildStatCard(liveStat, isDarkMode)
                    .animate()
                    .fadeIn(
                      duration: 500.ms,
                      delay: Duration(milliseconds: stat.delay),
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      delay: Duration(milliseconds: stat.delay),
                      curve: Curves.easeOutBack,
                    ),
              );
            },
          );
        }

        return _buildStatCard(stat, isDarkMode)
            .animate()
            .fadeIn(
              duration: 500.ms,
              delay: Duration(milliseconds: stat.delay),
            )
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
              delay: Duration(milliseconds: stat.delay),
              curve: Curves.easeOutBack,
            );
      },
    );
  }

  Widget _buildStatCard(_StatItem stat, bool isDarkMode) {
    return GlassContainer(
      blur: 10,
      opacity: isDarkMode ? 0.12 : 0.2,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // İkon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: FaIcon(stat.icon, color: stat.color, size: 18),
          ),
          const SizedBox(height: 8),
          // Değer
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Etiket
          Text(
            stat.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Menu Options
  Widget _buildMenuOptions(bool isDarkMode) {
    final menuItems = [
      _MenuItem(
        icon: FontAwesomeIcons.chartLine,
        label: 'Eğitimin için ayırdığın süre',
        color: const Color(0xFF11998E),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimeAnalyticsScreen()),
          );
        },
      ),
      _MenuItem(
        icon: FontAwesomeIcons.fileContract,
        label: 'Kullanıcı Sözleşmesi',
        color: Colors.blue,
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Kullanıcı sözleşmesi
        },
      ),
      _MenuItem(
        icon: FontAwesomeIcons.shieldHalved,
        label: 'Gizlilik Politikası',
        color: Colors.teal,
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Gizlilik politikası
        },
      ),
      _MenuItem(
        icon: FontAwesomeIcons.doorOpen,
        label: 'Çıkış Yap',
        color: Colors.orange,
        onTap: _showLogoutDialog,
      ),
      _MenuItem(
        icon: FontAwesomeIcons.trash,
        label: 'Hesabı Sil',
        color: Colors.red,
        onTap: _deleteAccount,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Ayarlar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        ...menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildMenuItem(item, isDarkMode)
              .animate()
              .fadeIn(
                duration: 400.ms,
                delay: Duration(milliseconds: 400 + index * 80),
              )
              .slideX(begin: 0.2, end: 0);
        }),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: item.onTap,
        child: GlassContainer(
          blur: 8,
          opacity: isDarkMode ? 0.1 : 0.15,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: item.color == Colors.red
                        ? Colors.red.shade300
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat Item Data
class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });
}

/// Menu Item Data
class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Background Painter
class _ProfileBackgroundPainter extends CustomPainter {
  final bool isDarkMode;
  final double animation;

  _ProfileBackgroundPainter({
    required this.isDarkMode,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isDarkMode) return;

    // Yıldızlar
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    final random = [0.1, 0.3, 0.5, 0.7, 0.9, 0.2, 0.4, 0.6, 0.8];

    for (int i = 0; i < 30; i++) {
      final x = (random[i % 9] * size.width + i * 37) % size.width;
      final y = (random[(i + 3) % 9] * size.height + i * 23) % size.height;
      final radius = 1.0 + (i % 3) * 0.5;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Glow efektleri
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(
                0xFFFF6B9D,
              ).withValues(alpha: 0.08 + animation * 0.04),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.2, size.height * 0.15),
              radius: 200,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.15),
      200,
      glowPaint,
    );

    final glowPaint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(
                0xFF6C5CE7,
              ).withValues(alpha: 0.1 + (1 - animation) * 0.05),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.8, size.height * 0.6),
              radius: 250,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      250,
      glowPaint2,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfileBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
