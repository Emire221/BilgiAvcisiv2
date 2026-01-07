// ═══════════════════════════════════════════════════════════════════════════
// 📚 DERS AĞIRLIKLARI (LESSON WEIGHTS)
// ═══════════════════════════════════════════════════════════════════════════
//
// Haftalık sınavlarda derslerin zorluk derecesine göre ağırlıklandırma yapılır.
// Daha zor derslerden alınan doğrular daha değerlidir.
//
// Ağırlık Sistemi:
// • 1.5 = Çok Zor (Matematik)
// • 1.4 = Zor (Fen Bilgisi)
// • 1.3 = Orta-Zor (İngilizce)
// • 1.2 = Orta (T.C İnkılap Tarihi ve Atatürkçülük)
// • 1.1 = Normal (Türkçe)
// • 1.0 = Standart (Sosyal Bilgiler)
// • 0.9 = Kolay (Hayat Bilgisi)
//
// ═══════════════════════════════════════════════════════════════════════════

class LessonWeights {
  LessonWeights._();

  /// Ders ağırlıkları
  static const Map<String, double> weights = {
    // Matematik - En zor ders
    'Matematik': 1.5,

    // Fen Bilgisi - Çok zor
    'Fen Bilgisi': 1.4,

    // İngilizce - Zor
    'İngilizce': 1.3,
    'English': 1.3, // Alternatif isim
    // T.C İnkılap Tarihi - Orta-Zor
    'T.C İnkılap Tarihi ve Atatürkçülük': 1.2,
    'İnkılap Tarihi': 1.2, // Kısa isim
    // Türkçe - Normal
    'Türkçe': 1.1,

    // Sosyal Bilgiler - Standart
    'Sosyal Bilgiler': 1.0,

    // Hayat Bilgisi - Kolay (3. sınıflar için)
    'Hayat Bilgisi': 0.9,
  };

  /// Ders adına göre ağırlık döndürür
  /// Bilinmeyen dersler için varsayılan 1.0 döner
  static double getWeight(String? lessonName) {
    if (lessonName == null || lessonName.isEmpty) return 1.0;

    // Tam eşleşme ara
    if (weights.containsKey(lessonName)) {
      return weights[lessonName]!;
    }

    // Kısmi eşleşme ara (case-insensitive)
    final lowerLessonName = lessonName.toLowerCase();

    if (lowerLessonName.contains('matematik') ||
        lowerLessonName.contains('math')) {
      return weights['Matematik']!;
    }
    if (lowerLessonName.contains('fen')) {
      return weights['Fen Bilgisi']!;
    }
    if (lowerLessonName.contains('ingilizce') ||
        lowerLessonName.contains('english')) {
      return weights['İngilizce']!;
    }
    if (lowerLessonName.contains('inkılap') ||
        lowerLessonName.contains('atatürk')) {
      return weights['T.C İnkılap Tarihi ve Atatürkçülük']!;
    }
    if (lowerLessonName.contains('türkçe') ||
        lowerLessonName.contains('turkce')) {
      return weights['Türkçe']!;
    }
    if (lowerLessonName.contains('sosyal')) {
      return weights['Sosyal Bilgiler']!;
    }
    if (lowerLessonName.contains('hayat')) {
      return weights['Hayat Bilgisi']!;
    }

    // Bilinmeyen ders için varsayılan
    return 1.0;
  }

  /// Bir soru listesinden maksimum ağırlıklı puanı hesaplar
  static double calculateMaxWeightedScore(List<String?> lessons) {
    double total = 0.0;
    for (var lesson in lessons) {
      total += getWeight(lesson);
    }
    return total;
  }

  /// Ders başına toplam soru sayısını hesaplar
  static Map<String, int> calculateSubjectTotals(List<String?> lessons) {
    final totals = <String, int>{};
    for (var lesson in lessons) {
      if (lesson != null && lesson.isNotEmpty) {
        totals[lesson] = (totals[lesson] ?? 0) + 1;
      }
    }
    return totals;
  }

  /// Ders bazlı ağırlıklı net puanı hesaplar
  ///
  /// [subjectScores]: Her dersten kaç doğru yapıldığı (ders adı -> doğru sayısı)
  /// [subjectTotals]: Her derste toplam kaç soru olduğu (ders adı -> toplam soru)
  ///
  /// Returns: Ağırlıklı toplam puan
  static double calculateWeightedScore(
    Map<String, int> subjectScores,
    Map<String, int> subjectTotals,
  ) {
    double totalWeightedScore = 0.0;

    subjectScores.forEach((lesson, correctCount) {
      final weight = getWeight(lesson);
      final lessonTotal = subjectTotals[lesson] ?? 1;

      // Her dersin katkısı = (doğru_sayısı / toplam_soru) * ağırlık
      final lessonContribution = (correctCount / lessonTotal) * weight;
      totalWeightedScore += lessonContribution;
    });

    return totalWeightedScore;
  }

  /// Ağırlık tablosunu metin olarak döndürür (debug için)
  static String getWeightsTable() {
    final buffer = StringBuffer();
    buffer.writeln('📚 Ders Ağırlıkları:');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final sortedWeights = weights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedWeights) {
      final stars = '⭐' * (entry.value * 2).round();
      buffer.writeln('${entry.key.padRight(40)} × ${entry.value} $stars');
    }

    return buffer.toString();
  }
}
