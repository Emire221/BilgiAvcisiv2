import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'util/app_colors.dart';
import 'core/navigator_key.dart';
import 'services/notification_service.dart';
import 'services/time_tracking_service.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'services/local_preferences_service.dart';
import 'services/scheduled_notification_helper.dart';

// Basit bir tema yöneticisi
class ThemeManager extends ValueNotifier<ThemeMode> {
  ThemeManager(ThemeMode initialMode) : super(initialMode);

  void toggleTheme(bool isDarkMode) {
    value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    // Tercihi kaydet
    LocalPreferencesService().setDarkMode(isDarkMode);
  }
}

// Global tema yöneticisi - main() içinde başlatılacak
late final ThemeManager themeManager;

/// Global RouteObserver - ekranlar arası geçişleri takip etmek için
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ekranın kapanmasını engelle
  WakelockPlus.enable();

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
  themeManager = ThemeManager(isDarkMode ? ThemeMode.dark : ThemeMode.light);

  // Global hata handler - Kırmızı hata ekranını önle
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Debug modunda hata detaylarını yazdır
    debugPrint('❌ ErrorWidget Hatası: ${details.exception}');
    debugPrint('📍 Stack: ${details.stack}');
    // Boş bir widget döndür (kırmızı hata ekranı yerine)
    return const SizedBox.shrink();
  };

  // Flutter framework hatalarını yakala
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('❌ Flutter Hatası: ${details.exception}');
    debugPrint('📍 Library: ${details.library}');
    debugPrint('📍 Context: ${details.context}');
    // Varsayılan davranışı devre dışı bırak (kırmızı ekran gösterme)
    // FlutterError.presentError(details);
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeManager,
      builder: (context, currentMode, child) {
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
          navigatorObservers: [routeObserver],
          home: const SplashScreen(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginScreen();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
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
