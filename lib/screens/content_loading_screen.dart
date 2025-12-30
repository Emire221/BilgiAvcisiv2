import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/navigator_key.dart';
import '../core/providers/sync_provider.dart';
import '../features/sync/domain/models/manifest_model.dart';
import '../services/notification_service.dart';
import '../services/local_preferences_service.dart';
import '../services/database_helper.dart';
import '../widgets/in_app_notification.dart';
import 'main_screen.dart';

/// İçerik Yükleme Ekranı
/// Profil kurulumu ve mascot seçimi sonrası içerik indirme ekranı
class ContentLoadingScreen extends ConsumerStatefulWidget {
  const ContentLoadingScreen({super.key});

  @override
  ConsumerState<ContentLoadingScreen> createState() =>
      _ContentLoadingScreenState();
}

class _ContentLoadingScreenState extends ConsumerState<ContentLoadingScreen>
    with TickerProviderStateMixin {
  // Animasyon kontrolleri
  late AnimationController _meshController;

  // Durum yönetimi
  bool _hasError = false;
  String _errorMessage = '';

  // 🎮 Eğlenceli motivasyon mesajları - çocuklar için (60+ mesaj!)
  final List<Map<String, dynamic>> _funMessages = [
    // 🚀 Uzay Teması
    {'emoji': '🚀', 'text': 'Uzay gemisi kalkışa hazırlanıyor!'},
    {'emoji': '👨‍🚀', 'text': 'Astronot kıyafeti giyiliyor...'},
    {'emoji': '🌍', 'text': 'Dünya yörüngesine giriyoruz!'},
    {'emoji': '🛸', 'text': 'Uzaylılardan bilgi alınıyor...'},
    {'emoji': '☄️', 'text': 'Kuyruklu yıldız geçiyor!'},
    {'emoji': '🌌', 'text': 'Galaksi taranıyor...'},

    // 🧙 Sihir Teması
    {'emoji': '🧙‍♂️', 'text': 'Büyücü derslerini sihirliyor...'},
    {'emoji': '✨', 'text': 'Sihir değneği sallanıyor!'},
    {'emoji': '🔮', 'text': 'Kristal küre geleceğini görüyor!'},
    {'emoji': '📜', 'text': 'Büyülü parşömen okunuyor...'},
    {'emoji': '🧪', 'text': 'İksir karıştırılıyor...'},
    {'emoji': '🎩', 'text': 'Şapkadan tavşan çıkıyor!'},

    // 🦸 Kahraman Teması
    {'emoji': '🦸', 'text': 'Süper güçler yükleniyor!'},
    {'emoji': '🦸‍♀️', 'text': 'Pelerin takılıyor...'},
    {'emoji': '💪', 'text': 'Süper kaslar şişiyor!'},
    {'emoji': '🏃', 'text': 'Işık hızına geçiliyor!'},
    {'emoji': '🔥', 'text': 'Ateş güçleri aktif!'},
    {'emoji': '❄️', 'text': 'Buz kuvvetleri hazır!'},

    // 🎪 Eğlence Teması
    {'emoji': '🎢', 'text': 'Bilgi lunapark treni hareket ediyor!'},
    {'emoji': '🎪', 'text': 'Sirk gösterisi başlamak üzere!'},
    {'emoji': '🎡', 'text': 'Dönme dolap kalkıyor!'},
    {'emoji': '🎠', 'text': 'Atlıkarınca dönüyor!'},
    {'emoji': '🎭', 'text': 'Eğlence perdeleri açılıyor!'},
    {'emoji': '🤹', 'text': 'Palyaço top çeviriyor!'},

    // 🏰 Macera Teması
    {'emoji': '🏰', 'text': 'Bilgi kalesi inşa ediliyor...'},
    {'emoji': '⚔️', 'text': 'Şövalye zırhı giyiliyor!'},
    {'emoji': '🗡️', 'text': 'Ejderhaya karşı hazırlanılıyor!'},
    {'emoji': '🐉', 'text': 'Ejderha eğitiliyor...'},
    {'emoji': '👑', 'text': 'Kraliyet tacı parlatılıyor!'},
    {'emoji': '🗝️', 'text': 'Hazine sandığı açılıyor!'},

    // 🌈 Doğa Teması
    {'emoji': '🌈', 'text': 'Gökkuşağı renkleri karıştırılıyor...'},
    {'emoji': '🌟', 'text': 'Yıldızlar senin için parlıyor!'},
    {'emoji': '🦋', 'text': 'Bilgi kelebekleri uçuşuyor!'},
    {'emoji': '🌺', 'text': 'Zeka çiçekleri açıyor...'},
    {'emoji': '🌻', 'text': 'Ayçiçekleri güneşe bakıyor!'},
    {'emoji': '🍀', 'text': 'Dört yapraklı yonca bulundu!'},

    // 🎨 Sanat Teması
    {'emoji': '🎨', 'text': 'Hayaller boyandırılıyor...'},
    {'emoji': '🖌️', 'text': 'Fırça dans ediyor!'},
    {'emoji': '🎵', 'text': 'Başarı melodisi çalınıyor...'},
    {'emoji': '🎸', 'text': 'Rock yıldızı sahneye çıkıyor!'},
    {'emoji': '🎹', 'text': 'Piyano tuşlarına basılıyor!'},
    {'emoji': '🥁', 'text': 'Davullar çalıyor!'},

    // ⚡ Güç Teması
    {'emoji': '⚡', 'text': 'Beyin şimşekleri çakıyor!'},
    {'emoji': '🔋', 'text': 'Enerji depoları dolduruluyor!'},
    {'emoji': '💡', 'text': 'Fikirler ampulleniyor!'},
    {'emoji': '🧲', 'text': 'Bilgi mıknatısı çalışıyor!'},
    {'emoji': '⭐', 'text': 'Yıldız gücü topanıyor!'},
    {'emoji': '🌙', 'text': 'Ay ışığı çekiliyor!'},

    // 🎮 Oyun Teması
    {'emoji': '🎮', 'text': 'Oyun konsolu açılıyor!'},
    {'emoji': '🕹️', 'text': 'Level yükleniyor...'},
    {'emoji': '🏆', 'text': 'Şampiyonluk yolu açılıyor!'},
    {'emoji': '🎯', 'text': 'Hedefler belirleniyor...'},
    {'emoji': '🥇', 'text': 'Altın madalya parlatılıyor!'},
    {'emoji': '🏅', 'text': 'Ödüller hazırlanıyor!'},

    // 🍭 Tatlı Teması
    {'emoji': '🍭', 'text': 'Şeker kamışları döndürülüyor!'},
    {'emoji': '🍩', 'text': 'Donuts şekillendiriliyor!'},
    {'emoji': '🎂', 'text': 'Pasta süsleniyor!'},
    {'emoji': '🍪', 'text': 'Kurabiyeler pişiyor!'},
    {'emoji': '🍫', 'text': 'Çikolata eritiliyor!'},
    {'emoji': '🧁', 'text': 'Cupcake kremalanıyor!'},

    // 🦄 Fantezi Teması
    {'emoji': '🦄', 'text': 'Tek boynuzlu at seni bekliyor!'},
    {'emoji': '🧚', 'text': 'Periler kanat çırpıyor!'},
    {'emoji': '🧜‍♀️', 'text': 'Deniz kızı şarkı söylüyor!'},
    {'emoji': '🌊', 'text': 'Dalga sörfü yapılıyor!'},
    {'emoji': '🏝️', 'text': 'Hazine adası keşfediliyor!'},
    {'emoji': '🎁', 'text': 'Sürprizler hazırlanıyor...'},
  ];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  // Mesajları karıştır ve sırayla göster
  late List<int> _shuffledIndices;
  int _shuffledPosition = 0;

  // Renkler
  static const Color _primaryPurple = Color(0xFF6C5CE7);
  static const Color _energeticCoral = Color(0xFFFF7675);
  static const Color _turquoise = Color(0xFF00CEC9);
  static const Color _backgroundBase = Color(0xFFF5F6FA);
  static const Color _darkOverlay = Color(0xFF2D3436);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startContentSync();
  }

  void _initializeAnimations() {
    _meshController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    // Mesaj indekslerini karıştır (shuffle) - rastgele ama tekrarsız
    _shuffledIndices = List.generate(_funMessages.length, (i) => i)..shuffle();
    _shuffledPosition = 0;
    _currentMessageIndex = _shuffledIndices[0];

    // 🔄 Mesaj değiştirme timer'ı - her 1.5 saniyede değiş (minimum 1 sn + okuma süresi)
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        // Sırayla karıştırılmış mesajları göster
        _shuffledPosition = (_shuffledPosition + 1) % _shuffledIndices.length;

        // Tüm mesajlar gösterildiğinde tekrar karıştır
        if (_shuffledPosition == 0) {
          _shuffledIndices.shuffle();
        }

        _currentMessageIndex = _shuffledIndices[_shuffledPosition];
      });
    });
  }

  Future<void> _startContentSync() async {
    // 🚩 Preferences servisi
    final prefsService = LocalPreferencesService();

    // 🧹 Önceki sync yarım kalmışsa bozuk verileri temizle
    final wasPreviousSyncComplete = await prefsService.isContentSyncCompleted();
    if (!wasPreviousSyncComplete) {
      // Önceki indirme yarıda kalmış - bozuk/eksik verileri temizle
      debugPrint('⚠️ Önceki sync yarım kalmış - veriler temizleniyor...');
      await DatabaseHelper().clearAllData();
    }

    // 🚩 Bayrağı FALSE yap - yeni işlem başlıyor
    await prefsService.setContentSyncCompleted(false);

    try {
      // Kullanıcının sınıf bilgisini al
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      final userData = userDoc.data();
      final selectedClass = userData?['classLevel'] as String?;
      final userName = userData?['name'] as String? ?? 'Öğrenci';

      if (selectedClass == null) {
        throw Exception('Sınıf bilgisi bulunamadı');
      }

      // 🎉 İlk kurulumda hoşgeldin bildirimi gönder (10 saniye sonra)
      await _scheduleWelcomeNotificationIfFirstTime(userName);

      // Sınıf adını güvenli formata çevir
      final safeClassName = selectedClass
          .replaceAll('.', '')
          .replaceAll(' ', '_')
          .replaceAll('ı', 'i')
          .replaceAll('İ', 'I');

      // İçerik senkronizasyonu başlat
      await ref
          .read(syncControllerProvider.notifier)
          .syncContent(safeClassName);

      final syncState = ref.read(syncControllerProvider);
      if (syncState.error != null) {
        throw Exception(syncState.error);
      }

      // ✅ Başarılı - Bayrağı TRUE yap
      await prefsService.setContentSyncCompleted(true);

      // Başarılı - MainScreen'e git
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToMain();
      }
    } catch (e) {
      // ❌ Hata durumunda bayrak FALSE kalır (zaten false yapılmıştı)
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToMain() {
    // Kullanıcı adını al ve in-app bildirim göster
    _showInAppWelcomeNotification();

    // Haftalık bildirimleri başlat (login sonrası bir kez)
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

  /// İlk girişte in-app hoşgeldin bildirimi göster
  Future<void> _showInAppWelcomeNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShownInAppWelcome =
          prefs.getBool('has_shown_inapp_welcome') ?? false;

      if (!hasShownInAppWelcome) {
        // Kullanıcı adını önce al (async gap öncesi)
        final user = FirebaseAuth.instance.currentUser;
        final userName = user?.displayName ?? 'Şampiyon';

        // 12 saniye sonra göster (kullanıcı ana ekrana geçtikten sonra)
        Future.delayed(const Duration(seconds: 12), () {
          // Widget hala mounted değilse çık
          if (!mounted) return;

          // navigatorKey kullanarak context al (async-safe)
          final navContext = navigatorKey.currentContext;
          if (navContext != null) {
            // ignore: use_build_context_synchronously
            showWelcomeNotification(navContext, userName);
          }
        });

        // İşareti kaydet
        await prefs.setBool('has_shown_inapp_welcome', true);
      }
    } catch (e) {
      debugPrint('In-app bildirim hatası: $e');
    }
  }

  /// İlk kurulumda hoşgeldin bildirimi gönder (sadece bir kez)
  Future<void> _scheduleWelcomeNotificationIfFirstTime(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasReceivedWelcome =
          prefs.getBool('has_received_welcome_notification') ?? false;

      if (!hasReceivedWelcome) {
        // İlk kez - hoşgeldin bildirimi planla (10 saniye sonra)
        await NotificationService().scheduleWelcomeNotification(
          userName: userName,
          delaySeconds: 10,
        );

        // İşareti kaydet - bir daha gönderilmeyecek
        await prefs.setBool('has_received_welcome_notification', true);
      }
    } catch (e) {
      // Bildirim hatası kritik değil, devam et
      debugPrint('Hoşgeldin bildirimi hatası: $e');
    }
  }

  @override
  void dispose() {
    _meshController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Mesh gradient arka plan
          _buildMeshGradientBackground(),

          // Ana içerik
          SafeArea(
            child: Center(
              child: _hasError
                  ? _buildErrorState()
                  : _buildLoadingState(syncState, screenWidth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshGradientBackground() {
    return AnimatedBuilder(
      animation: _meshController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: _backgroundBase,
          child: Stack(
            children: [
              // Mor top - sol üst
              _buildGradientOrb(
                color: _primaryPurple.withValues(alpha: 0.6),
                alignment: Alignment(
                  -1.2 + (_meshController.value * 0.4),
                  -1.2 + (_meshController.value * 0.3),
                ),
                size: 0.7,
              ),
              // Mercan top - sağ üst
              _buildGradientOrb(
                color: _energeticCoral.withValues(alpha: 0.5),
                alignment: Alignment(
                  1.2 - (_meshController.value * 0.3),
                  -0.8 + (_meshController.value * 0.4),
                ),
                size: 0.6,
              ),
              // Turkuaz top - alt orta
              _buildGradientOrb(
                color: _turquoise.withValues(alpha: 0.5),
                alignment: Alignment(
                  0.0 + (_meshController.value * 0.2),
                  1.0 - (_meshController.value * 0.2),
                ),
                size: 0.65,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientOrb({
    required Color color,
    required Alignment alignment,
    required double size,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: MediaQuery.of(context).size.width * size,
        height: MediaQuery.of(context).size.width * size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(SyncState syncState, double screenWidth) {
    final titleFontSize = (screenWidth * 0.07).clamp(24.0, 36.0);
    final messageFontSize = (screenWidth * 0.045).clamp(14.0, 20.0);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Başlık
          Text(
            '🚀 İçerikler Yükleniyor',
            style: GoogleFonts.nunito(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: _darkOverlay,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0),

          const SizedBox(height: 8),

          Text(
            'Biraz bekle, her şey hazırlanıyor!',
            style: GoogleFonts.nunito(
              fontSize: messageFontSize * 0.9,
              color: _darkOverlay.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 40),

          // Lottie animasyonu
          SizedBox(
                width: 180,
                height: 120,
                child: Lottie.asset(
                  'assets/animation/loading-kum.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return CircularProgressIndicator(
                      color: _primaryPurple,
                      strokeWidth: 3,
                    );
                  },
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: 32),

          // İlerleme çubuğu
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: syncState.progress > 0 ? syncState.progress : null,
                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                // Yüzde
                if (syncState.progress > 0)
                  Text(
                    '%${(syncState.progress * 100).toInt()}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primaryPurple,
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 24),

          // Sync mesajı veya komik mesaj
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: _primaryPurple.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildFunMessage(syncState, messageFontSize),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  /// Eğlenceli mesaj widget'ı - emoji ve metin ile
  Widget _buildFunMessage(SyncState syncState, double fontSize) {
    // Sync durumu varsa onu göster, yoksa eğlenceli mesaj
    if (syncState.message.isNotEmpty &&
        !syncState.message.contains('indiriliyor') &&
        !syncState.message.contains('işleniyor')) {
      return Text(
        syncState.message,
        key: ValueKey<String>(syncState.message),
        style: GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: _darkOverlay.withValues(alpha: 0.85),
        ),
        textAlign: TextAlign.center,
      );
    }

    final currentMessage = _funMessages[_currentMessageIndex];
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animasyonlu emoji
        Text(
              currentMessage['emoji'] as String,
              style: const TextStyle(fontSize: 28),
            )
            .animate(onComplete: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              duration: 500.ms,
            )
            .shake(hz: 2, offset: const Offset(2, 0)),
        const SizedBox(width: 12),
        // Metin
        Flexible(
          child: Text(
            currentMessage['text'] as String,
            key: ValueKey<int>(_currentMessageIndex),
            style: GoogleFonts.nunito(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: _darkOverlay.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hata ikonu
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _energeticCoral.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: _energeticCoral,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Bir sorun oluştu 😔',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _darkOverlay,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _errorMessage,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: _darkOverlay.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Tekrar dene butonu
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = '';
              });
              _startContentSync();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Atla butonu - çevrimdışı devam
          TextButton(
            onPressed: _navigateToMain,
            child: Text(
              'Şimdilik Atla',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _darkOverlay.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
