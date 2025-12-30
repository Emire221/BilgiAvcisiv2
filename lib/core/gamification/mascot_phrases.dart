import 'dart:math';

/// Maskot motivasyon cümleleri
class MascotPhrases {
  static final Random _random = Random();

  static const List<String> greetings = [
    'Bugün harikasın {name}!',
    'Hazır mısın {name}?',
    'Hadi {name}, başlayalım!',
    'Seninle gurur duyuyorum {name}!',
    'Bugün kendini aşacaksın {name}!',
  ];

  static const List<String> motivations = [
    'Test çözme zamanı!',
    'Bilgi avcılığına devam!',
    'Her soru bir adım daha!',
    'Başarı seninle!',
    'Öğrenmek çok eğlenceli!',
    'Video izlemeye ne dersin?',
    'Bilgi kartlarını deneyelim mi?',
  ];

  static const List<String> levelUpMessages = [
    'Tebrikler! Seviye {level} oldun!',
    'Harika! Artık {level}. seviyesin!',
    'Muhteşem! Seviye {level}!',
    'Bravo! {level}. seviyeye ulaştın!',
  ];

  static const List<String> xpGainMessages = [
    '+{xp} XP kazandın!',
    '{xp} deneyim puanı aldın!',
    'Harika! {xp} XP!',
  ];

  /// Rastgele selamlaşma mesajı
  static String getGreeting(String userName) {
    final message = greetings[_random.nextInt(greetings.length)];
    return message.replaceAll('{name}', userName);
  }

  /// Rastgele motivasyon mesajı
  static String getMotivation() {
    return motivations[_random.nextInt(motivations.length)];
  }

  /// Seviye atlama mesajı
  static String getLevelUpMessage(int level) {
    final message = levelUpMessages[_random.nextInt(levelUpMessages.length)];
    return message.replaceAll('{level}', level.toString());
  }

  /// XP kazanma mesajı
  static String getXpGainMessage(int xp) {
    final message = xpGainMessages[_random.nextInt(xpGainMessages.length)];
    return message.replaceAll('{xp}', xp.toString());
  }
}
