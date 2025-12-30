import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Uygulama Logger'ı - Merkezi Loglama Sistemi
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late final Logger _logger;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Stack trace'de kaç metot gösterilsin
        errorMethodCount: 8, // Hata durumunda kaç metot gösterilsin
        lineLength: 120, // Konsol satır uzunluğu
        colors: true, // Renkli çıktı
        printEmojis: true, // Emoji kullan
        dateTimeFormat:
            DateTimeFormat.onlyTimeAndSinceStart, // Zaman damgası ekle
      ),
      filter: ProductionFilter(), // Release'de logları kapat
    );
  }

  /// Info log
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Debug log
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Warning log
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Error log
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Verbose log (çok detaylı)
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Fatal log (kritik hatalar)
  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

/// Global logger instance
final logger = AppLogger();
