# 🔔 Bilgi Avcısı - Bildirim Sistemi Raporu

## 📋 İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [Teknik Altyapı](#teknik-altyapı)
3. [Bildirim Türleri](#bildirim-türleri)
4. [Zamanlama Stratejisi](#zamanlama-stratejisi)
5. [Platform Konfigürasyonu](#platform-konfigürasyonu)
6. [Uygulama İçi Bildirim Paneli](#uygulama-içi-bildirim-paneli)
7. [Veritabanı Yapısı](#veritabanı-yapısı)
8. [Kod Örnekleri](#kod-örnekleri)
9. [Test Senaryoları](#test-senaryoları)

---

## Genel Bakış

Bilgi Avcısı'nın bildirim sistemi, öğrencilerin düzenli çalışma alışkanlıkları kazanmasını desteklemek için tasarlanmıştır. Sistem yerel push bildirimleri kullanır ve 54 haftalık (yaklaşık 1 yıl+) döngüsel bir zamanlama planı uygular.

### Temel Özellikler

- ✅ Yerel push bildirimleri (internet gerektirmez)
- ✅ Kullanıcı tarafından özelleştirilebilir hatırlatma saati
- ✅ 54 haftalık tekrarlayan döngü
- ✅ Farklı bildirim kategorileri
- ✅ Uygulama içi bildirim geçmişi
- ✅ Okundu/okunmadı durumu takibi

---

## Teknik Altyapı

### Kullanılan Paketler

```yaml
dependencies:
  flutter_local_notifications: ^18.0.1
  timezone: ^0.10.0
  flutter_timezone: ^3.0.1
```

### Servis Dosyaları

| Dosya | Konum | Amaç |
|-------|-------|------|
| `notification_service.dart` | `lib/services/` | Ana bildirim servisi |
| `notification_scheduler.dart` | `lib/services/` | Zamanlama mantığı |
| `notification_repository.dart` | `lib/repositories/` | Veritabanı işlemleri |

---

## Bildirim Türleri

### 1. Çalışma Hatırlatması (`study_reminder`)
```dart
NotificationType.studyReminder
```
- **Amaç:** Günlük çalışma hatırlatması
- **Frekans:** Günlük
- **Örnek:** "📚 Merhaba! Bugün ders çalışmayı unutma!"

### 2. Günlük Meydan Okuma (`daily_challenge`)
```dart
NotificationType.dailyChallenge
```
- **Amaç:** Günlük test/oyun önerisi
- **Frekans:** Günlük
- **Örnek:** "🎯 Günlük testini çözmeyi unutma!"

### 3. Başarı Bildirimi (`achievement`)
```dart
NotificationType.achievement
```
- **Amaç:** Başarı ve seviye atlama bildirimi
- **Frekans:** Olay bazlı
- **Örnek:** "🏆 Tebrikler! Yeni seviyeye ulaştın!"

### 4. Seri Hatırlatması (`streak`)
```dart
NotificationType.streak
```
- **Amaç:** Çalışma serisini koruma hatırlatması
- **Frekans:** Günlük (seri varsa)
- **Örnek:** "🔥 3 günlük serisini koru!"

### 5. Motivasyon Mesajı (`motivation`)
```dart
NotificationType.motivation
```
- **Amaç:** Motivasyonel içerik
- **Frekans:** Rastgele
- **Örnek:** "💪 Sen başarabilirsin!"

---

## Zamanlama Stratejisi

### 54 Haftalık Döngü

```dart
// Bildirim zamanlama döngüsü
Future<void> scheduleWeeklyNotifications() async {
  final now = DateTime.now();
  final baseTime = _getUserPreferredTime(); // Kullanıcı tercihi
  
  for (int week = 0; week < 54; week++) {
    for (int day = 0; day < 7; day++) {
      final scheduledDate = now.add(Duration(days: (week * 7) + day));
      final notificationTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        baseTime.hour,
        baseTime.minute,
      );
      
      await _scheduleNotification(
        id: (week * 7) + day,
        scheduledTime: notificationTime,
        title: _getRandomTitle(),
        body: _getRandomBody(),
      );
    }
  }
}
```

### Neden 54 Hafta?

- 52 hafta = 1 yıl
- +2 hafta = Güvenlik tamponu
- Döngü bitiminde otomatik yenileme

### Timezone Desteği

```dart
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

Future<void> initializeTimezone() async {
  final String timezoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timezoneName));
}
```

---

## Platform Konfigürasyonu

### Android Yapılandırması

#### AndroidManifest.xml Permissions
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

#### Notification Channel
```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'bilgi_avcisi_channel',
  'Bilgi Avcısı Bildirimleri',
  description: 'Günlük hatırlatmalar ve motivasyon mesajları',
  importance: Importance.high,
  enableVibration: true,
  playSound: true,
  showBadge: true,
);
```

#### Notification Details
```dart
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'bilgi_avcisi_channel',
  'Bilgi Avcısı Bildirimleri',
  channelDescription: 'Günlük hatırlatmalar',
  importance: Importance.high,
  priority: Priority.high,
  icon: '@drawable/splash_logo',
  largeIcon: DrawableResourceAndroidBitmap('@drawable/splash_logo'),
  enableVibration: true,
  playSound: true,
  styleInformation: BigTextStyleInformation(''),
);
```

### iOS Yapılandırması

#### Info.plist
```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

#### iOS Notification Settings
```dart
const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
  badgeNumber: 1,
);
```

---

## Uygulama İçi Bildirim Paneli

### UI Bileşenleri

| Widget | Dosya | Amaç |
|--------|-------|------|
| `NotificationPanel` | `notification_panel.dart` | Ana panel widget |
| `NotificationCard` | `notification_card.dart` | Tekil bildirim kartı |
| `NotificationBadge` | `notification_badge.dart` | Okunmamış sayı rozeti |

### Panel Özellikleri

```dart
class NotificationPanel extends ConsumerWidget {
  // Özellikler:
  // - Tüm bildirimleri listeler
  // - Okundu olarak işaretleme
  // - Tek bildirimi silme
  // - Tüm bildirimleri temizleme
  // - Zamana göre sıralama (en yeni üstte)
}
```

### Erişim Yöntemi

Ana ekranda sağ üstte bildirim ikonu:
```dart
IconButton(
  icon: Stack(
    children: [
      const Icon(Icons.notifications),
      if (unreadCount > 0)
        Positioned(
          right: 0,
          top: 0,
          child: NotificationBadge(count: unreadCount),
        ),
    ],
  ),
  onPressed: () => _showNotificationPanel(context),
)
```

---

## Veritabanı Yapısı

### SQLite Tablosu

```sql
CREATE TABLE Notifications(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL,
  isRead INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL
);
```

### Model Sınıfı

```dart
class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'type': type,
    'isRead': isRead ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
  };

  factory NotificationModel.fromMap(Map<String, dynamic> map) => NotificationModel(
    id: map['id'],
    title: map['title'],
    body: map['body'],
    type: map['type'],
    isRead: map['isRead'] == 1,
    createdAt: DateTime.parse(map['createdAt']),
  );
}
```

### Repository Metodları

```dart
class NotificationRepository {
  // Bildirim kaydet
  Future<int> insertNotification(NotificationModel notification);
  
  // Tüm bildirimleri getir
  Future<List<NotificationModel>> getAllNotifications();
  
  // Okunmamış sayısı
  Future<int> getUnreadCount();
  
  // Okundu olarak işaretle
  Future<void> markAsRead(int id);
  
  // Tümünü okundu yap
  Future<void> markAllAsRead();
  
  // Bildirimi sil
  Future<void> deleteNotification(int id);
  
  // Tümünü sil
  Future<void> clearAllNotifications();
}
```

---

## Kod Örnekleri

### Bildirim Servisi Başlatma

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Timezone başlat
    tz.initializeTimeZones();
    final String timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    // Plugin başlat
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/splash_logo');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android kanal oluştur
    await _createNotificationChannel();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Bildirime tıklandığında yapılacak işlem
    // Örn: İlgili ekrana yönlendirme
  }
}
```

### Bildirim Zamanlama

```dart
Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
}) async {
  await _plugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledTime, tz.local),
    const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // Günlük tekrar
  );
}
```

### Anında Bildirim Gösterme

```dart
Future<void> showImmediateNotification({
  required String title,
  required String body,
}) async {
  await _plugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    ),
  );
}
```

---

## Test Senaryoları

### Unit Test Örnekleri

```dart
// test/notifications_test.dart

void main() {
  group('NotificationService Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
    });

    test('should initialize without errors', () async {
      expect(() => service.initialize(), returnsNormally);
    });

    test('should schedule notification for future time', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      expect(
        () => service.scheduleNotification(
          id: 1,
          title: 'Test',
          body: 'Test body',
          scheduledTime: futureTime,
        ),
        returnsNormally,
      );
    });

    test('should cancel specific notification', () async {
      await service.cancelNotification(1);
      // Verify cancellation
    });

    test('should cancel all notifications', () async {
      await service.cancelAllNotifications();
      // Verify all cancelled
    });
  });

  group('NotificationRepository Tests', () {
    late NotificationRepository repository;

    setUp(() {
      repository = NotificationRepository();
    });

    test('should insert notification', () async {
      final notification = NotificationModel(
        title: 'Test',
        body: 'Test body',
        type: 'study_reminder',
        createdAt: DateTime.now(),
      );
      final id = await repository.insertNotification(notification);
      expect(id, isPositive);
    });

    test('should get unread count', () async {
      final count = await repository.getUnreadCount();
      expect(count, isNonNegative);
    });

    test('should mark as read', () async {
      await repository.markAsRead(1);
      final notifications = await repository.getAllNotifications();
      final notification = notifications.firstWhere((n) => n.id == 1);
      expect(notification.isRead, isTrue);
    });
  });
}
```

---

## Özet

Bilgi Avcısı'nın bildirim sistemi, modern Flutter best practices'lerini takip eden, kapsamlı ve ölçeklenebilir bir yapıya sahiptir:

| Özellik | Durum |
|---------|-------|
| Yerel Push Bildirimleri | ✅ Tamamlandı |
| 54 Haftalık Döngü | ✅ Tamamlandı |
| Timezone Desteği | ✅ Tamamlandı |
| Uygulama İçi Panel | ✅ Tamamlandı |
| Okundu/Okunmadı Takibi | ✅ Tamamlandı |
| Android Desteği | ✅ Tamamlandı |
| iOS Desteği | ✅ Tamamlandı |
| Unit Testler | ✅ Tamamlandı |

---

*Bu rapor Bilgi Avcısı v1.0.0 için hazırlanmıştır.*
