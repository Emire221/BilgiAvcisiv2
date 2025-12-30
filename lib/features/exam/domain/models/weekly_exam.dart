import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_exam.freezed.dart';
part 'weekly_exam.g.dart';

/// Haftalık sınav modeli - haftalik_sinav.json yapısı
@freezed
class WeeklyExam with _$WeeklyExam {
  const factory WeeklyExam({
    /// JSON'da weeklyExamId olarak gelir
    required String examId,
    required String title,
    required String weekStart, // Pazartesi tarihi (ISO 8601)
    required int duration, // Dakika cinsinden
    required List<WeeklyExamQuestion> questions,
    String? description,
  }) = _WeeklyExam;

  /// Özel fromJson - weeklyExamId -> examId dönüşümü yapar
  factory WeeklyExam.fromJson(Map<String, dynamic> json) {
    // weeklyExamId -> examId dönüşümü
    final examId = json['examId'] as String? ?? json['weeklyExamId'] as String;

    return _$WeeklyExamImpl(
      examId: examId,
      title: json['title'] as String,
      weekStart: json['weekStart'] as String,
      duration: json['duration'] as int,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => WeeklyExamQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
    );
  }
}

/// Haftalık sınav sorusu
@freezed
class WeeklyExamQuestion with _$WeeklyExamQuestion {
  const factory WeeklyExamQuestion({
    required String questionId,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer, // "A", "B", "C" veya "D"
    String? topicId,
    String? lessonName,
  }) = _WeeklyExamQuestion;

  factory WeeklyExamQuestion.fromJson(Map<String, dynamic> json) =>
      _$WeeklyExamQuestionFromJson(json);
}

/// Haftalık sınav sonucu - Kullanıcının cevapları
@freezed
class WeeklyExamResult with _$WeeklyExamResult {
  const factory WeeklyExamResult({
    int? id,
    required String examId,
    required String odaId, // Sınav oturumu ID'si
    required String odaIsmi, // "Hafta 45 - 2025" gibi
    required String odaBaslangic, // ISO 8601
    required String odaBitis, // ISO 8601 (Çarşamba 23:59)
    required String sonucTarihi, // Pazar 12:00
    required String odaDurumu, // "aktif", "kapali", "sonuclanmis"
    required String kullaniciId,
    required Map<String, String> cevaplar, // {"1": "A", "2": "EMPTY"}
    int? dogru,
    int? yanlis,
    int? bos,
    int? puan,
    int? siralama, // Türkiye sıralaması
    int? toplamKatilimci,
    DateTime? completedAt,
  }) = _WeeklyExamResult;

  factory WeeklyExamResult.fromJson(Map<String, dynamic> json) =>
      _$WeeklyExamResultFromJson(json);
}

/// Sınav durumu enum
enum ExamRoomStatus {
  beklemede, // Pazartesi öncesi
  aktif, // Pazartesi-Çarşamba arası
  kapali, // Çarşamba-Pazar arası (sınav girişi kapalı)
  sonuclanmis, // Pazar 20:00 sonrası
}

/// Sınav durumu extension
extension ExamRoomStatusExtension on ExamRoomStatus {
  String get label {
    switch (this) {
      case ExamRoomStatus.beklemede:
        return 'Yakında Başlayacak';
      case ExamRoomStatus.aktif:
        return 'Sınav Aktif!';
      case ExamRoomStatus.kapali:
        return 'Sonuçlar Bekleniyor';
      case ExamRoomStatus.sonuclanmis:
        return 'Sonuçlar Açıklandı';
    }
  }

  String get motivationMessage {
    switch (this) {
      case ExamRoomStatus.beklemede:
        return 'Sınava hazır mısın? Pazartesi başlıyor!';
      case ExamRoomStatus.aktif:
        return 'Hadi sınava gir! Çarşambaya kadar vaktin var.';
      case ExamRoomStatus.kapali:
        return 'Sonuçlar Pazar 12:00\'da açıklanacak!';
      case ExamRoomStatus.sonuclanmis:
        return 'Tüm Türkiye\'de kaçıncı sıradasın, baktın mı?';
    }
  }
}
