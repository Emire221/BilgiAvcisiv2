import 'dart:async';
import 'package:flutter/widgets.dart';
import 'database_helper.dart';

/// Uygulama içi süre takibi servisi
/// Singleton yapısında, uygulama boyunca süreyi takip eder.
///
/// ⚡ Performans Optimizasyonu:
/// - Süre RAM'de tutulur, her saniye DB'ye yazılmaz
/// - DB kayıt sadece: pause/dispose/5 dakikada bir yapılır
/// - Pil ve disk ömrü korunur
class TimeTrackingService with WidgetsBindingObserver {
  static final TimeTrackingService _instance = TimeTrackingService._internal();
  factory TimeTrackingService() => _instance;
  TimeTrackingService._internal();

  Timer? _timer;
  Timer? _saveTimer; // Periyodik kayıt için
  int _todaySeconds = 0;
  bool _isRunning = false;
  String _currentDate = '';
  int _lastSavedSeconds =
      0; // Son kaydedilen değer (gereksiz yazmaları önlemek için)

  // Periyodik kayıt aralığı (5 dakika)
  static const Duration _saveInterval = Duration(minutes: 5);

  // Anlık güncelleme için stream
  final StreamController<int> _timeController =
      StreamController<int>.broadcast();
  Stream<int> get timeStream => _timeController.stream;

  /// Mevcut günün toplam saniyesini getir
  int get todaySeconds => _todaySeconds;

  /// Servisi başlat (main.dart'ta çağrılmalı)
  Future<void> start() async {
    if (_isRunning) return;

    WidgetsBinding.instance.addObserver(this);

    // Bugünün tarihini al
    _currentDate = _getTodayDate();

    // Veritabanından bugünün mevcut süresini yükle
    _todaySeconds = await DatabaseHelper().getDailyTime(_currentDate);
    _lastSavedSeconds = _todaySeconds;
    debugPrint(
      'TimeTrackingService: Başlatıldı. Bugünkü süre: $_todaySeconds saniye',
    );

    // Zamanlayıcıyı başlat
    _startTimer();
    // Periyodik kayıt zamanlayıcısını başlat
    _startSaveTimer();
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Gün değişimi kontrolü
      final newDate = _getTodayDate();
      if (newDate != _currentDate) {
        // Eski günün verisini kaydet
        _saveToDatabase();
        _currentDate = newDate;
        _todaySeconds = 0;
        _lastSavedSeconds = 0;
        debugPrint('TimeTrackingService: Yeni gün başladı');
      }

      _todaySeconds++;
      _timeController.add(_todaySeconds);

      // ⚡ Artık her saniye DB'ye yazmıyoruz - sadece RAM'de tutuyoruz
    });
  }

  /// Periyodik kayıt zamanlayıcısını başlat (5 dakikada bir)
  void _startSaveTimer() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(_saveInterval, (_) {
      _saveToDatabase();
    });
  }

  /// Veritabanına kaydet (sadece değişiklik varsa)
  Future<void> _saveToDatabase() async {
    if (_todaySeconds != _lastSavedSeconds && _currentDate.isNotEmpty) {
      await DatabaseHelper().saveDailyTime(_currentDate, _todaySeconds);
      _lastSavedSeconds = _todaySeconds;
      debugPrint(
        'TimeTrackingService: DB\'ye kaydedildi ($_todaySeconds saniye)',
      );
    }
  }

  /// Servisi durdur
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('TimeTrackingService: Durduruldu');
  }

  /// Uygulama yaşam döngüsü değişikliklerini dinle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Uygulama ön plana döndü
        if (!_isRunning) {
          debugPrint(
            'TimeTrackingService: Uygulama resumed, zamanlayıcı devam ediyor',
          );
          _startTimer();
          _startSaveTimer();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Uygulama arka plana gitti - ⚡ KAYDET
        _saveToDatabase();
        _saveTimer?.cancel();
        if (_isRunning) {
          debugPrint(
            'TimeTrackingService: Uygulama paused, zamanlayıcı duraklatıldı',
          );
          stop();
        }
        break;
    }
  }

  /// Servisi tamamen kapat
  void dispose() {
    // ⚡ Kapanmadan önce son veriyi kaydet
    _saveToDatabase();
    _saveTimer?.cancel();
    stop();
    WidgetsBinding.instance.removeObserver(this);
    _timeController.close();
  }

  /// Bugünün tarihini YYYY-MM-DD formatında döndür
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Saniyeyi dakika:saniye formatına çevir (örn: "5:32")
  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Saniyeyi saat:dakika:saniye formatına çevir (örn: "1:05:32")
  static String formatDurationLong(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
