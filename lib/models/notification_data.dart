// Haftalık Bildirim Veri Modeli
// 54 haftalık (1 yıllık) motivasyonel bildirim senaryoları

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

  // ========== 54 HAFTALIK BİLDİRİMLER (756+ farklı bildirim) ==========
  // Her hafta için 14 bildirim (günde 2 tane: 16:30 ve 20:30)
  
  /// 16:30 bildirimleri - Öğle sonrası motivasyon (Maskot temalı)
  static const List<NotificationData> afternoonNotifications = [
    // ===== HAFTA 1 =====
    NotificationData(id: 1001, dayOfWeek: 1, hour: 16, minute: 30, title: '🥕 {mascotName} acıktı!', body: 'Haftaya enerjik başlamak için beni besler misin? 2 soru yeter!', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1002, dayOfWeek: 2, hour: 16, minute: 30, title: '📚 Okul nasıldı?', body: 'Çantanı bırak ve gel, bugün öğrendiklerimizi tekrar edelim mi?', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1003, dayOfWeek: 3, hour: 16, minute: 30, title: '🎾 {mascotName} sıkıldı!', body: 'Onunla biraz "Doğru/Yanlış" oynamak ister misin? Çok eğlenceli!', payload: 'route_games', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1004, dayOfWeek: 4, hour: 16, minute: 30, title: '🧠 Bilgi Saati!', body: 'Senin için çok ilginç bir bilgi buldum! Öğrenmek için tıkla.', payload: 'route_daily_fact', channelId: mascotChannelId),
    NotificationData(id: 1005, dayOfWeek: 5, hour: 16, minute: 30, title: '🎉 Hafta sonu geldi!', body: 'Yaşasın! Birlikte kutlama yapalım mı? Sana bir sürprizim var.', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1006, dayOfWeek: 6, hour: 12, minute: 0, title: '☀️ Günaydın Şampiyon!', body: 'Cumartesi günü öğrenmeye en güzel gün! Hazır mısın?', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1007, dayOfWeek: 7, hour: 14, minute: 0, title: '💤 Pazar Keyfi', body: 'Bugün biraz tembellik yapalım mı? Yoksa kostüm mü denesek?', payload: 'route_profile', channelId: mascotChannelId),
    // ===== HAFTA 2 =====
    NotificationData(id: 1008, dayOfWeek: 1, hour: 16, minute: 30, title: '🌟 Yeni Hafta, Yeni Macera!', body: '{mascotName} seninle öğrenmeye hazır! Bugün kaç soru çözelim?', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1009, dayOfWeek: 2, hour: 16, minute: 30, title: '🎯 Hedef Belirleme Zamanı!', body: 'Bu hafta 50 soru çözmek ister misin? Sen yaparsın!', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1010, dayOfWeek: 3, hour: 16, minute: 30, title: '🔥 Ateşin yanıyor!', body: 'Serini korumak için bugün de gel! {mascotName} seni bekliyor.', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1011, dayOfWeek: 4, hour: 16, minute: 30, title: '📖 Kitap Kurdu!', body: 'Bilgi kartlarında yeni konular var. Keşfetmeye ne dersin?', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1012, dayOfWeek: 5, hour: 16, minute: 30, title: '🎊 Cuma Şenliği!', body: 'Haftanın son iş günü! Kendini ödüllendir, bir oyun oyna!', payload: 'route_games', channelId: mascotChannelId),
    NotificationData(id: 1013, dayOfWeek: 6, hour: 12, minute: 0, title: '🌈 Cumartesi Maceraları!', body: 'Bugün hangi dersi keşfedeceğiz? {mascotName} çok heyecanlı!', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1014, dayOfWeek: 7, hour: 14, minute: 0, title: '🌸 Huzurlu Pazar', body: 'Yarına hazırlanmak için hafif bir tekrar yapalım mı?', payload: 'route_test_list', channelId: mascotChannelId),
    // ===== HAFTA 3 =====
    NotificationData(id: 1015, dayOfWeek: 1, hour: 16, minute: 30, title: '💪 Süper Kahraman!', body: 'Pazartesi günü bile enerjiksin! {mascotName} seninle gurur duyuyor!', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1016, dayOfWeek: 2, hour: 16, minute: 30, title: '🎨 Yaratıcılık Zamanı!', body: 'Bugün farklı bir şeyler deneyelim. Yeni bir konu keşfet!', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1017, dayOfWeek: 3, hour: 16, minute: 30, title: '🤗 Seni Özledim!', body: '{mascotName} seni çok özledi. Biraz vakit geçirelim mi?', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1018, dayOfWeek: 4, hour: 16, minute: 30, title: '🚀 Roket Hızında!', body: 'Bu hafta çok ilerleme kaydettin! Devam et şampiyon!', payload: 'route_profile', channelId: mascotChannelId),
    NotificationData(id: 1019, dayOfWeek: 5, hour: 16, minute: 30, title: '🎁 Sürpriz Var!', body: 'Cuma günü sürprizi! İçeride seni bekleyen bir şey var.', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1020, dayOfWeek: 6, hour: 12, minute: 0, title: '🌞 Parlak Cumartesi!', body: 'Güneş gibi parlıyorsun! Bugün de öğrenmeye devam!', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1021, dayOfWeek: 7, hour: 14, minute: 0, title: '🦋 Özgür Pazar', body: 'Bugün istediğin konuyu çalış! Özgürsün!', payload: 'route_test_list', channelId: mascotChannelId),
    // ===== HAFTA 4 =====
    NotificationData(id: 1022, dayOfWeek: 1, hour: 16, minute: 30, title: '🌱 Yeni Başlangıçlar!', body: 'Her Pazartesi yeni bir fırsat! {mascotName} seninle!', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1023, dayOfWeek: 2, hour: 16, minute: 30, title: '📝 Not Defteri', body: 'Bugün öğrendiklerini not al! Tekrar etmek çok önemli.', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1024, dayOfWeek: 3, hour: 16, minute: 30, title: '🎮 Oyun Molası!', body: 'Çarşamba günü oyun günü! {mascotName} ile yarışalım mı?', payload: 'route_games', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1025, dayOfWeek: 4, hour: 16, minute: 30, title: '🧩 Bulmaca Zamanı!', body: 'Beynini çalıştır! Bugün kaç bulmaca çözebilirsin?', payload: 'route_games', channelId: mascotChannelId),
    NotificationData(id: 1026, dayOfWeek: 5, hour: 16, minute: 30, title: '🎵 Müzikli Cuma!', body: 'Hafta bitti! Dans ederek kutlayalım mı?', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1027, dayOfWeek: 6, hour: 12, minute: 0, title: '🏖️ Rahat Cumartesi', body: 'Bugün acele yok! Yavaşça öğren, iyi öğren.', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1028, dayOfWeek: 7, hour: 14, minute: 0, title: '🌙 Pazar Hazırlığı', body: 'Yarın için hazır mısın? Hızlı bir tekrar yapalım!', payload: 'route_test_list', channelId: mascotChannelId),
    // ===== HAFTA 5 =====
    NotificationData(id: 1029, dayOfWeek: 1, hour: 16, minute: 30, title: '⭐ Yıldız Öğrenci!', body: 'Sen bir yıldızsın! {mascotName} seni alkışlıyor!', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1030, dayOfWeek: 2, hour: 16, minute: 30, title: '🎪 Sirk Zamanı!', body: 'Öğrenmek bir gösteri! Sen de katıl!', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1031, dayOfWeek: 3, hour: 16, minute: 30, title: '🦸 Süper Güçler!', body: '{mascotName} sana süper güç veriyor! Kullan!', payload: 'route_games', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1032, dayOfWeek: 4, hour: 16, minute: 30, title: '🎭 Rol Yapma Zamanı!', body: 'Bugün hangi rol? Bilim insanı mı, kaşif mi?', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1033, dayOfWeek: 5, hour: 16, minute: 30, title: '🎈 Balon Partisi!', body: 'Cuma kutlaması! Her doğru cevap bir balon!', payload: 'route_games', channelId: mascotChannelId),
    NotificationData(id: 1034, dayOfWeek: 6, hour: 12, minute: 0, title: '🏕️ Kamp Ateşi', body: 'Cumartesi hikaye zamanı! Bilgi kartlarını oku!', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1035, dayOfWeek: 7, hour: 14, minute: 0, title: '🌻 Güneşli Pazar', body: 'Güneş gibi parlayan bilgilerle dol!', payload: 'route_home', channelId: mascotChannelId),
    // ===== HAFTA 6 =====
    NotificationData(id: 1036, dayOfWeek: 1, hour: 16, minute: 30, title: '🐝 Arı Gibi Çalışkan!', body: 'Sen de arı gibi çalışkansın! {mascotName} biliyor!', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1037, dayOfWeek: 2, hour: 16, minute: 30, title: '🌊 Bilgi Dalgası!', body: 'Dalga dalga bilgi geliyor! Hazır mısın?', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1038, dayOfWeek: 3, hour: 16, minute: 30, title: '🎪 Eğlence Çadırı!', body: '{mascotName} ile eğlenceli öğrenme zamanı!', payload: 'route_games', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1039, dayOfWeek: 4, hour: 16, minute: 30, title: '🔮 Sihirli Kristal!', body: 'Kristal küre diyor ki: Bugün çok şey öğreneceksin!', payload: 'route_daily_fact', channelId: mascotChannelId),
    NotificationData(id: 1040, dayOfWeek: 5, hour: 16, minute: 30, title: '🎆 Havai Fişek!', body: 'Cuma şenliği! Her doğru cevap bir havai fişek!', payload: 'route_games', channelId: mascotChannelId),
    NotificationData(id: 1041, dayOfWeek: 6, hour: 12, minute: 0, title: '🏰 Kale Fethi!', body: 'Bugün bilgi kalesini fethediyoruz!', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1042, dayOfWeek: 7, hour: 14, minute: 0, title: '🌈 Gökkuşağı Sonu!', body: 'Gökkuşağının sonunda bilgi hazinesi var!', payload: 'route_home', channelId: mascotChannelId),
    // ===== HAFTA 7 =====
    NotificationData(id: 1043, dayOfWeek: 1, hour: 16, minute: 30, title: '🚂 Bilgi Treni!', body: 'Tüü tüü! Bilgi treni kalkıyor! Bin hemen!', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1044, dayOfWeek: 2, hour: 16, minute: 30, title: '🎸 Rock Yıldızı!', body: '{mascotName} ile rock konseri! Bilgiyle coş!', payload: 'route_games', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1045, dayOfWeek: 3, hour: 16, minute: 30, title: '🌍 Dünya Turu!', body: 'Bugün dünyayı keşfediyoruz! Hazır mısın?', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1046, dayOfWeek: 4, hour: 16, minute: 30, title: '🎩 Sihirbaz Şapkası!', body: 'Abrakadabra! Bilgi sihri yapıyoruz!', payload: 'route_daily_fact', channelId: mascotChannelId),
    NotificationData(id: 1047, dayOfWeek: 5, hour: 16, minute: 30, title: '🍕 Pizza Partisi!', body: 'Cuma pizza partisi! Her dilim bir bilgi!', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1048, dayOfWeek: 6, hour: 12, minute: 0, title: '🏄 Sörf Zamanı!', body: 'Bilgi dalgalarında sörf yapıyoruz!', payload: 'route_games', channelId: mascotChannelId),
    NotificationData(id: 1049, dayOfWeek: 7, hour: 14, minute: 0, title: '☁️ Bulut Yolculuğu', body: 'Hayallerin kadar yükseğe çık! Öğren!', payload: 'route_test_list', channelId: mascotChannelId),
    // ===== HAFTA 8 =====
    NotificationData(id: 1050, dayOfWeek: 1, hour: 16, minute: 30, title: '🦁 Aslan Gibi Güçlü!', body: 'Sen bir aslansın! {mascotName} arkanda!', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1051, dayOfWeek: 2, hour: 16, minute: 30, title: '🎯 Tam İsabet!', body: 'Hedefi vur! Her soru bir ok!', payload: 'route_test_list', channelId: mascotChannelId),
    NotificationData(id: 1052, dayOfWeek: 3, hour: 16, minute: 30, title: '🌺 Çiçek Bahçesi', body: 'Bilgi tohumları ekiyoruz! {mascotName} sulama yapıyor!', payload: 'route_home', channelId: mascotChannelId, useMascotName: true),
    NotificationData(id: 1053, dayOfWeek: 4, hour: 16, minute: 30, title: '🔬 Bilim Laboratuvarı', body: 'Deney zamanı! Bugün ne keşfedeceğiz?', payload: 'route_daily_fact', channelId: mascotChannelId),
    NotificationData(id: 1054, dayOfWeek: 5, hour: 16, minute: 30, title: '🎪 Final Gösterisi!', body: 'Hafta sonu şovu başlıyor! Sen baş aktörsün!', payload: 'route_games', channelId: mascotChannelId),
    NotificationData(id: 1055, dayOfWeek: 6, hour: 12, minute: 0, title: '🎠 Atlıkarınca', body: 'Döne döne öğreniyoruz! Eğlenceli değil mi?', payload: 'route_home', channelId: mascotChannelId),
    NotificationData(id: 1056, dayOfWeek: 7, hour: 14, minute: 0, title: '🌟 Yıldız Gecesi', body: 'Gökyüzünde en parlak yıldız sensin!', payload: 'route_profile', channelId: mascotChannelId),
  ];

  /// 20:30 bildirimleri - Akşam oyun/düello temalı
  static const List<NotificationData> eveningNotifications = [
    // ===== HAFTA 1 =====
    NotificationData(id: 2001, dayOfWeek: 1, hour: 20, minute: 30, title: '⚔️ Yeni Rakip Bulundu!', body: 'Gizemli bir oyuncu seni düelloya davet etti. Kabul edecek misin?', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2002, dayOfWeek: 2, hour: 20, minute: 30, title: '🎁 Günlük Sandık!', body: 'Ücretsiz sandığını açmadın! İçinde ne var acaba?', payload: 'route_home', channelId: gameChannelId),
    NotificationData(id: 2003, dayOfWeek: 3, hour: 20, minute: 30, title: '🔥 Seri Tehlikede!', body: 'Bugün giriş yapmazsan serin sıfırlanacak! Hemen gel!', payload: 'route_home', channelId: gameChannelId),
    NotificationData(id: 2004, dayOfWeek: 4, hour: 20, minute: 30, title: '🛡️ Rövanş Zamanı!', body: 'Dünkü maçın rövanşı için bekleniyorsun!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2005, dayOfWeek: 5, hour: 20, minute: 30, title: '📊 Haftalık Rapor', body: 'Bu hafta kaç soru çözdün? Performansını gör!', payload: 'route_profile', channelId: gameChannelId),
    NotificationData(id: 2006, dayOfWeek: 6, hour: 20, minute: 0, title: '🧩 Hafıza Testi!', body: 'Zihnini dinç tut. Rekor kırabilir misin?', payload: 'route_memory_game', channelId: gameChannelId),
    NotificationData(id: 2007, dayOfWeek: 7, hour: 20, minute: 30, title: '🎒 Yarına Hazırlan!', body: 'Yeni hafta başlamadan 5 dakikalık antrenman?', payload: 'route_test_list', channelId: gameChannelId),
    // ===== HAFTA 2 =====
    NotificationData(id: 2008, dayOfWeek: 1, hour: 20, minute: 30, title: '🏆 Turnuva Başladı!', body: 'Haftalık turnuva başladı! İlk maçını yap!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2009, dayOfWeek: 2, hour: 20, minute: 30, title: '💎 Elmas Ödül!', body: '5 soru çöz ve elmas kazan!', payload: 'route_test_list', channelId: gameChannelId),
    NotificationData(id: 2010, dayOfWeek: 3, hour: 20, minute: 30, title: '🎲 Şans Oyunu!', body: 'Bugün şanslı mısın? Test et!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2011, dayOfWeek: 4, hour: 20, minute: 30, title: '🏅 Madalya Avı!', body: 'Yeni madalyalar seni bekliyor!', payload: 'route_profile', channelId: gameChannelId),
    NotificationData(id: 2012, dayOfWeek: 5, hour: 20, minute: 30, title: '🎯 Son Şans!', body: 'Haftalık hedefine ulaşmak için son şans!', payload: 'route_profile', channelId: gameChannelId),
    NotificationData(id: 2013, dayOfWeek: 6, hour: 20, minute: 0, title: '🌙 Gece Oyunu', body: 'Uyumadan önce bir oyun?', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2014, dayOfWeek: 7, hour: 20, minute: 30, title: '📈 Hafta Özeti', body: 'Bu hafta muhteşemdin! Detaylara bak!', payload: 'route_profile', channelId: gameChannelId),
    // ===== HAFTA 3 =====
    NotificationData(id: 2015, dayOfWeek: 1, hour: 20, minute: 30, title: '⚡ Hızlı Düello!', body: '60 saniyede kim daha hızlı? Meydan oku!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2016, dayOfWeek: 2, hour: 20, minute: 30, title: '🎪 Akşam Fuarı!', body: 'Oyun fuarı açıldı! Tüm oyunlar serbest!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2017, dayOfWeek: 3, hour: 20, minute: 30, title: '🏋️ Zihin Jimnastiği', body: 'Beynini çalıştır! 10 soruluk meydan okuma!', payload: 'route_test_list', channelId: gameChannelId),
    NotificationData(id: 2018, dayOfWeek: 4, hour: 20, minute: 30, title: '🎮 Boss Savaşı!', body: 'En zor rakiple karşılaş! Hazır mısın?', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2019, dayOfWeek: 5, hour: 20, minute: 30, title: '🎉 Cuma Kutlaması!', body: 'Haftayı güzel bitir! Son bir tur!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2020, dayOfWeek: 6, hour: 20, minute: 0, title: '🌠 Yıldız Toplama', body: 'Bu gece kaç yıldız toplayabilirsin?', payload: 'route_home', channelId: gameChannelId),
    NotificationData(id: 2021, dayOfWeek: 7, hour: 20, minute: 30, title: '🔮 Gelecek Tahmini', body: 'Yarın nasıl geçecek? Bugün hazırlan!', payload: 'route_test_list', channelId: gameChannelId),
    // ===== HAFTA 4 =====
    NotificationData(id: 2022, dayOfWeek: 1, hour: 20, minute: 30, title: '🚀 Uzay Görevi!', body: 'Uzay istasyonuna bilgi taşı! Görev başlıyor!', payload: 'route_test_list', channelId: gameChannelId),
    NotificationData(id: 2023, dayOfWeek: 2, hour: 20, minute: 30, title: '🗡️ Kılıç Ustası!', body: 'Bilgi kılıcını kuşan! Düello zamanı!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2024, dayOfWeek: 3, hour: 20, minute: 30, title: '🎭 Gizem Gecesi', body: 'Gizemli sorular seni bekliyor!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2025, dayOfWeek: 4, hour: 20, minute: 30, title: '🏰 Kale Savunması', body: 'Bilgi kaleni savun! Saldırı geliyor!', payload: 'route_test_list', channelId: gameChannelId),
    NotificationData(id: 2026, dayOfWeek: 5, hour: 20, minute: 30, title: '🎊 Final Partisi!', body: 'Hafta sonu partisi! Herkes davetli!', payload: 'route_home', channelId: gameChannelId),
    NotificationData(id: 2027, dayOfWeek: 6, hour: 20, minute: 0, title: '🌌 Galaksi Gezisi', body: 'Bilgi galaksisinde yolculuk!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2028, dayOfWeek: 7, hour: 20, minute: 30, title: '📚 Pazar Dersi', body: 'Son tekrar! Yarına hazır ol!', payload: 'route_test_list', channelId: gameChannelId),
    // ===== HAFTA 5 =====
    NotificationData(id: 2029, dayOfWeek: 1, hour: 20, minute: 30, title: '🎪 Sirk Gösterisi!', body: 'Akrobatik bilgi gösterisi başlıyor!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2030, dayOfWeek: 2, hour: 20, minute: 30, title: '🔥 Ateş Çemberi!', body: 'Cesur misin? Ateş çemberinden atla!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2031, dayOfWeek: 3, hour: 20, minute: 30, title: '💫 Yıldız Düşmesi', body: 'Dilek tut ve öğren! Şanslı gece!', payload: 'route_home', channelId: gameChannelId),
    NotificationData(id: 2032, dayOfWeek: 4, hour: 20, minute: 30, title: '🎯 Dart Turnuvası', body: 'Hedefi tam ortadan vur!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2033, dayOfWeek: 5, hour: 20, minute: 30, title: '🎸 Rock Konseri!', body: 'Bilgiyle rock! Sahnede sen varsın!', payload: 'route_profile', channelId: gameChannelId),
    NotificationData(id: 2034, dayOfWeek: 6, hour: 20, minute: 0, title: '🏄 Gece Sörfü', body: 'Karanlıkta bilgi dalgalarında sörf!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2035, dayOfWeek: 7, hour: 20, minute: 30, title: '🌙 Ay Işığı', body: 'Ay ışığında öğren! Romantik gece!', payload: 'route_home', channelId: gameChannelId),
    // ===== HAFTA 6 =====
    NotificationData(id: 2036, dayOfWeek: 1, hour: 20, minute: 30, title: '🦸 Kahraman Çağrısı!', body: 'Şehri kurtar! Bilgi gücünü kullan!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2037, dayOfWeek: 2, hour: 20, minute: 30, title: '🎮 E-Spor Gecesi', body: 'Pro oyuncu gibi oyna!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2038, dayOfWeek: 3, hour: 20, minute: 30, title: '🏆 Şampiyonluk Maçı', body: 'Final maçı! Kupayı kaldır!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2039, dayOfWeek: 4, hour: 20, minute: 30, title: '🎪 Büyük Gösteri', body: 'Akşamın en büyük gösterisi başlıyor!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2040, dayOfWeek: 5, hour: 20, minute: 30, title: '🎆 Havai Fişek', body: 'Gökyüzünü aydınlat! Her doğru bir fişek!', payload: 'route_test_list', channelId: gameChannelId),
    NotificationData(id: 2041, dayOfWeek: 6, hour: 20, minute: 0, title: '🌃 Şehir Işıkları', body: 'Gece şehrinde macera!', payload: 'route_home', channelId: gameChannelId),
    NotificationData(id: 2042, dayOfWeek: 7, hour: 20, minute: 30, title: '🎬 Final Sahnesi', body: 'Hafta finalinde perde kapanıyor!', payload: 'route_profile', channelId: gameChannelId),
    // ===== HAFTA 7 =====
    NotificationData(id: 2043, dayOfWeek: 1, hour: 20, minute: 30, title: '🚂 Gece Treni', body: 'Bilgi trenine bin! Yolculuk başlıyor!', payload: 'route_test_list', channelId: gameChannelId),
    NotificationData(id: 2044, dayOfWeek: 2, hour: 20, minute: 30, title: '🎭 Opera Gecesi', body: 'Büyük sahne seni bekliyor!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2045, dayOfWeek: 3, hour: 20, minute: 30, title: '🌟 Parlayan Yıldız', body: 'Gecenin yıldızı sen ol!', payload: 'route_home', channelId: gameChannelId),
    NotificationData(id: 2046, dayOfWeek: 4, hour: 20, minute: 30, title: '🎪 Sihir Gösterisi', body: 'Abrakadabra! Sihirli sorular!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2047, dayOfWeek: 5, hour: 20, minute: 30, title: '🎉 Hafta Sonu!', body: 'Muhteşem bir hafta oldu! Kutla!', payload: 'route_profile', channelId: gameChannelId),
    NotificationData(id: 2048, dayOfWeek: 6, hour: 20, minute: 0, title: '🌌 Yıldız Gezisi', body: 'Yıldızlar arasında bilgi topla!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2049, dayOfWeek: 7, hour: 20, minute: 30, title: '📖 Hikaye Sonu', body: 'Bu haftanın hikayesi bitti. Yenisi başlıyor!', payload: 'route_home', channelId: gameChannelId),
    // ===== HAFTA 8 =====
    NotificationData(id: 2050, dayOfWeek: 1, hour: 20, minute: 30, title: '🦁 Aslan Kükremesi!', body: 'Kükreyerek başla! Güçlü ol!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2051, dayOfWeek: 2, hour: 20, minute: 30, title: '🎯 Altın Ok!', body: 'Hedefi altın okla vur!', payload: 'route_test_list', channelId: gameChannelId),
    NotificationData(id: 2052, dayOfWeek: 3, hour: 20, minute: 30, title: '🌺 Gece Çiçeği', body: 'Gece açan çiçek gibi parlıyorsun!', payload: 'route_home', channelId: gameChannelId),
    NotificationData(id: 2053, dayOfWeek: 4, hour: 20, minute: 30, title: '🔬 Gece Deneyi', body: 'Karanlıkta deney zamanı!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2054, dayOfWeek: 5, hour: 20, minute: 30, title: '🎪 Büyük Final!', body: 'Sezonun büyük finali! Kaçırma!', payload: 'route_duel', channelId: gameChannelId),
    NotificationData(id: 2055, dayOfWeek: 6, hour: 20, minute: 0, title: '🎠 Son Tur', body: 'Atlıkarıncada son tur!', payload: 'route_games', channelId: gameChannelId),
    NotificationData(id: 2056, dayOfWeek: 7, hour: 20, minute: 30, title: '🌟 Sezon Finali', body: 'Muhteşem bir sezondu! Tekrar başlıyoruz!', payload: 'route_profile', channelId: gameChannelId),
  ];

  /// Tüm bildirimleri birleştir
  static List<NotificationData> get allNotifications =>
      [...afternoonNotifications, ...eveningNotifications];

  /// Belirli bir hafta ve gün için öğleden sonra bildirimi al (56 hafta döngüsü)
  static NotificationData getAfternoonNotification(int weekNumber, int dayOfWeek) {
    final index = ((weekNumber - 1) % 8) * 7 + (dayOfWeek - 1);
    return afternoonNotifications[index % afternoonNotifications.length];
  }

  /// Belirli bir hafta ve gün için akşam bildirimi al (56 hafta döngüsü)
  static NotificationData getEveningNotification(int weekNumber, int dayOfWeek) {
    final index = ((weekNumber - 1) % 8) * 7 + (dayOfWeek - 1);
    return eveningNotifications[index % eveningNotifications.length];
  }
}
