import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/guess_level.dart';
import '../../domain/entities/guess_question.dart';
import '../../domain/entities/temperature.dart';
import '../../data/guess_repository.dart';

/// Oyun durumu
class GuessState {
  final GuessLevel? level;
  final int currentQuestionIndex;
  final int? currentGuess;
  final Temperature temperature;
  final String feedbackMessage;
  final bool goUp; // Yukarı mı gitmeli?
  final int attempts;
  final int correctCount;
  final int totalScore;
  final bool isCorrect;
  final bool isGameOver;
  final bool isLoading;
  final String? error;

  const GuessState({
    this.level,
    this.currentQuestionIndex = 0,
    this.currentGuess,
    this.temperature = Temperature.cool,
    this.feedbackMessage = '',
    this.goUp = true,
    this.attempts = 0,
    this.correctCount = 0,
    this.totalScore = 0,
    this.isCorrect = false,
    this.isGameOver = false,
    this.isLoading = false,
    this.error,
  });

  GuessState copyWith({
    GuessLevel? level,
    int? currentQuestionIndex,
    int? currentGuess,
    Temperature? temperature,
    String? feedbackMessage,
    bool? goUp,
    int? attempts,
    int? correctCount,
    int? totalScore,
    bool? isCorrect,
    bool? isGameOver,
    bool? isLoading,
    String? error,
  }) {
    return GuessState(
      level: level ?? this.level,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentGuess: currentGuess,
      temperature: temperature ?? this.temperature,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      goUp: goUp ?? this.goUp,
      attempts: attempts ?? this.attempts,
      correctCount: correctCount ?? this.correctCount,
      totalScore: totalScore ?? this.totalScore,
      isCorrect: isCorrect ?? this.isCorrect,
      isGameOver: isGameOver ?? this.isGameOver,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Mevcut soru
  GuessQuestion? get currentQuestion {
    if (level == null || currentQuestionIndex >= level!.questions.length) {
      return null;
    }
    return level!.questions[currentQuestionIndex];
  }

  /// Toplam soru sayısı
  int get totalQuestions => level?.questions.length ?? 0;

  /// İlerleme yüzdesi
  double get progressPercent {
    if (totalQuestions == 0) return 0;
    return currentQuestionIndex / totalQuestions;
  }
}

/// Guess Controller - Oyun mantığını yönetir
class GuessController extends StateNotifier<GuessState> {
  final GuessRepository _repository;

  GuessController({GuessRepository? repository})
    : _repository = repository ?? GuessRepository(),
      super(const GuessState());

  /// Oyunu başlat
  Future<void> startGame({GuessLevel? level, int? difficulty}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      GuessLevel? gameLevel = level;

      if (gameLevel == null) {
        if (difficulty != null) {
          gameLevel = await _repository.getRandomLevelByDifficulty(difficulty);
        } else {
          gameLevel = await _repository.getRandomLevel();
        }
      }

      if (gameLevel == null || gameLevel.questions.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Oyun verisi bulunamadı',
        );
        return;
      }

      state = GuessState(
        level: gameLevel,
        currentQuestionIndex: 0,
        attempts: 0,
        correctCount: 0,
        totalScore: 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Oyun yüklenirken hata: $e',
      );
    }
  }

  /// Tahmin gönder
  void submitGuess(int guess) {
    final question = state.currentQuestion;
    if (question == null || state.isCorrect) return;

    final answer = question.answer;
    final tolerance = question.tolerance;
    final temperature = _calculateTemperature(guess, answer, tolerance);
    final goUp = guess < answer;

    final newAttempts = state.attempts + 1;

    // Puan hesaplama: Daha az denemede bulursan daha çok puan
    int scoreGained = 0;
    if (temperature == Temperature.correct) {
      // Maksimum 100 puan, her deneme -10 puan
      scoreGained = (100 - (newAttempts - 1) * 10).clamp(10, 100);
    }

    state = state.copyWith(
      currentGuess: guess,
      temperature: temperature,
      feedbackMessage: temperature.message,
      goUp: goUp,
      attempts: newAttempts,
      isCorrect: temperature == Temperature.correct,
      correctCount: temperature == Temperature.correct
          ? state.correctCount + 1
          : state.correctCount,
      totalScore: state.totalScore + scoreGained,
    );
  }

  /// Sıcaklık hesaplama algoritması
  Temperature _calculateTemperature(int guess, int answer, int tolerance) {
    final difference = (guess - answer).abs();

    // Tam doğru
    if (difference == 0) {
      return Temperature.correct;
    }

    // Tolerans içinde doğru sayılır
    if (difference <= tolerance * 0.05) {
      return Temperature.correct;
    }

    // Sıcaklık seviyeleri (toleransa göre oransal)
    final ratio = difference / tolerance;

    if (ratio <= 0.1) {
      return Temperature.boiling; // %10 içinde
    } else if (ratio <= 0.25) {
      return Temperature.hot; // %25 içinde
    } else if (ratio <= 0.5) {
      return Temperature.warm; // %50 içinde
    } else if (ratio <= 1.0) {
      return Temperature.cool; // Tolerans içinde
    } else if (ratio <= 2.0) {
      return Temperature.cold; // 2x tolerans
    } else {
      return Temperature.freezing; // Çok uzak
    }
  }

  /// Sonraki soruya geç
  void nextQuestion() {
    if (state.level == null) return;

    final nextIndex = state.currentQuestionIndex + 1;

    if (nextIndex >= state.level!.questions.length) {
      // Oyun bitti
      state = state.copyWith(isGameOver: true);
      return;
    }

    state = state.copyWith(
      currentQuestionIndex: nextIndex,
      currentGuess: null,
      temperature: Temperature.cool,
      feedbackMessage: '',
      goUp: true,
      attempts: 0,
      isCorrect: false,
    );
  }

  /// Soruyu atla
  void skipQuestion() {
    nextQuestion();
  }

  /// Oyunu sıfırla
  void resetGame() {
    if (state.level != null) {
      state = GuessState(
        level: state.level,
        currentQuestionIndex: 0,
        attempts: 0,
        correctCount: 0,
        totalScore: 0,
      );
    }
  }

  /// İpucu göster (puan düşürür)
  String? showHint() {
    return state.currentQuestion?.hint;
  }
}

/// Providers
final guessRepositoryProvider = Provider<GuessRepository>((ref) {
  return GuessRepository();
});

final guessControllerProvider =
    StateNotifierProvider<GuessController, GuessState>((ref) {
      return GuessController(repository: ref.watch(guessRepositoryProvider));
    });
