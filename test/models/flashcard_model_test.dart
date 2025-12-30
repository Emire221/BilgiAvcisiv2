import 'package:flutter_test/flutter_test.dart';
import 'package:bilgici/models/flashcard_model.dart';

void main() {
  group('FlashcardModel Tests', () {
    test('should create FlashcardModel from JSON', () {
      final json = {
        'kartID': 'K1',
        'onyuz': 'Sayılar ve Nicelikler konusu çok önemlidir',
        'dogruMu': false,
      };

      final flashcard = FlashcardModel.fromJson(json);

      expect(flashcard.kartID, 'K1');
      expect(flashcard.onyuz, 'Sayılar ve Nicelikler konusu çok önemlidir');
      expect(flashcard.dogruMu, false);
    });

    test('should create FlashcardModel with dogruMu true', () {
      const flashcard = FlashcardModel(
        kartID: 'K3',
        onyuz: 'Matematik çok eğlencelidir',
        dogruMu: true,
      );

      expect(flashcard.dogruMu, true);
      expect(flashcard.kartID, 'K3');
    });

    test('should create FlashcardModel with dogruMu false', () {
      const flashcard = FlashcardModel(
        kartID: 'K4',
        onyuz: 'Su soğuktur',
        dogruMu: false,
      );

      expect(flashcard.dogruMu, false);
      expect(flashcard.onyuz, 'Su soğuktur');
    });
  });

  group('FlashcardSetModel Tests', () {
    test('should create FlashcardSetModel from JSON', () {
      final json = {
        'kartSetID': 'SET1',
        'konuID': 'KONU1',
        'kartAdi': 'Sayılar',
        'kartlar': [
          {'kartID': 'K1', 'onyuz': 'Test 1', 'dogruMu': true},
          {'kartID': 'K2', 'onyuz': 'Test 2', 'dogruMu': false},
        ],
      };

      final flashcardSet = FlashcardSetModel.fromJson(json);

      expect(flashcardSet.kartSetID, 'SET1');
      expect(flashcardSet.konuID, 'KONU1');
      expect(flashcardSet.kartAdi, 'Sayılar');
      expect(flashcardSet.kartlar.length, 2);
      expect(flashcardSet.kartlar[0].kartID, 'K1');
      expect(flashcardSet.kartlar[1].dogruMu, false);
    });

    test('should create FlashcardSetModel with empty kartlar', () {
      const flashcardSet = FlashcardSetModel(
        kartSetID: 'SET2',
        konuID: 'KONU2',
        kartAdi: 'Boş Set',
        kartlar: [],
      );

      expect(flashcardSet.kartlar, isEmpty);
    });
  });
}
