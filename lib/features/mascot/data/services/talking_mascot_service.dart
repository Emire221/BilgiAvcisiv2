import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Talking Tom benzeri ses kaydı ve pitch shift oynatma servisi
class TalkingMascotService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  /// Kayıt yapılıyor mu?
  bool get isRecording => _isRecording;

  /// Ses çalınıyor mu?
  bool get isPlaying => _isPlaying;

  /// Mikrofon izni kontrolü ve isteme
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Kullanıcıyı ayarlara yönlendir
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Kayıt başlat
  Future<bool> startRecording() async {
    try {
      // İzin kontrolü
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        if (kDebugMode) {
          debugPrint('TalkingMascot: Mikrofon izni verilmedi');
        }
        return false;
      }

      // Kayıt cihazı kontrolü
      final canRecord = await _recorder.hasPermission();
      if (!canRecord) {
        if (kDebugMode) {
          debugPrint('TalkingMascot: Kayıt izni yok');
        }
        return false;
      }

      // Geçici dosya yolu
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/mascot_voice_$timestamp.m4a';

      // Kayıt ayarları
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;

      if (kDebugMode) {
        debugPrint('TalkingMascot: Kayıt başladı - $_currentRecordingPath');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TalkingMascot: Kayıt başlatma hatası - $e');
      }
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

      if (kDebugMode) {
        debugPrint('TalkingMascot: Kayıt durduruldu - $path');
      }

      return path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TalkingMascot: Kayıt durdurma hatası - $e');
      }
      _isRecording = false;
      return null;
    }
  }

  /// Kaydedilen sesi pitch shift ile oynat (sincap sesi)
  /// [pitchMultiplier] - 1.0 = normal, 1.5 = ince ses (sincap), 0.7 = kalın ses
  Future<void> playRecordingWithPitchShift({
    double pitchMultiplier = 1.5,
    double speedMultiplier = 1.3,
    VoidCallback? onComplete,
  }) async {
    try {
      if (_currentRecordingPath == null) {
        if (kDebugMode) {
          debugPrint('TalkingMascot: Çalınacak kayıt yok');
        }
        return;
      }

      final file = File(_currentRecordingPath!);
      if (!await file.exists()) {
        if (kDebugMode) {
          debugPrint('TalkingMascot: Kayıt dosyası bulunamadı');
        }
        return;
      }

      _isPlaying = true;

      // Dosyayı yükle
      await _player.setFilePath(_currentRecordingPath!);

      // Pitch ve hız ayarla
      await _player.setSpeed(speedMultiplier);
      await _player.setPitch(pitchMultiplier);

      // Oynatma tamamlandığında callback
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          onComplete?.call();
        }
      });

      // Oynat
      await _player.play();

      if (kDebugMode) {
        debugPrint(
          'TalkingMascot: Ses çalınıyor (pitch: $pitchMultiplier, speed: $speedMultiplier)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TalkingMascot: Ses çalma hatası - $e');
      }
      _isPlaying = false;
    }
  }

  /// Oynatmayı durdur
  Future<void> stopPlaying() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TalkingMascot: Oynatma durdurma hatası - $e');
      }
    }
  }

  /// Geçici ses dosyalarını temizle
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);

      await for (final file in dir.list()) {
        if (file is File && file.path.contains('mascot_voice_')) {
          await file.delete();
        }
      }

      if (kDebugMode) {
        debugPrint('TalkingMascot: Geçici dosyalar temizlendi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TalkingMascot: Temizleme hatası - $e');
      }
    }
  }

  /// Servisi kapat
  Future<void> dispose() async {
    await stopRecording();
    await stopPlaying();
    await _recorder.dispose();
    await _player.dispose();
    await cleanupTempFiles();
  }
}
