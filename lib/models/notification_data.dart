// Haftalık Bildirim Veri Modeli
// Master Plan'a göre 14 farklı bildirim senaryosu

class NotificationData {
  final int id;
  final int dayOfWeek; // 1=Pazartesi, 7=Pazar (DateTime.monday = 1)
  final int hour;
  final int minute;
  final String title;
  final String body;
  final String payload;
  final String channelId;
  final bool useMascotName; // Başlık/body'de {mascotName} kullanılacak mı

  const NotificationData({
    required this.id,
    required this.dayOfWeek,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
    required this.payload,
    required this.channelId,
    this.useMascotName = false,
  });

  /// Başlık ve body'deki {mascotName} placeholder'ını değiştirir
  String getTitle(String mascotName) {
    return title.replaceAll('{mascotName}', mascotName);
  }

  String getBody(String mascotName) {
    return body.replaceAll('{mascotName}', mascotName);
  }

  // ========== KANAL TANIMLARI ==========
  static const String mascotChannelId = 'mascot_channel';
  static const String mascotChannelName = 'Maskot Bildirimleri';
  static const String mascotChannelDesc =
      'Maskotunuzdan duygusal mesajlar ve hatırlatmalar';

  static const String gameChannelId = 'game_channel';
  static const String gameChannelName = 'Oyun Bildirimleri';
  static const String gameChannelDesc =
      'Düellolar, yarışmalar ve aksiyon bildirimleri';

  // ========== 14 HAFTALIK SENARYO ==========
  static const List<NotificationData> weeklyNotifications = [
    // ===== PAZARTESİ =====
    NotificationData(
      id: 100,
      dayOfWeek: 1, // Pazartesi
      hour: 16,
      minute: 30,
      title: '🥕 {mascotName} acıktı!',
      body: 'Haftaya enerjik başlamak için beni besler misin? 2 soru yeter!',
      payload: 'route_home',
      channelId: mascotChannelId,
      useMascotName: true,
    ),
    NotificationData(
      id: 200,
      dayOfWeek: 1,
      hour: 20,
      minute: 30,
      title: '⚔️ Yeni bir rakibin var',
      body: 'Gizemli bir oyuncu seni düelloya davet etti. Kabul edecek misin?',
      payload: 'route_duel',
      channelId: gameChannelId,
    ),

    // ===== SALI =====
    NotificationData(
      id: 101,
      dayOfWeek: 2, // Salı
      hour: 16,
      minute: 30,
      title: '📚 Okul nasıldı?',
      body: 'Çantanı bırak ve gel, bugün öğrendiklerimizi tekrar edelim mi?',
      payload: 'route_home',
      channelId: mascotChannelId,
    ),
    NotificationData(
      id: 201,
      dayOfWeek: 2,
      hour: 20,
      minute: 30,
      title: '🎁 Hazine Sandığı',
      body:
          'Günlük ücretsiz sandığını açmadın! İçinde ne olduğunu merak etmiyor musun?',
      payload: 'route_chest',
      channelId: gameChannelId,
    ),

    // ===== ÇARŞAMBA =====
    NotificationData(
      id: 102,
      dayOfWeek: 3, // Çarşamba
      hour: 16,
      minute: 30,
      title: '🎾 Oyun istiyor...',
      body:
          '{mascotName} çok sıkıldı. Onunla biraz \'Doğru/Yanlış\' oynamak ister misin?',
      payload: 'route_games',
      channelId: mascotChannelId,
      useMascotName: true,
    ),
    NotificationData(
      id: 202,
      dayOfWeek: 3,
      hour: 20,
      minute: 30,
      title: '🔥 Serin Tehlikede!',
      body:
          'Bugün giriş yapmazsan serin sıfırlanacak. Hemen gel ve ateşini koru!',
      payload: 'route_home',
      channelId: gameChannelId,
    ),

    // ===== PERŞEMBE =====
    NotificationData(
      id: 103,
      dayOfWeek: 4, // Perşembe
      hour: 16,
      minute: 30,
      title: '🧠 Bilgi Saati',
      body: 'Senin için çok ilginç bir bilgi buldum! Öğrenmek için tıkla.',
      payload: 'route_daily_fact',
      channelId: mascotChannelId,
    ),
    NotificationData(
      id: 203,
      dayOfWeek: 4,
      hour: 20,
      minute: 30,
      title: '🛡️ Rövanş Zamanı',
      body: 'Dünkü maçın rövanşı için bekleniyorsun. Kalkanlarını hazırla!',
      payload: 'route_duel',
      channelId: gameChannelId,
    ),

    // ===== CUMA =====
    NotificationData(
      id: 104,
      dayOfWeek: 5, // Cuma
      hour: 16,
      minute: 30,
      title: '🎉 Hafta sonu geldi!',
      body: 'Yaşasın! Birlikte kutlama yapalım mı? Sana bir sürprizim var.',
      payload: 'route_home',
      channelId: mascotChannelId,
    ),
    NotificationData(
      id: 204,
      dayOfWeek: 5,
      hour: 20,
      minute: 30,
      title: '📊 Haftalık Rapor',
      body: 'Bu hafta kaç soru çözdün? Performansını görmek için hemen gir.',
      payload: 'route_profile',
      channelId: gameChannelId,
    ),

    // ===== CUMARTESİ =====
    NotificationData(
      id: 105,
      dayOfWeek: 6, // Cumartesi
      hour: 12,
      minute: 0,
      title: '🏆 Hafta Sonu Turnuvası',
      body: 'Liderlik tablosu sıfırlandı! En tepeye çıkmak için şimdi başla.',
      payload: 'route_leaderboard',
      channelId: gameChannelId,
    ),
    NotificationData(
      id: 205,
      dayOfWeek: 6,
      hour: 20,
      minute: 0,
      title: '🧩 Hafıza Testi',
      body: 'Zihnini dinç tut. Hafıza kartları oyununda rekor kırabilir misin?',
      payload: 'route_memory_game',
      channelId: gameChannelId,
    ),

    // ===== PAZAR =====
    NotificationData(
      id: 106,
      dayOfWeek: 7, // Pazar
      hour: 14,
      minute: 0,
      title: '💤 Pazar Keyfi',
      body: 'Bugün biraz tembellik yapalım mı? Yoksa kostüm mü denesek?',
      payload: 'route_shop',
      channelId: mascotChannelId,
    ),
    NotificationData(
      id: 206,
      dayOfWeek: 7,
      hour: 20,
      minute: 30,
      title: '🎒 Yarına Hazır mısın?',
      body:
          'Yeni hafta başlamadan önce zihnimizi ısıtalım. 5 dakikalık antrenman?',
      payload: 'route_test_list',
      channelId: gameChannelId,
    ),
  ];
}
