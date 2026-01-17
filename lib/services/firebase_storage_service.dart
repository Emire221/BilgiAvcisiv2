import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:archive/archive.dart';
import '../models/models.dart';
import 'database_helper.dart';
import '../features/sync/domain/models/manifest_model.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage;
  final IDatabaseHelper _dbHelper;

  FirebaseStorageService({FirebaseStorage? storage, IDatabaseHelper? dbHelper})
    : _storage = storage ?? FirebaseStorage.instance,
      _dbHelper = dbHelper ?? DatabaseHelper();

  // Türkçe karakterleri düzgün şekilde normalize et
  String _normalizeCityName(String cityName) {
    return cityName
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('İ', 'i')
        .replaceAll('Ğ', 'g')
        .replaceAll('Ü', 'u')
        .replaceAll('Ş', 's')
        .replaceAll('Ö', 'o')
        .replaceAll('Ç', 'c');
  }

  // Okul verilerini indir (okullar/[IL].json)
  Future<List<School>> downloadSchoolData(String cityName) async {
    try {
      final normalizedName = _normalizeCityName(cityName);
      final ref = _storage.ref().child('okullar/$normalizedName.json');
      final data = await ref.getData();
      if (data == null) return [];

      final jsonString = utf8.decode(data);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => School.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Okul verisi indirme hatası: $e');
      return [];
    }
  }

  // Sınıf içeriğini indir ve veritabanına kaydet
  Future<void> downloadClassContent(
    String className,
    Function(String) onProgress,
  ) async {
    try {
      // 1. Temel dosyaları indir
      onProgress('📚 Kitaplar raftan alınıyor...');
      final dersListesiStr = await _downloadJsonString(
        className,
        'derslistesi.json',
      );
      final konuListesiStr = await _downloadJsonString(
        className,
        'konulistesi.json',
      );

      if (dersListesiStr == null || konuListesiStr == null) {
        throw Exception('Temel dosyalar bulunamadı');
      }

      // 2. Sadece içerik verilerini temizle (kullanıcı verileri korunur)
      await _dbHelper.clearContentDataOnly();

      // 3. JSON'ları arka planda parse et ve hazırla
      onProgress('✨ Sihir yapılıyor...');

      // Dersler
      final derslerData = await compute(_parseDersler, dersListesiStr);
      await _dbHelper.batchInsert('Dersler', derslerData);

      // Konular
      final konularData = await compute(_parseKonular, konuListesiStr);
      await _dbHelper.batchInsert('Konular', konularData);

      // 4. Ders klasörlerini tara ve içerikleri indir
      final dersler = derslerData.map((d) => Lesson.fromJson(d)).toList();

      for (var ders in dersler) {
        onProgress('🎯 ${ders.dersAdi} maceracıları hazırlanıyor...');
        String folderName = _getFolderNameForLesson(ders.dersAdi);

        // Testleri indir ve kaydet
        await _processFolderContent(
          '$className/$folderName/testler',
          'Testler',
          _parseTest,
        );

        // Bilgi kartlarını indir ve kaydet
        await _processFolderContent(
          '$className/$folderName/bilgi',
          'BilgiKartlari',
          _parseBilgiKart,
        );
      }

      onProgress('🎉 Süper! Her şey tamam!');
    } catch (e) {
      if (kDebugMode) debugPrint('İçerik indirme hatası: $e');
      rethrow;
    }
  }

  Future<String?> _downloadJsonString(String className, String fileName) async {
    try {
      // 1. Güvenli dosya ismi oluştur (Örn: "3. Sınıf" -> "3_Sinif")
      final safeClassName = className.replaceAll('.', '').replaceAll(' ', '_');
      final localFileName = '${safeClassName}_$fileName';

      // 2. Yerel dizini al
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$localFileName');

      // 3. Dosya var mı kontrol et
      if (await file.exists()) {
        if (kDebugMode) debugPrint('Yerel hafızadan okunuyor: $localFileName');
        return await file.readAsString();
      }

      // 4. Yoksa Firebase'den indir
      final fullPath = '$className/$fileName';
      if (kDebugMode) debugPrint('Firebase\'den indiriliyor: $fullPath');
      final ref = _storage.ref().child(fullPath);
      final data = await ref.getData();

      if (data == null) return null;

      final jsonString = utf8.decode(data);

      // 5. Yerel hafızaya kaydet
      await file.writeAsString(jsonString);
      if (kDebugMode) debugPrint('Yerel hafızaya kaydedildi: $localFileName');

      return jsonString;
    } catch (e) {
      if (kDebugMode) debugPrint('$fileName indirme hatası: $e');
      return null;
    }
  }

  Future<void> _processFolderContent(
    String path,
    String tableName,
    Map<String, dynamic> Function(String) parser,
  ) async {
    try {
      final result = await _storage.ref().child(path).listAll();
      List<Future<String?>> downloadTasks = [];

      for (var item in result.items) {
        if (item.name.endsWith('.json')) {
          downloadTasks.add(
            item.getData().then((data) {
              return data != null ? utf8.decode(data) : null;
            }),
          );
        }
      }

      final jsonStrings = await Future.wait(downloadTasks);
      final validStrings = jsonStrings.whereType<String>().toList();

      if (validStrings.isNotEmpty) {
        // Toplu parse ve insert
        final dataList = await compute(_parseList, {
          'strings': validStrings,
          'parser': parser,
        });
        await _dbHelper.batchInsert(tableName, dataList);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('$path içeriği indirme hatası: $e');
    }
  }

  String _getFolderNameForLesson(String lessonName) {
    if (lessonName.contains('Fen')) return 'Fen';
    if (lessonName.contains('Matematik')) return 'Matematik';
    if (lessonName.contains('Türkçe')) return 'Turkce';
    if (lessonName.contains('İnkılap')) {
      return 'T.C. Inkilap Tarihi ve Ataturkculuk';
    }
    if (lessonName.contains('İngilizce')) return 'Ingilizce';
    if (lessonName.contains('Sosyal')) return 'Sosyal';
    if (lessonName.contains('Din')) return 'Din';
    return lessonName.split(' ')[0];
  }

  // ========== YENİ SYNC 2.0 METODLARI ==========

  /// Manifest dosyasını indir ve parse et
  Future<Manifest> downloadManifest(String className) async {
    try {
      final ref = _storage.ref().child('$className/manifest.json');
      final data = await ref.getData();
      if (data == null) {
        throw Exception('Manifest dosyası bulunamadı');
      }

      final jsonString = utf8.decode(data);
      final jsonMap = json.decode(jsonString);
      return Manifest.fromJson(jsonMap as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('Manifest indirme hatası: $e');
      rethrow;
    }
  }

  /// tar.bz2 arşiv dosyasını indir ve aç
  Future<void> downloadAndExtractArchive(
    String archivePath,
    Function(String) onProgress, {
    String? destinationPath,
  }) async {
    try {
      onProgress('📦 Gizli paket geliyor...');

      // tar.bz2 dosyasını indir
      final ref = _storage.ref().child(archivePath);
      final data = await ref.getData();
      if (data == null) {
        throw Exception('Arşiv dosyası bulunamadı: $archivePath');
      }

      onProgress('🎁 Hediye açılıyor...');

      // BZip2 ile sıkıştırılmış tar arşivini aç
      // Önce BZip2 decode et, sonra tar decode et
      final decompressed = BZip2Decoder().decodeBytes(data);
      final archive = TarDecoder().decodeBytes(decompressed);

      String basePath;
      if (destinationPath != null) {
        basePath = destinationPath;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        basePath = directory.path;
      }

      for (final file in archive.files) {
        final filename = file.name;
        final outPath = '$basePath/$filename';
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }
      if (kDebugMode) {
        debugPrint(
          'Arşiv açma işlemi: $archivePath (${data.length} bytes) -> $basePath',
        );
      }
      onProgress('🌠 Büyülü kutu açıldı!');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Arşiv indirme/açma hatası ($archivePath): $e');
      }
      rethrow;
    }
  }

  /// Arşivden çıkan dosyaları tara ve veritabanına kaydet
  Future<void> processLocalArchiveContent(
    String rootPath,
    Function(String) onProgress,
  ) async {
    try {
      final dir = Directory(rootPath);
      if (!await dir.exists()) {
        throw Exception('Klasör bulunamadı: $rootPath');
      }

      // 1. Ders Listesi
      final dersListesiFile = File('${dir.path}/derslistesi.json');
      if (await dersListesiFile.exists()) {
        onProgress('📚 Dersler hazırlanıyor...');
        final jsonString = await dersListesiFile.readAsString();
        final derslerData = await compute(_parseDersler, jsonString);
        await _dbHelper.batchInsert('Dersler', derslerData);
      }

      // 2. Konu Listesi
      final konuListesiFile = File('${dir.path}/konulistesi.json');
      if (await konuListesiFile.exists()) {
        onProgress('🗺️ Konular haritalandırılıyor...');
        final jsonString = await konuListesiFile.readAsString();
        final konularData = await compute(_parseKonular, jsonString);
        await _dbHelper.batchInsert('Konular', konularData);
      }

      // 4. Kök dizindeki tüm JSON dosyalarını tara (testler ve bilgi kartları)
      onProgress('🎨 Rengarenk içerikler düzenleniyor...');
      final allFiles = dir.listSync();

      // Temel dosyaları filtrele
      final excludedFiles = {
        'derslistesi.json',
        'konulistesi.json',
        'konuvideo.json',
        'manifest.json',
      };

      int processedTests = 0;
      int processedFlashcards = 0;
      int processedLevels = 0;
      int processedWeeklyExams = 0;
      int processedGuessLevels = 0;
      int skippedFiles = 0;

      for (var item in allFiles) {
        if (item is File && item.path.endsWith('.json')) {
          final fileName = item.path.split(Platform.pathSeparator).last;

          // Temel dosyaları atla
          if (excludedFiles.contains(fileName)) {
            continue;
          }

          try {
            final jsonString = await item.readAsString();
            final jsonData = json.decode(jsonString);

            // Test dosyası mı kontrol et (testID alanı var mı?)
            if (jsonData is Map<String, dynamic> &&
                jsonData.containsKey('testID')) {
              final testData = _parseTest(jsonString);
              await _dbHelper.insertTest(testData);
              processedTests++;
              if (kDebugMode) debugPrint('Test işlendi: $fileName');
            }
            // Bilgi kartı dosyası mı kontrol et (kartSetID alanı var mı?)
            else if (jsonData is Map<String, dynamic> &&
                jsonData.containsKey('kartSetID')) {
              final bilgiKartData = _parseBilgiKart(jsonString);
              await _dbHelper.insertFlashcardSet(bilgiKartData);
              processedFlashcards++;
              if (kDebugMode) debugPrint('Bilgi kartı işlendi: $fileName');
            }
            // Fill Blanks Level dosyası mı kontrol et (levelID alanı var mı?)
            else if (jsonData is Map<String, dynamic> &&
                jsonData.containsKey('levelID')) {
              // questions field'ını JSON string olarak kaydet
              final levelData = Map<String, dynamic>.from(jsonData);
              if (levelData.containsKey('questions')) {
                levelData['questions'] = json.encode(levelData['questions']);
              }
              await _dbHelper.insertFillBlanksLevel(levelData);
              processedLevels++;
              if (kDebugMode) {
                debugPrint('Fill Blanks Level işlendi: $fileName');
              }
            }
            // Haftalık Sınav dosyası mı kontrol et (weeklyExamId alanı var mı?)
            else if (jsonData is Map<String, dynamic> &&
                jsonData.containsKey('weeklyExamId')) {
              // questions field'ını JSON string olarak kaydet
              final examData = Map<String, dynamic>.from(jsonData);
              if (examData.containsKey('questions')) {
                examData['questions'] = json.encode(examData['questions']);
              }
              // turkeyAverages Map'ini JSON string'e çevir
              if (examData.containsKey('turkeyAverages') &&
                  examData['turkeyAverages'] is Map) {
                examData['turkeyAverages'] = json.encode(
                  examData['turkeyAverages'],
                );
              }

              // Önce eski sınav verilerini sil, sonra yenisini ekle
              final newExamId = examData['weeklyExamId'] as String;
              await _dbHelper.clearOldWeeklyExamData(newExamId);
              await _dbHelper.insertWeeklyExam(examData);
              processedWeeklyExams++;
              debugPrint(
                'Haftalık Sınav işlendi (eski veriler silindi): $fileName',
              );
            }
            // Salla Bakalım (Guess) dosyası mı kontrol et (guessID veya sallaID alanı var mı?)
            else if (jsonData is Map<String, dynamic> &&
                (jsonData.containsKey('guessID') ||
                    jsonData.containsKey('sallaID'))) {
              // Sadece DB'de olan kolonları içeren yeni map oluştur
              final guessData = <String, dynamic>{
                'levelID': jsonData['guessID'] ?? jsonData['sallaID'],
                'title': jsonData['title'],
                'description': jsonData['description'],
                'difficulty': jsonData['difficulty'],
                'questions': jsonData.containsKey('questions')
                    ? json.encode(jsonData['questions'])
                    : '[]',
              };
              await _dbHelper.insertGuessLevel(guessData);
              processedGuessLevels++;
              if (kDebugMode) {
                debugPrint('Salla Bakalım Level işlendi: $fileName');
              }
            }
            // Ne test ne bilgi kartı ne de oyun dosyası değilse
            else {
              skippedFiles++;
              if (kDebugMode) {
                debugPrint('Bilinmeyen dosya formatı atlandı: $fileName');
              }
            }
          } catch (e) {
            skippedFiles++;
            if (kDebugMode) debugPrint('Dosya işleme hatası ($fileName): $e');
          }
        }
      }

      debugPrint(
        'İşlem özeti: $processedTests test, $processedFlashcards bilgi kartı, '
        '$processedLevels level, $processedWeeklyExams haftalık sınav, '
        '$processedGuessLevels salla bakalım, $skippedFiles atlanan dosya',
      );
      onProgress(
        '🏆 Harika! $processedTests test, $processedFlashcards kart hazır!',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Yerel içerik işleme hatası: $e');
      rethrow;
    }
  }

  /// JSON dosyasını indir ve DB'ye kaydet
  Future<void> downloadAndProcessJson(
    String jsonPath,
    Function(String) onProgress,
  ) async {
    try {
      onProgress('🔮 Kristal küre okunuyor...');

      final ref = _storage.ref().child(jsonPath);
      final data = await ref.getData();
      if (data == null) {
        throw Exception('JSON dosyası bulunamadı: $jsonPath');
      }

      final jsonString = utf8.decode(data);
      onProgress('✨ Büyü tamamlanıyor...');

      // Dosya tipine göre parse et ve DB'ye kaydet
      if (jsonPath.contains('derslistesi')) {
        final derslerData = await compute(_parseDersler, jsonString);
        await _dbHelper.batchInsert('Dersler', derslerData);
      } else if (jsonPath.contains('konulistesi')) {
        final konularData = await compute(_parseKonular, jsonString);
        await _dbHelper.batchInsert('Konular', konularData);
      } else if (jsonPath.contains('testler')) {
        final testData = _parseTest(jsonString);
        await _dbHelper.insertTest(testData);
      } else if (jsonPath.contains('bilgi')) {
        final bilgiKartData = _parseBilgiKart(jsonString);
        await _dbHelper.insertFlashcardSet(bilgiKartData);
      }

      onProgress('⭐ Parlak içerik hazır!');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('JSON indirme/işleme hatası ($jsonPath): $e');
      }
      rethrow;
    }
  }

  /// Oyun içeriği JSON dosyalarını indir (cache destekli)
  /// Path örnekleri: 'games/fill_blanks/levels.json', 'games/arena/questions.json'
  Future<String?> downloadGameContent(String path) async {
    try {
      // 1. Güvenli dosya ismi oluştur
      final safeFileName = path.replaceAll('/', '_');

      // 2. Yerel dizini al
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$safeFileName');

      // 3. Dosya var mı kontrol et (cache)
      if (await file.exists()) {
        if (kDebugMode) {
          debugPrint('Oyun içeriği cache\'ten okunuyor: $safeFileName');
        }
        return await file.readAsString();
      }

      // 4. Yoksa Firebase'den indir
      if (kDebugMode) {
        debugPrint('Firebase\'den oyun içeriği indiriliyor: $path');
      }
      final ref = _storage.ref().child(path);
      final data = await ref.getData();

      if (data == null) {
        throw Exception('Oyun içeriği bulunamadı: $path');
      }

      final jsonString = utf8.decode(data);

      // 5. Yerel hafızaya kaydet (cache)
      await file.writeAsString(jsonString);
      if (kDebugMode) {
        debugPrint('Oyun içeriği cache\'e kaydedildi: $safeFileName');
      }

      return jsonString;
    } catch (e) {
      if (kDebugMode) debugPrint('Oyun içeriği indirme hatası ($path): $e');
      return null;
    }
  }

  /// Cache'deki oyun içeriğini temizle
  Future<void> clearGameContentCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);
      await for (var entity in dir.list()) {
        if (entity is File && entity.path.contains('games_')) {
          await entity.delete();
          if (kDebugMode) debugPrint('Cache silindi: ${entity.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Cache temizleme hatası: $e');
    }
  }
}

// Top-level functions for compute
List<Map<String, dynamic>> _parseDersler(String jsonString) {
  final jsonMap = json.decode(jsonString);
  return (jsonMap['dersler'] as List)
      .map((e) => Lesson.fromJson(e).toMap())
      .toList();
}

List<Map<String, dynamic>> _parseKonular(String jsonString) {
  final jsonMap = json.decode(jsonString);
  return (jsonMap['konular'] as List)
      .map((e) => Topic.fromJson(e).toMap())
      .toList();
}

Map<String, dynamic> _parseTest(String jsonString) {
  return Test.fromJson(json.decode(jsonString)).toMap();
}

Map<String, dynamic> _parseBilgiKart(String jsonString) {
  return FlashcardSet.fromJson(json.decode(jsonString)).toMap();
}

List<Map<String, dynamic>> _parseList(Map<String, dynamic> args) {
  final strings = args['strings'] as List<String>;
  final parser = args['parser'] as Map<String, dynamic> Function(String);
  return strings.map((s) => parser(s)).toList();
}
