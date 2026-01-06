import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/shape_card.dart';
import '../../domain/entities/shape_game_state.dart';

/// Şekil eşleştirme oyun controller provider
final shapeGameProvider =
    StateNotifierProvider.autoDispose<ShapeGameController, ShapeGameState>(
      (ref) => ShapeGameController(),
    );

/// Şekil eşleştirme oyun controller'ı
class ShapeGameController extends StateNotifier<ShapeGameState> {
  Timer? _flipBackTimer;

  ShapeGameController() : super(const ShapeGameState());

  /// Oyunu başlat
  void startGame() {
    _flipBackTimer?.cancel();

    // 5 farklı şekil, her birinden 2 adet = 10 kart
    final shapes = ShapeType.schoolShapes;
    final cardPairs = <ShapeCard>[];

    // Her şekilden 2 kart oluştur
    for (int i = 0; i < shapes.length; i++) {
      cardPairs.add(ShapeCard(
        id: i * 2,
        shape: shapes[i],
        pairId: i,
      ));
      cardPairs.add(ShapeCard(
        id: i * 2 + 1,
        shape: shapes[i],
        pairId: i,
      ));
    }

    // Kartları karıştır
    cardPairs.shuffle();

    // ID'leri yeniden ata (pozisyona göre)
    final cards = List.generate(cardPairs.length, (index) {
      return ShapeCard(
        id: index,
        shape: cardPairs[index].shape,
        pairId: cardPairs[index].pairId,
      );
    });

    state = ShapeGameState(
      cards: cards,
      status: ShapeGameStatus.playing,
      startTime: DateTime.now(),
    );
  }

  /// Karta tıkla
  void flipCard(int cardId) {
    // Oyun oynamıyorsa veya kontrol yapılıyorsa işlem yapma
    if (!state.isPlaying && !state.isChecking) return;
    if (state.status == ShapeGameStatus.checking) return;

    final cardIndex = state.cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) return;

    final card = state.cards[cardIndex];

    // Zaten açık veya eşleşmiş kartlara tıklanamaz
    if (card.isFlipped || card.isMatched) return;

    // Kartı çevir
    final newCards = List<ShapeCard>.from(state.cards);
    newCards[cardIndex] = card.copyWith(isFlipped: true);

    // İlk kart mı yoksa ikinci kart mı?
    if (state.firstFlippedCardId == null) {
      // İlk kart
      state = state.copyWith(
        cards: newCards,
        firstFlippedCardId: cardId,
        moves: state.moves + 1,
      );
    } else {
      // İkinci kart - eşleşme kontrolü yap
      state = state.copyWith(
        cards: newCards,
        secondFlippedCardId: cardId,
        moves: state.moves + 1,
        status: ShapeGameStatus.checking,
      );
      _checkMatch();
    }
  }

  /// Eşleşme kontrolü
  void _checkMatch() {
    if (state.firstFlippedCardId == null || state.secondFlippedCardId == null) return;

    final firstCard = state.cards.firstWhere((c) => c.id == state.firstFlippedCardId);
    final secondCard = state.cards.firstWhere((c) => c.id == state.secondFlippedCardId);

    if (firstCard.pairId == secondCard.pairId) {
      // DOĞRU EŞLEŞMEǃ
      _handleCorrectMatch(firstCard, secondCard);
    } else {
      // YANLIŞ!
      _handleWrongMatch();
    }
  }

  /// Doğru eşleşme
  void _handleCorrectMatch(ShapeCard firstCard, ShapeCard secondCard) {
    final newCards = state.cards.map((c) {
      if (c.id == firstCard.id || c.id == secondCard.id) {
        return c.copyWith(isMatched: true, isFlipped: true);
      }
      return c;
    }).toList();

    final newMatches = state.matches + 1;

    // Oyun bitti mi?
    if (newMatches >= 5) {
      state = state.copyWith(
        cards: newCards,
        matches: newMatches,
        status: ShapeGameStatus.completed,
        endTime: DateTime.now(),
        clearFirstFlipped: true,
        clearSecondFlipped: true,
      );
    } else {
      state = state.copyWith(
        cards: newCards,
        matches: newMatches,
        status: ShapeGameStatus.playing,
        clearFirstFlipped: true,
        clearSecondFlipped: true,
      );
    }
  }

  /// Yanlış eşleşme
  void _handleWrongMatch() {
    state = state.copyWith(
      mistakes: state.mistakes + 1,
    );

    // 1 saniye bekle, sonra kartları kapat
    _flipBackTimer?.cancel();
    _flipBackTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      final newCards = state.cards.map((c) {
        if (c.id == state.firstFlippedCardId || c.id == state.secondFlippedCardId) {
          return c.copyWith(isFlipped: false);
        }
        return c;
      }).toList();

      state = state.copyWith(
        cards: newCards,
        status: ShapeGameStatus.playing,
        clearFirstFlipped: true,
        clearSecondFlipped: true,
      );
    });
  }

  /// Oyunu yeniden başlat
  void restartGame() {
    startGame();
  }

  /// Oyundan çık
  void exitGame() {
    _flipBackTimer?.cancel();
    state = const ShapeGameState();
  }

  @override
  void dispose() {
    _flipBackTimer?.cancel();
    super.dispose();
  }
}
