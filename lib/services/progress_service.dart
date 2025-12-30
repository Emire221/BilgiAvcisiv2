import 'package:flutter/foundation.dart';
import 'database_helper.dart';

/// 🎯 Merkezi İlerleme Takip Servisi
///
/// Context-Aware navigasyona uygun olarak mod bazlı ilerleme sayılarını hesaplar.
/// - Test modu: Sadece çözülmemiş test sayısını döner
/// - Flashcard modu: Sadece kart seti sayısını döner
/// - All modu: İkisinin toplamını döner
class ProgressService {
  final DatabaseHelper _dbHelper;

  ProgressService(this._dbHelper);

  /// Konu için tamamlanmamış içerik sayısını döner
  ///
  /// [topicId] - Konu ID'si
  /// [mode] - 'test', 'flashcard' veya 'all'
  ///
  /// Returns: Tamamlanmamış içerik sayısı
  Future<int> getTopicUncompletedCount(String topicId, String mode) async {
    switch (mode) {
      case 'test':
        return await _getUncompletedTestCount(topicId);
      case 'flashcard':
        return await _getUncompletedFlashcardCount(topicId);
      case 'all':
        final tests = await _getUncompletedTestCount(topicId);
        final flashcards = await _getUncompletedFlashcardCount(topicId);
        return tests + flashcards;
      default:
        return 0;
    }
  }

  /// Oyun için tamamlanmamış level sayısını döner
  ///
  /// [gameId] - Oyun ID'si ('fill_blanks', 'guess', 'memory', 'duel')
  ///
  /// Returns: Tamamlanmamış level sayısı (desteklenmiyorsa 0)
  Future<int> getGameUncompletedCount(String gameId) async {
    switch (gameId) {
      case 'fill_blanks':
      case 'guess':
        final total = await _dbHelper.getTotalLevelCount(gameId);
        final completed = await _dbHelper.getCompletedLevelCount(gameId);
        final result = (total - completed).clamp(0, total);
        if (kDebugMode) {
          debugPrint(
            '🎮 ProgressService [$gameId]: total=$total, completed=$completed, remaining=$result',
          );
        }
        return result;
      default:
        // Diğer oyunlar için badge gösterilmez
        return 0;
    }
  }

  // ============================================================
  // Private Helper Methods
  // ============================================================

  /// Konu için çözülmemiş test sayısı
  Future<int> _getUncompletedTestCount(String topicId) async {
    final total = await _dbHelper.getTestCountByTopic(topicId);
    final solved = await _dbHelper.getSolvedTestCountByTopic(topicId);
    final result = (total - solved).clamp(0, total);
    if (kDebugMode) {
      debugPrint(
        '📝 ProgressService [test] topicId=$topicId: total=$total, solved=$solved, remaining=$result',
      );
    }
    return result;
  }

  /// Konu için görüntülenmemiş flashcard set sayısı
  Future<int> _getUncompletedFlashcardCount(String topicId) async {
    final total = await _dbHelper.getFlashcardSetCountByTopic(topicId);
    final viewed = await _dbHelper.getViewedFlashcardSetCount(topicId);
    final result = (total - viewed).clamp(0, total);
    if (kDebugMode) {
      debugPrint(
        '🃏 ProgressService [flashcard] topicId=$topicId: total=$total, viewed=$viewed, remaining=$result',
      );
    }
    return result;
  }

  // ============================================================
  // Ders Bazlı Hesaplamalar
  // ============================================================

  /// Ders için tamamlanmamış toplam içerik sayısını döner
  ///
  /// [lessonId] - Ders ID'si
  /// [mode] - 'test', 'flashcard' veya 'all'
  ///
  /// Returns: Derse ait tüm konuların tamamlanmamış içerik toplamı
  Future<int> getLessonUncompletedCount(String lessonId, String mode) async {
    // Derse ait tüm konu ID'lerini al
    final topicIds = await _dbHelper.getTopicIdsByLesson(lessonId);

    if (topicIds.isEmpty) return 0;

    int total = 0;
    for (final topicId in topicIds) {
      total += await getTopicUncompletedCount(topicId, mode);
    }

    if (kDebugMode) {
      debugPrint(
        '📚 ProgressService [lesson] lessonId=$lessonId, mode=$mode: topicCount=${topicIds.length}, remaining=$total',
      );
    }
    return total;
  }

  // ============================================================
  // Uygulama Geneli İçerik Sayıları (Motivasyonel Progress Bar)
  // ============================================================

  /// Uygulamadaki toplam içerik sayısı (test + bilgi kartı seti)
  Future<int> getTotalContentCount() async {
    final tests = await _dbHelper.getTotalTestCount();
    final flashcards = await _dbHelper.getTotalFlashcardSetCount();
    final total = tests + flashcards;
    if (kDebugMode) {
      debugPrint(
        '🎯 ProgressService [total]: tests=$tests, flashcards=$flashcards, total=$total',
      );
    }
    return total;
  }

  /// Uygulamadaki tamamlanan içerik sayısı (çözülen test + görüntülenen bilgi kartı seti)
  Future<int> getCompletedContentCount() async {
    final solvedTests = await _dbHelper.getTotalSolvedTestCount();
    final viewedFlashcards = await _dbHelper.getTotalViewedFlashcardSetCount();
    final completed = solvedTests + viewedFlashcards;
    if (kDebugMode) {
      debugPrint(
        '✅ ProgressService [completed]: solvedTests=$solvedTests, viewedFlashcards=$viewedFlashcards, completed=$completed',
      );
    }
    return completed;
  }
}

