import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/models/weekly_exam.dart';
import '../../../services/database_helper.dart';

/// Haftalık sınav servisi - Zamana duyarlı sınav yönetimi
class WeeklyExamService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Sınav odasının mevcut durumunu hesapla
  ExamRoomStatus getExamStatus(DateTime weekStart) {
    final now = DateTime.now();

    // Pazartesi 00:00
    final examStart = DateTime(weekStart.year, weekStart.month, weekStart.day);

    // Çarşamba 23:59:59
    final examEnd = examStart.add(
      const Duration(days: 2, hours: 23, minutes: 59, seconds: 59),
    );

    // Pazar 12:00
    final resultTime = examStart.add(const Duration(days: 6, hours: 12));

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

  /// Bu hafta Pazartesi tarihini hesapla
  DateTime getThisWeekMonday() {
    final now = DateTime.now();
    // Pazartesi = 1, Pazar = 7
    final daysToSubtract = now.weekday - 1;
    return DateTime(now.year, now.month, now.day - daysToSubtract);
  }

  /// Hafta numarasını hesapla
  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  /// Oda ismini oluştur (örn: "Hafta 45 - 2025")
  String generateRoomName(DateTime weekStart) {
    final weekNum = getWeekNumber(weekStart);
    return 'Hafta $weekNum - ${weekStart.year}';
  }

  /// Veritabanından haftalık sınavı yükle
  Future<WeeklyExam?> loadWeeklyExam() async {
    try {
      // Önce veritabanından en son sınavı kontrol et
      final examData = await _dbHelper.getLatestWeeklyExam();

      if (examData != null) {
        // questions JSON string olarak saklandığı için decode et
        final questionsJson = examData['questions'] as String?;
        List<dynamic> questions = [];
        if (questionsJson != null && questionsJson.isNotEmpty) {
          questions = json.decode(questionsJson);
        }

        return WeeklyExam(
          examId: examData['weeklyExamId'] as String,
          title: examData['title'] as String? ?? 'Haftalık Sınav',
          weekStart: examData['weekStart'] as String? ?? '',
          duration: examData['duration'] as int? ?? 30,
          description: examData['description'] as String?,
          questions: questions
              .map((q) => WeeklyExamQuestion.fromJson(q))
              .toList(),
        );
      }

      // Database'de yoksa dosya sisteminde ara (eski yöntem)
      final directory = await getApplicationDocumentsDirectory();

      // Kullanıcının sınıfına göre klasör adını bul
      // Örn: 3_Sinif, 4_Sinif vs.
      final dirList = directory.listSync();

      for (var entity in dirList) {
        if (entity is Directory) {
          final examFile = File('${entity.path}/haftalik_sinav.json');
          if (await examFile.exists()) {
            final jsonString = await examFile.readAsString();
            final jsonData = json.decode(jsonString);
            return WeeklyExam.fromJson(jsonData);
          }
        }
      }

      // Doğrudan kök dizinde de kontrol et
      final rootExamFile = File('${directory.path}/haftalik_sinav.json');
      if (await rootExamFile.exists()) {
        final jsonString = await rootExamFile.readAsString();
        final jsonData = json.decode(jsonString);
        return WeeklyExam.fromJson(jsonData);
      }

      if (kDebugMode) debugPrint('haftalik_sinav.json bulunamadı');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Haftalık sınav yükleme hatası: $e');
      return null;
    }
  }

  /// Kullanıcının bu haftaki sınavı çözüp çözmediğini kontrol et
  Future<bool> hasUserCompletedExam(String examId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final db = await _dbHelper.database;
    final results = await db.query(
      'WeeklyExamResults',
      where: 'examId = ? AND odaKatilimciId = ?',
      whereArgs: [examId, user.uid],
    );

    return results.isNotEmpty;
  }

  /// Kullanıcının sınav sonucunu getir
  Future<WeeklyExamResult?> getUserExamResult(String examId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final db = await _dbHelper.database;
    final results = await db.query(
      'WeeklyExamResults',
      where: 'examId = ? AND odaKatilimciId = ?',
      whereArgs: [examId, user.uid],
    );

    if (results.isEmpty) return null;

    final result = results.first;
    return WeeklyExamResult(
      id: result['id'] as int?,
      examId: result['examId'] as String,
      odaId: result['odaId'] as String,
      odaIsmi: result['odaIsmi'] as String,
      odaBaslangic: result['odaBaslangic'] as String,
      odaBitis: result['odaBitis'] as String,
      sonucTarihi: result['sonucTarihi'] as String,
      odaDurumu: result['odaDurumu'] as String,
      kullaniciId: result['odaKatilimciId'] as String,
      cevaplar: json.decode(result['cevaplar'] as String),
      dogru: result['dogru'] as int?,
      yanlis: result['yanlis'] as int?,
      bos: result['bos'] as int?,
      puan: result['puan'] as int?,
      siralama: result['siralama'] as int?,
      toplamKatilimci: result['toplamKatilimci'] as int?,
      completedAt: result['completedAt'] != null
          ? DateTime.parse(result['completedAt'] as String)
          : null,
    );
  }

  /// Sınav sonucunu kaydet
  Future<void> saveExamResult({
    required String examId,
    required Map<String, String> answers,
    required WeeklyExam exam,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

    final weekStart = getThisWeekMonday();
    final examEnd = weekStart.add(
      const Duration(days: 2, hours: 23, minutes: 59, seconds: 59),
    );
    final resultTime = weekStart.add(const Duration(days: 6, hours: 12));

    // Doğru/Yanlış/Boş hesapla
    int dogru = 0;
    int yanlis = 0;
    int bos = 0;

    for (int i = 0; i < exam.questions.length; i++) {
      final questionId = (i + 1).toString();
      final userAnswer = answers[questionId];
      final correctAnswer = exam.questions[i].correctAnswer;

      if (userAnswer == null || userAnswer == 'EMPTY') {
        bos++;
      } else if (userAnswer == correctAnswer) {
        dogru++;
      } else {
        yanlis++;
      }
    }

    // 500 tam puan üzerinden hesaplama
    // Her soru eşit puanlı: 500 / soru sayısı
    // Yanlış cevap 1/4 doğruyu götürür
    final soruPuani = 500.0 / exam.questions.length;
    final net = dogru - (yanlis / 4);
    final puan = (net * soruPuani).round().clamp(0, 500);

    final db = await _dbHelper.database;
    await db.insert('WeeklyExamResults', {
      'examId': examId,
      'odaId': '${examId}_${weekStart.millisecondsSinceEpoch}',
      'odaIsmi': generateRoomName(weekStart),
      'odaBaslangic': weekStart.toIso8601String(),
      'odaBitis': examEnd.toIso8601String(),
      'sonucTarihi': resultTime.toIso8601String(),
      'odaDurumu': 'kapali',
      'odaKatilimciId': user.uid,
      'cevaplar': json.encode(answers),
      'dogru': dogru,
      'yanlis': yanlis,
      'bos': bos,
      'puan': puan,
      'siralama': null, // Pazar günü hesaplanacak
      'toplamKatilimci': null,
      'completedAt': DateTime.now().toIso8601String(),
    });

    debugPrint(
      'Sınav sonucu kaydedildi: Doğru=$dogru, Yanlış=$yanlis, Boş=$bos, Puan=$puan',
    );
  }

  /// Sonuçlar açıklandı mı kontrol et (Pazar 12:00)
  bool areResultsAvailable(DateTime weekStart) {
    final now = DateTime.now();
    final resultTime = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6, // Pazar
      12, // 12:00
    );
    return now.isAfter(resultTime);
  }

  /// Kalan süreyi hesapla
  Duration getTimeRemaining(DateTime weekStart, ExamRoomStatus status) {
    final now = DateTime.now();

    switch (status) {
      case ExamRoomStatus.beklemede:
        // Pazartesi 00:00'a kalan süre
        final examStart = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        );
        return examStart.difference(now);

      case ExamRoomStatus.aktif:
        // Çarşamba 23:59'a kalan süre
        final examEnd = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + 2,
          23,
          59,
          59,
        );
        return examEnd.difference(now);

      case ExamRoomStatus.kapali:
        // Pazar 12:00'a kalan süre
        final resultTime = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + 6,
          12,
        );
        return resultTime.difference(now);

      case ExamRoomStatus.sonuclanmis:
        return Duration.zero;
    }
  }

  /// Bu haftanın sınavı mı kontrol et
  bool isCurrentWeekExam(WeeklyExam exam) {
    try {
      final examWeekStart = DateTime.parse(exam.weekStart);
      final thisWeekMonday = getThisWeekMonday();

      // Aynı hafta mı kontrol et (yıl, ay, gün)
      return examWeekStart.year == thisWeekMonday.year &&
          examWeekStart.month == thisWeekMonday.month &&
          examWeekStart.day == thisWeekMonday.day;
    } catch (e) {
      if (kDebugMode) debugPrint('Tarih parse hatası: $e');
      return false;
    }
  }
}

