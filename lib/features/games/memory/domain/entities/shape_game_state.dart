import 'shape_card.dart';

/// Şekil eşleştirme oyun durumu
enum ShapeGameStatus { initial, playing, checking, completed }

class ShapeGameState {
  final List<ShapeCard> cards;
  final int? firstFlippedCardId;  // İlk açılan kartın ID'si
  final int? secondFlippedCardId; // İkinci açılan kartın ID'si
  final int matches;              // Doğru eşleşme sayısı
  final int mistakes;             // Hata sayısı
  final int moves;                // Toplam hamle sayısı
  final ShapeGameStatus status;
  final DateTime? startTime;
  final DateTime? endTime;

  const ShapeGameState({
    this.cards = const [],
    this.firstFlippedCardId,
    this.secondFlippedCardId,
    this.matches = 0,
    this.mistakes = 0,
    this.moves = 0,
    this.status = ShapeGameStatus.initial,
    this.startTime,
    this.endTime,
  });

  /// Oyun tamamlandı mı?
  bool get isCompleted => status == ShapeGameStatus.completed;

  /// Oyun devam ediyor mu?
  bool get isPlaying => status == ShapeGameStatus.playing;

  /// Kontrol yapılıyor mu?
  bool get isChecking => status == ShapeGameStatus.checking;

  /// Tüm kartlar eşleşti mi? (5 çift = 5 eşleşme)
  bool get allMatched => matches >= 5;

  /// Oyun süresi (saniye)
  int get elapsedSeconds {
    if (startTime == null) return 0;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!).inSeconds;
  }

  /// Skor hesaplama
  int get score {
    if (!isCompleted) return 0;
    int baseScore = 1000;
    int mistakePenalty = mistakes * 50;
    int timePenalty = (elapsedSeconds ~/ 10) * 10;
    return (baseScore - mistakePenalty - timePenalty).clamp(100, 1000);
  }

  /// Yıldız sayısı (1-3)
  int get starCount {
    if (mistakes == 0) return 3;
    if (mistakes <= 3) return 2;
    return 1;
  }

  ShapeGameState copyWith({
    List<ShapeCard>? cards,
    int? firstFlippedCardId,
    int? secondFlippedCardId,
    int? matches,
    int? mistakes,
    int? moves,
    ShapeGameStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    bool clearFirstFlipped = false,
    bool clearSecondFlipped = false,
  }) {
    return ShapeGameState(
      cards: cards ?? this.cards,
      firstFlippedCardId: clearFirstFlipped ? null : (firstFlippedCardId ?? this.firstFlippedCardId),
      secondFlippedCardId: clearSecondFlipped ? null : (secondFlippedCardId ?? this.secondFlippedCardId),
      matches: matches ?? this.matches,
      mistakes: mistakes ?? this.mistakes,
      moves: moves ?? this.moves,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
