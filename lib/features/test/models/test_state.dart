import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/question_model.dart';

part 'test_state.freezed.dart';

/// Test durumu enum
enum TestStatus { loading, active, paused, completed }

/// Test State - Immutable
@freezed
class TestState with _$TestState {
  const factory TestState({
    @Default([]) List<QuestionModel> questions,
    @Default(0) int currentQuestionIndex,
    @Default(60) int timeLeft,
    @Default(0) int score,
    @Default(0) int correctCount,
    @Default(0) int wrongCount,
    @Default({}) Map<int, String> userAnswers,
    @Default(TestStatus.loading) TestStatus status,
    String? errorMessage,
  }) = _TestState;

  const TestState._();

  /// Mevcut soruyu döner
  QuestionModel? get currentQuestion {
    if (questions.isEmpty ||
        currentQuestionIndex < 0 ||
        currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  /// Test tamamlanmış mı?
  bool get isCompleted => status == TestStatus.completed;

  /// Test aktif mi?
  bool get isActive => status == TestStatus.active;

  /// Cevaplanmış soru sayısı
  int get answeredQuestionsCount => userAnswers.length;

  /// İlerleme yüzdesi
  double get progress {
    if (questions.isEmpty) return 0.0;
    return answeredQuestionsCount / questions.length;
  }
}
