import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../features/mascot/presentation/screens/pet_selection_screen.dart';
import '../models/models.dart';
import '../services/firebase_storage_service.dart';
import '../widgets/glass_container.dart';

/// 🎮 Oyunlaştırılmış Profil Kurulum Ekranı
/// "Kahramanını Oluştur" Temalı Kimlik Oyunu
///
/// ✨ Özellikler:
/// - Responsive tasarım (Tablet/Phone)
/// - Animasyonlu mesh gradient arka plan
/// - Glassmorphism UI bileşenleri
/// - Cupertino Picker (iOS stili dönen tekerlek)
/// - Haptic feedback
/// - Sınıf rozet grid sistemi
/// - Animasyonlu ilerleme barı
/// - Pulse efektli buton
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with TickerProviderStateMixin {
  // Form Kontrolleri
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  // Seçim Verileri
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedSchoolID;
  String? _selectedClass;

  // Veri Listeleri
  List<String> _cities = [];
  List<School> _schools = [];
  List<String> _districts = [];
  List<School> _filteredSchools = [];
  List<Map<String, String>> _classes = [];

  // Durum Yönetimi
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  String _loadingMessage = 'Oyun hazırlanıyor...';

  // Animasyon Kontrolleri
  late AnimationController _blobController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Renkler
  static const Color _primaryPurple = Color(0xFF6C5CE7);
  static const Color _energeticCoral = Color(0xFFFF7675);
  static const Color _turquoise = Color(0xFF00CEC9);
  static const Color _softYellow = Color(0xFFFDCB6E);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadInitialData();
  }

  void _initAnimations() {
    _blobController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([_loadCities(), _loadClasses()]);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Veri yükleme hatası: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadClasses() async {
    try {
      final response = await rootBundle.loadString('assets/json/siniflar.json');
      final data = json.decode(response);
      setState(() {
        _classes = (data['siniflar'] as List)
            .map(
              (e) => {'id': e['id'].toString(), 'name': e['name'].toString()},
            )
            .toList();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Sınıf listesi yüklenemedi: $e');
    }
  }

  Future<void> _loadCities() async {
    try {
      final response = await rootBundle.loadString('assets/json/cities.json');
      final data = json.decode(response);
      setState(() => _cities = List<String>.from(data['cities']));
    } catch (e) {
      if (kDebugMode) debugPrint('Şehir listesi yüklenemedi: $e');
    }
  }

  // İl değişikliği için loading durumu - sadece ilk il seçiminde gösterilecek
  bool _isCityLoading = false;

  Future<void> _onCityChanged(String city) async {
    _triggerHaptic();

    // Loading sadece picker kapatıldığında ve okul verisi indirilirken gösterilecek
    // setState ile ana ekranı yenileme - sadece seçim değişikliği
    setState(() {
      _selectedCity = city;
      _selectedDistrict = null;
      _selectedSchoolID = null;
      _filteredSchools = [];
      _isCityLoading = true; // Sadece bu il için loading
    });

    try {
      final schools = await FirebaseStorageService().downloadSchoolData(city);
      final districtsSet = <String>{};
      for (final school in schools) {
        // İlçe adını normalize et - ilk harfi büyük yap
        final rawDistrict = school.ilce.trim();
        if (rawDistrict.isNotEmpty) {
          // Türkçe karakterleri koruyarak ilk harfi büyük yap
          final normalized = _capitalizeFirst(rawDistrict);
          districtsSet.add(normalized);
        }
      }
      final districts = districtsSet.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (mounted) {
        setState(() {
          _schools = schools;
          _districts = districts;
          _isCityLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCityLoading = false);
        _showError('Okul listesi yüklenemedi');
      }
    }
  }

  void _onDistrictChanged(String district) {
    _triggerHaptic();
    setState(() {
      _selectedDistrict = district;
      _selectedSchoolID = null;
      _filteredSchools =
          _schools
              .where(
                (s) =>
                    s.ilce.toLowerCase().trim() ==
                    district.toLowerCase().trim(),
              )
              .toList()
            ..sort(
              (a, b) =>
                  a.okulAdi.toLowerCase().compareTo(b.okulAdi.toLowerCase()),
            );
    });
  }

  void _onSchoolChanged(String schoolID) {
    _triggerHaptic();
    setState(() => _selectedSchoolID = schoolID);
  }

  void _onClassChanged(String classId) {
    _triggerHaptic();
    setState(() => _selectedClass = classId);
  }

  /// Türkçe karakterleri koruyarak ilk harfi büyük yapar
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    final first = text[0].toUpperCase();
    final rest = text.length > 1 ? text.substring(1).toLowerCase() : '';
    return '$first$rest';
  }

  Future<void> _triggerHaptic() async {
    await HapticFeedback.selectionClick();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _energeticCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool get _isFormComplete =>
      _nameController.text.trim().isNotEmpty &&
      _ageController.text.trim().isNotEmpty &&
      _selectedCity != null &&
      _selectedDistrict != null &&
      _selectedSchoolID != null &&
      _selectedClass != null;

  int get _completedSteps {
    int count = 0;
    // İsim dolu mu ve yaş geçerli mi kontrolü
    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);
    final isAgeValid = age != null && age >= 7 && age <= 18;

    if (_nameController.text.trim().isNotEmpty && isAgeValid) {
      count++;
    }
    if (_selectedCity != null &&
        _selectedDistrict != null &&
        _selectedSchoolID != null) {
      count++;
    }
    if (_selectedClass != null) {
      count++;
    }
    return count;
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate() || !_isFormComplete) {
      _showError('Lütfen tüm alanları doldurun');
      return;
    }

    _triggerHaptic();
    setState(() {
      _isSubmitting = true;
      _loadingMessage = 'Kahramanın hazırlanıyor...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final selectedSchool = _schools.firstWhere(
        (s) => s.okulID == _selectedSchoolID,
      );

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'city': _selectedCity,
        'district': _selectedDistrict,
        'schoolID': _selectedSchoolID,
        'schoolName': selectedSchool.okulAdi,
        'classLevel': _selectedClass,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Direkt mascot seçimine git, içerik yükleme orada yapılacak
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PetSelectionScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError('Hata oluştu: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _blobController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: _isLoadingData
                ? _buildLoadingState()
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
            Positioned(
              top: -100 + (math.sin(_blobController.value * math.pi * 2) * 50),
              right: -50 + (math.cos(_blobController.value * math.pi * 2) * 30),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _energeticCoral.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom:
                  -80 + (math.cos(_blobController.value * math.pi * 2) * 40),
              left: -60 + (math.sin(_blobController.value * math.pi * 2) * 35),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _softYellow.withValues(alpha: 0.25),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/animation/loading-kum.json',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _loadingMessage,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildMainContent(Size size, bool isTablet) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildProgressHeader(size)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, curve: Curves.easeOutBack),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? size.width * 0.15 : 20,
            vertical: 20,
          ),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildNameSection(size)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  _buildLocationSection(size)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  _buildClassSection(size, isTablet)
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOutBack),
                  const SizedBox(height: 32),
                  _buildContinueButton(size)
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutBack),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(Size size) {
    final progress = _completedSteps / 3;

    // Responsive değerler
    final screenWidth = size.width;
    final isSmallPhone = screenWidth < 360;
    final isMediumPhone = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    // Dinamik font boyutları
    final titleFontSize = isTablet ? 32.0 : (isMediumPhone ? 26.0 : 22.0);
    final subtitleFontSize = isTablet ? 18.0 : (isMediumPhone ? 15.0 : 13.0);
    final progressBarHeight = isTablet ? 14.0 : (isMediumPhone ? 12.0 : 10.0);
    final horizontalPadding = isTablet ? 32.0 : (isMediumPhone ? 20.0 : 16.0);
    final verticalPadding = isTablet ? 24.0 : (isMediumPhone ? 18.0 : 14.0);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: GlassContainer(
        blur: 8,
        opacity: 0.12,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık Row - emoji ve metin ayrı
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎮', style: TextStyle(fontSize: titleFontSize + 4)),
                    const SizedBox(width: 8),
                    Text(
                      'Kahramanını Oluştur',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallPhone ? 6 : 10),
              // Alt başlık
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      color: _softYellow,
                      size: subtitleFontSize + 2,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Adım $_completedSteps / 3',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallPhone ? 12 : 18),
              // Progress Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  return Stack(
                    children: [
                      // Arka plan
                      Container(
                        height: progressBarHeight,
                        width: barWidth,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            progressBarHeight / 2,
                          ),
                        ),
                      ),
                      // İlerleme
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        height: progressBarHeight,
                        width: barWidth * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_softYellow, _energeticCoral],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            progressBarHeight / 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _softYellow.withValues(alpha: 0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      // Parıltı efekti
                      if (progress > 0)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          right: barWidth * (1 - progress) + 4,
                          top: 2,
                          child: Container(
                            width: progressBarHeight - 4,
                            height: progressBarHeight - 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: isSmallPhone ? 8 : 12),
              // İlerleme yüzdeleri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) {
                  final isCompleted = index < _completedSteps;
                  final isCurrent = index == _completedSteps;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallPhone ? 8 : 12,
                      vertical: isSmallPhone ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? _softYellow.withValues(alpha: 0.3)
                          : (isCurrent
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Text(
                      isCompleted ? '✓' : '${index + 1}',
                      style: GoogleFonts.poppins(
                        color: isCompleted
                            ? _softYellow
                            : Colors.white.withValues(
                                alpha: isCurrent ? 1 : 0.5,
                              ),
                        fontSize: isSmallPhone ? 11 : 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameSection(Size size) {
    final maxChars = 20;
    final remaining = maxChars - _nameController.text.length;

    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _energeticCoral.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '👋 Kahramanın Adı Ne?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              maxLength: maxChars,
              // Türkçe karakterler ve tüm unicode harfler
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[\p{L}\s]', unicode: true),
                ),
              ],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'İsmini yaz...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '$remaining',
                    style: GoogleFonts.poppins(
                      color: remaining < 5
                          ? _energeticCoral
                          : Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                counterText: '',
              ),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'İsim gerekli' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              autovalidateMode: AutovalidateMode.onUserInteraction, // Anlık hata gösterimi
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Yaşın kaç? (7-18)',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.cake_outlined,
                  color: Colors.white70,
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v?.trim().isEmpty ?? true) {
                  return 'Yaş gerekli';
                }
                final age = int.tryParse(v!);
                if (age == null || age < 7 || age > 18) {
                  return 'Yaş 7-18 arasında olmalı';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Size size) {
    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _turquoise.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '📍 Nerede Yaşıyorsun?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPickerButton(
              label: _selectedCity ?? 'İl Seçiniz',
              icon: Icons.location_city,
              isSelected: _selectedCity != null,
              onTap: () => _showCityPicker(context),
            ),
            const SizedBox(height: 12),
            _isCityLoading
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Okullar yükleniyor...',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildPickerButton(
                    label: _selectedDistrict ?? 'İlçe Seçiniz',
                    icon: Icons.map,
                    isSelected: _selectedDistrict != null,
                    enabled: _selectedCity != null && _districts.isNotEmpty,
                    onTap: _selectedCity != null && _districts.isNotEmpty
                        ? _showDistrictPicker
                        : null,
                  ),
            const SizedBox(height: 12),
            _buildPickerButton(
              label: _selectedSchoolID != null && _filteredSchools.isNotEmpty
                  ? _filteredSchools
                        .firstWhere((s) => s.okulID == _selectedSchoolID)
                        .okulAdi
                  : 'Okul Seçiniz',
              icon: Icons.school,
              isSelected: _selectedSchoolID != null,
              enabled: _selectedDistrict != null && _filteredSchools.isNotEmpty,
              onTap: _selectedDistrict != null && _filteredSchools.isNotEmpty
                  ? _showSchoolPicker
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled
              ? (isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.1))
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? Colors.white : Colors.white38,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: enabled ? Colors.white : Colors.white38,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              enabled ? Icons.arrow_drop_down : Icons.lock_outline,
              color: enabled ? Colors.white : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSection(Size size, bool isTablet) {
    // Responsive değerler
    final screenWidth = size.width;
    final isSmallPhone = screenWidth < 360;

    // Grid için dinamik hesaplamalar
    final crossAxisCount = isTablet ? 3 : 2;
    final horizontalPadding = isTablet ? 24.0 : (isSmallPhone ? 16.0 : 20.0);
    final availableWidth =
        screenWidth -
        (horizontalPadding * 2) -
        (isTablet ? size.width * 0.3 : 40);
    final itemWidth =
        (availableWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
    final itemHeight = isTablet ? 80.0 : (isSmallPhone ? 70.0 : 75.0);
    final aspectRatio = itemWidth / itemHeight;

    return GlassContainer(
      blur: 10,
      opacity: 0.15,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.all(isSmallPhone ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallPhone ? 10 : 12),
                  decoration: BoxDecoration(
                    color: _softYellow.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: isSmallPhone ? 20 : 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎓 Hangi Sınıftasın?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallPhone ? 18 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_classes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Sınıflar yükleniyor...',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: isSmallPhone ? 10 : 12,
                  crossAxisSpacing: isSmallPhone ? 10 : 12,
                  childAspectRatio: aspectRatio.clamp(1.5, 3.0),
                ),
                itemCount: _classes.length,
                itemBuilder: (context, index) {
                  final classData = _classes[index];
                  final isSelected = _selectedClass == classData['id'];

                  return GestureDetector(
                    onTap: () => _onClassChanged(classData['id']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      transform: Matrix4.diagonal3Values(
                        isSelected ? 1.05 : 1.0,
                        isSelected ? 1.05 : 1.0,
                        1.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [_softYellow, _energeticCoral],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected
                            ? null
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _softYellow.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isSelected ? '⭐' : '🎯',
                                style: TextStyle(
                                  fontSize: isSmallPhone
                                      ? 18
                                      : (isTablet ? 24 : 20),
                                ),
                              ),
                              SizedBox(width: isSmallPhone ? 6 : 8),
                              Flexible(
                                child: Text(
                                  classData['name']!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: isSmallPhone
                                        ? 13
                                        : (isTablet ? 16 : 14),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  // Animasyon kaldırıldı - sorun yarattığı için basit widget döndürülüyor
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(Size size) {
    final isEnabled = _isFormComplete && !_isSubmitting;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) => Transform.scale(
        scale: isEnabled ? _pulseAnimation.value : 1.0,
        child: GestureDetector(
          onTap: isEnabled ? _completeSetup : null,
          child: Container(
            width: size.width * (size.width > 600 ? 0.5 : 0.8),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? LinearGradient(
                      colors: [_energeticCoral, _softYellow],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: isEnabled ? null : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: _energeticCoral.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _loadingMessage,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEnabled ? '🚀 DEVAM ET' : '🔒 Tüm Alanları Doldur',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (isEnabled) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showCityPicker(BuildContext context) {
    _triggerHaptic();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchablePickerSheet<String>(
        title: '📍 İl Seçiniz',
        items: _cities,
        itemBuilder: (city) => city,
        searchMatcher: (city, query) =>
            city.toLowerCase().contains(query.toLowerCase()),
        onSelected: (city) {
          Navigator.pop(context);
          _onCityChanged(city);
        },
      ),
    );
  }

  void _showDistrictPicker() {
    _triggerHaptic();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchablePickerSheet<String>(
        title: '🏘️ İlçe Seçiniz',
        items: _districts,
        itemBuilder: (district) => district,
        searchMatcher: (district, query) =>
            district.toLowerCase().contains(query.toLowerCase()),
        onSelected: (district) {
          Navigator.pop(context);
          _onDistrictChanged(district);
        },
      ),
    );
  }

  void _showSchoolPicker() {
    _triggerHaptic();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchablePickerSheet<School>(
        title: '🏫 Okul Seçiniz',
        items: _filteredSchools,
        itemBuilder: (s) => s.okulAdi,
        searchMatcher: (s, q) =>
            s.okulAdi.toLowerCase().contains(q.toLowerCase()),
        onSelected: (s) {
          Navigator.pop(context);
          _onSchoolChanged(s.okulID);
        },
      ),
    );
  }
}

// 🎨 Arama Özellikli Bottom Sheet
class _SearchablePickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemBuilder;
  final bool Function(T, String) searchMatcher;
  final void Function(T) onSelected;

  const _SearchablePickerSheet({
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.searchMatcher,
    required this.onSelected,
  });

  @override
  State<_SearchablePickerSheet<T>> createState() =>
      _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  final _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.75,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (q) {
                      setState(() {
                        _filteredItems = q.isEmpty
                            ? widget.items
                            : widget.items
                                  .where((i) => widget.searchMatcher(i, q))
                                  .toList();
                      });
                    },
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ara...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          'Sonuç bulunamadı',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (_, i) {
                      final item = _filteredItems[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            widget.itemBuilder(item),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white70,
                          ),
                          onTap: () => widget.onSelected(item),
                        ),
                      ).animate().fadeIn(delay: (i < 10 ? i * 30 : 0).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
