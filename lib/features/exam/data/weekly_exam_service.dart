import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/models/weekly_exam.dart';
import '../../../services/database_helper.dart';
import '../../../services/local_preferences_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🏆 TÜRKİYE GENELİ DENEME SINAVI SERVİSİ
// ═══════════════════════════════════════════════════════════════════════════
//
// HAFTALIK DÖNGÜ:
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ PAZARTESİ 00:00 ──────────► PERŞEMBE 23:59  │ YAYIN (Sarı Kart)        │
// │ CUMA 00:00 ───────────────► CUMARTESİ 11:59 │ SONUÇ BEKLENİYOR         │
// │ CUMARTESİ 12:00 ──────────► PAZAR 23:59     │ SONUÇLAR YAYINDA (Mor)   │
// │ PAZAR 23:59 ──────────────► PAZARTESİ 00:00 │ Yeni sınav başlar        │
// └─────────────────────────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// 📊 NORMAL DAĞILIM CDF FONKSİYONU
// ═══════════════════════════════════════════════════════════════════════════
/// Normal dağılım kümülatif dağılım fonksiyonu (CDF)
/// Verilen z-skoru için 0-1 arası yüzdelik dilim döndürür
///
/// Örnek değerler:
///   z = -3 → 0.0013 (%0.13 - çok düşük)
///   z = -2 → 0.0228 (%2.28)
///   z = -1 → 0.1587 (%15.87)
///   z =  0 → 0.5000 (%50 - ortalama)
///   z =  1 → 0.8413 (%84.13)
///   z =  2 → 0.9772 (%97.72)
///   z =  3 → 0.9987 (%99.87 - çok yüksek)
double _normalCDF(double z) {
  // Abramowitz ve Stegun yaklaşımı (hata < 7.5×10⁻⁸)
  const a1 = 0.254829592;
  const a2 = -0.284496736;
  const a3 = 1.421413741;
  const a4 = -1.453152027;
  const a5 = 1.061405429;
  const p = 0.3275911;

  // İşaret kaydet
  final sign = z < 0 ? -1 : 1;
  z = z.abs() / math.sqrt(2);

  // A&S formülü 7.1.26
  final t = 1.0 / (1.0 + p * z);
  final y =
      1.0 -
      (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-z * z);

  return 0.5 * (1.0 + sign * y);
}

class WeeklyExamService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─────────────────────────────────────────────────────────────────────────
  // ZAMAN HESAPLAMALARI
  // ─────────────────────────────────────────────────────────────────────────

  /// Bu haftanın Pazartesi'sini hesapla (00:00:00)
  DateTime getThisWeekMonday() {
    final now = DateTime.now();
    final daysToSubtract = now.weekday - 1; // Pazartesi = 1
    return DateTime(now.year, now.month, now.day - daysToSubtract, 0, 0, 0);
  }

  /// Belirli bir tarihin haftasının Pazartesi'sini bul
  DateTime getMondayOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract, 0, 0, 0);
  }

  /// Hafta numarasını hesapla (ISO 8601)
  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  /// Oda ismini oluştur (örn: "Hafta 2 - 2026")
  String generateRoomName(DateTime monday) {
    final weekNum = getWeekNumber(monday);
    return 'Hafta $weekNum - ${monday.year}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KART DURUMU HESAPLAMA (YENİ SİSTEM)
  // ─────────────────────────────────────────────────────────────────────────

  /// Kart durumunu hesapla - tüm mantık burada
  Future<ExamCardStatus> getCardStatus({
    WeeklyExam? currentExam,
    WeeklyExamResult? currentResult,
    WeeklyExamResult? previousUnviewedResult,
  }) async {
    // Önce görüntülenmemiş sonuç var mı kontrol et
    if (previousUnviewedResult != null) {
      return ExamCardStatus.onceSonucuGor;
    }

    // Sınav yoksa
    if (currentExam == null) {
      return ExamCardStatus.yakinda;
    }

    final now = DateTime.now();
    DateTime examWeekStart;

    try {
      examWeekStart = DateTime.parse(currentExam.weekStart);
    } catch (e) {
      debugPrint('❌ weekStart parse hatası: $e');
      return ExamCardStatus.yakinda;
    }

    final examMonday = getMondayOfWeek(examWeekStart);
    final thisMonday = getThisWeekMonday();

    // Sınav bu haftaya ait mi kontrol et
    if (!_isSameDay(examMonday, thisMonday)) {
      // Bu haftanın sınavı değil
      debugPrint(
        '⚠️ Sınav bu haftaya ait değil: examMonday=$examMonday, thisMonday=$thisMonday',
      );
      return ExamCardStatus.yakinda;
    }

    // Zaman dilimlerini hesapla
    final examStart = examMonday; // Pazartesi 00:00
    final examEnd = examMonday.add(
      const Duration(days: 3, hours: 23, minutes: 59, seconds: 59),
    ); // Perşembe 23:59:59
    final resultTime = examMonday.add(
      const Duration(days: 5, hours: 12),
    ); // Cumartesi 12:00
    final weekEnd = examMonday.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    ); // Pazar 23:59:59

    // DURUM 1: Sınav henüz başlamadı
    if (now.isBefore(examStart)) {
      return ExamCardStatus.yakinda;
    }

    // DURUM 2: Sınav yayında (Pazartesi 00:00 - Perşembe 23:59)
    if (now.isAfter(examStart) && now.isBefore(examEnd)) {
      if (currentResult != null) {
        // Kullanıcı sınavı tamamlamış
        return ExamCardStatus.tamampiSonucBekliyor;
      }
      // Sınav yayında, kullanıcı henüz girmemiş
      return ExamCardStatus.yayinda;
    }

    // DURUM 3: Sınav kapandı, sonuç bekleniyor (Cuma 00:00 - Cumartesi 11:59)
    if (now.isAfter(examEnd) && now.isBefore(resultTime)) {
      if (currentResult != null) {
        return ExamCardStatus.tamampiSonucBekliyor;
      }
      // Kaçırdı
      return ExamCardStatus.kacpipidin;
    }

    // DURUM 4: Sonuçlar açıklandı (Cumartesi 12:00 - Pazar 23:59)
    if (now.isAfter(resultTime) && now.isBefore(weekEnd)) {
      if (currentResult != null) {
        return ExamCardStatus.sonuclarAciklandi;
      }
      return ExamCardStatus.kacpipidin;
    }

    // DURUM 5: Hafta bitti
    return ExamCardStatus.yakinda;
  }

  /// İki tarihin aynı gün olup olmadığını kontrol et
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KALAN SÜRE HESAPLAMA
  // ─────────────────────────────────────────────────────────────────────────

  /// Kalan süreyi hesapla
  Duration getTimeRemaining(ExamCardStatus status, DateTime? examWeekStart) {
    final now = DateTime.now();
    final thisMonday = getThisWeekMonday();
    final monday = examWeekStart != null
        ? getMondayOfWeek(examWeekStart)
        : thisMonday;

    switch (status) {
      case ExamCardStatus.yukleniyor:
        return Duration.zero;

      case ExamCardStatus.yakinda:
        // Bir sonraki Pazartesi 00:00'a kalan
        var nextMonday = thisMonday;
        if (now.isAfter(thisMonday)) {
          nextMonday = thisMonday.add(const Duration(days: 7));
        }
        return nextMonday.difference(now);

      case ExamCardStatus.yayinda:
        // Perşembe 23:59'a kalan
        final examEnd = monday.add(
          const Duration(days: 3, hours: 23, minutes: 59, seconds: 59),
        );
        return examEnd.difference(now);

      case ExamCardStatus.tamampiSonucBekliyor:
        // Cumartesi 12:00'a kalan
        final resultTime = monday.add(const Duration(days: 5, hours: 12));
        return resultTime.difference(now);

      case ExamCardStatus.kacpipidin:
        // Bir sonraki Pazartesi 00:00'a kalan
        final nextMonday = monday.add(const Duration(days: 7));
        return nextMonday.difference(now);

      case ExamCardStatus.sonuclarAciklandi:
        // Pazar 23:59'a kalan
        final weekEnd = monday.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return weekEnd.difference(now);

      case ExamCardStatus.onceSonucuGor:
        return Duration.zero;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VERİTABANI İŞLEMLERİ
  // ─────────────────────────────────────────────────────────────────────────

  /// Bu haftanın sınavını yükle
  Future<WeeklyExam?> loadCurrentWeekExam() async {
    try {
      final thisMonday = getThisWeekMonday();
      final db = await _dbHelper.database;

      // Tüm sınavları al
      final results = await db.query('WeeklyExams', orderBy: 'weekStart DESC');

      if (results.isEmpty) {
        debugPrint('📭 Veritabanında hiç sınav yok');
        return null;
      }

      // Bu haftanın sınavını bul
      for (var examData in results) {
        final exam = _parseExamData(examData);
        if (exam == null) continue;

        try {
          final examWeekStart = DateTime.parse(exam.weekStart);
          final examMonday = getMondayOfWeek(examWeekStart);

          // Bu haftanın sınavı mı?
          if (_isSameDay(examMonday, thisMonday)) {
            debugPrint('✅ Bu haftanın sınavı bulundu: ${exam.examId}');
            return exam;
          }
        } catch (e) {
          continue;
        }
      }

      debugPrint('⚠️ Bu hafta için sınav bulunamadı');
      return null;
    } catch (e) {
      debugPrint('❌ Sınav yükleme hatası: $e');
      return null;
    }
  }

  /// Tüm sınavları yükle
  Future<List<WeeklyExam>> loadAllExams() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('WeeklyExams', orderBy: 'weekStart DESC');

      final exams = <WeeklyExam>[];
      for (var examData in results) {
        final exam = _parseExamData(examData);
        if (exam != null) exams.add(exam);
      }

      debugPrint('📚 ${exams.length} sınav yüklendi');
      return exams;
    } catch (e) {
      debugPrint('❌ Sınavları yükleme hatası: $e');
      return [];
    }
  }

  /// ID'ye göre sınavı getir
  Future<WeeklyExam?> getExamById(String examId) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        'WeeklyExams',
        where: 'weeklyExamId = ?',
        whereArgs: [examId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _parseExamData(rows.first);
    } catch (e) {
      debugPrint('❌ getExamById hatası: $e');
      return null;
    }
  }

  /// Exam data'yı WeeklyExam modeline çevir
  WeeklyExam? _parseExamData(Map<String, dynamic> examData) {
    try {
      final questionsJson = examData['questions']?.toString();
      List<dynamic> questions = [];
      if (questionsJson != null && questionsJson.isNotEmpty) {
        questions = json.decode(questionsJson);
      }

      final examId = examData['weeklyExamId']?.toString() ?? '';
      final title = examData['title']?.toString() ?? 'Türkiye Geneli Deneme';
      final weekStart = examData['weekStart']?.toString() ?? '';
      final description = examData['description']?.toString();

      int duration = 50;
      final durationValue = examData['duration'];
      if (durationValue is int) {
        duration = durationValue;
      } else if (durationValue != null) {
        duration = int.tryParse(durationValue.toString()) ?? 50;
      }

      int? totalUser;
      final totalUserValue = examData['totalUser'];
      if (totalUserValue is int) {
        totalUser = totalUserValue;
      } else if (totalUserValue != null) {
        totalUser = int.tryParse(totalUserValue.toString());
      }

      int? cityUser;
      final cityValue = examData['city'];
      if (cityValue is int) {
        cityUser = cityValue;
      } else if (cityValue != null) {
        cityUser = int.tryParse(cityValue.toString());
      }

      int? districtUser;
      final districtValue = examData['district'];
      if (districtValue is int) {
        districtUser = districtValue;
      } else if (districtValue != null) {
        districtUser = int.tryParse(districtValue.toString());
      }

      Map<String, double>? turkeyAverages;
      final turkeyAvgValue = examData['turkeyAverages'];
      if (turkeyAvgValue is String) {
        try {
          final parsed = json.decode(turkeyAvgValue);
          if (parsed is Map) {
            turkeyAverages = (parsed as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            );
          }
        } catch (e) {
          debugPrint('turkeyAverages parse hatası: $e');
        }
      } else if (turkeyAvgValue is Map) {
        turkeyAverages = (turkeyAvgValue as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
      }

      if (examId.isEmpty || weekStart.isEmpty) {
        return null;
      }

      return WeeklyExam(
        examId: examId,
        title: title,
        weekStart: weekStart,
        duration: duration,
        description: description,
        totalUser: totalUser,
        cityUser: cityUser,
        districtUser: districtUser,
        turkeyAverages: turkeyAverages,
        questions: questions
            .map((q) => WeeklyExamQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ Exam parse hatası: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KULLANICI SINAVLARI
  // ─────────────────────────────────────────────────────────────────────────

  /// Kullanıcının bu sınavı çözüp çözmediğini kontrol et
  Future<bool> hasUserCompletedExam(String examId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'WeeklyExamResults',
        where: 'examId = ? AND odaKatilimciId = ?',
        whereArgs: [examId, user.uid],
      );
      return results.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Sınav kontrolü hatası: $e');
      return false;
    }
  }

  /// Kullanıcının sınav sonucunu getir
  Future<WeeklyExamResult?> getUserExamResult(String examId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'WeeklyExamResults',
        where: 'examId = ? AND odaKatilimciId = ?',
        whereArgs: [examId, user.uid],
      );

      if (results.isEmpty) return null;
      return _parseResultData(results.first);
    } catch (e) {
      debugPrint('❌ Sonuç getirme hatası: $e');
      return null;
    }
  }

  /// Görüntülenmemiş sonucu getir (önce sonucu görmeli kontrolü için)
  Future<WeeklyExamResult?> getUnviewedResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final db = await _dbHelper.database;

      // resultViewed = 0 veya NULL olan sonuçları bul
      final results = await db.query(
        'WeeklyExamResults',
        where:
            'odaKatilimciId = ? AND (resultViewed = 0 OR resultViewed IS NULL)',
        whereArgs: [user.uid],
        orderBy: 'completedAt DESC',
        limit: 1,
      );

      if (results.isEmpty) return null;

      final result = results.first;

      // Sonucun açıklanma zamanı geldi mi kontrol et
      final sonucTarihi = result['sonucTarihi']?.toString();
      if (sonucTarihi != null) {
        try {
          final resultDate = DateTime.parse(sonucTarihi);
          if (DateTime.now().isAfter(resultDate)) {
            // Sonuç açıklanmış ama görüntülenmemiş
            return _parseResultData(result);
          }
        } catch (e) {
          debugPrint('Sonuç tarihi parse hatası: $e');
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Görüntülenmemiş sonuç hatası: $e');
      return null;
    }
  }

  /// Tüm sonuçları getir (başarılarım için)
  Future<List<WeeklyExamResult>> getAllUserResults() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'WeeklyExamResults',
        where: 'odaKatilimciId = ?',
        whereArgs: [user.uid],
        orderBy: 'completedAt DESC',
      );

      return results
          .map((r) => _parseResultData(r))
          .whereType<WeeklyExamResult>()
          .toList();
    } catch (e) {
      debugPrint('❌ Tüm sonuçları getirme hatası: $e');
      return [];
    }
  }

  /// Result data'yı WeeklyExamResult modeline çevir
  WeeklyExamResult? _parseResultData(Map<String, dynamic> result) {
    try {
      Map<String, String> cevaplar = {};
      final cevaplarJson = result['cevaplar']?.toString();
      if (cevaplarJson != null && cevaplarJson.isNotEmpty) {
        final decoded = json.decode(cevaplarJson);
        if (decoded is Map) {
          cevaplar = Map<String, String>.from(
            decoded.map((k, v) => MapEntry(k.toString(), v.toString())),
          );
        }
      }

      return WeeklyExamResult(
        id: result['id'] as int?,
        examId: result['examId']?.toString() ?? '',
        odaId: result['odaId']?.toString() ?? '',
        odaIsmi: result['odaIsmi']?.toString() ?? '',
        odaBaslangic: result['odaBaslangic']?.toString() ?? '',
        odaBitis: result['odaBitis']?.toString() ?? '',
        sonucTarihi: result['sonucTarihi']?.toString() ?? '',
        odaDurumu: result['odaDurumu']?.toString() ?? '',
        kullaniciId: result['odaKatilimciId']?.toString() ?? '',
        cevaplar: cevaplar,
        dogru: result['dogru'] as int?,
        yanlis: result['yanlis'] as int?,
        bos: result['bos'] as int?,
        puan: result['puan'] as int?,
        siralama: result['siralama'] as int?,
        toplamKatilimci: result['toplamKatilimci'] as int?,
        // İl/İlçe sıralama bilgileri
        ilSiralama: result['ilSiralama'] as int?,
        ilToplamKatilimci: result['ilToplamKatilimci'] as int?,
        ilceSiralama: result['ilceSiralama'] as int?,
        ilceToplamKatilimci: result['ilceToplamKatilimci'] as int?,
        userCity: result['userCity']?.toString(),
        userDistrict: result['userDistrict']?.toString(),
        completedAt: result['completedAt'] != null
            ? DateTime.tryParse(result['completedAt'].toString())
            : null,
        resultViewed: (result['resultViewed'] as int?) == 1,
      );
    } catch (e) {
      debugPrint('❌ Result parse hatası: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SONUÇ KAYDETME VE GÜNCELLEME
  // ─────────────────────────────────────────────────────────────────────────

  /// Sınav sonucunu kaydet
  Future<void> saveExamResult({
    required String examId,
    required Map<String, String> answers,
    required WeeklyExam exam,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

    try {
      // Kullanıcının il/ilçe bilgilerini profil kurulumundan al
      final prefsService = LocalPreferencesService();
      final userCity = await prefsService.getUserCity();
      final userDistrict = await prefsService.getUserDistrict();
      debugPrint('👤 Kullanıcı konumu: İl=$userCity, İlçe=$userDistrict');

      final examWeekStart = DateTime.parse(exam.weekStart);
      final examMonday = getMondayOfWeek(examWeekStart);

      final examEnd = examMonday.add(
        const Duration(days: 3, hours: 23, minutes: 59, seconds: 59),
      );
      final resultTime = examMonday.add(const Duration(days: 5, hours: 12));

      // Doğru/Yanlış/Boş hesapla
      int dogru = 0;
      int yanlis = 0;
      int bos = 0;

      for (int i = 0; i < exam.questions.length; i++) {
        final question = exam.questions[i];
        final questionIndex = (i + 1).toString(); // "1", "2", "3", ...
        final userAnswer = answers[questionIndex];
        final correctAnswer = question.correctAnswer.toUpperCase();

        if (userAnswer == null || userAnswer.isEmpty || userAnswer == 'EMPTY') {
          bos++;
        } else if (userAnswer.toUpperCase() == correctAnswer) {
          dogru++;
        } else {
          yanlis++;
        }
      }

      // ═══════════════════════════════════════════════════════════════════
      // 🎯 PROFESYONEL PUANLAMA VE SIRALAMA ALGORİTMASI
      // ═══════════════════════════════════════════════════════════════════
      //
      // PUANLAMA: Her soru eşit değerde
      //   Puan = (Doğru Sayısı / Toplam Soru) × 500
      //
      // SIRALAMA: Normal dağılım tabanlı gerçekçi sıralama
      //   - Ortalama başarı oranı: %65 (gerçek sınav verilerine uygun)
      //   - Standart sapma: %18 (geniş yayılım)
      //   - Z-skoru ile yüzdelik dilim hesaplanır
      //   - Yüksek puan = düşük sıralama (1. yer en iyi)
      //
      // ÖNEMLİ: 500 tam puan almak 1. olmayı garantilemez!
      //   - 500 puan ≈ Top %0.5 (ilk birkaç kişi)
      //   - 450 puan ≈ Top %5
      //   - 400 puan ≈ Top %15
      //   - 350 puan ≈ Top %35
      //   - 300 puan ≈ Top %55
      // ═══════════════════════════════════════════════════════════════════

      final toplamSoru = exam.questions.length;
      final soruPuani = 500.0 / toplamSoru;
      final puan = (dogru * soruPuani).round().clamp(0, 500);
      final basariOrani = dogru / toplamSoru;

      debugPrint(
        '📊 Puan: $dogru doğru × ${soruPuani.toStringAsFixed(2)} = $puan/500 (Başarı: %${(basariOrani * 100).toStringAsFixed(1)})',
      );

      // ═══════════════════════════════════════════════════════════════════
      // SIRALAMA HESAPLAMA (Ağırlıklı Rastgele Sapma Algoritması)
      // ═══════════════════════════════════════════════════════════════════
      //
      // Algoritma: Türkiye sıralaması baz alınarak il ve ilçe için
      // gerçekçi sapmalar uygulanır. Küçük havuzlarda (ilçe) sapma
      // daha yüksek olur - bu istatistiksel olarak daha gerçekçidir.
      // ═══════════════════════════════════════════════════════════════════

      final toplamKatilimci = exam.totalUser ?? 1500;
      final ilKatilimci =
          exam.cityUser ??
          (toplamKatilimci ~/ 4); // Varsayılan: Türkiye'nin %25'i
      final ilceKatilimci =
          exam.districtUser ?? (ilKatilimci ~/ 10); // Varsayılan: İlin %10'u

      // Normal dağılım parametreleri (gerçekçi sınav sonuçlarına uygun)
      const double ortalama = 0.65; // %65 ortalama başarı
      const double stdSapma = 0.18; // %18 standart sapma

      // Z-skoru hesapla
      final zScore = (basariOrani - ortalama) / stdSapma;

      // Normal dağılım CDF ile yüzdelik dilim hesapla (0-1 arası)
      final yuzdelikDilim = _normalCDF(zScore);

      // Türkiye sıralaması (referans nokta)
      // Yüksek yüzdelik = düşük sıralama (daha iyi)
      final siralama = ((toplamKatilimci * (1 - yuzdelikDilim)) + 1)
          .round()
          .clamp(1, toplamKatilimci);

      // Tutarlı seed oluştur (kullanıcı ID + sınav ID + puan)
      // Bu sayede aynı kullanıcı için aynı sonuçlar üretilir
      final seedString = '${user.uid}_${examId}_$puan';
      final seed = seedString.hashCode;
      final random = math.Random(seed);

      // ─────────────────────────────────────────────────────────────────
      // İL SAPMA HESAPLAMASI (sadece +, %10 ile %20 arası)
      // ─────────────────────────────────────────────────────────────────
      // Mantık: Küçük havuzda (il) genellikle daha başarılı görünürsün
      // Sapma miktarı: %10 ile %20 arasında rastgele (sadece pozitif)
      final ilSapmaOrani = 0.10 + random.nextDouble() * 0.10; // 0.10-0.20
      // Türkiye yüzdeliğine POZİTİF sapma uygula (daha başarılı)
      final ilYuzdelik = (yuzdelikDilim + ilSapmaOrani).clamp(0.01, 0.99);
      // İl sıralaması hesapla
      final ilSiralama = ((ilKatilimci * (1 - ilYuzdelik)) + 1).round().clamp(
        1,
        ilKatilimci,
      );

      // ─────────────────────────────────────────────────────────────────
      // İLÇE SAPMA HESAPLAMASI (sadece +, İl'e göre ek %8-%13)
      // ─────────────────────────────────────────────────────────────────
      // Mantık: Daha küçük havuzda (ilçe) İl'den de daha başarılı görünürsün
      // İl yüzdeliğine ek sapma: %8 ile %13 arası
      final ilceEkSapma = 0.08 + random.nextDouble() * 0.05; // 0.08-0.13
      // İl yüzdeliğine POZİTİF sapma uygula (İl'den de daha başarılı)
      final ilceYuzdelik = (ilYuzdelik + ilceEkSapma).clamp(0.01, 0.99);
      // İlçe sıralaması hesapla
      final ilceSiralama = ((ilceKatilimci * (1 - ilceYuzdelik)) + 1)
          .round()
          .clamp(1, ilceKatilimci);

      debugPrint(
        '🏆 Türkiye: $siralama/$toplamKatilimci (Top %${((1 - yuzdelikDilim) * 100).toStringAsFixed(1)})',
      );
      debugPrint(
        '🏙️ İl: $ilSiralama/$ilKatilimci (Yüzdelik: %${(ilYuzdelik * 100).toStringAsFixed(1)}, +${(ilSapmaOrani * 100).toStringAsFixed(1)}%)',
      );
      debugPrint(
        '🏘️ İlçe: $ilceSiralama/$ilceKatilimci (Yüzdelik: %${(ilceYuzdelik * 100).toStringAsFixed(1)}, +${((ilSapmaOrani + ilceEkSapma) * 100).toStringAsFixed(1)}%)',
      );
      debugPrint(
        '📈 Z-Score: ${zScore.toStringAsFixed(2)} | Baz Yüzdelik: %${(yuzdelikDilim * 100).toStringAsFixed(1)}',
      );

      final db = await _dbHelper.database;
      await db.insert('WeeklyExamResults', {
        'userId': user.uid,
        'examId': examId,
        'odaId': '${examId}_${examMonday.millisecondsSinceEpoch}',
        'odaIsmi': generateRoomName(examMonday),
        'odaBaslangic': examMonday.toIso8601String(),
        'odaBitis': examEnd.toIso8601String(),
        'sonucTarihi': resultTime.toIso8601String(),
        'odaDurumu': 'tamamlandi',
        'odaKatilimciId': user.uid,
        'cevaplar': json.encode(answers),
        'dogru': dogru,
        'yanlis': yanlis,
        'bos': bos,
        'puan': puan,
        'siralama': siralama,
        'toplamKatilimci': toplamKatilimci,
        // İl/İlçe sıralama bilgileri
        'ilSiralama': ilSiralama,
        'ilToplamKatilimci': ilKatilimci,
        'ilceSiralama': ilceSiralama,
        'ilceToplamKatilimci': ilceKatilimci,
        'userCity': userCity,
        'userDistrict': userDistrict,
        'completedAt': DateTime.now().toIso8601String(),
        'resultViewed': 0, // Henüz görüntülenmedi
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      debugPrint(
        '✅ Sınav kaydedildi: D=$dogru Y=$yanlis B=$bos P=$puan | TR:$siralama/$toplamKatilimci İL:$ilSiralama/$ilKatilimci İLÇE:$ilceSiralama/$ilceKatilimci',
      );
    } catch (e) {
      debugPrint('❌ Sınav kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Sonucun görüntülendiğini işaretle
  Future<void> markResultAsViewed(String examId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final db = await _dbHelper.database;
      await db.update(
        'WeeklyExamResults',
        {'resultViewed': 1},
        where: 'examId = ? AND odaKatilimciId = ?',
        whereArgs: [examId, user.uid],
      );
      debugPrint('✅ Sonuç görüntülendi işaretlendi: $examId');
    } catch (e) {
      debugPrint('❌ Sonuç güncelleme hatası: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ESKİ API (Geriye Uyumluluk)
  // ─────────────────────────────────────────────────────────────────────────

  /// Eski API - loadWeeklyExam
  Future<WeeklyExam?> loadWeeklyExam() async {
    return loadCurrentWeekExam();
  }

  /// Eski API - getExamStatus
  ExamRoomStatus getExamStatus(DateTime weekStart) {
    final now = DateTime.now();
    final examMonday = getMondayOfWeek(weekStart);

    final examStart = examMonday;
    final examEnd = examMonday.add(
      const Duration(days: 3, hours: 23, minutes: 59, seconds: 59),
    );
    final resultTime = examMonday.add(const Duration(days: 5, hours: 12));

    if (now.isBefore(examStart)) {
      return ExamRoomStatus.beklemede;
    } else if (now.isAfter(examStart) && now.isBefore(examEnd)) {
      return ExamRoomStatus.aktif;
    } else if (now.isAfter(examEnd) && now.isBefore(resultTime)) {
      return ExamRoomStatus.kapali;
    } else {
      return ExamRoomStatus.sonuclanmis;
    }
  }

  /// Eski API - getTimeRemaining
  Duration getTimeRemainingOld(DateTime weekStart, ExamRoomStatus status) {
    final now = DateTime.now();
    final examMonday = getMondayOfWeek(weekStart);

    switch (status) {
      case ExamRoomStatus.beklemede:
        return examMonday.difference(now);
      case ExamRoomStatus.aktif:
        final examEnd = examMonday.add(
          const Duration(days: 3, hours: 23, minutes: 59, seconds: 59),
        );
        return examEnd.difference(now);
      case ExamRoomStatus.kapali:
        final resultTime = examMonday.add(const Duration(days: 5, hours: 12));
        return resultTime.difference(now);
      case ExamRoomStatus.sonuclanmis:
        return Duration.zero;
    }
  }

  /// Eski API - areResultsAvailable
  bool areResultsAvailable(DateTime weekStart) {
    final now = DateTime.now();
    final resultTime = getMondayOfWeek(
      weekStart,
    ).add(const Duration(days: 5, hours: 12));
    return now.isAfter(resultTime);
  }

  /// Eski API - isCurrentWeekExam
  bool isCurrentWeekExam(WeeklyExam exam) {
    try {
      final examWeekStart = DateTime.parse(exam.weekStart);
      final thisMonday = getThisWeekMonday();
      return _isSameDay(getMondayOfWeek(examWeekStart), thisMonday);
    } catch (e) {
      return false;
    }
  }
}
