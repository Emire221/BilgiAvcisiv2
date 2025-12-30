import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/test_repository.dart';
import '../../../models/question_model.dart';
import '../models/test_state.dart';
import '../../../core/constants/app_constants.dart';

/// Test Controller - Business Logic
class TestController extends StateNotifier<TestState> {
  final TestRepository _repository;
  Timer? _timer;
  String? _currentTestId;

  TestController(this._repository) : super(const TestState());

  /// Testi başlat
  void initializeTest(List<QuestionModel> questions, {String? testId}) {
    _currentTestId = testId;
    if (questions.isEmpty) {
      state = state.copyWith(
        status: TestStatus.completed,
        errorMessage: 'Test soruları bulunamadı',
      );
      return;
    }

    state = state.copyWith(
      questions: questions,
      status: TestStatus.active,
      currentQuestionIndex: 0,
      timeLeft: AppConstants.defaultTestDuration,
      score: 0,
      correctCount: 0,
      wrongCount: 0,
      userAnswers: {},
      errorMessage: null,
    );

    startTimer();
  }

  /// Timer'ı başlat
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConstants.timerInterval, (timer) {
      if (state.timeLeft > 0 && state.status == TestStatus.active) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else if (state.timeLeft <= 0) {
        // Süre bittiğinde: son soru değilse sonrakine geç, son soru ise bitir
        if (state.currentQuestionIndex < state.questions.length - 1) {
          nextQuestion();
        } else {
          finishTest();
        }
      }
    });
  }

  /// Timer'ı duraklat
  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(status: TestStatus.paused);
  }

  /// Timer'ı devam ettir
  void resumeTimer() {
    if (state.status == TestStatus.paused) {
      state = state.copyWith(status: TestStatus.active);
      startTimer();
    }
  }

  /// Soruyu cevapla - sonuç bilgisi döndürür (popup için)
  /// Artık otomatik sonraki soruya geçmiyor, UI popup'tan geçişi tetikleyecek
  ({bool isCorrect, String correctAnswer, String? aciklama}) answerQuestion(
    String selectedAnswer,
  ) {
    if (state.currentQuestion == null || state.status != TestStatus.active) {
      return (isCorrect: false, correctAnswer: '', aciklama: null);
    }

    // Timer'ı duraklat - popup açıkken süre işlemesin
    _timer?.cancel();

    final currentQuestion = state.currentQuestion!;
    final correctAnswer = currentQuestion.dogruCevap;
    final isCorrect = selectedAnswer == correctAnswer;

    // Kullanıcı cevabını kaydet
    final updatedAnswers = Map<int, String>.from(state.userAnswers);
    updatedAnswers[state.currentQuestionIndex] = selectedAnswer;

    // Yeni state hesapla
    final newCorrectCount = isCorrect
        ? state.correctCount + 1
        : state.correctCount;
    final newWrongCount = !isCorrect ? state.wrongCount + 1 : state.wrongCount;
    final newScore = newCorrectCount * AppConstants.pointsPerCorrectAnswer;

    // State'i güncelle (senkron işlem)
    state = state.copyWith(
      userAnswers: updatedAnswers,
      correctCount: newCorrectCount,
      wrongCount: newWrongCount,
      score: newScore,
    );

    // Popup için sonuç bilgisini döndür
    return (
      isCorrect: isCorrect,
      correctAnswer: correctAnswer,
      aciklama: currentQuestion.aciklama,
    );
  }

  /// Popup kapandıktan sonra sonraki soruya geç veya testi bitir
  Future<void> proceedToNextOrFinish() async {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      nextQuestion();
    } else {
      await finishTest();
    }
  }

  /// Sonraki soruya geç
  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        timeLeft: AppConstants.defaultTestDuration, // Her soru için 60 saniye
      );

      // Timer'ı yeniden başlat (her soru için 60 saniye)
      startTimer();
    }
  }

  /// Testi bitir
  Future<void> finishTest() async {
    _timer?.cancel();

    // ÖNEMLİ: State güncellemelerinin tamamlanmasını bekle
    // Son sorunun puanının kaybolmaması için kritik
    await Future.microtask(() {});

    state = state.copyWith(status: TestStatus.completed);

    if (_currentTestId != null) {
      _repository.saveTestResult(
        _currentTestId!,
        state.score,
        state.correctCount,
        state.wrongCount,
      );
    }
  }

  /// Controller temizle
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
