/// Bul Bakalım oyunu kart modeli
class MemoryCard {
  final int id; // Kartın pozisyon ID'si (0-9)
  final int number; // Kartın üzerindeki sayı (1-10)
  final bool isFlipped; // Kart açık mı?
  final bool isMatched; // Doğru eşleşti mi?

  const MemoryCard({
    required this.id,
    required this.number,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    int? id,
    int? number,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      number: number ?? this.number,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  String toString() =>
      'MemoryCard(id: $id, number: $number, flipped: $isFlipped, matched: $isMatched)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryCard && other.id == id && other.number == number;
  }

  @override
  int get hashCode => id.hashCode ^ number.hashCode;
}
