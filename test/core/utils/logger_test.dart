import 'package:flutter_test/flutter_test.dart';
import 'package:bilgici/core/utils/logger.dart';

void main() {
  group('Logger Tests', () {
    late AppLogger logger;

    setUp(() {
      logger = AppLogger();
    });

    test('logger should be singleton', () {
      final logger1 = AppLogger();
      final logger2 = AppLogger();

      expect(identical(logger1, logger2), true);
    });

    test('info log should not throw error', () {
      // Logger sadece konsola yazdığı için hata fırlatmamalı
      logger.i('Test info message');
      // Test geçmeli çünkü exception fırlatılmadı
      expect(true, true);
    });

    test('debug log should not throw error', () {
      logger.d('Test debug message');
      expect(true, true);
    });

    test('warning log should not throw error', () {
      logger.w('Test warning message');
      expect(true, true);
    });

    test('error log should not throw error', () {
      logger.e('Test error message', Exception('Test'));
      expect(true, true);
    });

    test('verbose log should not throw error', () {
      logger.v('Test verbose message');
      expect(true, true);
    });

    test('fatal log should not throw error', () {
      logger.f('Test fatal message');
      expect(true, true);
    });

    test('error log with stack trace should not throw', () {
      logger.e('Error with stack', Exception('Test'), StackTrace.current);
      expect(true, true);
    });
  });
}
