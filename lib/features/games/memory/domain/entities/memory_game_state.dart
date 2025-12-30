import 'memory_card.dart';

/// Bul Bakalım oyun durumu
enum MemoryGameStatus { initial, playing, checking, completed }

class MemoryGameState {
  final List<MemoryCard> cards;
  final int nextExpectedNumber; // Sıradaki beklenen sayı (1-10)
  final int mistakes; // Toplam hata sayısı
  final int moves; // Toplam hamle sayısı
  final MemoryGameStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? lastFlippedCardId; // Son çevrilen kartın ID'si

  const MemoryGameState({
    this.cards = const [],
    this.nextExpectedNumber = 1,
    this.mistakes = 0,
    this.moves = 0,
    this.status = MemoryGameStatus.initial,
    this.startTime,
    this.endTime,
    this.lastFlippedCardId,
  });

  /// Oyun tamamlandı mı?
  bool get isCompleted => status == MemoryGameStatus.completed;

  /// Oyun devam ediyor mu?
  bool get isPlaying => status == MemoryGameStatus.playing;

  /// Kontrol yapılıyor mu? (Yanlış cevap sonrası)
  bool get isChecking => status == MemoryGameStatus.checking;

  /// Kaç kart doğru eşleşti?
  int get matchedCount => cards.where((c) => c.isMatched).length;

  /// Tüm kartlar eşleşti mi?
  bool get allMatched => matchedCount == 10;

  /// Oyun süresi (saniye)
  int get elapsedSeconds {
    if (startTime == null) return 0;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!).inSeconds;
  }

  /// Skor hesaplama
  /// - Hatasız bitirme: 1000 puan
  /// - Her hata -50 puan
  /// - Her 10 saniye -10 puan
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
    if (mistakes <= 2) return 2;
    if (mistakes <= 5) return 1;
    return 0;
  }

  MemoryGameState copyWith({
    List<MemoryCard>? cards,
    int? nextExpectedNumber,
    int? mistakes,
    int? moves,
    MemoryGameStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? lastFlippedCardId,
    bool clearLastFlipped = false,
  }) {
    return MemoryGameState(
      cards: cards ?? this.cards,
      nextExpectedNumber: nextExpectedNumber ?? this.nextExpectedNumber,
      mistakes: mistakes ?? this.mistakes,
      moves: moves ?? this.moves,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lastFlippedCardId: clearLastFlipped
          ? null
          : (lastFlippedCardId ?? this.lastFlippedCardId),
    );
  }

  @override
  String toString() =>
      'MemoryGameState(expected: $nextExpectedNumber, mistakes: $mistakes, status: $status)';
}
