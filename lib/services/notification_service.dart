import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'database_helper.dart';
import '../models/notification_data.dart';
import '../core/navigator_key.dart';
import '../core/utils/logger.dart';
import '../screens/main_screen.dart';
import '../features/duel/presentation/screens/duel_game_selection_screen.dart';
import '../features/games/memory/presentation/screens/memory_game_screen.dart';
import '../screens/lesson_selection_screen.dart';
import 'scheduled_notification_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Bildirimleri başlatır
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Timezone verisini yükle ve Türkiye saatini ayarla
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    // Android için bildirim izni iste
    await _requestPermissions();

    // Android 12+ için tam zamanlı alarm izni iste
    await _requestExactAlarmPermission();

    // Android kanallarını oluştur
    await _createNotificationChannels();

    // Okunmamış bildirim sayısını güncelle
    await updateUnreadCount();
  }

  /// Android 12+ için Exact Alarm iznini talep eder
  /// Bu izin olmadan zamanlanmış bildirimler gecikebilir veya çalışmayabilir
  Future<void> _requestExactAlarmPermission() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Android 12+ (SDK 31+) için exact alarm izni kontrolü
        final bool? canScheduleExact = await androidPlugin
            .canScheduleExactNotifications();

        if (canScheduleExact == false) {
          // İzin yoksa sistem ayarlarına yönlendir
          await androidPlugin.requestExactAlarmsPermission();
          logger.i('Exact Alarm izni talep edildi');
        } else {
          logger.d('Exact Alarm izni zaten mevcut');
        }
      }
    } catch (e) {
      logger.w('Exact Alarm izni kontrolü hatası: $e');
      // Hata olsa bile devam et - eski Android versiyonlarında bu API yok
    }
  }

  /// Android bildirim kanallarını oluşturur
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationData.mascotChannelId,
          NotificationData.mascotChannelName,
          description: NotificationData.mascotChannelDesc,
          importance: Importance.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_audio'),
          enableVibration: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationData.gameChannelId,
          NotificationData.gameChannelName,
          description: NotificationData.gameChannelDesc,
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_audio'),
          enableVibration: true,
        ),
      );
    }
  }

  /// MainScreen açılışında çağrılır - zamanlanmış bildirim kurulumu
  /// İzinler LoginScreen'de zaten istenmiş olmalı
  Future<void> ensureInitialized() async {
    try {
      logger.i('Bildirim servisi başlatılıyor...');

      // Zamanlanmış bildirimleri kur
      await initializeScheduledNotifications();

      logger.i('Bildirim servisi başarıyla başlatıldı');
    } catch (e, stack) {
      logger.e('Bildirim servisi başlatma hatası: $e', e, stack);
    }
  }

  /// Bildirim iznini ister (Android + iOS)
  Future<void> _requestPermissions() async {
    // Android
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Bildirime tıklandığında çalışır - Payload'a göre yönlendirme yapar
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    // Navigasyon için context'e ihtiyaç var
    final context = navigatorKey.currentContext;
    if (context == null) {
      logger.w('Navigator context bulunamadı, yönlendirme yapılamadı');
      return;
    }

    _handlePayloadNavigation(context, payload);
  }

  /// Payload'a göre ilgili ekrana yönlendirme yapar
  void _handlePayloadNavigation(BuildContext context, String payload) {
    switch (payload) {
      case 'route_home':
        // Ana sayfaya git (Tab 0 - Home)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
        break;

      case 'route_duel':
        // Düello seçim sayfasına git
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DuelGameSelectionScreen()),
        );
        break;

      case 'route_games':
        // Oyunlar sekmesine git (Tab 2)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainScreen(initialTabIndex: 2),
          ),
          (route) => false,
        );
        break;

      case 'route_profile':
        // Profil sekmesine git (Tab 3)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainScreen(initialTabIndex: 3),
          ),
          (route) => false,
        );
        break;

      case 'route_memory_game':
        // Hafıza oyununa git
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MemoryGameScreen()));
        break;

      case 'route_test_list':
        // Ders seçim ekranına git (Test modu)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LessonSelectionScreen(mode: 'test'),
          ),
        );
        break;

      case 'route_chest':
        // Ana sayfaya git ve sandık dialogu göster
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
        // Sandık dialogu için event gönder (ileride implement edilebilir)
        break;

      case 'route_daily_fact':
        // Ana sayfaya git (günlük bilgi popup ileride eklenebilir)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
        break;

      case 'route_leaderboard':
        // Lider tablosu - şimdilik ana sayfaya yönlendir
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
        break;

      case 'route_shop':
        // Mağaza - şimdilik ana sayfaya yönlendir
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
        break;

      default:
        // Tanımlanmamış payload - eski davranış (ID kontrolü)
        final int? notificationId = int.tryParse(payload);
        if (notificationId != null) {
          DatabaseHelper().markNotificationAsRead(notificationId);
        }
        break;
    }
  }

  // ========== HAFTALIK BİLDİRİMLER ==========

  /// Haftalık bildirimleri planlar (MainScreen açılışında)
  /// @param mascotName Maskot ismi (bildirim içeriklerinde kullanılır)
  Future<void> initializeScheduledNotifications({String? mascotName}) async {
    try {
      // Bildirim ayarını kontrol et
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? true;

      if (!notificationsEnabled) {
        logger.d('Bildirimler devre dışı, haftalık bildirimler kurulmadı');
        return;
      }

      // Maskot ismini al veya varsayılan kullan
      final storedMascotName =
          mascotName ?? prefs.getString('mascot_name') ?? 'Dostum';

      // Haftalık bildirimleri ScheduledNotificationHelper ile kur
      // 54 haftalık döngüde planlanır, maskot ismi ile kişiselleştirilir
      await ScheduledNotificationHelper.scheduleWeeklyNotifications(
        mascotName: storedMascotName,
      );

      logger.i(
        'Haftalık bildirimler başarıyla kuruldu (Maskot: $storedMascotName)',
      );
    } catch (e) {
      logger.e('Haftalık bildirim kurulum hatası: $e');
    }
  }

  /// Maskot ismini güncelle ve bildirimleri yeniden planla
  Future<void> updateMascotName(String mascotName) async {
    await ScheduledNotificationHelper.updateMascotName(mascotName);
  }

  // Okunmamış bildirim sayısı için notifier
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// Bildirim sayısını günceller
  Future<void> updateUnreadCount() async {
    final count = await DatabaseHelper().getUnreadNotificationCount();
    unreadCountNotifier.value = count;
  }

  /// Okunmuş olarak işaretle ve sayacı güncelle
  Future<void> markAsRead(int id) async {
    await DatabaseHelper().markNotificationAsRead(id);
    await updateUnreadCount();
  }

  /// Bildirim gönderir ve veritabanına kaydeder
  /// Eğer uygulama açıksa (foreground) ekrana düşer (Overlay)
  /// Değilse sistem bildirimi gönderir
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    bool forceSystemNotification = false,
  }) async {
    // 1. Veritabanına kaydet
    final int notificationId = await DatabaseHelper().insertNotification({
      'title': title,
      'body': body,
      'date': DateTime.now().toIso8601String(),
      'isRead': 0,
    });

    // Sayacı güncelle
    await updateUnreadCount();

    // 2. Uygulama durumunu kontrol et
    final isForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    if (isForeground && !forceSystemNotification) {
      // 3A. Uygulama AÇIKSA: In-App Notification (Overlay) göster
      _showInAppNotification(title, body, payload);
    } else {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'bilgi_avcisi_channel',
            'Bilgi Avcısı Bildirimleri',
            channelDescription: 'Eğitim içerikleri ve güncellemeler',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification_audio'),
            enableVibration: true,
            visibility: NotificationVisibility.public,
            icon: '@drawable/splash_logo',
            largeIcon: DrawableResourceAndroidBitmap('@drawable/splash_logo'),
            color: Color(0xFF667EEA),
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_audio.wav',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload ?? notificationId.toString(),
      );
    }
  }

  /// Uygulama içi bildirim gösterir (Snackbar / Overlay)
  void _showInAppNotification(String title, String body, String? payload) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 14)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2d3436), // Koyu tema uyumlu
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'GÖSTER',
          textColor: const Color(0xFF00CEC9),
          onPressed: () {
            if (payload != null) {
              _onNotificationTapped(
                NotificationResponse(
                  notificationResponseType:
                      NotificationResponseType.selectedNotification,
                  payload: payload,
                ),
              );
            }
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFF00CEC9).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );

    // Titreşim ver
    // HapticFeedback.mediumImpact(); // Titreşim istenirse eklenebilir
  }

  /// Tüm bildirimleri iptal eder
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Belirli bir bildirimi iptal eder
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // ========== SINAV BİLDİRİMLERİ ==========

  /// Sınav başlangıç bildirimi planla
  /// Sınav başladığında bildirim gönderir
  Future<void> scheduleExamStartNotification({
    required String examId,
    required String examTitle,
    required DateTime startDate,
  }) async {
    // Bildirim ID'si: examId'nin hash'i
    final notificationId = examId.hashCode;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'exam_notifications',
          'Sınav Bildirimleri',
          channelDescription: 'Deneme sınavları ve sonuçları',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@drawable/splash_logo',
          largeIcon: DrawableResourceAndroidBitmap('@drawable/splash_logo'),
          color: Color(0xFF667EEA),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Zamanlanmış bildirim
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Türkiye Geneli Deneme Başladı! 🎯',
      '$examTitle sınavı başladı. Hemen katıl!',
      _convertToTZDateTime(startDate),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'exam_start_$examId',
    );

    // Veritabanına kaydet
    await DatabaseHelper().insertNotification({
      'title': 'Türkiye Geneli Deneme Başladı! 🎯',
      'body': '$examTitle sınavı başladı. Hemen katıl!',
      'date': startDate.toIso8601String(),
      'isRead': 0,
    });
  }

  /// Sonuç açıklama bildirimi planla (Cuma 10:00)
  Future<void> scheduleResultNotification({
    required String examId,
    required String examTitle,
  }) async {
    // Cuma günü 10:00 hesapla
    final now = DateTime.now();
    DateTime resultDate = now;

    // Bir sonraki Cuma'yı bul (5 = Cuma)
    while (resultDate.weekday != DateTime.friday) {
      resultDate = resultDate.add(const Duration(days: 1));
    }

    // Saat 10:00'a ayarla
    resultDate = DateTime(
      resultDate.year,
      resultDate.month,
      resultDate.day,
      10,
      0,
    );

    // Bildirim ID'si: examId + "_result"
    final notificationId = '${examId}_result'.hashCode;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'exam_results',
          'Sınav Sonuçları',
          channelDescription: 'Deneme sınavı sonuçları',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@drawable/splash_logo',
          largeIcon: DrawableResourceAndroidBitmap('@drawable/splash_logo'),
          color: Color(0xFF667EEA),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Zamanlanmış bildirim
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Sonuçlar Açıklandı! 🎉',
      '$examTitle sonuçların hazır. Hemen kontrol et!',
      _convertToTZDateTime(resultDate),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'exam_result_$examId',
    );

    // Veritabanına kaydet
    await DatabaseHelper().insertNotification({
      'title': 'Sonuçlar Açıklandı! 🎉',
      'body': '$examTitle sonuçların hazır. Hemen kontrol et!',
      'date': resultDate.toIso8601String(),
      'isRead': 0,
    });
  }

  /// TZDateTime'a çevir (timezone paketi gerekli)
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  // ========== HOŞGELDİN BİLDİRİMİ ==========

  /// İlk kurulumdan sonra hoşgeldin bildirimi gönderir
  /// @param userName Kullanıcının adı
  /// @param delaySeconds Kaç saniye sonra gönderilecek (varsayılan: 10)
  Future<void> scheduleWelcomeNotification({
    required String userName,
    int delaySeconds = 10,
  }) async {
    final notificationId = 'welcome_$userName'.hashCode;
    final title = '🎉 Hoş Geldin $userName!';
    final body =
        '🚀 Öğrenme macerana hoş geldin!\n\n'
        '📚 Testler, bilgi kartları ve mini oyunlarla öğrenmeyi keşfet.\n'
        '🎮 Tüm ekranları kontrol etmeyi unutma!\n\n'
        '⭐ Şimdi başla ve bilgi avcısı ol!';

    // Veritabanına kaydet
    await DatabaseHelper().insertNotification({
      'title': title,
      'body': body,
      'date': DateTime.now().toIso8601String(),
      'isRead': 0,
    });

    // Sayacı güncelle
    await updateUnreadCount();

    // Belirtilen süre sonra bildirim gönder (zonedSchedule yerine Future.delayed + show)
    Future.delayed(Duration(seconds: delaySeconds), () async {
      try {
        const AndroidNotificationDetails
        androidDetails = AndroidNotificationDetails(
          'welcome_channel',
          'Hoşgeldin Bildirimleri',
          channelDescription: 'Yeni kullanıcılar için karşılama bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_audio'),
          enableVibration: true,
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            '🚀 Öğrenme macerana hoş geldin!\n\n'
            '📚 Testler, bilgi kartları ve mini oyunlarla öğrenmeyi keşfet.\n'
            '🎮 Tüm ekranları kontrol etmeyi unutma!\n\n'
            '⭐ Şimdi başla ve bilgi avcısı ol!',
          ),
        );

        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification_audio.wav',
        );

        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _notificationsPlugin.show(
          notificationId,
          title,
          body,
          notificationDetails,
          payload: 'welcome_notification',
        );

        logger.i('Hoşgeldin bildirimi gönderildi: $userName');
      } catch (e) {
        logger.e('Hoşgeldin bildirimi gönderilemedi: $e');
      }
    });
  }
}
