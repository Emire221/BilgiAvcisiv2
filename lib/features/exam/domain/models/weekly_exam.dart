import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_exam.freezed.dart';
part 'weekly_exam.g.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🏆 TÜRKİYE GENELİ DENEME SINAVI MODELLERİ
// ═══════════════════════════════════════════════════════════════════════════
//
// HAFTALIK DÖNGÜ:
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ PAZARTESİ 00:00 ──────────► PERŞEMBE 23:59  │ YAYIN (Sarı Kart)        │
// │ CUMA 00:00 ───────────────► CUMARTESİ 11:59 │ SONUÇ BEKLENİYOR         │
// │ CUMARTESİ 12:00 ──────────► PAZAR 23:59     │ SONUÇLAR YAYINDA (Mor)   │
// │ PAZAR 23:59 ──────────────► PAZARTESİ 00:00 │ Yeni sınav yüklenir      │
// └─────────────────────────────────────────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

/// Haftalık sınav modeli
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
    int? totalUser, // Sınava giren toplam kullanıcı sayısı (ör: 5000)
    Map<String, double>?
    turkeyAverages, // Türkiye geneli ders bazlı ortalama netler (ders adı -> net)
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
      totalUser: json['totalUser'] as int?,
      turkeyAverages: json['turkeyAverages'] != null
          ? (json['turkeyAverages'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            )
          : null,
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
    required String odaIsmi, // "Hafta 2 - 2026" gibi
    required String odaBaslangic, // ISO 8601
    required String odaBitis, // ISO 8601 (Perşembe 23:59)
    required String sonucTarihi, // Cumartesi 12:00
    required String odaDurumu, // "tamamlandi", "sonuclar_aciklandi"
    required String kullaniciId,
    required Map<String, String> cevaplar, // {"WQ001": "A", "WQ002": "B"}
    int? dogru,
    int? yanlis,
    int? bos,
    int? puan,
    int? siralama, // Türkiye sıralaması
    int? toplamKatilimci,
    DateTime? completedAt,
    @Default(false) bool resultViewed, // Sonuç görüntülendi mi?
  }) = _WeeklyExamResult;

  factory WeeklyExamResult.fromJson(Map<String, dynamic> json) =>
      _$WeeklyExamResultFromJson(json);
}

// ═══════════════════════════════════════════════════════════════════════════
// SINAV DURUM ENUMu
// ═══════════════════════════════════════════════════════════════════════════

/// Deneme sınavı durumları - UI kartı için
enum ExamCardStatus {
  /// Sınav yok veya yükleniyor (Gri kart)
  yukleniyor,

  /// Pazartesi bekleniyor - Pazar 23:59 sonrası (Gri kart)
  yakinda,

  /// Sınav yayında - Pazartesi 00:00 - Perşembe 23:59 (Sarı kart) 🔥
  yayinda,

  /// Kullanıcı tamamladı, sonuç bekleniyor - Cuma-Cumartesi 11:59 (Yeşil kart) ✅
  tamampiSonucBekliyor,

  /// Perşembe 23:59 geçti, kullanıcı girmedi (Turuncu kart) 😔
  kacpipidin,

  /// Sonuçlar açıklandı - Cumartesi 12:00 sonrası (Mor kart) 🏆
  sonuclarAciklandi,

  /// Önceki sınavın sonucu görüntülenmedi - önce sonucu görmeli (Turuncu kart)
  onceSonucuGor,
}

/// Durum extension'ı - UI için yardımcı metodlar
extension ExamCardStatusExtension on ExamCardStatus {
  /// Durum etiketi (kart üstünde gösterilecek)
  String get etiket {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return '⏳ YÜKLENİYOR';
      case ExamCardStatus.yakinda:
        return '⏰ YAKINDA';
      case ExamCardStatus.yayinda:
        return '🔥 YAYINDA';
      case ExamCardStatus.tamampiSonucBekliyor:
        return '✅ TAMAMLADIN';
      case ExamCardStatus.kacpipidin:
        return '😔 KAÇIRDIN';
      case ExamCardStatus.sonuclarAciklandi:
        return '🏆 SONUÇLAR';
      case ExamCardStatus.onceSonucuGor:
        return '👀 ÖNCE SONUCUNU GÖR';
    }
  }

  /// Komik/samimi mesajlar
  String get mesaj {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return 'Sınavlar hazırlanıyor...';
      case ExamCardStatus.yakinda:
        return 'Pazartesi saat 00:00\'da kapılar açılıyor! 🚀';
      case ExamCardStatus.yayinda:
        return 'Herkes yarışıyor, sen de katıl! 💪';
      case ExamCardStatus.tamampiSonucBekliyor:
        return 'Helal sana! Cumartesi 12:00\'de sonuçlar 🎉';
      case ExamCardStatus.kacpipidin:
        return 'Bu hafta kaçırdın ama Pazartesi yeni fırsat! 🌟';
      case ExamCardStatus.sonuclarAciklandi:
        return 'Türkiye sıralamanı gör şampiyon! 🏅';
      case ExamCardStatus.onceSonucuGor:
        return 'Önce geçen haftanın sonucuna bak! 👀';
    }
  }

  /// Alt başlık (kalan süre vs.)
  String get altBaslik {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return 'Lütfen bekle...';
      case ExamCardStatus.yakinda:
        return 'Yeni sınav Pazartesi 00:00\'da';
      case ExamCardStatus.yayinda:
        return 'Perşembe 23:59\'a kadar girebilirsin';
      case ExamCardStatus.tamampiSonucBekliyor:
        return 'Sonuçlar Cumartesi 12:00\'da açıklanacak';
      case ExamCardStatus.kacpipidin:
        return 'Pazartesi yeni sınav yayınlanacak';
      case ExamCardStatus.sonuclarAciklandi:
        return 'Türkiye sıralamanı kontrol et!';
      case ExamCardStatus.onceSonucuGor:
        return 'Sonucunu görmeden yeni sınava giremezsin';
    }
  }

  /// Buton metni
  String get butonMetni {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return '';
      case ExamCardStatus.yakinda:
        return '';
      case ExamCardStatus.yayinda:
        return 'BAŞLA 🚀';
      case ExamCardStatus.tamampiSonucBekliyor:
        return '';
      case ExamCardStatus.kacpipidin:
        return '';
      case ExamCardStatus.sonuclarAciklandi:
        return 'SONUÇLAR 🏆';
      case ExamCardStatus.onceSonucuGor:
        return 'SONUCU GÖR 👀';
    }
  }

  /// Buton gösterilsin mi?
  bool get butonGoster {
    return this == ExamCardStatus.yayinda ||
        this == ExamCardStatus.sonuclarAciklandi ||
        this == ExamCardStatus.onceSonucuGor;
  }

  /// Kart renkleri
  List<int> get renkler {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return [0xFF6B7280, 0xFF4B5563]; // Gri
      case ExamCardStatus.yakinda:
        return [0xFF6B7280, 0xFF4B5563]; // Gri
      case ExamCardStatus.yayinda:
        return [0xFFFFD700, 0xFFFF8C00]; // Altın Sarısı
      case ExamCardStatus.tamampiSonucBekliyor:
        return [0xFF10B981, 0xFF059669]; // Yeşil
      case ExamCardStatus.kacpipidin:
        return [0xFFF59E0B, 0xFFD97706]; // Turuncu
      case ExamCardStatus.sonuclarAciklandi:
        return [0xFF8B5CF6, 0xFF7C3AED]; // Mor
      case ExamCardStatus.onceSonucuGor:
        return [0xFFF59E0B, 0xFFD97706]; // Turuncu
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI HELPER PROPERTIES (Kart Widget için)
  // ═════════════════════════════════════════════════════════════════════════

  /// Kart etiketi (label alias)
  String get label {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return 'YÜKLENİYOR';
      case ExamCardStatus.yakinda:
        return 'YAKINDA';
      case ExamCardStatus.yayinda:
        return 'YAYINDA';
      case ExamCardStatus.tamampiSonucBekliyor:
        return 'TAMAMLANDI';
      case ExamCardStatus.kacpipidin:
        return 'KAÇIRDIN';
      case ExamCardStatus.sonuclarAciklandi:
        return 'SONUÇLAR';
      case ExamCardStatus.onceSonucuGor:
        return 'ÖNCE SONUCUNU GÖR';
    }
  }

  /// Kart ikonu
  IconData get icon {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return Icons.hourglass_empty;
      case ExamCardStatus.yakinda:
        return Icons.event_busy;
      case ExamCardStatus.yayinda:
        return Icons.emoji_events;
      case ExamCardStatus.tamampiSonucBekliyor:
        return Icons.check_circle;
      case ExamCardStatus.kacpipidin:
        return Icons.sentiment_dissatisfied;
      case ExamCardStatus.sonuclarAciklandi:
        return Icons.leaderboard;
      case ExamCardStatus.onceSonucuGor:
        return Icons.visibility;
    }
  }

  /// Ana renk
  Color get primaryColor {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return const Color(0xFF6B7280);
      case ExamCardStatus.yakinda:
        return const Color(0xFF6B7280);
      case ExamCardStatus.yayinda:
        return const Color(0xFFFF8C00);
      case ExamCardStatus.tamampiSonucBekliyor:
        return const Color(0xFF10B981);
      case ExamCardStatus.kacpipidin:
        return const Color(0xFFF59E0B);
      case ExamCardStatus.sonuclarAciklandi:
        return const Color(0xFF8B5CF6);
      case ExamCardStatus.onceSonucuGor:
        return const Color(0xFFF59E0B);
    }
  }

  /// Gradient (kart arka planı)
  LinearGradient get gradient {
    final colors = renkler.map((c) => Color(c)).toList();
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Buton metni (widget için)
  String get buttonText {
    switch (this) {
      case ExamCardStatus.yukleniyor:
        return '';
      case ExamCardStatus.yakinda:
        return '';
      case ExamCardStatus.yayinda:
        return 'BAŞLA';
      case ExamCardStatus.tamampiSonucBekliyor:
        return 'Bekle';
      case ExamCardStatus.kacpipidin:
        return '';
      case ExamCardStatus.sonuclarAciklandi:
        return 'GÖR';
      case ExamCardStatus.onceSonucuGor:
        return 'GÖR';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ESKİ ENUM (Geriye uyumluluk için)
// ═══════════════════════════════════════════════════════════════════════════

/// Eski sınav durumu enum - Result ekranı için kullanılıyor
enum ExamRoomStatus { beklemede, aktif, kapali, sonuclanmis }

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
        return 'Hadi sınava gir! Perşembeye kadar vaktin var.';
      case ExamRoomStatus.kapali:
        return 'Sonuçlar Cumartesi 12:00\'da açıklanacak!';
      case ExamRoomStatus.sonuclanmis:
        return 'Tüm Türkiye\'de kaçıncı sıradasın, baktın mı?';
    }
  }
}
