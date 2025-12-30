import '../entities/mascot.dart';

abstract class MascotRepository {
  /// Kullanıcının maskotunu getirir (yoksa null döner)
  Future<Mascot?> getUserMascot();

  /// Yeni maskot oluşturur
  Future<void> createMascot(Mascot mascot);

  /// Maskot bilgilerini günceller
  Future<void> updateMascot(Mascot mascot);

  /// Maskotun XP'sini artırır ve güncel hali döner
  Future<Mascot> addXp(int amount);

  /// Maskotun mood değerini günceller
  Future<void> updateMood(int mood);

  /// Kullanıcının maskotu olup olmadığını kontrol eder
  Future<bool> hasMascot();
}
