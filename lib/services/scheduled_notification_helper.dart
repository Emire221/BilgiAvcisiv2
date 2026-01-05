import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// Arka planda çalışan bildirim yardımcısı
/// Android: android_alarm_manager_plus
/// iOS: flutter_local_notifications zonedSchedule
class ScheduledNotificationHelper {
  static const String isolateName = 'notification_isolate';
  // Haftalık bildirimler için başlangıç ID'si
  static const int weeklyAlarmBaseId = 1000;
  static const int welcomeAlarmId = 9997;
  
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  /// Platform'a göre başlat
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
      debugPrint('✅ AndroidAlarmManager başlatıldı');
    } else if (Platform.isIOS) {
      debugPrint('✅ iOS için flutter_local_notifications kullanılacak');
    }
  }
  
  /// iOS için zamanlanmış bildirim
  static Future<void> _scheduleIOSNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      iOS: iosDetails,
    );

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'scheduled_notification',
    );
  }
  
  /// Belirtilen saat ve dakikada günlük bildirim planla
  static Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Bugün veya yarın için hedef zamanı hesapla
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // Eğer zaman geçmişse yarına ayarla
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    if (Platform.isAndroid) {
      // SharedPreferences'a bildirim bilgilerini kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarm_title_$id', title);
      await prefs.setString('alarm_body_$id', body);
      
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        weeklyAlarmBaseId + id,
        _showScheduledNotificationCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    } else if (Platform.isIOS) {
      await _scheduleIOSNotification(
        id: weeklyAlarmBaseId + id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
      );
    }
    
    debugPrint('📅 Bildirim planlandı: ID=$id, Saat=$hour:$minute, Zaman=$scheduledTime');
  }
  
  /// Haftalık bildirimleri planla (16:30 ve 20:30)
  static Future<void> scheduleWeeklyNotifications() async {
    // 16:30 bildirimi
    await scheduleDailyNotification(
      id: 1,
      hour: 16,
      minute: 30,
      title: '📚 Öğrenme Zamanı!',
      body: 'Bugün yeni bir şeyler öğrenmeye ne dersin? 🎯',
    );
    
    // 20:30 bildirimi
    await scheduleDailyNotification(
      id: 2,
      hour: 20,
      minute: 30,
      title: '🎮 Oyun Vakti!',
      body: 'Günün yorgunluğunu mini oyunlarla at! 🚀',
    );
    
    debugPrint('✅ Haftalık bildirimler planlandı');
  }
  
  /// Tüm alarmları iptal et
  static Future<void> cancelAllAlarms() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(welcomeAlarmId);
      
      // Haftalık alarmları iptal et
      for (int i = 1; i <= 14; i++) {
        await AndroidAlarmManager.cancel(weeklyAlarmBaseId + i);
      }
    } else if (Platform.isIOS) {
      await _notificationsPlugin.cancel(welcomeAlarmId);
      
      for (int i = 1; i <= 14; i++) {
        await _notificationsPlugin.cancel(weeklyAlarmBaseId + i);
      }
    }
    
    debugPrint('🗑️ Tüm alarmlar iptal edildi');
  }
}

// ========== CALLBACK FONKSİYONLARI (Top-level olmalı - sadece Android için) ==========

/// Zamanlanmış bildirim callback'i - Isolate'da çalışır (Android)
@pragma('vm:entry-point')
Future<void> _showScheduledNotificationCallback() async {
  debugPrint('📅 Alarm tetiklendi: Zamanlanmış bildirim');
  
  // Flutter Local Notifications'ı başlat
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );
  
  await notificationsPlugin.initialize(initSettings);
  
  // Bildirim göster
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'scheduled_channel',
    'Zamanlanmış Bildirimler',
    channelDescription: 'Zamanlanmış bildirimler için kanal',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await notificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
    '📚 Öğrenme Zamanı!',
    'Bugün yeni bir şeyler öğrenmeye ne dersin? 🎯',
    notificationDetails,
  );
  
  debugPrint('✅ Zamanlanmış bildirim gösterildi');
}
