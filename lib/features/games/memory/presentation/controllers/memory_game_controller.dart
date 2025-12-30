import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/memory_card.dart';
import '../../domain/entities/memory_game_state.dart';

/// Bul Bakalım oyun controller provider
final memoryGameProvider =
    StateNotifierProvider.autoDispose<MemoryGameController, MemoryGameState>(
      (ref) => MemoryGameController(),
    );

/// Bul Bakalım oyun controller'ı
class MemoryGameController extends StateNotifier<MemoryGameState> {
  Timer? _flipBackTimer;

  MemoryGameController() : super(const MemoryGameState());

  /// Oyunu başlat
  void startGame() {
    _flipBackTimer?.cancel();

    // 1-10 arası sayıları oluştur ve karıştır
    final numbers = List.generate(10, (i) => i + 1)..shuffle();

    // Kartları oluştur
    final cards = List.generate(10, (index) {
      return MemoryCard(
        id: index,
        number: numbers[index],
        isFlipped: false,
        isMatched: false,
      );
    });

    state = MemoryGameState(
      cards: cards,
      nextExpectedNumber: 1,
      mistakes: 0,
      moves: 0,
      status: MemoryGameStatus.playing,
      startTime: DateTime.now(),
    );
  }

  /// Karta tıkla
  void flipCard(int cardId) {
    // Oyun oynamıyorsa veya kontrol yapılıyorsa işlem yapma
    if (!state.isPlaying || state.isChecking) return;

    final cardIndex = state.cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) return;

    final card = state.cards[cardIndex];

    // Zaten açık veya eşleşmiş kartlara tıklanamaz
    if (card.isFlipped || card.isMatched) return;

    // Kartı çevir
    final newCards = List<MemoryCard>.from(state.cards);
    newCards[cardIndex] = card.copyWith(isFlipped: true);

    state = state.copyWith(
      cards: newCards,
      moves: state.moves + 1,
      lastFlippedCardId: cardId,
    );

    // Doğru mu yanlış mı kontrol et
    _checkCard(card);
  }

  /// Kartı kontrol et
  void _checkCard(MemoryCard card) {
    if (card.number == state.nextExpectedNumber) {
      // DOĞRU! Kartı eşleşmiş olarak işaretle
      _markAsMatched(card.id);
    } else {
      // YANLIŞ! Tüm kartları kapat
      _handleWrongGuess();
    }
  }

  /// Kartı doğru eşleşmiş olarak işaretle
  void _markAsMatched(int cardId) {
    final newCards = state.cards.map((c) {
      if (c.id == cardId) {
        return c.copyWith(isMatched: true, isFlipped: true);
      }
      return c;
    }).toList();

    final newExpected = state.nextExpectedNumber + 1;

    // Oyun bitti mi?
    if (newExpected > 10) {
      state = state.copyWith(
        cards: newCards,
        nextExpectedNumber: newExpected,
        status: MemoryGameStatus.completed,
        endTime: DateTime.now(),
        clearLastFlipped: true,
      );
    } else {
      state = state.copyWith(
        cards: newCards,
        nextExpectedNumber: newExpected,
        clearLastFlipped: true,
      );
    }
  }

  /// Yanlış tahmin - tüm kartları kapat
  void _handleWrongGuess() {
    // Önce checking durumuna geç
    state = state.copyWith(
      status: MemoryGameStatus.checking,
      mistakes: state.mistakes + 1,
    );

    // 1.5 saniye bekle, sonra tüm kartları kapat
    _flipBackTimer?.cancel();
    _flipBackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      // Tüm kartları kapat (eşleşenler hariç - ama bu oyunda hepsi kapanır)
      final newCards = state.cards.map((c) {
        return c.copyWith(isFlipped: false, isMatched: false);
      }).toList();

      // Sayacı sıfırla
      state = state.copyWith(
        cards: newCards,
        nextExpectedNumber: 1,
        status: MemoryGameStatus.playing,
        clearLastFlipped: true,
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
    state = const MemoryGameState();
  }

  @override
  void dispose() {
    _flipBackTimer?.cancel();
    super.dispose();
  }
}
