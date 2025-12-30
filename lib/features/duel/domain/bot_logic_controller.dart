import 'dart:math';

/// Bot'un akıllı cevap verme mantığını yöneten controller
///
/// Algoritma:
/// - Kullanıcı öndeyse: Bot doğru cevap verir (yakalamak için)
/// - Kullanıcı gerideyse: Bot yanlış cevap verir (kullanıcının yakalaması için)
/// - Beraberlik varsa: Tek sayılı beraberliklerde yanlış, çift sayılarda doğru
class BotLogicController {
  int _userScore = 0;
  int _botScore = 0;
  int _drawCount = 0;
  int _currentQuestionIndex = 0;

  final Random _random = Random();

  // Getters
  int get userScore => _userScore;
  int get botScore => _botScore;
  int get drawCount => _drawCount;
  int get currentQuestionIndex => _currentQuestionIndex;

  /// Kullanıcı puanını günceller
  void updateUserScore(bool isCorrect) {
    if (isCorrect) {
      _userScore++;
    }
  }

  /// Bot'un bu soruya doğru cevap verip vermeyeceğini hesaplar
  bool shouldBotAnswerCorrectly() {
    if (_userScore > _botScore) {
      // Kullanıcı öndeyse: Bot DOĞRU cevap verir (yakalamak için)
      return true;
    } else if (_userScore < _botScore) {
      // Kullanıcı gerideyse: Bot YANLIŞ cevap verir (kullanıcının yakalaması için)
      return false;
    } else {
      // Beraberlik durumu
      _drawCount++;
      // Tek sayılı beraberliklerde yanlış, çift sayılarda doğru
      return _drawCount % 2 == 0;
    }
  }

  /// Bot cevap verdikten sonra puanı günceller
  void updateBotScore(bool isCorrect) {
    if (isCorrect) {
      _botScore++;
    }
  }

  /// Sonraki soruya geç
  void nextQuestion() {
    _currentQuestionIndex++;
  }

  /// Bot'un cevap vermesi için rastgele süre (2-4 saniye arası)
  Duration getBotAnswerDelay() {
    final milliseconds = 2000 + _random.nextInt(2000); // 2000-4000 ms
    return Duration(milliseconds: milliseconds);
  }

  /// Oyunu sıfırla
  void reset() {
    _userScore = 0;
    _botScore = 0;
    _drawCount = 0;
    _currentQuestionIndex = 0;
  }

  /// Oyun sonucunu hesapla
  DuelResult getResult() {
    if (_userScore > _botScore) {
      return DuelResult.win;
    } else if (_userScore < _botScore) {
      return DuelResult.lose;
    } else {
      return DuelResult.draw;
    }
  }
}

/// Düello sonuç enum'u
enum DuelResult { win, lose, draw }
