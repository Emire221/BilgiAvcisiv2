import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

// 🔥 Firebase Analytics & Monitoring
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_performance/firebase_performance.dart';

import 'firebase_options.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'util/app_colors.dart';
import 'core/navigator_key.dart';
import 'services/notification_service.dart';
import 'services/time_tracking_service.dart';

// ⚡ Wakelock import kaldırıldı - artık sadece gerekli ekranlarda kullanılacak
import 'services/local_preferences_service.dart';
import 'services/scheduled_notification_helper.dart';
import 'providers/theme_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ⚠️ LEGACY ThemeManager - Backward Compatibility İçin Korunuyor
// ═══════════════════════════════════════════════════════════════════════════
// YENİ KODLARDA ref.watch(themeProvider) KULLANIN!
// Bu sınıf kademeli geçiş için tutuluyor, gelecekte kaldırılacak.
// ═══════════════════════════════════════════════════════════════════════════
@Deprecated('Use themeProvider from providers/theme_provider.dart instead')
class ThemeManager extends ValueNotifier<ThemeMode> {
  ThemeManager(ThemeMode initialMode) : super(initialMode);

  void toggleTheme(bool isDarkMode) {
    value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    // Tercihi kaydet
    LocalPreferencesService().setDarkMode(isDarkMode);
  }
}

// Global tema yöneticisi - main() içinde başlatılacak
// ignore: deprecated_member_use_from_same_package
late final ThemeManager themeManager;

/// Global RouteObserver - ekranlar arası geçişleri takip etmek için
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

// ═══════════════════════════════════════════════════════════════════════════
// 🔥 FIREBASE ANALYTICS - Global Instance
// ═══════════════════════════════════════════════════════════════════════════
/// Firebase Analytics instance - sayfa geçişleri ve event takibi için
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

/// Firebase Analytics Observer - NavigatorObserver olarak kullanılır
/// MaterialApp'e eklenerek otomatik sayfa geçiş takibi sağlar
final FirebaseAnalyticsObserver analyticsObserver = FirebaseAnalyticsObserver(
  analytics: analytics,
);

void main() async {
  // ═══════════════════════════════════════════════════════════════════════════
  // 🛡️ CRASHLYTICS: Global Error Zone
  // ═══════════════════════════════════════════════════════════════════════════
  // Tüm asenkron hataları yakalamak için runZonedGuarded kullanıyoruz
  // Bu sayede try-catch ile yakalanamayan hatalar bile Crashlytics'e gider
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // 📱 Ekran yönlendirmesini dikey olarak kilitle (Portrait Only)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // ─────────────────────────────────────────────────────────────────────────
      // 🔥 CRASHLYTICS KURULUMU
      // ─────────────────────────────────────────────────────────────────────────
      // Release modda Crashlytics aktif, Debug modda devre dışı (konsol yeterli)
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );

      // Flutter Framework hatalarını Crashlytics'e yönlendir
      FlutterError.onError = (FlutterErrorDetails details) {
        debugPrint('❌ Flutter Hatası: ${details.exception}');
        debugPrint('📍 Library: ${details.library}');
        debugPrint('📍 Context: ${details.context}');
        // 🔥 Crashlytics'e gönder (release modda)
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      // Platform Dispatcher hataları (asenkron hatalar)
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('❌ Platform Hatası: $error');
        debugPrint('📍 Stack: $stack');
        // 🔥 Crashlytics'e fatal error olarak gönder
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true; // Hatayı işledik
      };

      // ─────────────────────────────────────────────────────────────────────────
      // 📊 PERFORMANCE MONITORING KURULUMU
      // ─────────────────────────────────────────────────────────────────────────
      // Otomatik ağ izleme ve uygulama performans metrikleri
      final performance = FirebasePerformance.instance;
      await performance.setPerformanceCollectionEnabled(!kDebugMode);

      // ─────────────────────────────────────────────────────────────────────────
      // ⚙️ REMOTE CONFIG KURULUMU
      // ─────────────────────────────────────────────────────────────────────────
      await _initRemoteConfig();

      // ⚡ Global Wakelock KALDIRILDI - Pil tasarrufu için
      // Artık sadece Test/Sınav ekranlarında etkinleştirilecek

      // Türkçe tarih formatını başlat
      await initializeDateFormatting('tr_TR', null);

      // Bildirim servisini başlat
      await NotificationService().initialize();

      // Android Alarm Manager'i başlat (zamanlanmış bildirimler için)
      await ScheduledNotificationHelper.initialize();

      // Süre takibi servisini başlat
      await TimeTrackingService().start();

      // Tema tercihini yükle (Varsayılan: Dark Mode)
      final isDarkMode = await LocalPreferencesService().isDarkMode();
      final initialThemeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

      // Legacy ThemeManager (backward compatibility - kademeli olarak kaldırılacak)
      // ignore: deprecated_member_use_from_same_package
      themeManager = ThemeManager(initialThemeMode);

      // Global hata handler - Release/Debug moda göre farklı davranış
      ErrorWidget.builder = (FlutterErrorDetails details) {
        // Debug modunda hata detaylarını yazdır
        debugPrint('❌ ErrorWidget Hatası: ${details.exception}');
        debugPrint('📍 Stack: ${details.stack}');

        // 🔥 Crashlytics'e gönder (non-fatal)
        FirebaseCrashlytics.instance.recordError(
          details.exception,
          details.stack,
          reason: 'ErrorWidget triggered',
        );

        // Release modda kullanıcı dostu hata ekranı göster
        if (kReleaseMode) {
          return Container(
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF1A1A2E),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.orange[300],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bir şeyler yanlış gitti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lütfen sayfayı yenileyin veya uygulamayı yeniden başlatın.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Debug modda Flutter'ın kendi hata ekranını göster (detaylı bilgi için)
        return ErrorWidget.withDetails(
          message: details.exception.toString(),
          error: details.exception is FlutterError
              ? details.exception as FlutterError
              : null,
        );
      };

      // ✅ Riverpod ProviderScope ile başlat
      // themeProvider override ile başlangıç tema modunu ayarla
      runApp(
        ProviderScope(
          overrides: [
            themeProvider.overrideWith(
              (ref) => ThemeNotifier(initialThemeMode),
            ),
          ],
          child: const MyApp(),
        ),
      );
    },
    (error, stack) {
      // ═══════════════════════════════════════════════════════════════════════
      // 🔥 CRASHLYTICS: Zone dışı asenkron hataları yakala
      // ═══════════════════════════════════════════════════════════════════════
      debugPrint('❌ Yakalanmamış Asenkron Hata: $error');
      debugPrint('📍 Stack: $stack');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚙️ REMOTE CONFIG: Uzaktan Yapılandırma Başlatma
// ═══════════════════════════════════════════════════════════════════════════
/// Firebase Remote Config'i başlatır ve varsayılan değerleri ayarlar
/// Uygulama ayarlarını sunucudan çekerek, uygulama güncellemesi yapmadan
/// değişiklik yapmayı mümkün kılar.
Future<void> _initRemoteConfig() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Geliştirme/Test için kısa cache süresi, Production'da daha uzun
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 5) // Debug: sık güncelleme
            : const Duration(hours: 12), // Release: 12 saatte bir
      ),
    );

    // Varsayılan değerler (internet yoksa bunlar kullanılır)
    await remoteConfig.setDefaults({
      // Sınav Ayarları
      'exam_duration_minutes': 45,
      'exam_warning_seconds': 300, // Son 5 dakika uyarısı
      // Bakım Modu
      'maintenance_mode': false,
      'maintenance_message':
          'Uygulama bakımda, lütfen daha sonra tekrar deneyin.',

      // Özellik Bayrakları (Feature Flags)
      'feature_games_enabled': true,
      'feature_ai_chat_enabled': true,
      'feature_weekly_exam_enabled': true,

      // UI Ayarları
      'daily_fact_enabled': true,
      'mascot_animations_enabled': true,

      // Rate Limiting
      'max_daily_tests': 50,
      'max_flashcard_reviews': 100,
    });

    // Sunucudan güncel değerleri çek ve aktifleştir
    await remoteConfig.fetchAndActivate();

    debugPrint('✅ Remote Config başlatıldı');
  } catch (e) {
    // Hata olursa varsayılan değerler kullanılır, uygulama çökmez
    debugPrint('⚠️ Remote Config hatası (varsayılanlar kullanılacak): $e');
  }
}

/// 🎯 Ana Uygulama Widget'ı - Artık ConsumerWidget
/// Riverpod themeProvider'ı dinliyor
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // ✅ Yeni yöntem: Riverpod themeProvider kullan
    // ValueListenableBuilder artık gerekli değil!
    final currentMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Bilgi Avcısı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.nunitoTextTheme(textTheme).apply(
          bodyColor: AppColors.textLight,
          displayColor: AppColors.textLight,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.nunitoTextTheme(textTheme).apply(
          bodyColor: AppColors.textDark,
          displayColor: AppColors.textDark,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.backgroundDark,
        ),
        useMaterial3: true,
      ),
      themeMode: currentMode,
      // ═══════════════════════════════════════════════════════════════════════
      // 📊 ANALYTICS: Sayfa Geçişlerini Otomatik Takip Et
      // ═══════════════════════════════════════════════════════════════════════
      // analyticsObserver: Her sayfa değişimini Firebase'e "screen_view" olarak gönderir
      // routeObserver: Eski observer - mevcut kod uyumluluğu için korunuyor
      navigatorObservers: [analyticsObserver, routeObserver],
      home: const SplashScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ✅ PERFORMANS: AuthWrapper StatefulWidget olarak refactor edildi
// ═══════════════════════════════════════════════════════════════════════════
// Eski Sorun: FutureBuilder her rebuild'de (klavye açılması, tema değişimi vb.)
// Firestore'dan veri çekiyordu. Bu hem maliyet hem de UX sorunu yaratıyordu.
//
// Yeni Çözüm: initState'te bir kez çek ve cache'le.
// FutureBuilder artık hafızadaki _userDataFuture'a bakıyor.
// ═══════════════════════════════════════════════════════════════════════════

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // ✅ Cache: Firestore sorgusu sadece bir kez yapılır
  Future<DocumentSnapshot>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Firestore'dan kullanıcı verisini bir kez çek ve cache'le
  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginScreen();

    // ✅ _userDataFuture null ise (çok nadir durum) tekrar yükle
    if (_userDataFuture == null) {
      _loadUserData();
    }

    return FutureBuilder<DocumentSnapshot>(
      // ✅ PERFORMANS: Artık her build'de yeni sorgu yapılmıyor
      // Cache'lenmiş Future kullanılıyor
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Hata: ${snapshot.error}')));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          return const MainScreen();
        }

        return const ProfileSetupScreen();
      },
    );
  }
}
