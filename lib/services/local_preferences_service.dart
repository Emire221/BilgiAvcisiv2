import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences işlemlerini merkezi olarak yöneten servis
class LocalPreferencesService {
  static const String _keyUserName = 'userName';
  static const String _keyUserGrade = 'userGrade';
  static const String _keyUserSchool = 'userSchool';
  static const String _keyUserAvatar = 'userAvatar';
  static const String _keyUserCity = 'userCity';
  static const String _keyUserDistrict = 'userDistrict';
  static const String _keyIsFirstRun = 'isFirstRun';
  static const String _keyLastSyncVersion = 'lastSyncVersion';
  static const String _keyLastSyncDate = 'lastSyncDate';
  static const String _keyContentSyncCompleted = 'contentSyncCompleted';

  /// İçerik senkronizasyonunun başarıyla tamamlanıp tamamlanmadığını kaydeder
  Future<void> setContentSyncCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyContentSyncCompleted, value);
  }

  /// İçerik senkronizasyonunun tamamlanıp tamamlanmadığını kontrol eder
  /// Varsayılan: false (güvenli taraf - senkronizasyon yapılmadı varsayılır)
  Future<bool> isContentSyncCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyContentSyncCompleted) ?? false;
  }

  /// Kullanıcı profilini yerel önbelleğe kaydeder
  Future<void> saveUserProfile({
    required String name,
    required String grade,
    required String school,
    String? avatar,
    String? city,
    String? district,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserGrade, grade);
    await prefs.setString(_keyUserSchool, school);
    if (avatar != null) await prefs.setString(_keyUserAvatar, avatar);
    if (city != null) await prefs.setString(_keyUserCity, city);
    if (district != null) await prefs.setString(_keyUserDistrict, district);
  }

  /// Kullanıcı adını getirir
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Kullanıcı sınıfını getirir
  Future<String?> getUserGrade() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserGrade);
  }

  /// Kullanıcı okul bilgisini getirir
  Future<String?> getUserSchool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserSchool);
  }

  /// Kullanıcı avatar bilgisini getirir
  Future<String?> getUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserAvatar);
  }

  /// Kullanıcı şehir bilgisini getirir
  Future<String?> getUserCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserCity);
  }

  /// Kullanıcı ilçe bilgisini getirir
  Future<String?> getUserDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserDistrict);
  }

  /// Tüm kullanıcı profil bilgilerini getirir
  Future<Map<String, String?>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyUserName),
      'grade': prefs.getString(_keyUserGrade),
      'school': prefs.getString(_keyUserSchool),
      'avatar': prefs.getString(_keyUserAvatar),
      'city': prefs.getString(_keyUserCity),
      'district': prefs.getString(_keyUserDistrict),
    };
  }

  /// İlk çalıştırma durumunu kontrol eder
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstRun) ?? true;
  }

  /// İlk çalıştırma bayrağını günceller
  Future<void> setFirstRunComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstRun, false);
  }

  /// Son senkronizasyon versiyonunu kaydeder
  Future<void> setLastSyncVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSyncVersion, version);
  }

  /// Son senkronizasyon versiyonunu getirir
  Future<String?> getLastSyncVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSyncVersion);
  }

  /// Son senkronizasyon tarihini kaydeder
  Future<void> setLastSyncDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSyncDate, date.toIso8601String());
  }

  /// Son senkronizasyon tarihini getirir
  Future<DateTime?> getLastSyncDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyLastSyncDate);
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  /// Tüm yerel verileri temizler
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ========== TEMA AYARLARI ==========

  static const String _keyIsDarkMode = 'isDarkMode';

  /// Dark mode tercihini kaydeder
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, value);
  }

  /// Dark mode tercihini getirir (Varsayılan: TRUE - Dark Mode)
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDarkMode) ?? true;
  }
}
