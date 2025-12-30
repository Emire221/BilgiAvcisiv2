import 'package:flutter/material.dart';

/// Sıcaklık durumu enum'u - Tahmin doğruluğuna göre
enum Temperature {
  freezing, // Çok uzak (buz gibi soğuk)
  cold, // Uzak (soğuk)
  cool, // Biraz uzak (serin)
  warm, // Yaklaşıyor (ılık)
  hot, // Çok yakın (sıcak)
  boiling, // Neredeyse doğru (kaynar)
  correct, // Doğru cevap
}

/// Temperature extension - Renk ve mesaj yardımcıları
extension TemperatureExtension on Temperature {
  /// Sıcaklık durumuna göre ana renk
  Color get color {
    switch (this) {
      case Temperature.freezing:
        return const Color(0xFF0D47A1); // Koyu mavi
      case Temperature.cold:
        return const Color(0xFF1565C0); // Mavi
      case Temperature.cool:
        return const Color(0xFF42A5F5); // Açık mavi
      case Temperature.warm:
        return const Color(0xFFFFB300); // Turuncu-sarı
      case Temperature.hot:
        return const Color(0xFFFF6F00); // Turuncu
      case Temperature.boiling:
        return const Color(0xFFE53935); // Kırmızı
      case Temperature.correct:
        return const Color(0xFF43A047); // Yeşil
    }
  }

  /// Sıcaklık durumuna göre gradient
  LinearGradient get gradient {
    switch (this) {
      case Temperature.freezing:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D47A1), Color(0xFF1A237E)],
        );
      case Temperature.cold:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        );
      case Temperature.cool:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
        );
      case Temperature.warm:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
        );
      case Temperature.hot:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF6F00), Color(0xFFE65100)],
        );
      case Temperature.boiling:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        );
      case Temperature.correct:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        );
    }
  }

  /// Sıcaklık durumuna göre feedback mesajı
  String get message {
    switch (this) {
      case Temperature.freezing:
        return 'Buz gibi soğuk! 🥶';
      case Temperature.cold:
        return 'Soğuk... ❄️';
      case Temperature.cool:
        return 'Biraz serin 🌬️';
      case Temperature.warm:
        return 'Ilık, yaklaşıyorsun! 🌤️';
      case Temperature.hot:
        return 'Sıcak! Çok yakınsın! 🔥';
      case Temperature.boiling:
        return 'KAYNIYOR! Neredeyse buldun! 🌋';
      case Temperature.correct:
        return 'DOĞRU! 🎉';
    }
  }

  /// Yön ipucu mesajı
  String directionHint(bool goUp) {
    if (this == Temperature.correct) return '';
    return goUp ? '⬆️ Yukarı çık!' : '⬇️ Aşağı in!';
  }

  /// İkon
  IconData get icon {
    switch (this) {
      case Temperature.freezing:
        return Icons.ac_unit;
      case Temperature.cold:
        return Icons.severe_cold;
      case Temperature.cool:
        return Icons.air;
      case Temperature.warm:
        return Icons.wb_sunny;
      case Temperature.hot:
        return Icons.local_fire_department;
      case Temperature.boiling:
        return Icons.whatshot;
      case Temperature.correct:
        return Icons.celebration;
    }
  }

  /// Termometre seviyesi (0.0 - 1.0 arası)
  double get thermometerLevel {
    switch (this) {
      case Temperature.freezing:
        return 0.1;
      case Temperature.cold:
        return 0.25;
      case Temperature.cool:
        return 0.4;
      case Temperature.warm:
        return 0.55;
      case Temperature.hot:
        return 0.75;
      case Temperature.boiling:
        return 0.9;
      case Temperature.correct:
        return 1.0;
    }
  }
}
