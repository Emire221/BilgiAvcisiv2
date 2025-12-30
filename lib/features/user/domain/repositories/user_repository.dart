/// Kullanıcı profil ve veri işlemlerini soyutlayan repository interface
abstract class UserRepository {
  /// Kullanıcı profilini kaydeder veya günceller
  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required String grade,
    required String city,
    required String district,
    required String schoolId,
    required String schoolName,
    String? avatar,
    String? email,
  });

  /// Kullanıcı profilini getirir
  Future<Map<String, dynamic>?> getUserProfile(String userId);

  /// Kullanıcının sınıf bilgisini getirir
  Future<String> getUserGrade(String userId);

  /// Test sonucunu kaydeder
  Future<void> saveTestResult({
    required String userId,
    required String testId,
    required String topicId,
    required String topicName,
    required int score,
    required int correctCount,
    required int wrongCount,
    int? duration,
  });

  /// Kullanıcının toplam puanını getirir
  Future<int> getTotalScore(String userId);
}
