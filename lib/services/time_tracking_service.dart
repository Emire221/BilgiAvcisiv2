import 'dart:async';
import 'package:flutter/widgets.dart';
import 'database_helper.dart';

/// Uygulama içi süre takibi servisi
/// Singleton yapısında, uygulama boyunca süreyi takip eder ve her saniye kaydeder.
class TimeTrackingService with WidgetsBindingObserver {
  static final TimeTrackingService _instance = TimeTrackingService._internal();
  factory TimeTrackingService() => _instance;
  TimeTrackingService._internal();

  Timer? _timer;
  int _todaySeconds = 0;
  bool _isRunning = false;
  String _currentDate = '';

  // Anlık güncelleme için stream
  final StreamController<int> _timeController = StreamController<int>.broadcast();
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
    debugPrint('TimeTrackingService: Başlatıldı. Bugünkü süre: $_todaySeconds saniye');
    
    // Zamanlayıcıyı başlat
    _startTimer();
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Gün değişimi kontrolü
      final newDate = _getTodayDate();
      if (newDate != _currentDate) {
        _currentDate = newDate;
        _todaySeconds = 0;
        debugPrint('TimeTrackingService: Yeni gün başladı');
      }
      
      _todaySeconds++;
      _timeController.add(_todaySeconds);
      
      // Her saniye veritabanına kaydet
      DatabaseHelper().saveDailyTime(_currentDate, _todaySeconds);
    });
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
          debugPrint('TimeTrackingService: Uygulama resumed, zamanlayıcı devam ediyor');
          _startTimer();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Uygulama arka plana gitti
        if (_isRunning) {
          debugPrint('TimeTrackingService: Uygulama paused, zamanlayıcı duraklatıldı');
          stop();
        }
        break;
    }
  }

  /// Servisi tamamen kapat
  void dispose() {
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
