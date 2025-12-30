import 'dart:convert';
import 'package:http/http.dart' as http;

/// Zaman manipülasyonunu tespit eden servis
class TimeService {
  static const String _worldTimeApiUrl =
      'https://worldtimeapi.org/api/timezone/Europe/Istanbul';
  static const int _maxAllowedDifferenceSeconds = 300; // 5 dakika

  /// Gerçek zamanı worldtimeapi.org'dan alır ve cihaz saati ile karşılaştırır
  /// 5 dakikadan fazla fark varsa exception fırlatır
  /// NOT: Test/deneme için geçici olarak devre dışı bırakıldı
  Future<void> validateTime() async {
    // TODO: Production'da bu satırı kaldır
    return; // Geçici olarak devre dışı

    // ignore: dead_code
    try {
      // Gerçek zamanı API'den al
      final realTime = await _fetchRealTime();

      // Cihaz zamanını al
      final deviceTime = DateTime.now();

      // Farkı hesapla (saniye cinsinden)
      final difference = deviceTime.difference(realTime).inSeconds.abs();

      // 5 dakikadan fazla fark varsa hata fırlat
      if (difference > _maxAllowedDifferenceSeconds) {
        throw TimeManipulationException(
          'Cihaz saati ile gerçek zaman arasında ${difference ~/ 60} dakika fark tespit edildi. '
          'Lütfen cihaz saatinizi düzeltin.',
          deviceTime: deviceTime,
          realTime: realTime,
          differenceSeconds: difference,
        );
      }
    } catch (e) {
      if (e is TimeManipulationException) {
        rethrow;
      }
      // API'ye erişilemezse veya başka bir hata olursa, sessizce geç
      // (Offline durumda kullanıcıyı engellememek için)
    }
  }

  /// worldtimeapi.org'dan gerçek zamanı getirir
  Future<DateTime> _fetchRealTime() async {
    final response = await http
        .get(Uri.parse(_worldTimeApiUrl))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dateTimeStr = data['datetime'] as String;
      return DateTime.parse(dateTimeStr);
    } else {
      throw Exception('Zaman API\'sine erişilemedi');
    }
  }

  /// Cihaz saati ile gerçek zaman arasındaki farkı saniye cinsinden döndürür
  /// Hata durumunda null döner
  Future<int?> getTimeDifference() async {
    try {
      final realTime = await _fetchRealTime();
      final deviceTime = DateTime.now();
      return deviceTime.difference(realTime).inSeconds;
    } catch (e) {
      return null;
    }
  }
}

/// Zaman manipülasyonu tespit edildiğinde fırlatılan exception
class TimeManipulationException implements Exception {
  final String message;
  final DateTime deviceTime;
  final DateTime realTime;
  final int differenceSeconds;

  TimeManipulationException(
    this.message, {
    required this.deviceTime,
    required this.realTime,
    required this.differenceSeconds,
  });

  @override
  String toString() => message;
}
