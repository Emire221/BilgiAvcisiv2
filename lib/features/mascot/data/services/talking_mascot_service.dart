import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audio_session/audio_session.dart';

class TalkingMascotService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  
  // Session'ın sadece bir kez başlatılması yeterlidir
  bool _isSessionInitialized = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  /// 1. Ses Oturumunu Başlat (TEK VE SABİT MOD)
  /// iOS'te Record <-> Playback arasında sürekli geçiş yapmak hoparlörü bozar.
  /// Bu yüzden "playAndRecord" modunda sabit kalıyoruz.
  Future<void> _initAudioSession() async {
    if (_isSessionInitialized) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: 
          AVAudioSessionCategoryOptions.defaultToSpeaker | // Sesi ahize yerine hoparlöre verir
          AVAudioSessionCategoryOptions.allowBluetooth | 
          AVAudioSessionCategoryOptions.allowAirPlay |
          AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidWillPauseWhenDucked: true,
      ));
      await session.setActive(true);
      _isSessionInitialized = true;
    } catch (e) {
      debugPrint('TalkingMascot: Session hatası - $e');
    }
  }

  Future<bool> startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted == false) {
        return false;
      }

      await _initAudioSession(); // Session'ı garantiye al

      final tempDir = await getTemporaryDirectory();
      // DÜZELTME 1: .wav formatı (Gecikmesiz yazma için şart)
      _currentRecordingPath = '${tempDir.path}/mascot_rec_${DateTime.now().millisecondsSinceEpoch}.wav';

      // DÜZELTME 2: Encoder WAV (PCM) olmalı
      const config = RecordConfig(
        encoder: AudioEncoder.wav, 
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      return true;
    } catch (e) {
      debugPrint('TalkingMascot: Kayıt başlatılamadı - $e');
      _isRecording = false;
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;
      
      final path = await _recorder.stop();
      _isRecording = false;
      
      // DÜZELTME 3: Dosya sisteminin dosyayı kapatması için minik bir bekleme
      if (Platform.isIOS) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      return path;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  Future<void> playRecordingWithPitchShift({
    double pitchMultiplier = 1.5,
    double speedMultiplier = 1.3,
    VoidCallback? onComplete,
  }) async {
    if (_currentRecordingPath == null) {
      onComplete?.call();
      return;
    }

    try {
      _isPlaying = true;

      final file = File(_currentRecordingPath!);
      if (!await file.exists() || await file.length() < 500) {
        debugPrint('TalkingMascot: Dosya çok küçük veya yok');
        _isPlaying = false;
        onComplete?.call();
        return;
      }

      // Player ayarları
      await _player.stop();
      await _player.setVolume(1.0); // Sesi maksimuma zorla
      
      // Dosyayı yükle
      await _player.setFilePath(_currentRecordingPath!);
      
      // Efektler
      await _player.setPitch(pitchMultiplier);
      await _player.setSpeed(speedMultiplier);

      // Oynat ve bitmesini bekle (Stream listener yerine await play en sağlıklısıdır)
      await _player.play();

    } catch (e) {
      debugPrint('TalkingMascot: Oynatma hatası - $e');
    } finally {
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

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}