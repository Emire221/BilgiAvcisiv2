import 'package:freezed_annotation/freezed_annotation.dart';

part 'trial_exam.freezed.dart';
part 'trial_exam.g.dart';

/// Deneme sınavı modeli
@freezed
class TrialExam with _$TrialExam {
  const factory TrialExam({
    required String id,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required int duration, // Dakika cinsinden
    required List<ExamQuestion> questions,
  }) = _TrialExam;

  factory TrialExam.fromJson(Map<String, dynamic> json) =>
      _$TrialExamFromJson(json);
}

/// Sınav sorusu modeli
@freezed
class ExamQuestion with _$ExamQuestion {
  const factory ExamQuestion({
    required String id,
    required String text,
    required List<String> options, // A, B, C, D şıkları
    required String correctAnswer, // "A", "B", "C" veya "D"
    required String topicId,
  }) = _ExamQuestion;

  factory ExamQuestion.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionFromJson(json);
}

/// Deneme sonucu modeli
@freezed
class TrialResult with _$TrialResult {
  const factory TrialResult({
    int? id,
    required String examId,
    required String userId,
    required Map<String, String>
    rawAnswers, // {"1": "A", "2": "EMPTY", "3": "C"}
    int? score,
    DateTime? completedAt,
  }) = _TrialResult;

  factory TrialResult.fromJson(Map<String, dynamic> json) =>
      _$TrialResultFromJson(json);
}

/// Sınav durumu
@freezed
class ExamState with _$ExamState {
  const factory ExamState({
    @Default(false) bool isLoading,
    @Default(0) int currentQuestionIndex,
    @Default({}) Map<String, String> answers,
    @Default(0) int remainingSeconds,
    String? error,
  }) = _ExamState;
}
