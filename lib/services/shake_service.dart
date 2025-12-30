import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/database_helper.dart';
import '../features/games/fill_blanks/presentation/screens/level_selection_screen.dart';
import '../features/games/guess/presentation/screens/guess_level_selection_screen.dart';
import '../features/games/memory/presentation/screens/memory_game_screen.dart';
import '../features/duel/presentation/screens/duel_game_selection_screen.dart';

/// İçerik türleri
enum ContentType { test, flashcard, fillBlanks, sallabakalim, bulbakalim, duel }

/// Telefon sallama algılama ve rastgele içerik önerme servisi
/// sensors_plus ile daha hassas ve güvenilir algılama
class ShakeService {
  final BuildContext _context;
  final VoidCallback? onShake;

  // Accelerometer subscription
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Shake algılama parametreleri - DAHA HASSAS
  static const double _shakeThreshold = 12.0; // m/s² - düşürüldü (15'ten 12'ye)
  static const Duration _shakeCooldown = Duration(
    milliseconds: 1500,
  ); // Cooldown süresi
  static const Duration _shakeWindow = Duration(
    milliseconds: 800,
  ); // Shake penceresi
  static const int _requiredShakeCount = 2; // Gereken shake sayısı (3'ten 2'ye)

  // Durum değişkenleri
  DateTime? _lastShakeTime;
  DateTime? _lastTriggerTime;
  int _shakeCount = 0;
  bool _isProcessing = false;

  // Önceki değerler (hareket tespiti için)
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  bool _initialized = false;

  // Global pause mekanizması - oyun ekranları açıkken devre dışı bırakmak için
  static bool _isPaused = false;

  /// ShakeService'i geçici olarak duraklat (oyun ekranları için)
  static void pause() {
    _isPaused = true;
    if (kDebugMode) debugPrint('⏸️ ShakeService duraklatıldı');
  }

  /// ShakeService'i devam ettir
  static void resume() {
    _isPaused = false;
    if (kDebugMode) debugPrint('▶️ ShakeService devam ediyor');
  }

  /// ShakeService'in duraklatılıp duraklatılmadığını kontrol et
  static bool get isPaused => _isPaused;

  ShakeService(this._context, {this.onShake});

  /// Shake dinlemeyi başlat
  void start() {
    if (kDebugMode) debugPrint('🔊 ShakeService başlatılıyor...');

    _accelerometerSubscription =
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 50), // 20 Hz örnekleme
        ).listen(
          _onAccelerometerEvent,
          onError: (error) {
            if (kDebugMode) debugPrint('❌ Accelerometer hatası: $error');
          },
          cancelOnError: false,
        );

    if (kDebugMode) debugPrint('✅ ShakeService başlatıldı');
  }

  /// Accelerometer event işleyici
  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Duraklatılmışsa veya işlem yapılıyorsa çık
    if (_isPaused || _isProcessing) return;

    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    if (!_initialized) {
      _lastX = x;
      _lastY = y;
      _lastZ = z;
      _initialized = true;
      return;
    }

    // Delta hesapla (ani hareket)
    final double deltaX = (x - _lastX).abs();
    final double deltaY = (y - _lastY).abs();
    final double deltaZ = (z - _lastZ).abs();

    // Toplam ivme değişimi
    final double acceleration = sqrt(
      deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ,
    );

    // Değerleri güncelle
    _lastX = x;
    _lastY = y;
    _lastZ = z;

    // Shake algılama
    if (acceleration > _shakeThreshold) {
      _onShakeDetected();
    }
  }

  /// Shake algılandığında
  void _onShakeDetected() {
    final now = DateTime.now();

    // Cooldown kontrolü
    if (_lastTriggerTime != null &&
        now.difference(_lastTriggerTime!) < _shakeCooldown) {
      return;
    }

    // Shake penceresi kontrolü
    if (_lastShakeTime != null &&
        now.difference(_lastShakeTime!) > _shakeWindow) {
      // Pencere dışında, sayacı sıfırla
      _shakeCount = 0;
    }

    _shakeCount++;
    _lastShakeTime = now;

    if (kDebugMode) {
      debugPrint(
        '📳 Shake algılandı! Sayı: $_shakeCount / $_requiredShakeCount',
      );
    }

    // Yeterli shake sayısına ulaşıldı mı?
    if (_shakeCount >= _requiredShakeCount) {
      _shakeCount = 0;
      _lastTriggerTime = now;
      _triggerShakeAction();
    }
  }

  /// Shake aksiyonunu tetikle
  void _triggerShakeAction() {
    if (kDebugMode) debugPrint('🎉 Shake tetiklendi!');

    // Titreşim feedback'i
    HapticFeedback.heavyImpact();

    // Custom callback
    if (onShake != null) {
      onShake!();
    }

    // Dialog göster
    _showRandomContentDialog();
  }

  /// Rastgele içerik seç ve dialog göster
  Future<void> _showRandomContentDialog() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final db = await DatabaseHelper().database;
      final random = Random();

      // Tüm içerik türlerinden rastgele birini seç
      final contentTypes = ContentType.values;
      final selectedType = contentTypes[random.nextInt(contentTypes.length)];

      if (kDebugMode) debugPrint('🎲 Seçilen içerik: $selectedType');

      switch (selectedType) {
        case ContentType.test:
          await _showTestContent(db, random);
          break;
        case ContentType.flashcard:
          await _showFlashcardContent(db, random);
          break;
        case ContentType.fillBlanks:
          _showGameContent(
            title: '🧩 Cümle Tamamlama',
            description: 'Boşluğa doğru kelimeyi sürükle ve öğren!',
            icon: Icons.text_fields,
            color: Colors.purple,
            onAction: () {
              Navigator.of(_context).pop();
              Navigator.push(
                _context,
                MaterialPageRoute(
                  builder: (context) => const LevelSelectionScreen(),
                ),
              );
            },
          );
          break;
        case ContentType.sallabakalim:
          _showGameContent(
            title: '📳 Salla Bakalım',
            description: 'Telefonu salla ve sayıyı tahmin et!',
            icon: Icons.vibration,
            color: Colors.teal,
            onAction: () {
              Navigator.of(_context).pop();
              Navigator.push(
                _context,
                MaterialPageRoute(
                  builder: (context) => const GuessLevelSelectionScreen(),
                ),
              );
            },
          );
          break;
        case ContentType.bulbakalim:
          _showGameContent(
            title: '🔢 Bul Bakalım',
            description: '1\'den 10\'a kadar sırayla bul!',
            icon: Icons.grid_view_rounded,
            color: Colors.indigo,
            onAction: () {
              Navigator.of(_context).pop();
              Navigator.push(
                _context,
                MaterialPageRoute(
                  builder: (context) => const MemoryGameScreen(),
                ),
              );
            },
          );
          break;
        case ContentType.duel:
          _showGameContent(
            title: '⚔️ 1v1 Düello',
            description: 'Rakibinle yarış ve şampiyon ol!',
            icon: Icons.sports_esports,
            color: Colors.orange,
            onAction: () {
              Navigator.of(_context).pop();
              Navigator.push(
                _context,
                MaterialPageRoute(
                  builder: (context) => const DuelGameSelectionScreen(),
                ),
              );
            },
          );
          break;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Shake service error: $e');
    } finally {
      // Dialog kapandıktan sonra işlemi serbest bırak
      Future.delayed(const Duration(milliseconds: 500), () {
        _isProcessing = false;
      });
    }
  }

  /// Test içeriği göster
  Future<void> _showTestContent(dynamic db, Random random) async {
    final tests = await db.query('Tests', limit: 100);
    if (tests.isEmpty) {
      _showGameContent(
        title: '🎮 Salla Bakalım',
        description: 'Telefonu salla ve sayıyı tahmin et!',
        icon: Icons.vibration,
        color: Colors.teal,
        onAction: () {
          Navigator.of(_context).pop();
          Navigator.push(
            _context,
            MaterialPageRoute(
              builder: (context) => const GuessLevelSelectionScreen(),
            ),
          );
        },
      );
      return;
    }

    final randomTest = tests[random.nextInt(tests.length)];
    final testName = randomTest['testName'] as String;

    _showContentDialog(
      title: '📝 Şansına Bu Çıktı!',
      content: '"$testName" testini çözmek ister misin?',
      actionLabel: 'Hadi Başlayalım!',
      icon: Icons.quiz,
      color: Colors.orange,
      onAction: () {
        Navigator.of(_context).pop();
      },
    );
  }

  /// Bilgi kartı içeriği göster
  Future<void> _showFlashcardContent(dynamic db, Random random) async {
    final flashcards = await db.query('Flashcards', limit: 100);
    if (flashcards.isEmpty) {
      _showGameContent(
        title: '🔢 Bul Bakalım',
        description: '1\'den 10\'a kadar sırayla bul!',
        icon: Icons.grid_view_rounded,
        color: Colors.indigo,
        onAction: () {
          Navigator.of(_context).pop();
          Navigator.push(
            _context,
            MaterialPageRoute(builder: (context) => const MemoryGameScreen()),
          );
        },
      );
      return;
    }

    final randomCard = flashcards[random.nextInt(flashcards.length)];
    final front = randomCard['front'] as String? ?? 'Bilgi Kartı';

    _showContentDialog(
      title: '🃏 Bilgi Kartı!',
      content: '"$front" kartını öğrenmek ister misin?',
      actionLabel: 'Kartı Gör!',
      icon: Icons.style,
      color: Colors.green,
      onAction: () {
        Navigator.of(_context).pop();
      },
    );
  }

  /// Oyun içeriği göster
  void _showGameContent({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onAction,
  }) {
    _showContentDialog(
      title: title,
      content: description,
      actionLabel: 'Oyna!',
      icon: icon,
      color: color,
      onAction: onAction,
    );
  }

  /// İçerik önerisi dialogu göster
  void _showContentDialog({
    required String title,
    required String content,
    required String actionLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onAction,
  }) {
    if (!_context.mounted) return;

    showDialog(
      context: _context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_android, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Telefonu salladın! 📱',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Belki Sonra',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).then((_) {
      _isProcessing = false;
    });
  }

  /// Shake dinlemeyi durdur
  void dispose() {
    if (kDebugMode) debugPrint('🛑 ShakeService durduruluyor...');
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _initialized = false;
    _shakeCount = 0;
  }
}
