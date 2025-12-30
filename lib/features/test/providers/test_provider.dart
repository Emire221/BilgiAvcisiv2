import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/repository_providers.dart';
import '../controller/test_controller.dart';
import '../models/test_state.dart';
import '../../../models/question_model.dart';

/// Test Controller Provider
final testControllerProvider =
    StateNotifierProvider.autoDispose<TestController, TestState>((ref) {
      final repository = ref.watch(testRepositoryProvider);
      return TestController(repository);
    });

/// Mevcut soru provider
final currentQuestionProvider = Provider.autoDispose<QuestionModel?>((ref) {
  final state = ref.watch(testControllerProvider);
  return state.currentQuestion;
});

/// Test tamamlandı mı?
final isTestCompletedProvider = Provider.autoDispose<bool>((ref) {
  final status = ref.watch(testControllerProvider.select((s) => s.status));
  return status == TestStatus.completed;
});

/// Test aktif mi?
final isTestActiveProvider = Provider.autoDispose<bool>((ref) {
  final status = ref.watch(testControllerProvider.select((s) => s.status));
  return status == TestStatus.active;
});

/// Kalan süre provider
final timeLeftProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(testControllerProvider.select((s) => s.timeLeft));
});

/// Puan provider
final scoreProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(testControllerProvider.select((s) => s.score));
});
