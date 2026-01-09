import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/mascot.dart';
import '../providers/mascot_provider.dart';
import '../../../../core/navigator_key.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/local_preferences_service.dart';
import '../../../../services/database_helper.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/in_app_notification.dart';
import '../../../../screens/main_screen.dart';

/// 🎮 3D Sahne Stili Maskot Seçim Ekranı
/// Carousel yapısı ile modern, animasyonlu tasarım
class PetSelectionScreen extends ConsumerStatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  ConsumerState<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends ConsumerState<PetSelectionScreen>
    with TickerProviderStateMixin {
  // Seçim durumları
  PetType? _selectedPetType;
  bool _isHatching = false;
  bool _showCelebration = false;

  // Sync durumları
  bool _isSyncing = false;
  bool _syncError = false;
  String _errorMessage = '';

  // Carousel kontrolü
  late PageController _pageController;
  int _currentPage = 0; // En baştan başla
  double _pageOffset = 0.0;

  // Animasyon kontrolleri
  late AnimationController _blobController;
  late AnimationController _selectionController;
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _jumpAnimation;

  // Renkler
  static const Color _primaryPurple = Color(0xFF6C5CE7);
  static const Color _energeticCoral = Color(0xFFFF7675);
  static const Color _turquoise = Color(0xFF00CEC9);
  static const Color _softYellow = Color(0xFFFDCB6E);

  // Maskot listesi
  final List<PetType> _petTypes = PetType.values;

  // 🎮 Eğlenceli motivasyon mesajları
  final List<Map<String, dynamic>> _funMessages = [
    {'emoji': '🚀', 'text': 'Uzay gemisi kalkışa hazırlanıyor!'},
    {'emoji': '🧙‍♂️', 'text': 'Büyücü derslerini sihirliyor...'},
    {'emoji': '🦸', 'text': 'Süper güçler yükleniyor!'},
    {'emoji': '🎢', 'text': 'Bilgi lunapark treni hareket ediyor!'},
    {'emoji': '🏰', 'text': 'Bilgi kalesi inşa ediliyor...'},
    {'emoji': '🌈', 'text': 'Gökkuşağı renkleri karıştırılıyor...'},
    {'emoji': '⚡', 'text': 'Beyin şimşekleri çakıyor!'},
    {'emoji': '🎮', 'text': 'Level yükleniyor...'},
    {'emoji': '🦄', 'text': 'Tek boynuzlu at seni bekliyor!'},
    {'emoji': '🌟', 'text': 'Yıldızlar senin için parlıyor!'},
  ];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _initPageController();
    _initAnimations();
  }

  void _initPageController() {
    _pageController = PageController(
      viewportFraction: 0.65,
      initialPage: _currentPage,
    );
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    setState(() {
      _pageOffset = _pageController.page ?? 1.0;
    });
  }

  void _initAnimations() {
    // Arka plan blob animasyonu
    _blobController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // Seçim animasyonu
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.elasticOut),
    );

    // Kutlama animasyonu (zıplama)
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _jumpAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -30.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -30.0, end: 0.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -15.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -15.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _celebrationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _blobController.dispose();
    _selectionController.dispose();
    _celebrationController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  // ==================== MANTIK FONKSİYONLARI (AYNEN KORUNDU) ====================

  Future<void> _selectPetType(PetType petType) async {
    setState(() {
      _selectedPetType = petType;
      _isHatching = true;
    });

    await _selectionController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _selectionController.reverse();

    if (!mounted) return;

    _showNameDialog();
  }

  void _showNameDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _primaryPurple.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text('✨', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Maskotuna İsim Ver',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seçilen maskot mini önizleme
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              // ✅ Lottie optimize edildi
              child: Lottie.asset(
                _selectedPetType?.getLottiePath() ?? '',
                fit: BoxFit.contain,
                frameRate: FrameRate.max,
                options: LottieOptions(enableMergePaths: true),
              ),
            ),
            TextField(
              controller: nameController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Örn: Zeki, Bilge, Meraklı...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _isHatching = false;
                _selectedPetType = null;
              });
            },
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _softYellow,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lütfen bir isim girin'),
                    backgroundColor: _energeticCoral,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);
              await _startCelebrationAndCreate(name);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Macera Başlasın!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Text('🚀', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startCelebrationAndCreate(String name) async {
    // Kutlama animasyonu başlat
    setState(() => _showCelebration = true);
    HapticFeedback.heavyImpact();

    // Zıplama animasyonu
    await _celebrationController.forward();

    // 1.5 saniye bekle (konfeti için)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mascot oluştur
    await _createMascot(name);
  }

  Future<void> _createMascot(String name) async {
    if (_selectedPetType == null) return;

    final mascot = Mascot(
      petType: _selectedPetType!,
      petName: name,
      currentXp: 0,
      level: 1,
      mood: 100,
    );

    try {
      final repository = ref.read(mascotRepositoryProvider);
      await repository.createMascot(mascot);

      if (!mounted) return;

      // Sync başlat - aynı ekranda kalıp progress göster
      await _startContentSync();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _showCelebration = false;
        _isHatching = false;
        _syncError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// İçerik senkronizasyonu başlat
  Future<void> _startContentSync() async {
    setState(() {
      _isSyncing = true;
      _syncError = false;
    });

    // Mesaj timer'ını başlat
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _funMessages.length;
      });
    });

    final prefsService = LocalPreferencesService();

    // Önceki sync yarım kalmışsa temizle
    final wasComplete = await prefsService.isContentSyncCompleted();
    if (!wasComplete) {
      await DatabaseHelper().clearAllData();
    }

    await prefsService.setContentSyncCompleted(false);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw Exception('Kullanıcı profili bulunamadı');

      final userData = userDoc.data();
      final selectedClass = userData?['classLevel'] as String?;
      final userName = userData?['name'] as String? ?? 'Öğrenci';

      if (selectedClass == null) throw Exception('Sınıf bilgisi bulunamadı');

      // Hoşgeldin bildirimi planla
      await _scheduleWelcomeNotificationIfFirstTime(userName);

      // Sınıf adını güvenli formata çevir
      final safeClassName = selectedClass
          .replaceAll('.', '')
          .replaceAll(' ', '_')
          .replaceAll('ı', 'i')
          .replaceAll('İ', 'I');

      // Sync başlat
      await ref
          .read(syncControllerProvider.notifier)
          .syncContent(safeClassName);

      final syncState = ref.read(syncControllerProvider);
      if (syncState.error != null) throw Exception(syncState.error);

      await prefsService.setContentSyncCompleted(true);

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToMain();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncError = true;
          _errorMessage = e.toString();
          _isSyncing = false;
        });
      }
    }
  }

  /// Hoşgeldin bildirimi gönder
  Future<void> _scheduleWelcomeNotificationIfFirstTime(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasReceivedWelcome =
          prefs.getBool('has_received_welcome_notification') ?? false;

      if (!hasReceivedWelcome) {
        await NotificationService().scheduleWelcomeNotification(
          userName: userName,
          delaySeconds: 10,
        );
        await prefs.setBool('has_received_welcome_notification', true);
      }
    } catch (e) {
      debugPrint('Hoşgeldin bildirimi hatası: $e');
    }
  }

  /// In-app hoşgeldin bildirimi göster
  void _showInAppWelcomeNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShownInAppWelcome =
          prefs.getBool('has_shown_inapp_welcome') ?? false;

      if (!hasShownInAppWelcome) {
        final user = FirebaseAuth.instance.currentUser;
        final userName = user?.displayName ?? 'Şampiyon';

        Future.delayed(const Duration(seconds: 12), () {
          if (!mounted) return;
          final navContext = navigatorKey.currentContext;
          if (navContext != null) {
            // ignore: use_build_context_synchronously
            showWelcomeNotification(navContext, userName);
          }
        });

        await prefs.setBool('has_shown_inapp_welcome', true);
      }
    } catch (e) {
      debugPrint('In-app bildirim hatası: $e');
    }
  }

  /// Ana ekrana git
  void _navigateToMain() {
    _messageTimer?.cancel();
    _showInAppWelcomeNotification();
    NotificationService().initializeScheduledNotifications();

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeIn = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          final scaleUp = Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return FadeTransition(
            opacity: fadeIn,
            child: ScaleTransition(scale: scaleUp, child: child),
          );
        },
      ),
      (route) => false,
    );
  }

  // ==================== UI BUILD METODLARI ====================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    // Senkronizasyon/kutlama sırasında geri tuşunu devre dışı bırak
    return PopScope(
      canPop: false, // Geri tuşu devre dışı - maskot seçimi ve sync sırasında
      child: Scaffold(
        body: Stack(
          children: [
            // Animasyonlu arka plan
            _buildAnimatedBackground(),

            // Ana içerik
            SafeArea(
              child: _showCelebration
                  ? _buildCelebrationOverlay(size)
                  : _buildMainContent(size, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _primaryPurple,
              Color.lerp(_primaryPurple, _turquoise, _blobController.value)!,
              _turquoise,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Hareketli blob 1
            Positioned(
              top: -80 + (math.sin(_blobController.value * math.pi * 2) * 40),
              right: -40 + (math.cos(_blobController.value * math.pi * 2) * 25),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _energeticCoral.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Hareketli blob 2
            Positioned(
              bottom:
                  -60 + (math.cos(_blobController.value * math.pi * 2) * 35),
              left: -50 + (math.sin(_blobController.value * math.pi * 2) * 30),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _softYellow.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Hareketli blob 3
            Positioned(
              top: 200 + (math.sin(_blobController.value * math.pi) * 20),
              left: 100 + (math.cos(_blobController.value * math.pi) * 15),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(Size size, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final headerHeight = isTablet ? 140.0 : 120.0;
        final carouselHeight = isTablet
            ? availableHeight * 0.55
            : availableHeight * 0.50;
        final buttonAreaHeight =
            availableHeight - headerHeight - carouselHeight;

        return Column(
          children: [
            // Header
            SizedBox(height: headerHeight, child: _buildHeader(size, isTablet)),

            // Carousel Area
            SizedBox(
              height: carouselHeight,
              child: _buildMascotCarousel(size, isTablet),
            ),

            // Button Area
            SizedBox(
              height: buttonAreaHeight,
              child: _buildActionButton(size, isTablet),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(Size size, bool isTablet) {
    final titleSize = isTablet ? 36.0 : 28.0;
    final subtitleSize = isTablet ? 18.0 : 15.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40 : 24,
        vertical: isTablet ? 20 : 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Başlık
          FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🐾', style: TextStyle(fontSize: titleSize + 4)),
                    const SizedBox(width: 12),
                    Text(
                      'Yol Arkadaşını Seç',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, curve: Curves.easeOutBack),

          const SizedBox(height: 8),

          // Alt başlık
          Text(
            'Maceranda sana eşlik edecek dostunu seç',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: subtitleSize,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildMascotCarousel(Size size, bool isTablet) {
    return Column(
      children: [
        // Carousel
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentPage = index);
            },
            itemCount: _petTypes.length,
            itemBuilder: (context, index) {
              return _buildMascotCard(index, size, isTablet);
            },
          ),
        ),

        // İsim kartı
        _buildNameCard(isTablet),

        // Sayfa göstergesi
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildMascotCard(int index, Size size, bool isTablet) {
    final petType = _petTypes[index];
    final isActive = index == _currentPage;
    final isSelected = _selectedPetType == petType;

    // Parallax ve scale hesaplama
    final distance = (index - _pageOffset).abs();
    final scale = (1 - (distance * 0.25)).clamp(0.7, 1.0);
    final opacity = (1 - (distance * 0.5)).clamp(0.4, 1.0);

    final cardSize = isTablet ? 280.0 : 220.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        final selectionScale = isSelected && _isHatching
            ? _scaleAnimation.value
            : 1.0;

        return AnimatedBuilder(
          animation: _jumpAnimation,
          builder: (context, _) {
            final jumpOffset = isSelected && _showCelebration
                ? _jumpAnimation.value
                : 0.0;

            return Transform.translate(
              offset: Offset(0, jumpOffset),
              child: Transform.scale(
                scale: scale * selectionScale,
                child: Opacity(
                  opacity: opacity,
                  child: GestureDetector(
                    onTap: _isHatching
                        ? null
                        : () {
                            // Sayfaya git
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                            );
                          },
                    child: Container(
                      width: cardSize,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow efekti
                          if (isActive)
                            Container(
                              width: cardSize * 0.9,
                              height: cardSize * 0.9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: petType.color.withValues(alpha: 0.5),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),

                          // Glass kart
                          GlassContainer(
                            blur: 12,
                            opacity: isActive ? 0.25 : 0.15,
                            borderRadius: BorderRadius.circular(cardSize / 2),
                            child: Container(
                              width: cardSize,
                              height: cardSize,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isActive
                                    ? Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        width: 3,
                                      )
                                    : null,
                              ),
                              // ✅ Lottie optimize edildi
                              child: Lottie.asset(
                                petType.getLottiePath(),
                                fit: BoxFit.contain,
                                animate: isActive,
                                frameRate: FrameRate.max,
                                options: LottieOptions(enableMergePaths: true),
                              ),
                            ),
                          ),

                          // Seçildi işareti
                          if (isSelected)
                            Positioned(
                              top: 10,
                              right: 10,
                              child:
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _softYellow,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _softYellow.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.black87,
                                      size: 20,
                                    ),
                                  ).animate().scale(
                                    duration: 300.ms,
                                    curve: Curves.elasticOut,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNameCard(bool isTablet) {
    final currentPet = _petTypes[_currentPage];
    final cardFontSize = isTablet ? 24.0 : 20.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40, vertical: 8),
      child: GlassContainer(
        blur: 8,
        opacity: 0.2,
        borderRadius: BorderRadius.circular(16),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 24,
          vertical: isTablet ? 16 : 12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: currentPet.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: currentPet.color.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                currentPet.displayName,
                key: ValueKey(currentPet),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: cardFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_petTypes.length, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(5),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButton(Size size, bool isTablet) {
    final buttonWidth = isTablet ? size.width * 0.5 : size.width * 0.85;
    final buttonHeight = isTablet ? 64.0 : 56.0;
    final fontSize = isTablet ? 20.0 : 18.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 40 : 20,
          vertical: 16,
        ),
        child:
            GestureDetector(
                  onTap: _isHatching
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _selectPetType(_petTypes[_currentPage]);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isHatching
                            ? [Colors.grey, Colors.grey.shade600]
                            : [_energeticCoral, _softYellow],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(buttonHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: _isHatching
                              ? Colors.transparent
                              : _energeticCoral.withValues(alpha: 0.5),
                          blurRadius: _isHatching ? 0 : 20,
                          spreadRadius: _isHatching ? 0 : 2,
                          offset: _isHatching
                              ? Offset.zero
                              : const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Parlama efekti
                        if (!_isHatching)
                          Positioned(
                            left: 20,
                            child: Container(
                              width: 40,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                        // Buton içeriği
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isHatching ? 'BEKLEYİN...' : 'SEÇ VE BAŞLA',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            if (!_isHatching) ...[
                              const SizedBox(width: 12),
                              const Text('🎮', style: TextStyle(fontSize: 24)),
                            ],
                            if (_isHatching) ...[
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.3, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildCelebrationOverlay(Size size) {
    final syncState = ref.watch(syncControllerProvider);

    return Stack(
      children: [
        // Animasyonlu arka plan
        _buildAnimatedBackground(),

        // Ana içerik
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Maskot animasyonu
                  AnimatedBuilder(
                    animation: _jumpAnimation,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(0, _jumpAnimation.value),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_selectedPetType?.color ?? Colors.white)
                                    .withValues(alpha: 0.6),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          // ✅ Lottie optimize edildi
                          child: Lottie.asset(
                            _selectedPetType?.getLottiePath() ?? '',
                            fit: BoxFit.contain,
                            frameRate: FrameRate.max,
                            options: LottieOptions(enableMergePaths: true),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Başlık
                  Text(
                        '🎉 Harika Seçim! 🎉',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  // Alt başlık veya progress
                  if (_syncError)
                    _buildSyncErrorWidget()
                  else if (_isSyncing) ...[
                    Text(
                      'Maceran başlıyor...',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 18,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                    const SizedBox(height: 32),

                    // Progress bar
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: syncState.progress > 0
                              ? syncState.progress
                              : null,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            _softYellow,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),

                    if (syncState.progress > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '%${(syncState.progress * 100).toInt()}',
                        style: GoogleFonts.poppins(
                          color: _softYellow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Eğlenceli mesaj
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          key: ValueKey(_currentMessageIndex),
                          children: [
                            Text(
                              _funMessages[_currentMessageIndex]['emoji']
                                  as String,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _funMessages[_currentMessageIndex]['text']
                                    as String,
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 700.ms),
                  ] else
                    Text(
                      'Maceran başlıyor...',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 18,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncErrorWidget() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: _energeticCoral.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _energeticCoral.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'Bir sorun oluştu 😔',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _syncError = false;
                  _errorMessage = '';
                });
                _startContentSync();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _softYellow,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _navigateToMain,
              child: Text(
                'Atla',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
