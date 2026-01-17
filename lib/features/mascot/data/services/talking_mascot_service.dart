import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audio_session/audio_session.dart';

/// Talking Tom benzeri ses kaydı ve pitch shift oynatma servisi
class TalkingMascotService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

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

  /// Ses oturumunu yapılandır (Kayıt veya Oynatma için)
  Future<void> _configureAudioSession({required bool isRecording}) async {
    final session = await AudioSession.instance;
    
    if (isRecording) {
      // KAYIT MODU: Hem kayıt hem oynatma izinli, varsayılan hoparlör
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker |
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.allowAirPlay,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidWillPauseWhenDucked: true,
      ));
    } else {
      // OYNATMA MODU: Sadece medya oynatma (Hoparlörü zorlar)
      await session.configure(const AudioSessionConfiguration.music());
    }
  }

  /// Kayıt başlat
  Future<bool> startRecording() async {
    try {
      // İzinleri kontrol et
      if (!await requestMicrophonePermission()) return false;

      // 1. Ses oturumunu KAYIT moduna al (iOS için kritik)
      await _configureAudioSession(isRecording: true);

      // Geçici dosya yolu
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/mascot_voice_$timestamp.wav';

      // Kayıt ayarları (iOS pitch shift için WAV en güvenlisidir)
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
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
      return path;
    } catch (e) {
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
    if (_currentRecordingPath == null) return;

    try {
      _isPlaying = true;

      // 1. Ses oturumunu OYNATMA moduna al (iOS'te sesi hoparlöre vermek için ŞART)
      await _configureAudioSession(isRecording: false);

      // 2. Dosyayı yükle
      await _player.setFilePath(_currentRecordingPath!);

      // 3. Efektleri ayarla
      await _player.setSpeed(speedMultiplier);
      await _player.setPitch(pitchMultiplier);

      // 4. Oynat ve bitmesini BEKLE (Stream listener yerine await kullanıldı)
      await _player.play();

    } catch (e) {
      debugPrint('TalkingMascot: Oynatma hatası - $e');
    } finally {
      // 5. Her durumda (hata olsa bile) durumu sıfırla ve callback'i çağır
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
            await file.delete();
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
