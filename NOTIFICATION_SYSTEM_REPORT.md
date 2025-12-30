# Yerel Bildirim Sistemi Raporu 🔔

**Rapor Tarihi:** 31 Aralık 2025  
**Sürüm:** v1.0.0
**Konu:** Otomatik Bildirimler, UI Entegrasyonu ve Teknik Detaylar

---

## 1. Yönetici Özeti

Bilgi Avcısı uygulamasının kullanıcı bağlılığını artırmak (retention) ve düzenli kullanımı teşvik etmek amacıyla kapsamlı bir **Yerel Bildirim Sistemi (Local Notification System)** geliştirilmiştir. Bu sistem, dış sunucu bağımlılığı olmadan cihaz üzerinde çalışan akıllı bir mekanizmadır.

**Öne Çıkan Özellikler:**
- **14 Farklı Senaryo:** Haftanın her günü için özelleştirilmiş 2 farklı bildirim (Örn: Maskot besleme, Düello daveti).
- **Akıllı UI Entegrasyonu:**
  - **Red Dot (Kırmızı Nokta):** Sadece okunmamış bildirim varsa yanar.
  - **In-App Overlay:** Uygulama açıkken gelen bildirimler, kullanıcıyı rahatsız etmeden ekran içinde (Snackbar benzeri) görünür.
- **Kanal Ayrımı:** Oyun ve Maskot bildirimleri için ayrı kanallar.
- **Derin Bağlantılar (Deep Linking):** Bildirime tıklandığında ilgili ekrana (Örn: Düello, Market, Profil) yönlendirme.

---

## 2. Otomatik Bildirim Senaryoları (Haftalık Plan)

Sistem, kullanıcı uygulamayı yüklediği andan itibaren haftalık döngüsel bir takvime göre bildirimleri planlar.

### 📅 Pazartesi
| Saat | Tür | Başlık | İçerik | Aksiyon |
|---|---|---|---|---|
| 16:30 | 🥕 Maskot | `{mascotName} acıktı!` | "Haftaya enerjik başlamak için beni besler misin? 2 soru yeter!" | Ana Sayfa |
| 20:30 | ⚔️ Oyun | `Yeni bir rakibin var` | "Gizemli bir oyuncu seni düelloya davet etti. Kabul edecek misin?" | Düello Ekranı |

### 📅 Salı
| Saat | Tür | Başlık | İçerik | Aksiyon |
|---|---|---|---|---|
| 16:30 | 📚 Maskot | `Okul nasıldı?` | "Çantanı bırak ve gel, bugün öğrendiklerimizi tekrar edelim mi?" | Ana Sayfa |
| 20:30 | 🎁 Oyun | `Hazine Sandığı` | "Günlük ücretsiz sandığını açmadın! İçinde ne olduğunu merak etmiyor musun?" | Sandık/Market |

### 📅 Çarşamba
| Saat | Tür | Başlık | İçerik | Aksiyon |
|---|---|---|---|---|
| 16:30 | 🎾 Maskot | `Oyun istiyor...` | "{mascotName} çok sıkıldı. Onunla biraz 'Doğru/Yanlış' oynamak ister misin?" | Oyunlar |
| 20:30 | 🔥 Oyun | `Serin Tehlikede!` | "Bugün giriş yapmazsan serin sıfırlanacak. Hemen gel ve ateşini koru!" | Ana Sayfa |

### 📅 Perşembe
| Saat | Tür | Başlık | İçerik | Aksiyon |
|---|---|---|---|---|
| 16:30 | 🧠 Maskot | `Bilgi Saati` | "Senin için çok ilginç bir bilgi buldum! Öğrenmek için tıkla." | Günlük Bilgi |
| 20:30 | 🛡️ Oyun | `Rövanş Zamanı` | "Dünkü maçın rövanşı için bekleniyorsun. Kalkanlarını hazırla!" | Düello Ekranı |

### 📅 Cuma
| Saat | Tür | Başlık | İçerik | Aksiyon |
|---|---|---|---|---|
| 16:30 | 🎉 Maskot | `Hafta sonu geldi!` | "Yaşasın! Birlikte kutlama yapalım mı? Sana bir sürprizim var." | Ana Sayfa |
| 20:30 | 📊 Oyun | `Haftalık Rapor` | "Bu hafta kaç soru çözdün? Performansını görmek için hemen gir." | Profil |

### 📅 Cumartesi
| Saat | Tür | Başlık | İçerik | Aksiyon |
|---|---|---|---|---|
| 12:00 | 🏆 Oyun | `Hafta Sonu Turnuvası` | "Liderlik tablosu sıfırlandı! En tepeye çıkmak için şimdi başla." | Liderlik |
| 20:00 | 🧩 Oyun | `Hafıza Testi` | "Zihnini dinç tut. Hafıza kartları oyununda rekor kırabilir misin?" | Hafıza Oyunu |

### 📅 Pazar
| Saat | Tür | Başlık | İçerik | Aksiyon |
|---|---|---|---|---|
| 14:00 | 💤 Maskot | `Pazar Keyfi` | "Bugün biraz tembellik yapalım mı? Yoksa kostüm mü denesek?" | Market |
| 20:30 | 🎒 Oyun | `Yarına Hazır mısın?` | "Yeni hafta başlamadan önce zihnimizi ısıtalım. 5 dakikalık antrenman?" | Test Listesi |

---

## 3. Teknik Mimari

### 3.1 Veri Modeli
`NotificationData` sınıfı, her bildirim için gerekli olan tüm verileri (id, gün, saat, başlık, body, payload, channelId) tutar.

### 3.2 Servis Yapısı (`NotificationService`)
- **flutter_local_notifications:** Temel bildirim motoru.
- **timezone:** Yerel saat dilimi hesaplamaları için kullanılır.
- **zonedSchedule:** Bildirimlerin işletim sistemi alarm yöneticisine (AlarmManager) kaydedilmesini sağlar.

### 3.3 Kanal Yapısı (Android)
Android 8.0+ için iki ayrı bildirim kanalı tanımlanmıştır:
1.  **Maskot Bildirimleri (`mascot_channel`)**: `Importance.max` - Yüksek öncelik, sesli.
2.  **Oyun Bildirimleri (`game_channel`)**: `Importance.max` - Yüksek öncelik, titreşimli.

---

## 4. UI/UX İyileştirmeleri

### 4.1 Akıllı Kırmızı Nokta (Red Dot)
Eskiden sürekli yanan kırmızı nokta, artık gerçek zamanlı bir mantığa sahiptir:
- **Veritabanı Entegrasyonu:** `Notifications` tablosundaki `isRead=0` kayıtlarını sayar.
- **ValueNotifier:** Okunmamış sayısı değiştiğinde UI anlık olarak güncellenir.
- **Logic:** `if (unreadCount > 0) showRedDot();`

### 4.2 Foreground (Uygulama İçi) Bildirim Yönetimi
Kullanıcı uygulama içindeyken standart sistem bildirimi yerine özel bir arayüz gösterilir:
- **Overlay (Snackbar):** Ekranın altında şık, karanlık temalı, etkileşimli bir kutucuk belirir.
- **Avantajı:** Kullanıcıyı uygulamadan koparmaz, bildirim paneline gitmesini gerektirmez.
- **Logic:**
  ```dart
  if (AppLifecycleState == resumed) {
      showInAppSnackBar(); // Özel UI
  } else {
      showSystemNotification(); // Android/iOS Standart
  }
  ```

### 4.3 Bildirim Ekranı Tasarımı
- **Yükseklik:** Ekranın %55'ini kaplayan kompakt yapı.
- **Header:** "🔔 BİLDİRİMLER" başlığı ortalanmış, kalın ve okunaklı.
- **Liste:** Animasyonlu (Slide+Fade) bildirim listesi.
- **Etkileşim:** Tıklanınca okundu işaretlenir ve ilgili sayfaya gider.

---

## 5. Gelecek Planları

- **A/B Testi:** Hangi bildirim metinlerinin daha fazla tıklandığının ölçülmesi.
- **Kişiselleştirme:** Kullanıcının en aktif olduğu saatlere göre bildirim zamanlamasının otomatik kaydırılması.
- **Bulut Bildirimleri (FCM):** Sunucu taraflı anlık kampanya bildirimlerinin entegrasyonu.

---

**Rapor Sonu**
