import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audio_session/audio_session.dart';

/// Bellek tabanlı ses kaynağı - dosya sistemi sorunlarını aşmak için
/// iOS'te recorder.stop() sonrası dosya kilidi sorununu çözer
class _MemoryAudioSource extends StreamAudioSource {
  final Uint8List _audioData;
  final String _contentType;

  _MemoryAudioSource(this._audioData, {String? contentType})
    : _contentType = contentType ?? 'audio/mp4';

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _audioData.length;
    return StreamAudioResponse(
      sourceLength: _audioData.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_audioData.sublist(start, end)),
      contentType: _contentType,
    );
  }
}

class TalkingMascotService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  Uint8List? _lastRecordingBytes; // Bellek tabanlı oynatma için
  bool _isRecording = false;
  bool _isPlaying = false;

  // Session'ın sadece bir kez başlatılması yeterlidir
  bool _isSessionInitialized = false;
  AudioSession? _audioSession;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  /// 1. Ses Oturumunu Başlat (TEK VE SABİT MOD - WARM SESSION)
  /// iOS'te Record <-> Playback arasında sürekli geçiş yapmak hoparlörü bozar.
  /// Bu yüzden "playAndRecord" modunda sabit kalıyoruz.
  ///
  /// ÖNEMLİ: spokenAudio modu ve defaultToSpeaker kombinasyonu
  /// iOS'te ahize yerine hoparlörü zorlar.
  Future<void> _initAudioSession() async {
    if (_isSessionInitialized) return;
    try {
      _audioSession = await AudioSession.instance;
      await _audioSession!.configure(
        AudioSessionConfiguration(
          // ═══════════════════════════════════════════════════════════════
          // iOS YAPILANDIRMASI
          // ═══════════════════════════════════════════════════════════════
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions
                  .defaultToSpeaker | // 🔊 HOPARLÖR ZORLA
              AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.allowAirPlay,
          // spokenAudio: Ses tanıma/konuşma için optimize edilmiş mod
          // defaultMode yerine spokenAudio kullanmak daha stabil
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions:
              AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,

          // ═══════════════════════════════════════════════════════════════
          // ANDROID YAPILANDIRMASI
          // ═══════════════════════════════════════════════════════════════
          // voiceCommunication yerine media kullanıyoruz
          // voiceCommunication ahizeyi hedefler, media hoparlörü hedefler
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage
                .media, // 🔊 HOPARLÖR ZORLA (voiceCommunication değil!)
            flags: AndroidAudioFlags
                .audibilityEnforced, // Ses duyulabilirliğini zorla
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ),
      );
      await _audioSession!.setActive(true);
      _isSessionInitialized = true;
      debugPrint(
        'TalkingMascot: ✅ Ses oturumu başarıyla yapılandırıldı (Hoparlör modu)',
      );
    } catch (e) {
      debugPrint('TalkingMascot: ❌ Session hatası - $e');
    }
  }

  /// iOS'te ses oturumunu yeniden aktif et (route değişikliklerinde)
  Future<void> _ensureSessionActive() async {
    if (_audioSession != null) {
      try {
        await _audioSession!.setActive(true);
      } catch (e) {
        debugPrint('TalkingMascot: Session aktifleştirme hatası - $e');
      }
    }
  }

  Future<bool> startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted == false) {
        return false;
      }

      await _initAudioSession(); // Session'ı garantiye al
      await _ensureSessionActive(); // Session aktif mi kontrol et

      final tempDir = await getTemporaryDirectory();
      // iOS için M4A (AAC) formatı kullanılmalı - WAV iOS'te pitch shift ile uyumsuz
      _currentRecordingPath =
          '${tempDir.path}/mascot_rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // iOS native format: AAC Low Complexity + Mono kanal (en stabil)
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1, // Mono - ses efektleri için daha temiz
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      debugPrint('TalkingMascot: 🎙️ Kayıt başladı');
      return true;
    } catch (e) {
      debugPrint('TalkingMascot: ❌ Kayıt başlatılamadı - $e');
      _isRecording = false;
      return false;
    }
  }

  /// Kaydı durdur ve dosyayı belleğe al (Race Condition çözümü)
  /// iOS'te dosya sistemi gecikmelerini aşmak için dosyayı RAM'e kopyalıyoruz
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      // 1. Recorder'ı durdur ve path'i al
      final path = await _recorder.stop();
      _isRecording = false;
      debugPrint('TalkingMascot: 🛑 Kayıt durduruldu');

      if (path == null) return null;

      // 2. iOS ve Android için dosya sistemi senkronizasyonu
      // iOS'te AAC encoder dosyayı tamamen yazmadan return edebilir
      // Bu gecikme dosyanın tamamen yazılmasını garantiler
      if (Platform.isIOS) {
        await Future.delayed(const Duration(milliseconds: 150));
      }

      // 3. Dosyanın hazır olmasını bekle (retry mekanizması)
      final file = File(path);
      int retryCount = 0;
      const maxRetries = 10;

      while (retryCount < maxRetries) {
        if (await file.exists()) {
          final length = await file.length();
          if (length > 500) {
            // Dosya yeterli boyutta, okumaya hazır
            break;
          }
        }
        // Dosya henüz hazır değil, bekle
        await Future.delayed(const Duration(milliseconds: 50));
        retryCount++;
      }

      // 4. Dosyayı belleğe oku (Race Condition çözümü)
      // Bu sayede oynatma sırasında dosya sistemi kilidi sorun olmaz
      try {
        _lastRecordingBytes = await file.readAsBytes();
        debugPrint(
          'TalkingMascot: 📦 Ses belleğe alındı (${_lastRecordingBytes!.length} bytes)',
        );
      } catch (e) {
        debugPrint(
          'TalkingMascot: ⚠️ Dosya okunamadı, disk tabanlı oynatma kullanılacak - $e',
        );
        _lastRecordingBytes = null;
      }

      return path;
    } catch (e) {
      debugPrint('TalkingMascot: ❌ Kayıt durdurma hatası - $e');
      _isRecording = false;
      return null;
    }
  }

  /// Kaydedilen sesi pitch ve speed efektleriyle oynat
  /// iOS için Varispeed algoritması kullanılır (doğal ince ses)
  Future<void> playRecordingWithPitchShift({
    double pitchMultiplier = 1.5,
    double speedMultiplier = 1.3,
    VoidCallback? onComplete,
  }) async {
    // Hem dosya yolu hem de bellek verisi yoksa çık
    if (_currentRecordingPath == null && _lastRecordingBytes == null) {
      debugPrint('TalkingMascot: ⚠️ Oynatılacak kayıt yok');
      onComplete?.call();
      return;
    }

    try {
      _isPlaying = true;

      // Ses oturumunu aktif tut (iOS route değişikliği koruması)
      await _ensureSessionActive();

      // Önceki oynatmayı temizle
      await _player.stop();
      await _player.setVolume(1.0); // Ses seviyesini maksimuma ayarla

      // ═══════════════════════════════════════════════════════════════
      // SES KAYNAĞINI AYARLA (Bellek > Dosya önceliği)
      // ═══════════════════════════════════════════════════════════════
      bool sourceSet = false;

      // 1. Öncelik: Bellek tabanlı oynatma (Race Condition'a karşı güvenli)
      if (_lastRecordingBytes != null && _lastRecordingBytes!.isNotEmpty) {
        try {
          final memorySource = _MemoryAudioSource(
            _lastRecordingBytes!,
            contentType: 'audio/mp4', // AAC/M4A için
          );
          await _player.setAudioSource(memorySource);
          sourceSet = true;
          debugPrint('TalkingMascot: 🧠 Bellek tabanlı oynatma aktif');
        } catch (e) {
          debugPrint(
            'TalkingMascot: ⚠️ Bellek kaynağı hatası, dosyaya geçiliyor - $e',
          );
        }
      }

      // 2. Yedek: Dosya tabanlı oynatma
      if (!sourceSet && _currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists() && await file.length() > 500) {
          // iOS için ek güvenlik gecikmesi
          if (Platform.isIOS) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          await _player.setFilePath(_currentRecordingPath!);
          sourceSet = true;
          debugPrint('TalkingMascot: 📁 Dosya tabanlı oynatma aktif');
        }
      }

      if (!sourceSet) {
        debugPrint('TalkingMascot: ❌ Ses kaynağı ayarlanamadı');
        _isPlaying = false;
        onComplete?.call();
        return;
      }

      // ═══════════════════════════════════════════════════════════════
      // PITCH VE SPEED AYARLARI
      // ═══════════════════════════════════════════════════════════════
      // iOS'te Varispeed algoritması: Hız değişimi tonu doğal olarak etkiler
      // Bu sayede speed(1.5) otomatik olarak ince ses verir
      //
      // NOT: just_audio'da darwinAudioTimePitchAlgorithm doğrudan desteklenmiyor
      // Bu yüzden speed ve pitch kombinasyonu kullanıyoruz

      // Önce speed ayarla (iOS'te ton değişimine yol açar)
      await _player.setSpeed(speedMultiplier);

      // Ardından pitch ayarla (ek ton yükseltme)
      // iOS'te speed zaten tonu değiştirdiği için pitch'i biraz düşük tutuyoruz
      if (Platform.isIOS) {
        // iOS: Speed zaten tonu değiştiriyor, pitch'i hafif tut
        await _player.setPitch(pitchMultiplier * 0.9);
      } else {
        // Android: Pitch ve speed bağımsız çalışır
        await _player.setPitch(pitchMultiplier);
      }

      debugPrint(
        'TalkingMascot: 🎵 Oynatma başlıyor (Speed: $speedMultiplier, Pitch: $pitchMultiplier)',
      );

      // ═══════════════════════════════════════════════════════════════
      // OYNATMA VE TAMAMLANMA TAKİBİ
      // ═══════════════════════════════════════════════════════════════
      // Oynatma bitişini dinle
      final completer = Completer<void>();

      late StreamSubscription<PlayerState> subscription;
      subscription = _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          subscription.cancel();
        }
      });

      // Oynatmayı başlat
      await _player.play();

      // Oynatma bitene kadar bekle
      await completer.future;

      debugPrint('TalkingMascot: ✅ Oynatma tamamlandı');
    } catch (e) {
      debugPrint('TalkingMascot: ❌ Oynatma hatası - $e');
    } finally {
      _isPlaying = false;
      onComplete?.call();
    }
  }

  Future<void> stopPlaying() async {
    try {
      await _player.stop();
      _isPlaying = false;
      debugPrint('TalkingMascot: ⏹️ Oynatma durduruldu');
    } catch (_) {}
  }

  /// Tüm kaynakları temizle ve belleği serbest bırak
  Future<void> dispose() async {
    try {
      await _recorder.dispose();
      await _player.dispose();
      _lastRecordingBytes = null;
      _currentRecordingPath = null;

      // Ses oturumunu deaktif et
      if (_audioSession != null) {
        await _audioSession!.setActive(false);
      }
      debugPrint('TalkingMascot: 🧹 Kaynaklar temizlendi');
    } catch (e) {
      debugPrint('TalkingMascot: Dispose hatası - $e');
    }
  }

  /// Kaydı temizle (yeni kayıt için)
  void clearRecording() {
    _lastRecordingBytes = null;
    _currentRecordingPath = null;
    debugPrint('TalkingMascot: 🗑️ Kayıt temizlendi');
  }

  /// Mikrofon izni iste ve sonucunu döndür
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Uygulama ayarlarını aç (izin vermek için)
  Future<bool> openAppSettingsForPermission() async {
    return await openAppSettings();
  }
}
