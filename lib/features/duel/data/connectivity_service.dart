import 'dart:io';
import 'package:flutter/foundation.dart';

/// İnternet bağlantısını kontrol eden servis
class ConnectivityService {
  /// İnternet bağlantısını kontrol eder
  /// Google DNS'e bağlanarak gerçek internet erişimini test eder
  static Future<bool> hasInternetConnection() async {
    try {
      // Google DNS'e bağlanmayı dene
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (kDebugMode) debugPrint('✅ İnternet bağlantısı var');
        return true;
      }

      if (kDebugMode) debugPrint('❌ İnternet bağlantısı yok');
      return false;
    } on SocketException catch (_) {
      if (kDebugMode) debugPrint('❌ İnternet bağlantısı yok (SocketException)');
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ İnternet kontrolü hatası: $e');
      return false;
    }
  }
}
