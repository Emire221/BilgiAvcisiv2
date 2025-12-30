/// Mock ödeme servisi (Geliştirme aşaması için)
class SubscriptionService {
  /// Kullanıcının premium üyelik durumu
  /// Geliştirme aşamasında her zaman true döner
  bool get isPremium => true;

  /// Premium özelliklere erişim kontrolü
  Future<bool> checkPremiumAccess() async {
    // TODO: Gerçek ödeme sistemi entegrasyonu yapılacak
    // Şimdilik tüm kullanıcılar premium
    return isPremium;
  }

  /// Premium özellik kullanımını kontrol eder
  /// Premium değilse exception fırlatır
  Future<void> requirePremium() async {
    if (!isPremium) {
      throw PremiumRequiredException('Bu özellik premium üyelik gerektirir.');
    }
  }

  /// Abonelik bilgilerini getirir (Mock)
  Future<SubscriptionInfo> getSubscriptionInfo() async {
    return SubscriptionInfo(
      isPremium: isPremium,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      plan: 'Premium (Development)',
    );
  }
}

/// Abonelik bilgileri modeli
class SubscriptionInfo {
  final bool isPremium;
  final DateTime? expiryDate;
  final String plan;

  SubscriptionInfo({
    required this.isPremium,
    this.expiryDate,
    required this.plan,
  });
}

/// Premium üyelik gerektiğinde fırlatılan exception
class PremiumRequiredException implements Exception {
  final String message;

  PremiumRequiredException(this.message);

  @override
  String toString() => message;
}
