import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class IDatabaseHelper {
  Future<void> batchInsert(String table, List<Map<String, dynamic>> rows);
  Future<void> insertTest(Map<String, dynamic> row);
  Future<void> insertFlashcardSet(Map<String, dynamic> row);
  Future<void> insertFillBlanksLevel(Map<String, dynamic> row);
  Future<void> insertWeeklyExam(Map<String, dynamic> row);
  Future<void> insertGuessLevel(Map<String, dynamic> row);
  Future<Map<String, dynamic>?> getLatestWeeklyExam();
  Future<void> clearOldWeeklyExamData(String newExamId);
  Future<void> clearAllData();
  Future<void> addDownloadedFile(String path);
  Future<void> insertDers(Map<String, dynamic> row);
  Future<void> insertKonu(Map<String, dynamic> row);
}

class DatabaseHelper implements IDatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bilgi_avcisi.db');
    return await openDatabase(
      path,
      version: 13,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Dersler Tablosu
    await db.execute('''
      CREATE TABLE Dersler(
        dersID TEXT PRIMARY KEY,
        dersAdi TEXT,
        ikon TEXT,
        renk TEXT
      )
    ''');

    // Konular Tablosu
    await db.execute('''
      CREATE TABLE Konular(
        konuID TEXT PRIMARY KEY,
        dersID TEXT,
        konuAdi TEXT,
        sira INTEGER,
        FOREIGN KEY(dersID) REFERENCES Dersler(dersID)
      )
    ''');

    // Testler Tablosu
    await db.execute('''
      CREATE TABLE Testler(
        testID TEXT PRIMARY KEY,
        konuID TEXT,
        testAdi TEXT,
        zorluk INTEGER,
        cozumVideoURL TEXT,
        sorular TEXT, -- JSON String olarak saklanacak
        FOREIGN KEY(konuID) REFERENCES Konular(konuID)
      )
    ''');

    // Bilgi Kartları Tablosu
    await db.execute('''
      CREATE TABLE BilgiKartlari(
        kartSetID TEXT PRIMARY KEY,
        konuID TEXT,
        kartAdi TEXT,
        kartlar TEXT, -- JSON String olarak saklanacak
        FOREIGN KEY(konuID) REFERENCES Konular(konuID)
      )
    ''');

    // Bildirimler Tablosu
    await db.execute('''
      CREATE TABLE Notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        date TEXT,
        isRead INTEGER
      )
    ''');

    // Deneme Sınavları Tablosu
    await db.execute('''
      CREATE TABLE TrialExams(
        id TEXT PRIMARY KEY,
        title TEXT,
        startDate TEXT,
        endDate TEXT,
        duration INTEGER,
        contentJson TEXT
      )
    ''');

    // Deneme Sonuçları Tablosu (Ham Cevaplar)
    await db.execute('''
      CREATE TABLE TrialResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        examId TEXT,
        userId TEXT,
        rawAnswers TEXT,
        score INTEGER,
        completedAt TEXT,
        FOREIGN KEY(examId) REFERENCES TrialExams(id)
      )
    ''');

    // Kullanıcı Maskotları Tablosu
    await db.execute('''
      CREATE TABLE UserPets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petType TEXT NOT NULL,
        petName TEXT NOT NULL,
        currentXp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        mood INTEGER DEFAULT 100,
        createdAt TEXT DEFAULT (datetime('now'))
      )
    ''');

    // İndirilen Dosyalar Tablosu
    await db.execute('''
      CREATE TABLE DownloadedFiles(
        path TEXT PRIMARY KEY,
        date TEXT
      )
    ''');

    // Test Sonuçları Tablosu
    await db.execute('''
      CREATE TABLE TestResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        testId TEXT,
        score INTEGER,
        correct INTEGER,
        wrong INTEGER,
        date TEXT
      )
    ''');

    // Fill Blanks Levels Tablosu
    await db.execute('''
      CREATE TABLE FillBlanksLevels(
        levelID TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        difficulty INTEGER,
        category TEXT,
        questions TEXT
      )
    ''');

    // Game Results Tablosu (Tüm oyun sonuçları için)
    await db.execute('''
      CREATE TABLE GameResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gameType TEXT NOT NULL,
        score INTEGER,
        correctCount INTEGER,
        wrongCount INTEGER,
        totalQuestions INTEGER,
        completedAt TEXT,
        details TEXT,
        key TEXT
      )
    ''');

    // Haftalık Sınavlar Tablosu (İndirilen sınav verileri)
    await db.execute('''
      CREATE TABLE WeeklyExams(
        weeklyExamId TEXT PRIMARY KEY,
        title TEXT,
        weekStart TEXT,
        duration INTEGER,
        description TEXT,
        questions TEXT
      )
    ''');

    // Haftalık Sınav Sonuçları Tablosu
    await db.execute('''
      CREATE TABLE WeeklyExamResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        examId TEXT NOT NULL,
        odaId TEXT NOT NULL,
        odaIsmi TEXT,
        odaBaslangic TEXT,
        odaBitis TEXT,
        sonucTarihi TEXT,
        odaDurumu TEXT,
        odaKatilimciId TEXT NOT NULL,
        cevaplar TEXT,
        dogru INTEGER,
        yanlis INTEGER,
        bos INTEGER,
        puan INTEGER,
        siralama INTEGER,
        toplamKatilimci INTEGER,
        completedAt TEXT
      )
    ''');

    // Salla Bakalım (Guess) Tablosu
    await db.execute('''
      CREATE TABLE GuessLevels(
        levelID TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        difficulty INTEGER,
        questions TEXT
      )
    ''');

    // Görüntülenen Bilgi Kartı Setleri Tablosu (badge takibi için)
    await db.execute('''
      CREATE TABLE ViewedFlashcardSets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kartSetID TEXT NOT NULL UNIQUE,
        topicID TEXT NOT NULL,
        viewedAt TEXT
      )
    ''');

    // Düello Görülen İçerik Tablosu (aynı içeriğin tekrar gösterilmemesi için)
    await db.execute('''
      CREATE TABLE SeenDuelContent(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contentType TEXT NOT NULL,
        contentId TEXT NOT NULL,
        seenAt TEXT NOT NULL,
        UNIQUE(contentType, contentId)
      )
    ''');

    // Günlük Uygulama Kullanım Süresi Tablosu
    await db.execute('''
      CREATE TABLE DailyTimeTracking(
        date TEXT PRIMARY KEY,
        durationSeconds INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS Notifications(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          body TEXT,
          date TEXT,
          isRead INTEGER
        )
      ''');
    }

    if (oldVersion < 3) {
      // Deneme Sınavları Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS TrialExams(
          id TEXT PRIMARY KEY,
          title TEXT,
          startDate TEXT,
          endDate TEXT,
          duration INTEGER,
          contentJson TEXT
        )
      ''');

      // Deneme Sonuçları Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS TrialResults(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          examId TEXT,
          userId TEXT,
          rawAnswers TEXT,
          score INTEGER,
          completedAt TEXT,
          FOREIGN KEY(examId) REFERENCES TrialExams(id)
        )
      ''');
    }

    if (oldVersion < 4) {
      // Kullanıcı Maskotları Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS UserPets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          petType TEXT NOT NULL,
          petName TEXT NOT NULL,
          currentXp INTEGER DEFAULT 0,
          level INTEGER DEFAULT 1,
          mood INTEGER DEFAULT 100,
          createdAt TEXT DEFAULT (datetime('now'))
        )
      ''');
    }

    if (oldVersion < 5) {
      // İndirilen Dosyalar Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS DownloadedFiles(
          path TEXT PRIMARY KEY,
          date TEXT
        )
      ''');

      // Test Sonuçları Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS TestResults(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          testId TEXT,
          score INTEGER,
          correct INTEGER,
          wrong INTEGER,
          date TEXT
        )
      ''');

      // Fill Blanks Levels Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS FillBlanksLevels(
          levelID TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          difficulty INTEGER,
          category TEXT,
          questions TEXT
        )
      ''');
    }

    if (oldVersion < 6) {
      // Game Results Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS GameResults(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          gameType TEXT NOT NULL,
          score INTEGER,
          correctCount INTEGER,
          wrongCount INTEGER,
          totalQuestions INTEGER,
          completedAt TEXT,
          details TEXT
        )
      ''');
    }

    if (oldVersion < 7) {
      // Haftalık Sınav Sonuçları Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS WeeklyExamResults(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          examId TEXT NOT NULL,
          odaId TEXT NOT NULL,
          odaIsmi TEXT,
          odaBaslangic TEXT,
          odaBitis TEXT,
          sonucTarihi TEXT,
          odaDurumu TEXT,
          odaKatilimciId TEXT NOT NULL,
          cevaplar TEXT,
          dogru INTEGER,
          yanlis INTEGER,
          bos INTEGER,
          puan INTEGER,
          siralama INTEGER,
          toplamKatilimci INTEGER,
          completedAt TEXT
        )
      ''');
    }

    if (oldVersion < 8) {
      // Haftalık Sınavlar Tablosu (İndirilen sınav verileri)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS WeeklyExams(
          weeklyExamId TEXT PRIMARY KEY,
          title TEXT,
          weekStart TEXT,
          duration INTEGER,
          description TEXT,
          questions TEXT
        )
      ''');
    }

    if (oldVersion < 9) {
      // Salla Bakalım (Guess) Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS GuessLevels(
          levelID TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          difficulty INTEGER,
          questions TEXT
        )
      ''');
    }

    if (oldVersion < 10) {
      // Görüntülenen Bilgi Kartı Setleri Tablosu (badge takibi için)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ViewedFlashcardSets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kartSetID TEXT NOT NULL UNIQUE,
          topicID TEXT NOT NULL,
          viewedAt TEXT
        )
      ''');
    }

    if (oldVersion < 11) {
      // Düello Görülen İçerik Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS SeenDuelContent(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contentType TEXT NOT NULL,
          contentId TEXT NOT NULL,
          seenAt TEXT NOT NULL,
          UNIQUE(contentType, contentId)
        )
      ''');
    }

    if (oldVersion < 12) {
      // GameResults tablosuna key sütunu ekle (TestID veya KonuID için)
      try {
        await db.execute('ALTER TABLE GameResults ADD COLUMN key TEXT');
      } catch (e) {
        // Sütun zaten varsa hata verebilir, yut
        if (e.toString().contains('duplicate column name')) {
          // ignore
        }
      }
    }

    if (oldVersion < 13) {
      // Günlük Uygulama Kullanım Süresi Tablosu
      await db.execute('''
        CREATE TABLE IF NOT EXISTS DailyTimeTracking(
          date TEXT PRIMARY KEY,
          durationSeconds INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  // Ekleme Metotları
  @override
  Future<void> insertDers(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert(
      'Dersler',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertKonu(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert(
      'Konular',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertTest(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert(
      'Testler',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertBilgiKart(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert(
      'BilgiKartlari',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Test için alias metod
  Future<int> insertFlashcard(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(
      'BilgiKartlari',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // FlashcardSet için alias metod
  @override
  Future<void> insertFlashcardSet(Map<String, dynamic> row) async {
    await insertBilgiKart(row);
  }

  // Haftalık Sınav ekleme metodu
  @override
  Future<void> insertWeeklyExam(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert(
      'WeeklyExams',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Haftalık Sınav getirme metodu
  @override
  Future<Map<String, dynamic>?> getLatestWeeklyExam() async {
    Database db = await database;
    final results = await db.query(
      'WeeklyExams',
      orderBy: 'weekStart DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Eski haftalık sınav verilerini temizle
  /// Yeni sınav geldiğinde eski sınav ve sonuçlarını siler
  /// @param newExamId: Yeni gelen sınavın ID'si - bu silinmeyecek
  @override
  Future<void> clearOldWeeklyExamData(String newExamId) async {
    Database db = await database;

    await db.transaction((txn) async {
      // Yeni sınav dışındaki tüm sınavları sil
      await txn.delete(
        'WeeklyExams',
        where: 'weeklyExamId != ?',
        whereArgs: [newExamId],
      );

      // Yeni sınav dışındaki tüm sonuçları sil
      await txn.delete(
        'WeeklyExamResults',
        where: 'examId != ?',
        whereArgs: [newExamId],
      );
    });
  }

  // Bildirimler için CRUD Metotları
  Future<int> insertNotification(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(
      'Notifications',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    Database db = await database;
    return await db.query('Notifications', orderBy: 'date DESC');
  }

  Future<int> deleteNotification(int id) async {
    Database db = await database;
    return await db.delete('Notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markNotificationAsRead(int id) async {
    Database db = await database;
    await db.update(
      'Notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUnreadNotificationCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM Notifications WHERE isRead = 0',
    )) ?? 0;
  }

  // Temizleme Metodu (Yeni sınıf indirildiğinde eskileri silmek için)
  @override
  Future<void> clearAllData() async {
    Database db = await database;
    await db.transaction((txn) async {
      await txn.delete('Dersler');
      await txn.delete('Konular');
      await txn.delete('Testler');
      await txn.delete('BilgiKartlari');
    });
  }

  // Toplu Ekleme Metodu (Batch Insert)
  @override
  Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;
    Database db = await database;
    Batch batch = db.batch();

    for (var row in rows) {
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // İndirilen Dosyalar Metotları
  Future<List<String>> getDownloadedFiles() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('DownloadedFiles');
    return List.generate(maps.length, (i) {
      return maps[i]['path'] as String;
    });
  }

  @override
  Future<void> addDownloadedFile(String path) async {
    Database db = await database;
    await db.insert('DownloadedFiles', {
      'path': path,
      'date': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Test Sonuçları Metotları
  Future<void> saveTestResult(
    String testId,
    int score,
    int correct,
    int wrong,
  ) async {
    Database db = await database;
    await db.insert('TestResults', {
      'testId': testId,
      'score': score,
      'correct': correct,
      'wrong': wrong,
      'date': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fill Blanks Levels  Metotları
  @override
  Future<void> insertFillBlanksLevel(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert(
      'FillBlanksLevels',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFillBlanksLevels() async {
    Database db = await database;
    return await db.query('FillBlanksLevels', orderBy: 'difficulty ASC');
  }

  // Game Results Metotları
  Future<void> saveGameResult({
    required String gameType,
    required int score,
    required int correctCount,
    required int wrongCount,
    required int totalQuestions,
    String? details,
    String? key, // TestID veya KonuID
  }) async {
    Database db = await database;

    // Önce yeni sonucu kaydet
    await db.insert('GameResults', {
      'gameType': gameType,
      'score': score,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'totalQuestions': totalQuestions,
      'completedAt': DateTime.now().toIso8601String(),
      'details': details,
      'key': key,
    });

    // Sonra eski kayıtları temizle (son 50'yi koru)
    await _cleanOldGameResults(db);
  }

  Future<void> _cleanOldGameResults(Database db) async {
    // Toplam kayıt sayısını al
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM GameResults',
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;

    // Eğer 50'den fazla kayıt varsa, en eskileri sil
    if (count > 50) {
      final deleteCount = count - 50;
      await db.rawDelete(
        '''
        DELETE FROM GameResults 
        WHERE id IN (
          SELECT id FROM GameResults 
          ORDER BY completedAt ASC 
          LIMIT ?
        )
      ''',
        [deleteCount],
      );
    }
  }

  /// Salla Bakalım sonuçlarını kaydet (son 10 oyun tutulur)
  Future<void> saveGuessResult({
    required int score,
    required int correctCount,
    required int totalQuestions,
    required String levelTitle,
    required int difficulty,
    required int totalAttempts,
  }) async {
    Database db = await database;

    // Yeni sonucu kaydet
    await db.insert('GameResults', {
      'gameType': 'guess',
      'score': score,
      'correctCount': correctCount,
      'wrongCount': totalQuestions - correctCount,
      'totalQuestions': totalQuestions,
      'completedAt': DateTime.now().toIso8601String(),
      'details':
          '{"levelTitle": "$levelTitle", "difficulty": $difficulty, "totalAttempts": $totalAttempts}',
    });

    // Salla Bakalım için son 10 kaydı tut, eskilerini sil
    await _cleanOldGuessResults(db);
  }

  Future<void> _cleanOldGuessResults(Database db) async {
    // Salla Bakalım kayıt sayısını al
    final countResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM GameResults WHERE gameType = 'guess'",
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;

    // Eğer 10'dan fazla kayıt varsa, en eskileri sil
    if (count > 10) {
      final deleteCount = count - 10;
      await db.rawDelete(
        '''
        DELETE FROM GameResults 
        WHERE id IN (
          SELECT id FROM GameResults 
          WHERE gameType = 'guess'
          ORDER BY completedAt ASC 
          LIMIT ?
        )
      ''',
        [deleteCount],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getGameResults(String gameType) async {
    Database db = await database;
    
    if (gameType == 'test') {
      // Test için detaylı sorgu (Ders ve Konu adlarını da getir)
      // GameResults tablosunda 'testId' sütunu var mı? Hayır, 'key' sütunu var.
      // GameResults tablosu: id, gameType, score, correct, wrong, completedAt, key (testId olabilir)
      
      // Önce tüm sonuçları al
      final results = await db.query(
        'GameResults',
        where: 'gameType = ?',
        whereArgs: [gameType],
        orderBy: 'completedAt DESC',
      );
      
      List<Map<String, dynamic>> enrichedResults = [];
      
      for (final result in results) {
        final resultMap = Map<String, dynamic>.from(result);
        final testId = result['key'] as String?;
        
        if (testId != null && testId.isNotEmpty) {
          // Bu testin konusunu ve dersini bul
          final testData = await db.rawQuery('''
            SELECT T.testAdi, K.konuAdi, D.dersAdi 
            FROM Testler T
            JOIN Konular K ON T.konuID = K.konuID
            JOIN Dersler D ON K.dersID = D.dersID
            WHERE T.testID = ?
          ''', [testId]);
          
          if (testData.isNotEmpty) {
            resultMap['testAdi'] = testData.first['testAdi'];
            resultMap['konuAdi'] = testData.first['konuAdi'];
            resultMap['dersAdi'] = testData.first['dersAdi'];
          }
        }
        enrichedResults.add(resultMap);
      }
      return enrichedResults;
    } else if (gameType == 'flashcard') {
      // Flashcard için detaylı sorgu (Ders ve Konu adlarını da getir)
      final results = await db.query(
        'GameResults',
        where: 'gameType = ?',
        whereArgs: [gameType],
        orderBy: 'completedAt DESC',
      );
      
      List<Map<String, dynamic>> enrichedResults = [];
      
      for (final result in results) {
        final resultMap = Map<String, dynamic>.from(result);
        final topicId = result['key'] as String?;
        
        if (topicId != null && topicId.isNotEmpty) {
          // Bu konuyu ve dersini bul
          final topicData = await db.rawQuery('''
            SELECT K.konuAdi, D.dersAdi 
            FROM Konular K
            JOIN Dersler D ON K.dersID = D.dersID
            WHERE K.konuID = ?
          ''', [topicId]);
          
          if (topicData.isNotEmpty) {
            resultMap['konuAdi'] = topicData.first['konuAdi'];
            resultMap['dersAdi'] = topicData.first['dersAdi'];
          }
        }
        enrichedResults.add(resultMap);
      }
      return enrichedResults;
    } else {
      return await db.query(
        'GameResults',
        where: 'gameType = ?',
        whereArgs: [gameType],
        orderBy: 'completedAt DESC',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllGameResults() async {
    Database db = await database;
    return await db.query('GameResults', orderBy: 'completedAt DESC');
  }

  /// Haftalık sınav sonuçlarını getir
  Future<List<Map<String, dynamic>>> getWeeklyExamResults() async {
    Database db = await database;
    return await db.query(
      'WeeklyExamResults',
      orderBy: 'completedAt DESC',
    );
  }

  // ============================================================
  // Başarı Analitik Metodları
  // ============================================================

  /// Ders bazlı başarı oranlarını hesapla
  /// Her ders için çözülen testlerdeki doğru/toplam oranını döner
  Future<List<Map<String, dynamic>>> getLessonSuccessRates() async {
    Database db = await database;
    
    // Dersleri al
    final dersler = await db.query('Dersler');
    
    List<Map<String, dynamic>> result = [];
    
    for (final ders in dersler) {
      final dersId = ders['dersID'] as String;
      final dersAdi = ders['dersAdi'] as String? ?? '';
      
      // Bu derse ait konuları al
      final konular = await db.query(
        'Konular',
        where: 'dersID = ?',
        whereArgs: [dersId],
      );
      
      if (konular.isEmpty) continue;
      
      final konuIds = konular.map((k) => k['konuID'] as String).toList();
      
      // Bu konulara ait testleri al
      final placeholders = List.filled(konuIds.length, '?').join(',');
      final testler = await db.rawQuery(
        'SELECT testID FROM Testler WHERE konuID IN ($placeholders)',
        konuIds,
      );
      
      if (testler.isEmpty) {
        result.add({
          'dersID': dersId,
          'dersAdi': dersAdi,
          'basariOrani': 0.0,
          'toplamTest': 0,
          'cozulenTest': 0,
        });
        continue;
      }
      
      final testIds = testler.map((t) => t['testID'] as String).toList();
      final testPlaceholders = List.filled(testIds.length, '?').join(',');
      
      // Bu testlerden çözülenlerin sonuçlarını al
      final sonuclar = await db.rawQuery(
        'SELECT correct, wrong FROM TestResults WHERE testId IN ($testPlaceholders)',
        testIds,
      );
      
      if (sonuclar.isEmpty) {
        result.add({
          'dersID': dersId,
          'dersAdi': dersAdi,
          'basariOrani': 0.0,
          'toplamTest': testIds.length,
          'cozulenTest': 0,
        });
        continue;
      }
      
      // Toplam doğru ve yanlış hesapla
      int toplamDogru = 0;
      int toplamSoru = 0;
      
      for (final sonuc in sonuclar) {
        final dogru = sonuc['correct'] as int? ?? 0;
        final yanlis = sonuc['wrong'] as int? ?? 0;
        toplamDogru += dogru;
        toplamSoru += dogru + yanlis;
      }
      
      final basariOrani = toplamSoru > 0 ? (toplamDogru / toplamSoru) * 100 : 0.0;
      
      result.add({
        'dersID': dersId,
        'dersAdi': dersAdi,
        'basariOrani': basariOrani,
        'toplamTest': testIds.length,
        'cozulenTest': sonuclar.length,
      });
    }
    
    return result;
  }

  /// Seçilen derse ait konu başarı oranlarını hesapla
  Future<List<Map<String, dynamic>>> getTopicSuccessRates(String dersId) async {
    Database db = await database;
    
    // Derse ait konuları al
    final konular = await db.query(
      'Konular',
      where: 'dersID = ?',
      whereArgs: [dersId],
      orderBy: 'sira ASC',
    );
    
    List<Map<String, dynamic>> result = [];
    
    for (final konu in konular) {
      final konuId = konu['konuID'] as String;
      final konuAdi = konu['konuAdi'] as String? ?? '';
      
      // Bu konuya ait testleri al
      final testler = await db.query(
        'Testler',
        columns: ['testID'],
        where: 'konuID = ?',
        whereArgs: [konuId],
      );
      
      if (testler.isEmpty) {
        result.add({
          'konuID': konuId,
          'konuAdi': konuAdi,
          'basariOrani': 0.0,
          'cozulenTest': 0,
        });
        continue;
      }
      
      final testIds = testler.map((t) => t['testID'] as String).toList();
      final placeholders = List.filled(testIds.length, '?').join(',');
      
      // Bu testlerin sonuçlarını al
      final sonuclar = await db.rawQuery(
        'SELECT correct, wrong FROM TestResults WHERE testId IN ($placeholders)',
        testIds,
      );
      
      if (sonuclar.isEmpty) {
        result.add({
          'konuID': konuId,
          'konuAdi': konuAdi,
          'basariOrani': 0.0,
          'cozulenTest': 0,
        });
        continue;
      }
      
      // Başarı oranını hesapla
      int toplamDogru = 0;
      int toplamSoru = 0;
      
      for (final sonuc in sonuclar) {
        final dogru = sonuc['correct'] as int? ?? 0;
        final yanlis = sonuc['wrong'] as int? ?? 0;
        toplamDogru += dogru;
        toplamSoru += dogru + yanlis;
      }
      
      final basariOrani = toplamSoru > 0 ? (toplamDogru / toplamSoru) * 100 : 0.0;
      
      result.add({
        'konuID': konuId,
        'konuAdi': konuAdi,
        'basariOrani': basariOrani,
        'cozulenTest': sonuclar.length,
      });
    }
    
    return result;
  }

  /// Rastgele Fill Blanks level çeker
  /// Tüm veriyi belleğe almak yerine SQL RANDOM() kullanır
  Future<Map<String, dynamic>?> getRandomFillBlanksLevel() async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM FillBlanksLevels ORDER BY RANDOM() LIMIT 1',
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Belirlenen zorluk seviyesinden rastgele Fill Blanks level çeker
  /// @param difficulty: 1-3 arası zorluk seviyesi
  Future<Map<String, dynamic>?> getRandomFillBlanksByDifficulty(
    int difficulty,
  ) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM FillBlanksLevels WHERE difficulty = ? ORDER BY RANDOM() LIMIT 1',
      [difficulty],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ============================================================
  // Salla Bakalım (Guess) Metodları
  // ============================================================

  /// Guess Level ekleme
  @override
  Future<void> insertGuessLevel(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert(
      'GuessLevels',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Tüm Guess seviyelerini getir
  Future<List<Map<String, dynamic>>> getGuessLevels() async {
    Database db = await database;
    return await db.query('GuessLevels', orderBy: 'difficulty ASC, title ASC');
  }

  /// Belirli bir Guess seviyesini getir
  Future<Map<String, dynamic>?> getGuessLevel(String levelId) async {
    Database db = await database;
    final results = await db.query(
      'GuessLevels',
      where: 'levelID = ?',
      whereArgs: [levelId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Rastgele Guess seviyesi getir
  Future<Map<String, dynamic>?> getRandomGuessLevel() async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM GuessLevels ORDER BY RANDOM() LIMIT 1',
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Belirli zorluk seviyesinden rastgele Guess level çeker
  Future<Map<String, dynamic>?> getRandomGuessByDifficulty(
    int difficulty,
  ) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM GuessLevels WHERE difficulty = ? ORDER BY RANDOM() LIMIT 1',
      [difficulty],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ============================================================
  // Maskot Metodları
  // ============================================================

  /// Aktif maskotu getir (bildirimler için mascot ismi)
  Future<Map<String, dynamic>?> getActiveMascot() async {
    Database db = await database;
    final results = await db.query('UserPets', orderBy: 'id DESC', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  // ============================================================
  // İlerleme Takip Metodları (Progress Service için)
  // ============================================================

  /// Konu için toplam test sayısı
  Future<int> getTestCountByTopic(String topicId) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Testler WHERE konuID = ?',
      [topicId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Konu için çözülmüş test sayısı (TestResults tablosundan)
  Future<int> getSolvedTestCountByTopic(String topicId) async {
    Database db = await database;
    // Önce bu konuya ait test ID'lerini al
    final tests = await db.query(
      'Testler',
      columns: ['testID'],
      where: 'konuID = ?',
      whereArgs: [topicId],
    );

    if (tests.isEmpty) return 0;

    // Test ID'leri listesi
    final testIds = tests.map((t) => t['testID'] as String).toList();
    final placeholders = List.filled(testIds.length, '?').join(',');

    // Bu testlerden kaç tanesi çözülmüş
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT testId) as count FROM TestResults WHERE testId IN ($placeholders)',
      testIds,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Konu için toplam flashcard set sayısı
  Future<int> getFlashcardSetCountByTopic(String topicId) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM BilgiKartlari WHERE konuID = ?',
      [topicId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Oyun tipi için toplam level sayısı
  Future<int> getTotalLevelCount(String gameType) async {
    Database db = await database;
    String table;
    switch (gameType) {
      case 'fill_blanks':
        table = 'FillBlanksLevels';
        break;
      case 'guess':
        table = 'GuessLevels';
        break;
      default:
        return 0;
    }
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Oyun tipi için tamamlanan level sayısı (GameResults'tan benzersiz details)
  Future<int> getCompletedLevelCount(String gameType) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT details) as count FROM GameResults WHERE gameType = ? AND details IS NOT NULL',
      [gameType],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Flashcard Görüntüleme Takibi
  // ════════════════════════════════════════════════════════════════════════════

  /// Görüntülenen flashcard setini kaydet
  Future<void> saveViewedFlashcardSet(String kartSetID, String topicID) async {
    Database db = await database;
    await db.insert('ViewedFlashcardSets', {
      'kartSetID': kartSetID,
      'topicID': topicID,
      'viewedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Konu için görüntülenen flashcard set sayısı
  Future<int> getViewedFlashcardSetCount(String topicId) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ViewedFlashcardSets WHERE topicID = ?',
      [topicId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Derse ait tüm konu ID'lerini döner
  Future<List<String>> getTopicIdsByLesson(String lessonId) async {
    Database db = await database;
    final result = await db.query(
      'Konular',
      columns: ['konuID'],
      where: 'dersID = ?',
      whereArgs: [lessonId],
    );
    return result.map((row) => row['konuID'] as String).toList();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Tekil Öğe Tamamlanma Kontrolü (YENİ badge için)
  // ════════════════════════════════════════════════════════════════════════════

  /// Belirli bir test çözülmüş mü?
  Future<bool> isTestSolved(String testId) async {
    Database db = await database;
    final result = await db.query(
      'TestResults',
      where: 'testId = ?',
      whereArgs: [testId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Belirli bir flashcard seti görüntülenmiş mi?
  Future<bool> isFlashcardSetViewed(String kartSetID) async {
    Database db = await database;
    final result = await db.query(
      'ViewedFlashcardSets',
      where: 'kartSetID = ?',
      whereArgs: [kartSetID],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Belirli bir oyun level'ı tamamlanmış mı?
  /// [gameType] - 'fill_blanks' veya 'guess'
  /// [levelTitle] - Level başlığı (details alanında aranacak)
  Future<bool> isLevelCompleted(String gameType, String levelTitle) async {
    Database db = await database;
    final result = await db.query(
      'GameResults',
      where: 'gameType = ? AND details LIKE ?',
      whereArgs: [gameType, '%$levelTitle%'],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Toplam İçerik Sayıları (Motivasyonel Progress Bar için)
  // ════════════════════════════════════════════════════════════════════════════

  /// Uygulamadaki toplam test sayısı
  Future<int> getTotalTestCount() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM Testler');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Uygulamadaki toplam çözülmüş test sayısı
  Future<int> getTotalSolvedTestCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT testId) as count FROM TestResults',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Uygulamadaki toplam bilgi kartı seti sayısı
  Future<int> getTotalFlashcardSetCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM BilgiKartlari',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Uygulamadaki toplam görüntülenen bilgi kartı seti sayısı
  Future<int> getTotalViewedFlashcardSetCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ViewedFlashcardSets',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DÜELLO GÖRÜLEN İÇERİK TAKİBİ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Düelloda gösterilen içeriği işaretle
  Future<void> markDuelContentAsSeen(String contentType, String contentId) async {
    Database db = await database;
    await db.insert(
      'SeenDuelContent',
      {
        'contentType': contentType,
        'contentId': contentId,
        'seenAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Belirli türdeki görülen içerik ID'lerini getir
  Future<List<String>> getSeenDuelContentIds(String contentType) async {
    Database db = await database;
    final results = await db.query(
      'SeenDuelContent',
      columns: ['contentId'],
      where: 'contentType = ?',
      whereArgs: [contentType],
    );
    return results.map((r) => r['contentId'] as String).toList();
  }

  /// Belirli türdeki görülen içerikleri sıfırla
  Future<void> resetSeenDuelContent(String contentType) async {
    Database db = await database;
    await db.delete(
      'SeenDuelContent',
      where: 'contentType = ?',
      whereArgs: [contentType],
    );
  }

  /// Tüm düello içeriklerinin görülüp görülmediğini kontrol et
  Future<bool> isAllDuelContentSeen(String contentType, int totalCount) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM SeenDuelContent WHERE contentType = ?',
      [contentType],
    );
    final seenCount = Sqflite.firstIntValue(result) ?? 0;
    return seenCount >= totalCount;
  }

  // ==================== SÜRE TAKİBİ METOTLARI ====================

  /// Bugünün süresini kaydet veya güncelle (saniye cinsinden)
  Future<void> saveDailyTime(String date, int durationSeconds) async {
    Database db = await database;
    await db.insert(
      'DailyTimeTracking',
      {'date': date, 'durationSeconds': durationSeconds},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Belirli bir günün süresini getir (saniye cinsinden)
  Future<int> getDailyTime(String date) async {
    Database db = await database;
    final result = await db.query(
      'DailyTimeTracking',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (result.isEmpty) return 0;
    return (result.first['durationSeconds'] as int?) ?? 0;
  }

  /// Bu haftanın verilerini getir (Pazartesi-Pazar)
  Future<List<Map<String, dynamic>>> getWeeklyTimeData() async {
    final now = DateTime.now();
    // Haftanın Pazartesi gününü bul (weekday: 1 = Pazartesi)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final List<Map<String, dynamic>> weekData = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final seconds = await getDailyTime(dateStr);
      
      weekData.add({
        'date': dateStr,
        'dayName': _getDayName(date.weekday),
        'durationSeconds': seconds,
        'durationMinutes': (seconds / 60).round(),
      });
    }
    return weekData;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Pzt';
      case 2: return 'Sal';
      case 3: return 'Çar';
      case 4: return 'Per';
      case 5: return 'Cum';
      case 6: return 'Cmt';
      case 7: return 'Paz';
      default: return '';
    }
  }
}
