import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bilgici/services/database_helper.dart';

void main() {
  // Test için sqflite ffi'yi başlat
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Notifications Database Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper();
      // Her testten önce veritabanını temizle
      final db = await dbHelper.database;
      await db.delete('Notifications');
    });

    test('insertNotification - Bildirim başarıyla eklenmeli', () async {
      // Arrange
      final notification = {
        'title': 'Test Bildirimi',
        'body': 'Bu bir test bildirimidir',
        'date': DateTime.now().toIso8601String(),
        'isRead': 0,
      };

      // Act
      final id = await dbHelper.insertNotification(notification);

      // Assert
      expect(id, greaterThan(0));
    });

    test(
      'getNotifications - Bildirimleri tarihe göre sıralı getirmeli',
      () async {
        // Arrange
        final now = DateTime.now();
        final notification1 = {
          'title': 'İlk Bildirim',
          'body': 'İlk bildirim içeriği',
          'date': now.subtract(const Duration(minutes: 10)).toIso8601String(),
          'isRead': 0,
        };
        final notification2 = {
          'title': 'İkinci Bildirim',
          'body': 'İkinci bildirim içeriği',
          'date': now.toIso8601String(),
          'isRead': 0,
        };

        await dbHelper.insertNotification(notification1);
        await dbHelper.insertNotification(notification2);

        // Act
        final notifications = await dbHelper.getNotifications();

        // Assert
        expect(notifications.length, 2);
        // En yeni bildirim ilk sırada olmalı (DESC)
        expect(notifications[0]['title'], 'İkinci Bildirim');
        expect(notifications[1]['title'], 'İlk Bildirim');
      },
    );

    test('deleteNotification - Bildirim başarıyla silinmeli', () async {
      // Arrange
      final notification = {
        'title': 'Silinecek Bildirim',
        'body': 'Bu bildirim silinecek',
        'date': DateTime.now().toIso8601String(),
        'isRead': 0,
      };
      final id = await dbHelper.insertNotification(notification);

      // Act
      final deletedCount = await dbHelper.deleteNotification(id);

      // Assert
      expect(deletedCount, 1);

      // Verify silindi mi
      final notifications = await dbHelper.getNotifications();
      expect(notifications.where((n) => n['id'] == id).isEmpty, true);
    });

    test(
      'markNotificationAsRead - Bildirim okundu olarak işaretlenmeli',
      () async {
        // Arrange
        final notification = {
          'title': 'Okunacak Bildirim',
          'body': 'Bu bildirim okunacak',
          'date': DateTime.now().toIso8601String(),
          'isRead': 0,
        };
        final id = await dbHelper.insertNotification(notification);

        // Act
        await dbHelper.markNotificationAsRead(id);

        // Assert
        final notifications = await dbHelper.getNotifications();
        final updatedNotification = notifications.firstWhere(
          (n) => n['id'] == id,
        );
        expect(updatedNotification['isRead'], 1);
      },
    );

    test('getNotifications - Boş liste döndürmeli (bildirim yoksa)', () async {
      // Act
      final notifications = await dbHelper.getNotifications();

      // Assert
      expect(notifications, isEmpty);
    });

    test('insertNotification - Tüm alanlar doğru kaydedilmeli', () async {
      // Arrange
      final testDate = DateTime.now().toIso8601String();
      final notification = {
        'title': 'Tam Test',
        'body': 'Tüm alanlar test ediliyor',
        'date': testDate,
        'isRead': 0,
      };

      // Act
      final id = await dbHelper.insertNotification(notification);
      final notifications = await dbHelper.getNotifications();
      final savedNotification = notifications.firstWhere((n) => n['id'] == id);

      // Assert
      expect(savedNotification['title'], 'Tam Test');
      expect(savedNotification['body'], 'Tüm alanlar test ediliyor');
      expect(savedNotification['date'], testDate);
      expect(savedNotification['isRead'], 0);
    });

    test(
      'markNotificationAsRead - Var olmayan ID için hata vermemeli',
      () async {
        // Act & Assert - Exception fırlatmamalı
        await dbHelper.markNotificationAsRead(99999);
      },
    );

    test('deleteNotification - Var olmayan ID için 0 dönmeli', () async {
      // Act
      final deletedCount = await dbHelper.deleteNotification(99999);

      // Assert
      expect(deletedCount, 0);
    });

    test(
      'Multiple notifications - Çoklu bildirim ekleme ve sıralama',
      () async {
        // Arrange
        final now = DateTime.now();
        final notifications = List.generate(
          5,
          (i) => {
            'title': 'Bildirim ${i + 1}',
            'body': 'İçerik ${i + 1}',
            'date': now
                .subtract(Duration(minutes: 5 - i))
                .toIso8601String(), // En yeni son
            'isRead': i % 2, // Bazıları okunmuş
          },
        );

        // Act
        for (var notif in notifications) {
          await dbHelper.insertNotification(notif);
        }

        final result = await dbHelper.getNotifications();

        // Assert
        expect(result.length, 5);
        // İlk eleman en yeni olmalı
        expect(result[0]['title'], 'Bildirim 5');
        expect(result[4]['title'], 'Bildirim 1');
      },
    );
  });
}
