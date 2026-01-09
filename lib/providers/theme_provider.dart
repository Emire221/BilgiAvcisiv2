import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_preferences_service.dart';

/// 🎨 Theme Provider - Riverpod ile Tema Yönetimi
///
/// Eski ValueNotifier yerine Riverpod StateNotifier kullanılıyor
/// Bu sayede:
/// - Daha iyi test edilebilirlik
/// - Tek tip state management (Provider karışımı yok)
/// - Otomatik dispose ve lifecycle yönetimi
/// - Consumer widget'lar ile granular rebuild

/// Theme state notifier - tema değişikliklerini yönetir
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(ThemeMode initialMode) : super(initialMode);

  /// Temayı değiştir ve tercihi kaydet
  Future<void> toggleTheme(bool isDarkMode) async {
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await LocalPreferencesService().setDarkMode(isDarkMode);
  }

  /// Dark mode mu?
  bool get isDarkMode => state == ThemeMode.dark;

  /// Sistem temasını takip et
  Future<void> setSystemTheme() async {
    state = ThemeMode.system;
  }
}

/// Theme provider - global tema state'i
///
/// Kullanım:
/// ```dart
/// // Tema okuma
/// final themeMode = ref.watch(themeProvider);
///
/// // Tema değiştirme
/// ref.read(themeProvider.notifier).toggleTheme(true); // Dark mode
/// ref.read(themeProvider.notifier).toggleTheme(false); // Light mode
/// ```
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  // Varsayılan dark mode - main.dart'ta override edilecek
  return ThemeNotifier(ThemeMode.dark);
});

/// isDarkMode helper provider - kolay erişim için
///
/// Kullanım:
/// ```dart
/// final isDark = ref.watch(isDarkModeProvider);
/// ```
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  if (themeMode == ThemeMode.system) {
    // Sistem teması için window brightness'a bakılmalı
    // Bu provider widget tree dışında olduğundan MediaQuery kullanamıyoruz
    // Varsayılan dark döndür, widget içinde MediaQuery kullan
    return true;
  }
  return themeMode == ThemeMode.dark;
});

/// Theme provider'ı başlat - main.dart'ta kullanılacak
/// Kaydedilen tema tercihini yükler
Future<ThemeMode> loadSavedTheme() async {
  final isDarkMode = await LocalPreferencesService().isDarkMode();
  return isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
