import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/mascot.dart';
import '../providers/mascot_provider.dart';
import '../../../../screens/content_loading_screen.dart';
import '../../../../widgets/glass_container.dart';

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
              child: Lottie.asset(
                _selectedPetType?.getLottiePath() ?? '',
                fit: BoxFit.contain,
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ContentLoadingScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _showCelebration = false;
        _isHatching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: _energeticCoral),
      );
    }
  }

  // ==================== UI BUILD METODLARI ====================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
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
                              child: Lottie.asset(
                                petType.getLottiePath(),
                                fit: BoxFit.contain,
                                animate: isActive,
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
                      boxShadow: _isHatching
                          ? null
                          : [
                              BoxShadow(
                                color: _energeticCoral.withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
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
    return Stack(
      children: [
        // Konfeti / Yıldız Lottie
        Positioned.fill(
          child: Lottie.asset(
            'assets/animation/loading-kum.json', // Placeholder - konfeti yerine
            fit: BoxFit.cover,
            repeat: false,
          ),
        ),

        // Ortada seçilen maskot
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      child: Lottie.asset(
                        _selectedPetType?.getLottiePath() ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
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
      ],
    );
  }
}
