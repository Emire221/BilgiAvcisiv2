import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audio_session/audio_session.dart';

/// Talking Tom benzeri ses kaydı ve pitch shift oynatma servisi
/// iOS için optimize edilmiş Audio Session yönetimi
class TalkingMascotService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  
  /// Audio Session tek seferlik initialization flag
  bool _sessionInitialized = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  /// Mikrofon izni kontrolü ve isteme
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return false;
  }

  Future<bool> openAppSettingsForPermission() async {
    return await openAppSettings();
  }

  /// Ses oturumunu tek seferlik yapılandır (playAndRecord modu - iOS için kritik)
  /// 
  /// iOS'te AVAudioSession kategorileri arasında hızlı geçiş yapmak
  /// ses motorunun kilitlenmesine neden olur. Bu nedenle session
  /// uygulama yaşam döngüsü boyunca sabit kalır.
  Future<void> _initAudioSession() async {
    if (_sessionInitialized) return;
    
    try {
      final session = await AudioSession.instance;
      
      // Hem kayıt hem oynatma için tek sabit mod
      // defaultToSpeaker: Ses ahizeden değil hoparlörden çıkar
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: 
          AVAudioSessionCategoryOptions.defaultToSpeaker |
          AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.allowAirPlay,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidWillPauseWhenDucked: true,
      ));
      
      _sessionInitialized = true;
      debugPrint('TalkingMascot: Audio Session başarıyla yapılandırıldı');
    } catch (e) {
      debugPrint('TalkingMascot: Audio Session hatası - $e');
    }
  }

  /// Kayıt başlat
  Future<bool> startRecording() async {
    try {
      // İzinleri kontrol et
      if (!await requestMicrophonePermission()) return false;

      // Tek seferlik Audio Session initialization
      await _initAudioSession();

      // Geçici dosya yolu (.m4a formatı - iOS Core Audio ile native uyumlu)
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/mascot_voice_$timestamp.wav';

      // Kayıt ayarları (AAC encoder - iOS için optimal)
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      debugPrint('TalkingMascot: Kayıt başladı - $_currentRecordingPath');
      return true;
    } catch (e) {
      debugPrint('TalkingMascot: Kayıt hatası - $e');
      _isRecording = false;
      return false;
    }
  }

  /// Kayıt durdur
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;
      
      final path = await _recorder.stop();
      _isRecording = false;
      
      // Race condition'ı önlemek için kısa bir bekleme (Güvenli IO Delay)
      await Future.delayed(const Duration(milliseconds: 250));
      
      debugPrint('TalkingMascot: Kayıt durduruldu - $path');
      return path;
    } catch (e) {
      debugPrint('TalkingMascot: Kayıt durdurma hatası - $e');
      _isRecording = false;
      return null;
    }
  }

  /// Kaydedilen sesi pitch shift ile oynat
  Future<void> playRecordingWithPitchShift({
    double pitchMultiplier = 1.5,
    double speedMultiplier = 1.3,
    VoidCallback? onComplete,
  }) async {
    if (_currentRecordingPath == null) {
      debugPrint('TalkingMascot: Oynatılacak kayıt yok');
      onComplete?.call();
      return;
    }

    try {
      _isPlaying = true;

      // Dosya varlığını kontrol et
      final file = File(_currentRecordingPath!);
      if (!await file.exists()) {
        debugPrint('TalkingMascot: Kayıt dosyası bulunamadı - $_currentRecordingPath');
        return;
      }
      
      // Dosya boyutunu kontrol et (boş dosya olabilir)
      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('TalkingMascot: Kayıt dosyası boş');
        return;
      }
      
      debugPrint('TalkingMascot: Oynatma başlıyor ($fileSize bytes, pitch: $pitchMultiplier, speed: $speedMultiplier)');

      // Session zaten _initAudioSession'da ayarlandı
      // Ek yapılandırma yapmıyoruz - iOS'te session değişimi sorun yaratır

      // Dosyayı yükle
      await _player.setFilePath(_currentRecordingPath!);

      // Efektleri ayarla
      await _player.setSpeed(speedMultiplier);
      await _player.setPitch(pitchMultiplier);

      // Ses seviyesini zorla (iOS'te ahize modunda kalmaması için)
      await _player.setVolume(1.0);

      // Oynat ve bitmesini bekle
      await _player.play();
      
      debugPrint('TalkingMascot: Oynatma tamamlandı');

    } catch (e) {
      debugPrint('TalkingMascot: Oynatma hatası - $e');
    } finally {
      // Her durumda (hata olsa bile) durumu sıfırla ve callback'i çağır
      _isPlaying = false;
      onComplete?.call();
    }
  }

  Future<void> stopPlaying() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (_) {}
  }

  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      if (await dir.exists()) {
        await for (final file in dir.list()) {
          if (file is File && file.path.contains('mascot_voice_')) {
            try {
              await file.delete();
            } catch (_) {
              // Dosya silinemiyor olabilir (kullanımda vs.)
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stopRecording();
    await stopPlaying();
    await _recorder.dispose();
    await _player.dispose();
    await cleanupTempFiles();
  }
}
