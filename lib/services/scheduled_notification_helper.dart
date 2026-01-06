import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_data.dart';

/// Arka planda çalışan bildirim yardımcısı
/// 54 haftalık bildirim planlaması yapar
/// Android: flutter_local_notifications zonedSchedule (AlarmManager problemleri için)
/// iOS: flutter_local_notifications zonedSchedule
class ScheduledNotificationHelper {
  static const String _lastScheduleKey = 'last_notification_schedule_date';
  static const String _mascotNameKey = 'mascot_name';
  static const int _maxScheduledNotifications = 64; // Android limiti
  
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  /// Platform'a göre başlat
  static Future<void> initialize() async {
    // flutter_local_notifications zaten main.dart'ta başlatıldı
    debugPrint('✅ ScheduledNotificationHelper başlatıldı');
  }
  
  /// 54 haftalık bildirimleri planla
  /// Android limiti nedeniyle her seferinde en fazla 64 bildirim planlanır
  /// Uygulama her açıldığında yeniden planlanır
  static Future<void> scheduleWeeklyNotifications({String? mascotName}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Bildirimler devre dışıysa çık
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      if (!notificationsEnabled) {
        debugPrint('⚠️ Bildirimler devre dışı, planlama atlandı');
        return;
      }
      
      // Maskot ismini al
      final storedMascotName = mascotName ?? prefs.getString(_mascotNameKey) ?? 'Dostum';
      
      // Mevcut bildirimleri temizle
      await cancelAllScheduledNotifications();
      
      // Şu anki tarih ve saat
      final now = DateTime.now();
      final currentWeekOfYear = _getWeekOfYear(now);
      
      // 54 haftalık bildirim planla (Android limiti: 64)
      // Her gün 2 bildirim = 14 bildirim/hafta
      // 4 haftalık plan = 56 bildirim (limit altında)
      int scheduledCount = 0;
      
      for (int weekOffset = 0; weekOffset < 4 && scheduledCount < _maxScheduledNotifications - 2; weekOffset++) {
        final targetWeek = currentWeekOfYear + weekOffset;
        
        for (int dayOfWeek = 1; dayOfWeek <= 7 && scheduledCount < _maxScheduledNotifications - 2; dayOfWeek++) {
          // Öğleden sonra bildirimi (16:30 veya 12:00/14:00)
          final afternoonNotif = NotificationData.getAfternoonNotification(targetWeek, dayOfWeek);
          final afternoonTime = _getNextOccurrence(
            dayOfWeek, 
            afternoonNotif.hour, 
            afternoonNotif.minute,
            weekOffset,
          );
          
          if (afternoonTime.isAfter(now)) {
            await _scheduleNotification(
              id: afternoonNotif.id + weekOffset * 100,
              title: afternoonNotif.getTitle(storedMascotName),
              body: afternoonNotif.getBody(storedMascotName),
              scheduledTime: afternoonTime,
              payload: afternoonNotif.payload,
              channelId: afternoonNotif.channelId,
            );
            scheduledCount++;
          }
          
          // Akşam bildirimi (20:30 veya 20:00)
          final eveningNotif = NotificationData.getEveningNotification(targetWeek, dayOfWeek);
          final eveningTime = _getNextOccurrence(
            dayOfWeek, 
            eveningNotif.hour, 
            eveningNotif.minute,
            weekOffset,
          );
          
          if (eveningTime.isAfter(now)) {
            await _scheduleNotification(
              id: eveningNotif.id + weekOffset * 100,
              title: eveningNotif.getTitle(storedMascotName),
              body: eveningNotif.getBody(storedMascotName),
              scheduledTime: eveningTime,
              payload: eveningNotif.payload,
              channelId: eveningNotif.channelId,
            );
            scheduledCount++;
          }
        }
      }
      
      // Son planlama tarihini kaydet
      await prefs.setString(_lastScheduleKey, now.toIso8601String());
      
      debugPrint('✅ $scheduledCount bildirim planlandı (54 haftalık döngü)');
    } catch (e, stack) {
      debugPrint('❌ Bildirim planlama hatası: $e');
      debugPrint('📍 Stack: $stack');
    }
  }
  
  /// Belirli bir bildirim planla
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
    required String channelId,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId == NotificationData.mascotChannelId 
            ? NotificationData.mascotChannelName 
            : NotificationData.gameChannelName,
        channelDescription: channelId == NotificationData.mascotChannelId 
            ? NotificationData.mascotChannelDesc 
            : NotificationData.gameChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/splash_logo',
        largeIcon: const DrawableResourceAndroidBitmap('@drawable/splash_logo'),
        styleInformation: BigTextStyleInformation(body),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        color: const Color(0xFF667EEA),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      if (kDebugMode) {
        debugPrint('📅 Planlandı: $title @ ${scheduledTime.toString()}');
      }
    } catch (e) {
      debugPrint('❌ Bildirim planlama hatası (ID: $id): $e');
    }
  }
  
  /// Belirli gün ve saat için bir sonraki oluşumu hesapla
  static DateTime _getNextOccurrence(int dayOfWeek, int hour, int minute, int weekOffset) {
    final now = DateTime.now();
    
    // Bu haftanın hedef gününü bul
    int daysUntilTarget = dayOfWeek - now.weekday;
    if (daysUntilTarget < 0) {
      daysUntilTarget += 7;
    }
    
    // Hafta offsetini ekle
    daysUntilTarget += weekOffset * 7;
    
    final targetDate = now.add(Duration(days: daysUntilTarget));
    final scheduledTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );
    
    // Eğer bugün ve saat geçtiyse bir sonraki haftaya al
    if (scheduledTime.isBefore(now) && weekOffset == 0) {
      return scheduledTime.add(const Duration(days: 7));
    }
    
    return scheduledTime;
  }
  
  /// Yılın kaçıncı haftası
  static int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return (daysDifference / 7).ceil() + 1;
  }
  
  /// Tüm zamanlanmış bildirimleri iptal et
  static Future<void> cancelAllScheduledNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('🗑️ Tüm zamanlanmış bildirimler iptal edildi');
    } catch (e) {
      debugPrint('❌ Bildirim iptal hatası: $e');
    }
  }
  
  /// Belirli bir bildirimi iptal et
  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('❌ Bildirim iptal hatası (ID: $id): $e');
    }
  }
  
  /// Maskot ismini güncelle ve bildirimleri yeniden planla
  static Future<void> updateMascotName(String mascotName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mascotNameKey, mascotName);
    
    // Bildirimleri yeniden planla
    await scheduleWeeklyNotifications(mascotName: mascotName);
  }
  
  /// Eski metot uyumluluğu için (cancelAllAlarms)
  static Future<void> cancelAllAlarms() async {
    await cancelAllScheduledNotifications();
  }
}
