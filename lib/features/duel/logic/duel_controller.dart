import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/bot_logic_controller.dart'
    show BotLogicController, DuelResult;
import '../domain/entities/bot_profile.dart';
import '../domain/entities/duel_entities.dart';
import '../data/duel_repository.dart';

// Re-export DuelResult for consumers
export '../domain/bot_logic_controller.dart' show DuelResult;

/// Düello state'i
class DuelState {
  final DuelStatus status;
  final DuelGameType? gameType;
  final BotProfile? botProfile;
  final int userScore;
  final int botScore;
  final int currentQuestionIndex;
  final int totalQuestions;
  final bool? userAnsweredCorrectly;
  final bool? botAnsweredCorrectly;
  final bool isUserTurn;
  final bool isBotAnswering;
  final int? userSelectedIndex;
  final int? botSelectedIndex;
  final String? errorMessage;
  // Guess (Salla Bakalım) için ek alanlar
  final int? userGuess;
  final int? botGuess;
  final String? userTemperature;
  final String? botTemperature;
  final bool? userGuessCorrect;
  final bool? botGuessCorrect;
  // FindCards (Bul Bakalım) için ek alanlar
  final List<DuelMemoryCard>? memoryCards;
  final int nextExpectedNumber; // Sıradaki beklenen sayı (1-10)
  final bool isUserMemoryTurn; // Kullanıcının sırası mı?
  final int? lastFlippedCardId; // Son çevrilen kartın ID'si
  final bool isProcessingMemoryTurn; // Tur işleniyor mu?
  final String? memoryTurnMessage; // Durum mesajı

  const DuelState({
    this.status = DuelStatus.idle,
    this.gameType,
    this.botProfile,
    this.userScore = 0,
    this.botScore = 0,
    this.currentQuestionIndex = 0,
    this.totalQuestions = 5,
    this.userAnsweredCorrectly,
    this.botAnsweredCorrectly,
    this.isUserTurn = true,
    this.isBotAnswering = false,
    this.userSelectedIndex,
    this.botSelectedIndex,
    this.errorMessage,
    this.userGuess,
    this.botGuess,
    this.userTemperature,
    this.botTemperature,
    this.userGuessCorrect,
    this.botGuessCorrect,
    this.memoryCards,
    this.nextExpectedNumber = 1,
    this.isUserMemoryTurn = true,
    this.lastFlippedCardId,
    this.isProcessingMemoryTurn = false,
    this.memoryTurnMessage,
  });

  DuelState copyWith({
    DuelStatus? status,
    DuelGameType? gameType,
    BotProfile? botProfile,
    int? userScore,
    int? botScore,
    int? currentQuestionIndex,
    int? totalQuestions,
    bool? userAnsweredCorrectly,
    bool? botAnsweredCorrectly,
    bool? isUserTurn,
    bool? isBotAnswering,
    int? userSelectedIndex,
    int? botSelectedIndex,
    String? errorMessage,
    bool clearUserAnswer = false,
    bool clearBotAnswer = false,
    bool clearSelections = false,
    int? userGuess,
    int? botGuess,
    String? userTemperature,
    String? botTemperature,
    bool? userGuessCorrect,
    bool? botGuessCorrect,
    bool clearGuessData = false,
    List<DuelMemoryCard>? memoryCards,
    int? nextExpectedNumber,
    bool? isUserMemoryTurn,
    int? lastFlippedCardId,
    bool clearLastFlipped = false,
    bool? isProcessingMemoryTurn,
    String? memoryTurnMessage,
    bool clearMemoryMessage = false,
  }) {
    return DuelState(
      status: status ?? this.status,
      gameType: gameType ?? this.gameType,
      botProfile: botProfile ?? this.botProfile,
      userScore: userScore ?? this.userScore,
      botScore: botScore ?? this.botScore,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      userAnsweredCorrectly: clearUserAnswer
          ? null
          : (userAnsweredCorrectly ?? this.userAnsweredCorrectly),
      botAnsweredCorrectly: clearBotAnswer
          ? null
          : (botAnsweredCorrectly ?? this.botAnsweredCorrectly),
      isUserTurn: isUserTurn ?? this.isUserTurn,
      isBotAnswering: isBotAnswering ?? this.isBotAnswering,
      userSelectedIndex: clearSelections
          ? null
          : (userSelectedIndex ?? this.userSelectedIndex),
      botSelectedIndex: clearSelections
          ? null
          : (botSelectedIndex ?? this.botSelectedIndex),
      errorMessage: errorMessage,
      userGuess: clearGuessData ? null : (userGuess ?? this.userGuess),
      botGuess: clearGuessData ? null : (botGuess ?? this.botGuess),
      userTemperature: clearGuessData
          ? null
          : (userTemperature ?? this.userTemperature),
      botTemperature: clearGuessData
          ? null
          : (botTemperature ?? this.botTemperature),
      userGuessCorrect: clearGuessData
          ? null
          : (userGuessCorrect ?? this.userGuessCorrect),
      botGuessCorrect: clearGuessData
          ? null
          : (botGuessCorrect ?? this.botGuessCorrect),
      memoryCards: memoryCards ?? this.memoryCards,
      nextExpectedNumber: nextExpectedNumber ?? this.nextExpectedNumber,
      isUserMemoryTurn: isUserMemoryTurn ?? this.isUserMemoryTurn,
      lastFlippedCardId: clearLastFlipped
          ? null
          : (lastFlippedCardId ?? this.lastFlippedCardId),
      isProcessingMemoryTurn:
          isProcessingMemoryTurn ?? this.isProcessingMemoryTurn,
      memoryTurnMessage: clearMemoryMessage
          ? null
          : (memoryTurnMessage ?? this.memoryTurnMessage),
    );
  }
}

/// Düello controller provider
final duelControllerProvider = StateNotifierProvider<DuelController, DuelState>(
  (ref) {
    return DuelController();
  },
);

/// Düello controller - oyun mantığını yönetir
class DuelController extends StateNotifier<DuelState> {
  DuelController() : super(const DuelState());

  final DuelRepository _repository = DuelRepository();
  final BotLogicController _botLogic = BotLogicController();

  List<DuelQuestion> _testQuestions = [];
  List<DuelFillBlankQuestion> _fillBlankQuestions = [];
  List<DuelGuessQuestion> _guessQuestions = [];

  // Getters
  List<DuelQuestion> get testQuestions => _testQuestions;
  List<DuelFillBlankQuestion> get fillBlankQuestions => _fillBlankQuestions;
  List<DuelGuessQuestion> get guessQuestions => _guessQuestions;
  DuelQuestion? get currentTestQuestion =>
      state.currentQuestionIndex < _testQuestions.length
      ? _testQuestions[state.currentQuestionIndex]
      : null;
  DuelFillBlankQuestion? get currentFillBlankQuestion =>
      state.currentQuestionIndex < _fillBlankQuestions.length
      ? _fillBlankQuestions[state.currentQuestionIndex]
      : null;
  DuelGuessQuestion? get currentGuessQuestion =>
      state.currentQuestionIndex < _guessQuestions.length
      ? _guessQuestions[state.currentQuestionIndex]
      : null;

  /// Mevcut yarışma konusu/dosya adı
  String? get currentTopicName {
    switch (state.gameType) {
      case DuelGameType.test:
        return _testQuestions.isNotEmpty ? _testQuestions.first.topicName : null;
      case DuelGameType.fillBlanks:
        return _fillBlankQuestions.isNotEmpty ? _fillBlankQuestions.first.topicName : null;
      case DuelGameType.guess:
        return _guessQuestions.isNotEmpty ? _guessQuestions.first.topicName : null;
      default:
        return null;
    }
  }

  /// Oyun türünü seç ve başlat
  /// [userLevel] - Kullanıcının seviyesi (bot seviyesi buna göre belirlenir)
  Future<void> selectGameType(DuelGameType type, {int userLevel = 1}) async {
    state = state.copyWith(
      gameType: type,
      status: DuelStatus.searching,
      botProfile: BotProfile.random(userLevel: userLevel),
    );

    if (kDebugMode) debugPrint('🎮 Oyun türü seçildi: $type');
  }

  /// Soruları yükle
  Future<bool> loadQuestions() async {
    try {
      if (state.gameType == DuelGameType.test) {
        _testQuestions = await _repository.getTestQuestions();
        if (kDebugMode) {
          debugPrint('📚 ${_testQuestions.length} test sorusu yüklendi');
        }
      } else if (state.gameType == DuelGameType.fillBlanks) {
        _fillBlankQuestions = await _repository.getFillBlankQuestions();
        if (kDebugMode) {
          debugPrint(
            '📚 ${_fillBlankQuestions.length} cümle tamamlama sorusu yüklendi',
          );
        }
      } else if (state.gameType == DuelGameType.guess) {
        _guessQuestions = await _repository.getGuessQuestions();
        if (kDebugMode) {
          debugPrint(
            '📚 ${_guessQuestions.length} salla bakalım sorusu yüklendi',
          );
        }
      } else if (state.gameType == DuelGameType.findCards) {
        // Bul Bakalım için soru yükleme gerekmez, kartlar initMemoryGame'de oluşturulur
        if (kDebugMode) {
          debugPrint('🧠 Bul Bakalım oyunu hazırlanıyor');
        }
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Soru yükleme hatası: $e');
      state = state.copyWith(errorMessage: 'Sorular yüklenemedi');
      return false;
    }
  }

  /// Rakip bulundu - oyuna başla
  void startGame() {
    _botLogic.reset();
    state = state.copyWith(
      status: DuelStatus.playing,
      userScore: 0,
      botScore: 0,
      currentQuestionIndex: 0,
      isUserTurn: true,
      clearUserAnswer: true,
      clearBotAnswer: true,
      clearSelections: true,
      clearGuessData: true,
    );

    // Bul Bakalım için memory game başlat
    if (state.gameType == DuelGameType.findCards) {
      _initMemoryGame();
      return;
    }

    // Guess modunda bot kullanıcıdan sonra tahmin yapacak, diğer modlarda paralel
    if (state.gameType != DuelGameType.guess) {
      _startBotAnswering();
    }
  }

  /// Bot cevaplama sürecini başlat
  void _startBotAnswering() {
    if (state.status != DuelStatus.playing) return;

    state = state.copyWith(isBotAnswering: true);

    // Bot rastgele süre sonra cevap verecek
    final delay = _botLogic.getBotAnswerDelay();

    Future.delayed(delay, () {
      if (state.status == DuelStatus.playing && state.isBotAnswering) {
        _botAnswer();
      }
    });
  }

  /// Bot cevap verir
  void _botAnswer() {
    if (state.status != DuelStatus.playing) return;

    final shouldBeCorrect = _botLogic.shouldBotAnswerCorrectly();

    int botSelectedIndex;
    int correctIndex;

    if (state.gameType == DuelGameType.test) {
      final question = currentTestQuestion;
      if (question == null) return;
      correctIndex = question.correctIndex;
    } else {
      final question = currentFillBlankQuestion;
      if (question == null) return;
      correctIndex = question.options.indexOf(question.answer);
    }

    if (shouldBeCorrect) {
      botSelectedIndex = correctIndex;
    } else {
      // Yanlış bir seçenek seç
      final optionCount = state.gameType == DuelGameType.test
          ? currentTestQuestion!.options.length
          : currentFillBlankQuestion!.options.length;
      do {
        botSelectedIndex = DateTime.now().microsecond % optionCount;
      } while (botSelectedIndex == correctIndex);
    }

    _botLogic.updateBotScore(shouldBeCorrect);

    state = state.copyWith(
      botAnsweredCorrectly: shouldBeCorrect,
      botSelectedIndex: botSelectedIndex,
      botScore: _botLogic.botScore,
      isBotAnswering: false,
    );

    if (kDebugMode) {
      debugPrint(
        '🤖 Bot cevapladı: ${shouldBeCorrect ? "DOĞRU" : "YANLIŞ"} (Skor: ${_botLogic.botScore})',
      );
    }

    // Eğer kullanıcı da cevap verdiyse sonraki soruya geç
    _checkAndProceed();
  }

  /// Kullanıcı cevap verir
  void userAnswer(int selectedIndex, bool isCorrect) {
    if (state.status != DuelStatus.playing ||
        state.userAnsweredCorrectly != null) {
      return;
    }

    _botLogic.updateUserScore(isCorrect);

    state = state.copyWith(
      userAnsweredCorrectly: isCorrect,
      userSelectedIndex: selectedIndex,
      userScore: _botLogic.userScore,
    );

    if (kDebugMode) {
      debugPrint(
        '👤 Kullanıcı cevapladı: ${isCorrect ? "DOĞRU" : "YANLIŞ"} (Skor: ${_botLogic.userScore})',
      );
    }

    // Eğer bot da cevap verdiyse sonraki soruya geç
    _checkAndProceed();
  }

  /// Her iki taraf da cevapladıysa sonraki soruya geç
  void _checkAndProceed() {
    if (state.userAnsweredCorrectly != null &&
        state.botAnsweredCorrectly != null) {
      // 1.5 saniye bekle ve sonraki soruya geç
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextQuestion();
      });
    }
  }

  /// Sonraki soruya geç
  void _nextQuestion() {
    final nextIndex = state.currentQuestionIndex + 1;
    int totalQuestions;
    if (state.gameType == DuelGameType.test) {
      totalQuestions = _testQuestions.length;
    } else if (state.gameType == DuelGameType.fillBlanks) {
      totalQuestions = _fillBlankQuestions.length;
    } else {
      totalQuestions = _guessQuestions.length;
    }

    if (nextIndex >= totalQuestions) {
      // Oyun bitti
      state = state.copyWith(
        status: DuelStatus.finished,
        currentQuestionIndex: nextIndex,
      );
      if (kDebugMode) {
        debugPrint(
          '🏁 Oyun bitti! Kullanıcı: ${state.userScore}, Bot: ${state.botScore}',
        );
      }
    } else {
      // Sonraki soru
      _botLogic.nextQuestion();
      state = state.copyWith(
        currentQuestionIndex: nextIndex,
        clearUserAnswer: true,
        clearBotAnswer: true,
        clearSelections: true,
        clearGuessData: true,
      );

      // Guess modunda bot kullanıcıdan sonra tahmin yapacak, diğer modlarda paralel
      if (state.gameType != DuelGameType.guess) {
        _startBotAnswering();
      }
    }
  }

  /// Sonucu al
  DuelResult getResult() {
    return _botLogic.getResult();
  }

  /// Oyunu sıfırla
  void reset() {
    _botLogic.reset();
    _testQuestions = [];
    _fillBlankQuestions = [];
    _guessQuestions = [];
    state = const DuelState();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SALLA BAKALIM (GUESS) OYUN MANTIĞI
  // Her iki oyuncu birer tahmin yapar, doğru cevaba en yakın olan puan kazanır
  // ═══════════════════════════════════════════════════════════════════════════

  /// Kullanıcı tahmin gönderir (Salla Bakalım için)
  void userGuessAnswer(int guess) {
    if (state.status != DuelStatus.playing || state.userGuess != null) {
      return;
    }

    final question = currentGuessQuestion;
    if (question == null) return;

    final answer = question.answer;
    final tolerance = question.tolerance;
    final userDistance = (guess - answer).abs();
    final temperature = _calculateTemperature(guess, answer, tolerance);

    state = state.copyWith(userGuess: guess, userTemperature: temperature);

    if (kDebugMode) {
      debugPrint(
        '👤 Kullanıcı tahmin etti: $guess (Cevap: $answer, Uzaklık: $userDistance)',
      );
    }

    // Kullanıcı tahmin ettikten sonra bot tahmin yapar
    _startBotGuessing(answer, tolerance);
  }

  /// Bot tahmin yapar (Salla Bakalım için)
  void _startBotGuessing(int correctAnswer, int tolerance) {
    state = state.copyWith(isBotAnswering: true);

    // Bot 1-2 saniye düşünür
    final delay = Duration(
      milliseconds: 1000 + DateTime.now().millisecond % 1500,
    );

    Future.delayed(delay, () {
      if (state.status == DuelStatus.playing && state.isBotAnswering) {
        _botGuessAnswer(correctAnswer, tolerance);
      }
    });
  }

  /// Bot tahmin algoritması
  void _botGuessAnswer(int correctAnswer, int tolerance) {
    // Bot tahmini hesapla - kullanıcı tahminine ve skor durumuna göre
    final userGuess = state.userGuess ?? correctAnswer;
    final botGuess = _calculateBotGuess(correctAnswer, tolerance, userGuess);
    final temperature = _calculateTemperature(
      botGuess,
      correctAnswer,
      tolerance,
    );

    state = state.copyWith(
      botGuess: botGuess,
      botTemperature: temperature,
      isBotAnswering: false,
    );

    if (kDebugMode) {
      debugPrint('🤖 Bot tahmin etti: $botGuess (Cevap: $correctAnswer)');
    }

    // Her iki taraf da tahmin etti, kazananı belirle
    _determineGuessWinner(correctAnswer);
  }

  /// Bot tahmin hesaplama algoritması - Skor durumuna göre akıllı tahmin
  /// - Kullanıcı öndeyse: Bot daha yakın tahmin yapar (yetişmeye çalışır)
  /// - Bot öndeyse: Bot daha uzak tahmin yapar (kullanıcıya şans verir)
  /// - Beraberlikte: Tek sorularda yakın, çift sorularda uzak tahmin
  int _calculateBotGuess(int correctAnswer, int tolerance, int userGuess) {
    final random = DateTime.now().microsecond;
    final userScore = state.userScore;
    final botScore = state.botScore;
    final questionNum = state.currentQuestionIndex + 1; // 1-indexed

    // Kullanıcının doğru cevaba uzaklığı
    final userDistance = (userGuess - correctAnswer).abs();

    // Bot'un strateji durumu
    bool shouldBotWin;

    if (userScore > botScore) {
      // Kullanıcı önde - bot daha yakın tahmin yapmalı (yetişmeye çalışır)
      shouldBotWin = true;
    } else if (botScore > userScore) {
      // Bot önde - bot daha uzak tahmin yapmalı (kullanıcıya şans verir)
      shouldBotWin = false;
    } else {
      // Berabere - tek sorularda yakın, çift sorularda uzak
      shouldBotWin = questionNum.isOdd;
    }

    double botDistance;

    if (shouldBotWin) {
      // Bot kazanmaya çalışıyor - kullanıcıdan daha yakın tahmin yap
      // Kullanıcının uzaklığının %30-70'i kadar yakınlık
      final winRatio = 0.3 + (random % 40) / 100; // 0.30 - 0.70
      botDistance = (userDistance * winRatio).clamp(0.0, tolerance * 0.5);

      // Eğer kullanıcı çok yakınsa, bot biraz daha yakın olmaya çalışsın
      if (userDistance < tolerance * 0.1) {
        botDistance = (tolerance * (random % 8) / 100).clamp(
          0.0,
          userDistance * 0.8,
        );
      }
    } else {
      // Bot kaybetmeye çalışıyor - kullanıcıdan daha uzak tahmin yap
      // Kullanıcının uzaklığının 1.2-2x kadar uzaklık
      final loseRatio = 1.2 + (random % 80) / 100; // 1.20 - 2.00
      botDistance = (userDistance * loseRatio).clamp(
        tolerance * 0.3,
        tolerance * 1.5,
      );

      // Eğer kullanıcı çok uzaksa, bot biraz daha az uzakta olsun (ama yine kaybetsin)
      if (userDistance > tolerance * 0.8) {
        botDistance = userDistance + (tolerance * 0.1) + (random % 20);
      }
    }

    // Yön belirleme: doğru cevabın altında mı üstünde mi (rastgele)
    final direction = (random % 2 == 0) ? 1 : -1;
    var botGuess = correctAnswer + (botDistance * direction).round();

    // Negatif sayı kontrolü
    if (botGuess < 0) botGuess = botDistance.round().abs();

    if (kDebugMode) {
      debugPrint(
        '🎯 Bot strateji: ${shouldBotWin ? "KAZANMAYA" : "KAYBETMEYE"} çalışıyor '
        '(Skor: Kullanıcı $userScore - Bot $botScore, Soru: $questionNum)',
      );
      debugPrint(
        '📊 Uzaklıklar: Kullanıcı=$userDistance, Bot=${botDistance.round()}',
      );
    }

    return botGuess;
  }

  /// Kazananı belirle - doğru cevaba en yakın olan puan kazanır
  void _determineGuessWinner(int correctAnswer) {
    final userGuess = state.userGuess;
    final botGuess = state.botGuess;

    if (userGuess == null || botGuess == null) return;

    final userDistance = (userGuess - correctAnswer).abs();
    final botDistance = (botGuess - correctAnswer).abs();

    bool userWins;
    bool isDraw = false;

    if (userDistance < botDistance) {
      // Kullanıcı daha yakın tahmin etti
      userWins = true;
      _botLogic.updateUserScore(true);
    } else if (botDistance < userDistance) {
      // Bot daha yakın tahmin etti
      userWins = false;
      _botLogic.updateBotScore(true);
    } else {
      // Berabere - ikisi de puan almaz
      userWins = false;
      isDraw = true;
    }

    state = state.copyWith(
      userGuessCorrect: userWins,
      botGuessCorrect: !userWins && !isDraw,
      userScore: _botLogic.userScore,
      botScore: _botLogic.botScore,
    );

    if (kDebugMode) {
      if (isDraw) {
        debugPrint('🤝 Berabere! Her iki tahmin de eşit uzaklıkta.');
      } else {
        debugPrint(
          '${userWins ? "👤 Kullanıcı" : "🤖 Bot"} kazandı! '
          '(Kullanıcı: $userDistance, Bot: $botDistance uzaklıkta)',
        );
      }
    }

    // 2 saniye bekle ve sonraki soruya geç
    Future.delayed(const Duration(milliseconds: 2500), () {
      _nextQuestion();
    });
  }

  /// Sıcaklık hesaplama (tahmin ile doğru cevap arasındaki fark)
  String _calculateTemperature(int guess, int answer, int tolerance) {
    final difference = (guess - answer).abs();

    if (difference == 0) return 'correct';
    if (difference <= tolerance * 0.05) return 'correct';

    final ratio = difference / tolerance;

    if (ratio <= 0.1) return 'boiling';
    if (ratio <= 0.25) return 'hot';
    if (ratio <= 0.5) return 'warm';
    if (ratio <= 1.0) return 'cool';
    if (ratio <= 2.0) return 'cold';
    return 'freezing';
  }

  /// Kullanıcı sonraki soruya geçmek istiyor (Guess için)
  void skipGuessQuestion() {
    if (state.gameType == DuelGameType.guess) {
      _nextQuestion();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUL BAKALIM (FIND CARDS) OYUN MANTIĞI
  // Sıra bazlı kart eşleme oyunu - yanlış cevapta sıra değişir
  // ═══════════════════════════════════════════════════════════════════════════

  // Bot'un sınırlı hafızası - tüm kartları hatırlar ama yanlışları unutabilir
  final Map<int, int> _botCardMemory = {}; // cardId -> number
  final Random _random = Random();

  /// Memory oyununu başlat
  void _initMemoryGame() {
    _botCardMemory.clear();

    // 1-10 arası sayıları oluştur ve karıştır
    final numbers = List.generate(10, (i) => i + 1)..shuffle();

    // Kartları oluştur
    final cards = List.generate(10, (index) {
      return DuelMemoryCard(
        id: index,
        number: numbers[index],
        isFlipped: false,
        isMatched: false,
      );
    });

    state = state.copyWith(
      memoryCards: cards,
      nextExpectedNumber: 1,
      isUserMemoryTurn: true,
      isProcessingMemoryTurn: false,
      memoryTurnMessage: 'Senin sıran! 1 numaralı kartı bul.',
    );

    if (kDebugMode) {
      debugPrint(
        '🧠 Memory oyunu başlatıldı - ${cards.length} kart oluşturuldu',
      );
    }
  }

  /// Kullanıcı kart çevirir
  void flipMemoryCard(int cardId) {
    if (state.status != DuelStatus.playing) return;
    if (!state.isUserMemoryTurn) return;
    if (state.isProcessingMemoryTurn) return;

    final cards = state.memoryCards;
    if (cards == null) return;

    final cardIndex = cards.indexWhere((c) => c.id == cardId);
    if (cardIndex == -1) return;

    final card = cards[cardIndex];

    // Zaten açık veya eşleşmiş kartlara tıklanamaz
    if (card.isFlipped || card.isMatched) return;

    // Kartı çevir
    final newCards = List<DuelMemoryCard>.from(cards);
    newCards[cardIndex] = card.copyWith(isFlipped: true);

    state = state.copyWith(
      memoryCards: newCards,
      lastFlippedCardId: cardId,
      isProcessingMemoryTurn: true,
    );

    // Bot bu kartı hatırlasın
    _botRememberCard(cardId, card.number);

    // Doğru mu yanlış mı kontrol et
    _checkMemoryCard(card, isUser: true);
  }

  /// Kartı kontrol et
  void _checkMemoryCard(DuelMemoryCard card, {required bool isUser}) {
    if (card.number == state.nextExpectedNumber) {
      // DOĞRU!
      _handleMemoryCorrectGuess(card.id, isUser: isUser);
    } else {
      // YANLIŞ!
      _handleMemoryWrongGuess(isUser: isUser);
    }
  }

  /// Doğru kart bulundu
  void _handleMemoryCorrectGuess(int cardId, {required bool isUser}) {
    final cards = state.memoryCards;
    if (cards == null) return;

    final newCards = cards.map((c) {
      if (c.id == cardId) {
        return c.copyWith(isMatched: true, isFlipped: true);
      }
      return c;
    }).toList();

    final newExpected = state.nextExpectedNumber + 1;
    final currentPlayer = isUser ? 'Kullanıcı' : 'Bot';

    // Puan ekle
    if (isUser) {
      _botLogic.updateUserScore(true);
    } else {
      _botLogic.updateBotScore(true);
    }

    if (kDebugMode) {
      debugPrint(
        '✅ $currentPlayer doğru kart buldu: ${state.nextExpectedNumber}',
      );
    }

    // Oyun bitti mi?
    if (newExpected > 10) {
      state = state.copyWith(
        memoryCards: newCards,
        nextExpectedNumber: newExpected,
        status: DuelStatus.finished,
        userScore: _botLogic.userScore,
        botScore: _botLogic.botScore,
        isProcessingMemoryTurn: false,
        memoryTurnMessage: 'Oyun bitti!',
      );
      if (kDebugMode) {
        debugPrint(
          '🏁 Memory oyunu bitti! Kullanıcı: ${state.userScore}, Bot: ${state.botScore}',
        );
      }
    } else {
      // Devam - aynı oyuncu oynamaya devam eder
      state = state.copyWith(
        memoryCards: newCards,
        nextExpectedNumber: newExpected,
        userScore: _botLogic.userScore,
        botScore: _botLogic.botScore,
        isProcessingMemoryTurn: false,
        clearLastFlipped: true,
        memoryTurnMessage: isUser
            ? 'Harika! Şimdi $newExpected numaralı kartı bul.'
            : '${state.botProfile?.name ?? "Rakip"} doğru buldu! Sırası devam ediyor...',
      );

      // Bot sırası ise devam et
      if (!isUser) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _botPlayMemoryTurn();
        });
      }
    }
  }

  /// Yanlış kart - sıra değişir, TÜM kartlar kapanır (bulunanlar dahil)
  void _handleMemoryWrongGuess({required bool isUser}) {
    final currentPlayer = isUser ? 'Kullanıcı' : 'Bot';

    if (kDebugMode) {
      debugPrint('❌ $currentPlayer yanlış kart açtı! Sıra değişiyor.');
    }

    // 1.5 saniye bekle, TÜM kartları kapat ve sırayı değiştir
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (state.status != DuelStatus.playing) return;

      final cards = state.memoryCards;
      if (cards == null) return;

      // TÜM kartları kapat - eşleşenler DAHİL (oyun sıfırlanıyor)
      final newCards = cards.map((c) {
        return c.copyWith(isFlipped: false, isMatched: false);
      }).toList();

      // Sırayı değiştir ve sayacı sıfırla
      final newIsUserTurn = !isUser;

      state = state.copyWith(
        memoryCards: newCards,
        nextExpectedNumber: 1,
        isUserMemoryTurn: newIsUserTurn,
        isProcessingMemoryTurn: false,
        clearLastFlipped: true,
        memoryTurnMessage: newIsUserTurn
            ? 'Senin sıran! 1 numaralı kartı bul.'
            : '${state.botProfile?.name ?? "Rakip"} oynuyor...',
      );

      // Bot sırası ise bot oynasın
      if (!newIsUserTurn) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _botPlayMemoryTurn();
        });
      }
    });
  }

  /// Bot kart açar
  void _botPlayMemoryTurn() {
    if (state.status != DuelStatus.playing) return;
    if (state.isUserMemoryTurn) return;

    final cards = state.memoryCards;
    if (cards == null) return;

    // Bot düşünme süresi
    state = state.copyWith(
      isProcessingMemoryTurn: true,
      memoryTurnMessage: '${state.botProfile?.name ?? "Rakip"} düşünüyor...',
    );

    // Her tur başında bot biraz unutabilir
    _botForgetSomeCards();

    // 1-2 saniye düşün
    final thinkTime = Duration(milliseconds: 1000 + _random.nextInt(1500));
    Future.delayed(thinkTime, () {
      if (state.status != DuelStatus.playing) return;
      if (state.isUserMemoryTurn) return;

      final targetNumber = state.nextExpectedNumber;
      int? selectedCardId;

      // Hafızada bu sayı var mı?
      for (final entry in _botCardMemory.entries) {
        if (entry.value == targetNumber) {
          // Kartın hala açık olup olmadığını kontrol et
          final card = cards.firstWhere(
            (c) => c.id == entry.key,
            orElse: () => const DuelMemoryCard(id: -1, number: -1),
          );
          if (card.id != -1 && !card.isMatched && !card.isFlipped) {
            selectedCardId = entry.key;
            break;
          }
        }
      }

      // Hafızada yoksa rastgele seç - AMA hafızada olup hedef sayı olmayan kartları çıkar
      if (selectedCardId == null) {
        final availableCards = cards
            .where((c) => !c.isMatched && !c.isFlipped)
            .where((c) {
              // Hafızada bu kart var mı ve hedef sayı değil mi? O zaman seçme
              if (_botCardMemory.containsKey(c.id)) {
                return _botCardMemory[c.id] == targetNumber;
              }
              return true; // Hafızada değilse seçilebilir
            })
            .toList();

        if (availableCards.isEmpty) {
          // Eğer tüm kartlar hafızada ve yanlış ise, yine de bir tane seç (mecbur)
          final fallbackCards = cards
              .where((c) => !c.isMatched && !c.isFlipped)
              .toList();
          if (fallbackCards.isEmpty) return;
          selectedCardId =
              fallbackCards[_random.nextInt(fallbackCards.length)].id;
        } else {
          selectedCardId =
              availableCards[_random.nextInt(availableCards.length)].id;
        }
      }

      // Kartı aç
      final cardIndex = cards.indexWhere((c) => c.id == selectedCardId);
      if (cardIndex == -1) return;

      final card = cards[cardIndex];
      final newCards = List<DuelMemoryCard>.from(cards);
      newCards[cardIndex] = card.copyWith(isFlipped: true);

      state = state.copyWith(
        memoryCards: newCards,
        lastFlippedCardId: selectedCardId,
      );

      // Bot bu kartı hatırlasın
      _botRememberCard(selectedCardId, card.number);

      if (kDebugMode) {
        debugPrint(
          '🤖 Bot kart açtı: id=$selectedCardId, number=${card.number} (aranan: $targetNumber)',
        );
      }

      // Kontrol et
      _checkMemoryCard(card, isUser: false);
    });
  }

  /// Bot kartı hafızasına ekle
  void _botRememberCard(int cardId, int number) {
    _botCardMemory[cardId] = number;
    // Not: Hafıza limiti yok - tüm kartlar hatırlanır
    // Rekabetçilik _botForgetSomeCards ile sağlanır

    if (kDebugMode) {
      debugPrint('🧠 Bot hafızası: $_botCardMemory');
    }
  }

  /// Bot bazı YANLIŞ kartları unutabilir (doğru kartlar ASLA unutulmaz)
  void _botForgetSomeCards() {
    if (_botCardMemory.isEmpty) return;

    // Aranan sayıdan KÜÇÜK sayılar doğru bulunmuş demek - onları ASLA unutma
    // Sadece yanlış kartları (aranan sayıdan büyük olanları) unutabilir
    final targetNumber = state.nextExpectedNumber;

    // Unutulabilir kartlar: sayısı >= targetNumber olan kartlar
    final forgettableCards = _botCardMemory.entries
        .where((e) => e.value >= targetNumber)
        .toList();

    // %30 şansla bir yanlış kart unut
    if (_random.nextDouble() < 0.3 && forgettableCards.isNotEmpty) {
      final forgottenEntry =
          forgettableCards[_random.nextInt(forgettableCards.length)];
      _botCardMemory.remove(forgottenEntry.key);
      if (kDebugMode) {
        debugPrint(
          '🤖 Bot unuttu: cardId=${forgottenEntry.key} (sayı: ${forgottenEntry.value})',
        );
      }
    }
  }
}
