import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_helper.dart';
import '../services/progress_service.dart';
import '../repositories/test_repository.dart';
import '../repositories/test_repository_impl.dart';
import '../repositories/flashcard_repository.dart';
import '../repositories/flashcard_repository_impl.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final testRepositoryProvider = Provider<TestRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  return TestRepositoryImpl(dbHelper);
});

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  return FlashcardRepositoryImpl(dbHelper);
});

// ============================================================
// Progress Service Providers
// ============================================================

/// Progress Service Provider
final progressServiceProvider = Provider<ProgressService>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  return ProgressService(dbHelper);
});

/// Topic Progress Provider - Konu bazlı tamamlanmamış içerik sayısı
/// Parametre: (topicId, mode) record
/// autoDispose: Ekran her görüntülendiğinde yeniden fetch edilir
final topicProgressProvider = FutureProvider.autoDispose
    .family<int, ({String topicId, String mode})>((ref, params) {
      final service = ref.read(progressServiceProvider);
      return service.getTopicUncompletedCount(params.topicId, params.mode);
    });

/// Game Progress Provider - Oyun bazlı tamamlanmamış level sayısı
/// Parametre: gameId string
/// autoDispose: Ekran her görüntülendiğinde yeniden fetch edilir
final gameProgressProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  gameId,
) {
  final service = ref.read(progressServiceProvider);
  return service.getGameUncompletedCount(gameId);
});

/// Lesson Progress Provider - Ders bazlı toplam tamamlanmamış içerik sayısı
/// Parametre: (lessonId, mode) record
/// autoDispose: Ekran her görüntülendiğinde yeniden fetch edilir
final lessonProgressProvider = FutureProvider.autoDispose
    .family<int, ({String lessonId, String mode})>((ref, params) {
      final service = ref.read(progressServiceProvider);
      return service.getLessonUncompletedCount(params.lessonId, params.mode);
    });

// ============================================================
// Tekil Öğe Tamamlanma Kontrolü (YENİ badge için)
// ============================================================

/// Test çözülmüş mü provider
final isTestSolvedProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  testId,
) {
  final dbHelper = ref.read(databaseHelperProvider);
  return dbHelper.isTestSolved(testId);
});

/// Flashcard seti görüntülenmiş mi provider
final isFlashcardViewedProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, kartSetID) {
      final dbHelper = ref.read(databaseHelperProvider);
      return dbHelper.isFlashcardSetViewed(kartSetID);
    });

/// Oyun level'ı tamamlanmış mı provider
/// Parametre: (gameType, levelTitle) record
final isLevelCompletedProvider = FutureProvider.autoDispose
    .family<bool, ({String gameType, String levelTitle})>((ref, params) {
      final dbHelper = ref.read(databaseHelperProvider);
      return dbHelper.isLevelCompleted(params.gameType, params.levelTitle);
    });

// ============================================================
// Motivasyonel Progress Bar Provider'ları
// ============================================================

/// Toplam içerik sayısı provider (test + bilgi kartı seti)
final totalContentCountProvider = FutureProvider.autoDispose<int>((ref) {
  final service = ref.read(progressServiceProvider);
  return service.getTotalContentCount();
});

/// Tamamlanan içerik sayısı provider (çözülen test + görüntülenen bilgi kartı)
final completedContentCountProvider = FutureProvider.autoDispose<int>((ref) {
  final service = ref.read(progressServiceProvider);
  return service.getCompletedContentCount();
});
