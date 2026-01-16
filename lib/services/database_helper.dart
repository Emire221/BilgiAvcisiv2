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

  /// Aktif kullanıcı ID'si - tüm sorgularda kullanılacak
  String? _activeUserId;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Aktif kullanıcıyı ayarla (giriş yapıldığında çağrılmalı)
  void setActiveUser(String userId) {
    _activeUserId = userId;
  }

  /// Aktif kullanıcı ID'sini getir
  String get activeUserId => _activeUserId ?? '';

  /// Aktif kullanıcı ayarlanmış mı?
  bool get hasActiveUser => _activeUserId != null && _activeUserId!.isNotEmpty;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bilgi_avcisi.db');
    return await openDatabase(
      path,
      version: 19, // Versiyon 19 - userId eklendi
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    // Dersler Tablosu - userId ile
    await db.execute('''
      CREATE TABLE Dersler(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dersID TEXT NOT NULL,
        userId TEXT NOT NULL,
        dersAdi TEXT,
        ikon TEXT,
        renk TEXT,
        UNIQUE(dersID, userId)
      )
    ''');

    // Konular Tablosu - userId ile
    await db.execute('''
      CREATE TABLE Konular(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        konuID TEXT NOT NULL,
        userId TEXT NOT NULL,
        dersID TEXT,
        konuAdi TEXT,
        sira INTEGER,
        UNIQUE(konuID, userId)
      )
    ''');

    // Testler Tablosu - userId ile
    await db.execute('''
      CREATE TABLE Testler(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        testID TEXT NOT NULL,
        userId TEXT NOT NULL,
        konuID TEXT,
        testAdi TEXT,
        zorluk INTEGER,
        cozumVideoURL TEXT,
        sorular TEXT,
        UNIQUE(testID, userId)
      )
    ''');

    // Bilgi Kartları Tablosu - userId ile
    await db.execute('''
      CREATE TABLE BilgiKartlari(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kartSetID TEXT NOT NULL,
        userId TEXT NOT NULL,
        konuID TEXT,
        kartAdi TEXT,
        kartlar TEXT,
        UNIQUE(kartSetID, userId)
      )
    ''');

    // Bildirimler Tablosu - userId ile
    await db.execute('''
      CREATE TABLE Notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        title TEXT,
        body TEXT,
        date TEXT,
        isRead INTEGER
      )
    ''');

    // Deneme Sınavları Tablosu - userId ile
    await db.execute('''
      CREATE TABLE TrialExams(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        examId TEXT NOT NULL,
        userId TEXT NOT NULL,
        title TEXT,
        startDate TEXT,
        endDate TEXT,
        duration INTEGER,
        contentJson TEXT,
        UNIQUE(examId, userId)
      )
    ''');

    // Deneme Sonuçları Tablosu (Ham Cevaplar) - userId zaten var
    await db.execute('''
      CREATE TABLE TrialResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        examId TEXT,
        userId TEXT NOT NULL,
        rawAnswers TEXT,
        score INTEGER,
        completedAt TEXT
      )
    ''');

    // Kullanıcı Maskotları Tablosu - userId ile
    await db.execute('''
      CREATE TABLE UserPets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        petType TEXT NOT NULL,
        petName TEXT NOT NULL,
        currentXp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        mood INTEGER DEFAULT 100,
        createdAt TEXT DEFAULT (datetime('now')),
        UNIQUE(userId)
      )
    ''');

    // İndirilen Dosyalar Tablosu - userId ile
    await db.execute('''
      CREATE TABLE DownloadedFiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL,
        userId TEXT NOT NULL,
        date TEXT,
        UNIQUE(path, userId)
      )
    ''');

    // Test Sonuçları Tablosu - userId ile
    await db.execute('''
      CREATE TABLE TestResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        testId TEXT,
        score INTEGER,
        correct INTEGER,
        wrong INTEGER,
        date TEXT
      )
    ''');

    // Fill Blanks Levels Tablosu - userId ile
    await db.execute('''
      CREATE TABLE FillBlanksLevels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        levelID TEXT NOT NULL,
        userId TEXT NOT NULL,
        title TEXT,
        description TEXT,
        difficulty INTEGER,
        category TEXT,
        questions TEXT,
        UNIQUE(levelID, userId)
      )
    ''');

    // Game Results Tablosu (Tüm oyun sonuçları için) - userId ile
    await db.execute('''
      CREATE TABLE GameResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
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

    // Haftalık Sınavlar Tablosu (İndirilen sınav verileri) - userId ile
    await db.execute('''
      CREATE TABLE WeeklyExams(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weeklyExamId TEXT NOT NULL,
        userId TEXT NOT NULL,
        title TEXT,
        weekStart TEXT,
        duration INTEGER,
        description TEXT,
        totalUser INTEGER,
        turkeyAverages TEXT,
        city INTEGER,
        district INTEGER,
        questions TEXT,
        UNIQUE(weeklyExamId, userId)
      )
    ''');

    // Haftalık Sınav Sonuçları Tablosu - userId ile
    await db.execute('''
      CREATE TABLE WeeklyExamResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
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
        ilSiralama INTEGER,
        ilToplamKatilimci INTEGER,
        ilceSiralama INTEGER,
        ilceToplamKatilimci INTEGER,
        userCity TEXT,
        userDistrict TEXT,
        completedAt TEXT,
        resultViewed INTEGER DEFAULT 0
      )
    ''');

    // Salla Bakalım (Guess) Tablosu - userId ile
    await db.execute('''
      CREATE TABLE GuessLevels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        levelID TEXT NOT NULL,
        userId TEXT NOT NULL,
        title TEXT,
        description TEXT,
        difficulty INTEGER,
        questions TEXT,
        UNIQUE(levelID, userId)
      )
    ''');

    // Görüntülenen Bilgi Kartı Setleri Tablosu (badge takibi için) - userId ile
    await db.execute('''
      CREATE TABLE ViewedFlashcardSets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        kartSetID TEXT NOT NULL,
        topicID TEXT NOT NULL,
        viewedAt TEXT,
        UNIQUE(kartSetID, userId)
      )
    ''');

    // Düello Görülen İçerik Tablosu - userId ile
    await db.execute('''
      CREATE TABLE SeenDuelContent(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        contentType TEXT NOT NULL,
        contentId TEXT NOT NULL,
        seenAt TEXT NOT NULL,
        UNIQUE(contentType, contentId, userId)
      )
    ''');

    // Günlük Uygulama Kullanım Süresi Tablosu - userId ile
    await db.execute('''
      CREATE TABLE DailyTimeTracking(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL DEFAULT 0,
        UNIQUE(date, userId)
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
          totalUser INTEGER,
          turkeyAverages TEXT,
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

    if (oldVersion < 14) {
      // WeeklyExamResults tablosuna resultViewed kolonu ekle
      // Kullanıcı sonucu görmeden yeni sınava giremez kuralı için
      try {
        await db.execute('''
          ALTER TABLE WeeklyExamResults ADD COLUMN resultViewed INTEGER DEFAULT 0
        ''');
      } catch (e) {
        // Kolon zaten mevcutsa hata alınır, görmezden gel
      }
    }

    if (oldVersion < 15) {
      // WeeklyExams tablosuna totalUser ve turkeyAverages kolonları ekle
      try {
        await db.execute(
          'ALTER TABLE WeeklyExams ADD COLUMN totalUser INTEGER',
        );
      } catch (e) {
        // Kolon zaten mevcutsa hata alınır, görmezden gel
      }
      try {
        await db.execute(
          'ALTER TABLE WeeklyExams ADD COLUMN turkeyAverages TEXT',
        );
      } catch (e) {
        // Kolon zaten mevcutsa hata alınır, görmezden gel
      }
    }

    if (oldVersion < 16) {
      // WeeklyExamResults tablosuna il/ilçe sıralama kolonları ekle
      final columns = [
        'ilSiralama INTEGER',
        'ilToplamKatilimci INTEGER',
        'ilceSiralama INTEGER',
        'ilceToplamKatilimci INTEGER',
      ];
      for (final column in columns) {
        try {
          await db.execute('ALTER TABLE WeeklyExamResults ADD COLUMN $column');
        } catch (e) {
          // Kolon zaten mevcutsa hata alınır, görmezden gel
        }
      }
    }

    if (oldVersion < 17) {
      // WeeklyExams tablosuna city ve district kolonları ekle
      try {
        await db.execute('ALTER TABLE WeeklyExams ADD COLUMN city INTEGER');
      } catch (e) {
        // Kolon zaten mevcutsa hata alınır, görmezden gel
      }
      try {
        await db.execute('ALTER TABLE WeeklyExams ADD COLUMN district INTEGER');
      } catch (e) {
        // Kolon zaten mevcutsa hata alınır, görmezden gel
      }
    }

    if (oldVersion < 18) {
      // WeeklyExamResults tablosuna userCity ve userDistrict kolonları ekle
      try {
        await db.execute(
          'ALTER TABLE WeeklyExamResults ADD COLUMN userCity TEXT',
        );
      } catch (e) {
        // Kolon zaten mevcutsa hata alınır, görmezden gel
      }
      try {
        await db.execute(
          'ALTER TABLE WeeklyExamResults ADD COLUMN userDistrict TEXT',
        );
      } catch (e) {
        // Kolon zaten mevcutsa hata alınır, görmezden gel
      }
    }

    // Versiyon 19: Tüm tablolara userId kolonu ekleme (Kullanıcı Bazlı İzolasyon)
    if (oldVersion < 19) {
      // Tüm tablolara userId kolonu ekle
      final tablesNeedingUserId = [
        'Dersler',
        'Konular',
        'Testler',
        'BilgiKartlari',
        'Notifications',
        'UserPets',
        'DownloadedFiles',
        'TestResults',
        'FillBlanksLevels',
        'GameResults',
        'WeeklyExams',
        'WeeklyExamResults',
        'GuessLevels',
        'ViewedFlashcardSets',
        'SeenDuelContent',
        'DailyTimeTracking',
        'TrialExams',
      ];

      for (final table in tablesNeedingUserId) {
        try {
          await db.execute('ALTER TABLE $table ADD COLUMN userId TEXT');
        } catch (e) {
          // Kolon zaten varsa veya tablo yoksa ignore
        }
      }

      // TrialResults tablosunda userId zaten var, sadece NOT NULL kontrolü
      // Mevcut verilerde userId = NULL olanlar eski kullanıcının verileri olacak
    }
  }

  // Ekleme Metotları - Tüm metodlara userId otomatik ekleniyor
  @override
  Future<void> insertDers(Map<String, dynamic> row) async {
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    await db.insert(
      'Dersler',
      rowWithUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertKonu(Map<String, dynamic> row) async {
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    await db.insert(
      'Konular',
      rowWithUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertTest(Map<String, dynamic> row) async {
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    await db.insert(
      'Testler',
      rowWithUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertBilgiKart(Map<String, dynamic> row) async {
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    await db.insert(
      'BilgiKartlari',
      rowWithUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Test için alias metod
  Future<int> insertFlashcard(Map<String, dynamic> row) async {
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    return await db.insert(
      'BilgiKartlari',
      rowWithUser,
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
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    await db.insert(
      'WeeklyExams',
      rowWithUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Haftalık Sınav getirme metodu - userId filtresi ile
  @override
  Future<Map<String, dynamic>?> getLatestWeeklyExam() async {
    Database db = await database;
    final results = await db.query(
      'WeeklyExams',
      where: 'userId = ?',
      whereArgs: [activeUserId],
      orderBy: 'weekStart DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Eski haftalık sınav verilerini temizle (ARTIK SADECE ESKİ SINAVLARI SAKLIYORUZ)
  /// Bu metod artık hiçbir şey silmiyor - tüm sınavlar ve sonuçlar kalıcı olarak saklanıyor
  /// Başarılarım sekmesinde geçmiş sonuçları gösterebilmek için gerekli
  /// @param newExamId: Yeni gelen sınavın ID'si - artık kullanılmıyor ama geriye uyumluluk için kalıyor
  @override
  Future<void> clearOldWeeklyExamData(String newExamId) async {
    // Artık hiçbir şey silmiyoruz - tüm sınavlar ve sonuçlar kalıcı
    // Eski davranış: Yeni sınav dışındaki tüm sınavları ve sonuçları siliyordu
    // Yeni davranış: Hiçbir şey silinmiyor
  }

  // Bildirimler için CRUD Metotları - userId filtresi ile
  Future<int> insertNotification(Map<String, dynamic> row) async {
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    return await db.insert(
      'Notifications',
      rowWithUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    Database db = await database;
    return await db.query(
      'Notifications',
      where: 'userId = ?',
      whereArgs: [activeUserId],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteNotification(int id) async {
    Database db = await database;
    return await db.delete(
      'Notifications',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, activeUserId],
    );
  }

  Future<void> markNotificationAsRead(int id) async {
    Database db = await database;
    await db.update(
      'Notifications',
      {'isRead': 1},
      where: 'id = ? AND userId = ?',
      whereArgs: [id, activeUserId],
    );
  }

  Future<int> getUnreadNotificationCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Notifications WHERE isRead = 0 AND userId = ?',
            [activeUserId],
          ),
        ) ??
        0;
  }

  // Temizleme Metodu (Yeni sınıf indirildiğinde eskileri silmek için) - sadece aktif kullanıcının verilerini siler
  @override
  Future<void> clearAllData() async {
    Database db = await database;
    await db.transaction((txn) async {
      await txn.delete('Dersler', where: 'userId = ?', whereArgs: [activeUserId]);
      await txn.delete('Konular', where: 'userId = ?', whereArgs: [activeUserId]);
      await txn.delete('Testler', where: 'userId = ?', whereArgs: [activeUserId]);
      await txn.delete('BilgiKartlari', where: 'userId = ?', whereArgs: [activeUserId]);
    });
  }

  // Toplu Ekleme Metodu (Batch Insert) - userId otomatik eklenir
  @override
  Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;
    Database db = await database;
    Batch batch = db.batch();

    for (var row in rows) {
      final rowWithUser = Map<String, dynamic>.from(row);
      rowWithUser['userId'] = activeUserId;
      batch.insert(table, rowWithUser, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // İndirilen Dosyalar Metotları - userId filtresi ile
  Future<List<String>> getDownloadedFiles() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DownloadedFiles',
      where: 'userId = ?',
      whereArgs: [activeUserId],
    );
    return List.generate(maps.length, (i) {
      return maps[i]['path'] as String;
    });
  }

  @override
  Future<void> addDownloadedFile(String path) async {
    Database db = await database;
    await db.insert('DownloadedFiles', {
      'path': path,
      'userId': activeUserId,
      'date': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Test Sonuçları Metotları - userId otomatik eklenir
  Future<void> saveTestResult(
    String testId,
    int score,
    int correct,
    int wrong,
  ) async {
    Database db = await database;
    await db.insert('TestResults', {
      'userId': activeUserId,
      'testId': testId,
      'score': score,
      'correct': correct,
      'wrong': wrong,
      'date': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fill Blanks Levels Metotları - userId ile
  @override
  Future<void> insertFillBlanksLevel(Map<String, dynamic> row) async {
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    await db.insert(
      'FillBlanksLevels',
      rowWithUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFillBlanksLevels() async {
    Database db = await database;
    return await db.query(
      'FillBlanksLevels',
      where: 'userId = ?',
      whereArgs: [activeUserId],
      orderBy: 'difficulty ASC',
    );
  }

  // Game Results Metotları - userId ile
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
      'userId': activeUserId,
      'gameType': gameType,
      'score': score,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'totalQuestions': totalQuestions,
      'completedAt': DateTime.now().toIso8601String(),
      'details': details,
      'key': key,
    });

    // Sonra eski kayıtları temizle (son 50'yi koru) - kullanıcı bazlı
    await _cleanOldGameResults(db);
  }

  Future<void> _cleanOldGameResults(Database db) async {
    // Aktif kullanıcı için toplam kayıt sayısını al
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM GameResults WHERE userId = ?',
      [activeUserId],
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
          WHERE userId = ?
          ORDER BY completedAt ASC 
          LIMIT ?
        )
      ''',
        [activeUserId, deleteCount],
      );
    }
  }

  /// Salla Bakalım sonuçlarını kaydet (son 10 oyun tutulur) - userId ile
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
      'userId': activeUserId,
      'gameType': 'guess',
      'score': score,
      'correctCount': correctCount,
      'wrongCount': totalQuestions - correctCount,
      'totalQuestions': totalQuestions,
      'completedAt': DateTime.now().toIso8601String(),
      'details':
          '{"levelTitle": "$levelTitle", "difficulty": $difficulty, "totalAttempts": $totalAttempts}',
    });

    // Salla Bakalım için son 10 kaydı tut, eskilerini sil - kullanıcı bazlı
    await _cleanOldGuessResults(db);
  }

  Future<void> _cleanOldGuessResults(Database db) async {
    // Aktif kullanıcı için Salla Bakalım kayıt sayısını al
    final countResult = await db.rawQuery(
      "SELECT COUNT(*) as count FROM GameResults WHERE gameType = 'guess' AND userId = ?",
      [activeUserId],
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
          WHERE gameType = 'guess' AND userId = ?
          ORDER BY completedAt ASC 
          LIMIT ?
        )
      ''',
        [activeUserId, deleteCount],
      );
    }
  }

  // Game Results için userId filtreli sorgu
  Future<List<Map<String, dynamic>>> getGameResults(String gameType) async {
    Database db = await database;

    if (gameType == 'test') {
      // Test için detaylı sorgu (Ders ve Konu adlarını da getir)
      // GameResults tablosunda 'testId' sütunu var mı? Hayır, 'key' sütunu var.
      // GameResults tablosu: id, gameType, score, correct, wrong, completedAt, key (testId olabilir)

      // Önce tüm sonuçları al - userId filtresi ile
      final results = await db.query(
        'GameResults',
        where: 'gameType = ? AND userId = ?',
        whereArgs: [gameType, activeUserId],
        orderBy: 'completedAt DESC',
      );

      List<Map<String, dynamic>> enrichedResults = [];

      for (final result in results) {
        final resultMap = Map<String, dynamic>.from(result);
        final testId = result['key'] as String?;

        if (testId != null && testId.isNotEmpty) {
          // Bu testin konusunu ve dersini bul - userId filtresi ile
          final testData = await db.rawQuery(
            '''
            SELECT T.testAdi, K.konuAdi, D.dersAdi 
            FROM Testler T
            JOIN Konular K ON T.konuID = K.konuID AND K.userId = T.userId
            JOIN Dersler D ON K.dersID = D.dersID AND D.userId = K.userId
            WHERE T.testID = ? AND T.userId = ?
          ''',
            [testId, activeUserId],
          );

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
      // Flashcard için detaylı sorgu (Ders ve Konu adlarını da getir) - userId filtresi ile
      final results = await db.query(
        'GameResults',
        where: 'gameType = ? AND userId = ?',
        whereArgs: [gameType, activeUserId],
        orderBy: 'completedAt DESC',
      );

      List<Map<String, dynamic>> enrichedResults = [];

      for (final result in results) {
        final resultMap = Map<String, dynamic>.from(result);
        final topicId = result['key'] as String?;

        if (topicId != null && topicId.isNotEmpty) {
          // Bu konuyu ve dersini bul - userId filtresi ile
          final topicData = await db.rawQuery(
            '''
            SELECT K.konuAdi, D.dersAdi 
            FROM Konular K
            JOIN Dersler D ON K.dersID = D.dersID AND D.userId = K.userId
            WHERE K.konuID = ? AND K.userId = ?
          ''',
            [topicId, activeUserId],
          );

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
        where: 'gameType = ? AND userId = ?',
        whereArgs: [gameType, activeUserId],
        orderBy: 'completedAt DESC',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllGameResults() async {
    Database db = await database;
    return await db.query(
      'GameResults',
      where: 'userId = ?',
      whereArgs: [activeUserId],
      orderBy: 'completedAt DESC',
    );
  }

  /// Haftalık sınav sonuçlarını getir
  /// @param userId: Kullanıcı ID'si - eğer verilirse sadece bu kullanıcının sonuçları döner
  /// @param onlyAnnounced: true ise sadece sonucu açıklanmış sınavları döner (sonucTarihi geçmiş olanlar)
  Future<List<Map<String, dynamic>>> getWeeklyExamResults({
    String? userId,
    bool onlyAnnounced = true,
  }) async {
    Database db = await database;
    List<Map<String, dynamic>> results;

    // userId parametresi verilirse onu, verilmezse aktif kullanıcıyı kullan
    final targetUserId = userId ?? activeUserId;
    results = await db.query(
      'WeeklyExamResults',
      where: 'userId = ?',
      whereArgs: [targetUserId],
      orderBy: 'completedAt DESC',
    );

    // Sadece sonucu açıklanmış sınavları filtrele
    if (onlyAnnounced) {
      final now = DateTime.now();
      results = results.where((result) {
        final sonucTarihiStr = result['sonucTarihi'] as String?;
        if (sonucTarihiStr == null || sonucTarihiStr.isEmpty) {
          return false; // sonucTarihi yoksa gösterme
        }
        try {
          final sonucTarihi = DateTime.parse(sonucTarihiStr);
          return now.isAfter(sonucTarihi); // Sadece geçmiş tarihlileri göster
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return results;
  }

  // ============================================================
  // Başarı Analitik Metodları
  // ============================================================

  /// Ders bazlı başarı oranlarını hesapla
  /// Her ders için çözülen testlerdeki doğru/toplam oranını döner - userId filtresi ile
  Future<List<Map<String, dynamic>>> getLessonSuccessRates() async {
    Database db = await database;

    // Aktif kullanıcının derslerini al
    final dersler = await db.query(
      'Dersler',
      where: 'userId = ?',
      whereArgs: [activeUserId],
    );

    List<Map<String, dynamic>> result = [];

    for (final ders in dersler) {
      final dersId = ders['dersID'] as String;
      final dersAdi = ders['dersAdi'] as String? ?? '';

      // Bu derse ait konuları al - userId filtresi ile
      final konular = await db.query(
        'Konular',
        where: 'dersID = ? AND userId = ?',
        whereArgs: [dersId, activeUserId],
      );

      if (konular.isEmpty) continue;

      final konuIds = konular.map((k) => k['konuID'] as String).toList();

      // Bu konulara ait testleri al - userId filtresi ile
      final placeholders = List.filled(konuIds.length, '?').join(',');
      final testler = await db.rawQuery(
        'SELECT testID FROM Testler WHERE konuID IN ($placeholders) AND userId = ?',
        [...konuIds, activeUserId],
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

      // Bu testlerden çözülenlerin sonuçlarını al - userId filtresi ile
      final sonuclar = await db.rawQuery(
        'SELECT correct, wrong FROM TestResults WHERE testId IN ($testPlaceholders) AND userId = ?',
        [...testIds, activeUserId],
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

      final basariOrani = toplamSoru > 0
          ? (toplamDogru / toplamSoru) * 100
          : 0.0;

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

  /// Seçilen derse ait konu başarı oranlarını hesapla - userId filtresi ile
  Future<List<Map<String, dynamic>>> getTopicSuccessRates(String dersId) async {
    Database db = await database;

    // Derse ait konuları al - userId filtresi ile
    final konular = await db.query(
      'Konular',
      where: 'dersID = ? AND userId = ?',
      whereArgs: [dersId, activeUserId],
      orderBy: 'sira ASC',
    );

    List<Map<String, dynamic>> result = [];

    for (final konu in konular) {
      final konuId = konu['konuID'] as String;
      final konuAdi = konu['konuAdi'] as String? ?? '';

      // Bu konuya ait testleri al - userId filtresi ile
      final testler = await db.query(
        'Testler',
        columns: ['testID'],
        where: 'konuID = ? AND userId = ?',
        whereArgs: [konuId, activeUserId],
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

      // Bu testlerin sonuçlarını al - userId filtresi ile
      final sonuclar = await db.rawQuery(
        'SELECT correct, wrong FROM TestResults WHERE testId IN ($placeholders) AND userId = ?',
        [...testIds, activeUserId],
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

      final basariOrani = toplamSoru > 0
          ? (toplamDogru / toplamSoru) * 100
          : 0.0;

      result.add({
        'konuID': konuId,
        'konuAdi': konuAdi,
        'basariOrani': basariOrani,
        'cozulenTest': sonuclar.length,
      });
    }

    return result;
  }

  /// Rastgele Fill Blanks level çeker - userId filtresi ile
  /// Tüm veriyi belleğe almak yerine SQL RANDOM() kullanır
  Future<Map<String, dynamic>?> getRandomFillBlanksLevel() async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM FillBlanksLevels WHERE userId = ? ORDER BY RANDOM() LIMIT 1',
      [activeUserId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Belirlenen zorluk seviyesinden rastgele Fill Blanks level çeker - userId filtresi ile
  /// @param difficulty: 1-3 arası zorluk seviyesi
  Future<Map<String, dynamic>?> getRandomFillBlanksByDifficulty(
    int difficulty,
  ) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM FillBlanksLevels WHERE difficulty = ? AND userId = ? ORDER BY RANDOM() LIMIT 1',
      [difficulty, activeUserId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ============================================================
  // Salla Bakalım (Guess) Metodları - userId ile
  // ============================================================

  /// Guess Level ekleme - userId ile
  @override
  Future<void> insertGuessLevel(Map<String, dynamic> row) async {
    final rowWithUser = Map<String, dynamic>.from(row);
    rowWithUser['userId'] = activeUserId;
    Database db = await database;
    await db.insert(
      'GuessLevels',
      rowWithUser,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Tüm Guess seviyelerini getir - userId filtresi ile
  Future<List<Map<String, dynamic>>> getGuessLevels() async {
    Database db = await database;
    return await db.query(
      'GuessLevels',
      where: 'userId = ?',
      whereArgs: [activeUserId],
      orderBy: 'difficulty ASC, title ASC',
    );
  }

  /// Belirli bir Guess seviyesini getir - userId filtresi ile
  Future<Map<String, dynamic>?> getGuessLevel(String levelId) async {
    Database db = await database;
    final results = await db.query(
      'GuessLevels',
      where: 'levelID = ? AND userId = ?',
      whereArgs: [levelId, activeUserId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Rastgele Guess seviyesi getir - userId filtresi ile
  Future<Map<String, dynamic>?> getRandomGuessLevel() async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM GuessLevels WHERE userId = ? ORDER BY RANDOM() LIMIT 1',
      [activeUserId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Belirli zorluk seviyesinden rastgele Guess level çeker - userId filtresi ile
  Future<Map<String, dynamic>?> getRandomGuessByDifficulty(
    int difficulty,
  ) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM GuessLevels WHERE difficulty = ? AND userId = ? ORDER BY RANDOM() LIMIT 1',
      [difficulty, activeUserId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ============================================================
  // Maskot Metodları
  // ============================================================

  /// Aktif maskotu getir (bildirimler için mascot ismi) - userId filtresi ile
  Future<Map<String, dynamic>?> getActiveMascot() async {
    Database db = await database;
    final results = await db.query(
      'UserPets',
      where: 'userId = ?',
      whereArgs: [activeUserId],
      orderBy: 'id DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ============================================================
  // İlerleme Takip Metodları (Progress Service için)
  // ============================================================

  /// Konu için toplam test sayısı - userId filtresi ile
  Future<int> getTestCountByTopic(String topicId) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Testler WHERE konuID = ? AND userId = ?',
      [topicId, activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Konu için çözülmüş test sayısı (TestResults tablosundan) - userId filtresi ile
  Future<int> getSolvedTestCountByTopic(String topicId) async {
    Database db = await database;
    // Önce bu konuya ait test ID'lerini al - userId filtresi ile
    final tests = await db.query(
      'Testler',
      columns: ['testID'],
      where: 'konuID = ? AND userId = ?',
      whereArgs: [topicId, activeUserId],
    );

    if (tests.isEmpty) return 0;

    // Test ID'leri listesi
    final testIds = tests.map((t) => t['testID'] as String).toList();
    final placeholders = List.filled(testIds.length, '?').join(',');

    // Bu testlerden kaç tanesi çözülmüş - userId filtresi ile
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT testId) as count FROM TestResults WHERE testId IN ($placeholders) AND userId = ?',
      [...testIds, activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Konu için toplam flashcard set sayısı - userId filtresi ile
  Future<int> getFlashcardSetCountByTopic(String topicId) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM BilgiKartlari WHERE konuID = ? AND userId = ?',
      [topicId, activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Oyun tipi için toplam level sayısı - userId filtresi ile
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
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table WHERE userId = ?',
      [activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Oyun tipi için tamamlanan level sayısı (GameResults'tan benzersiz details) - userId filtresi ile
  Future<int> getCompletedLevelCount(String gameType) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT details) as count FROM GameResults WHERE gameType = ? AND details IS NOT NULL AND userId = ?',
      [gameType, activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Flashcard Görüntüleme Takibi - userId ile
  // ════════════════════════════════════════════════════════════════════════════

  /// Görüntülenen flashcard setini kaydet - userId ile
  Future<void> saveViewedFlashcardSet(String kartSetID, String topicID) async {
    Database db = await database;
    await db.insert('ViewedFlashcardSets', {
      'userId': activeUserId,
      'kartSetID': kartSetID,
      'topicID': topicID,
      'viewedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Konu için görüntülenen flashcard set sayısı - userId filtresi ile
  Future<int> getViewedFlashcardSetCount(String topicId) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ViewedFlashcardSets WHERE topicID = ? AND userId = ?',
      [topicId, activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Derse ait tüm konu ID'lerini döner - userId filtresi ile
  Future<List<String>> getTopicIdsByLesson(String lessonId) async {
    Database db = await database;
    final result = await db.query(
      'Konular',
      columns: ['konuID'],
      where: 'dersID = ? AND userId = ?',
      whereArgs: [lessonId, activeUserId],
    );
    return result.map((row) => row['konuID'] as String).toList();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Tekil Öğe Tamamlanma Kontrolü (YENİ badge için) - userId ile
  // ════════════════════════════════════════════════════════════════════════════

  /// Belirli bir test çözülmüş mü? - userId filtresi ile
  Future<bool> isTestSolved(String testId) async {
    Database db = await database;
    final result = await db.query(
      'TestResults',
      where: 'testId = ? AND userId = ?',
      whereArgs: [testId, activeUserId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Belirli bir flashcard seti görüntülenmiş mi? - userId filtresi ile
  Future<bool> isFlashcardSetViewed(String kartSetID) async {
    Database db = await database;
    final result = await db.query(
      'ViewedFlashcardSets',
      where: 'kartSetID = ? AND userId = ?',
      whereArgs: [kartSetID, activeUserId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Belirli bir oyun level'ı tamamlanmış mı? - userId filtresi ile
  /// [gameType] - 'fill_blanks' veya 'guess'
  /// [levelTitle] - Level başlığı (details alanında aranacak)
  Future<bool> isLevelCompleted(String gameType, String levelTitle) async {
    Database db = await database;
    final result = await db.query(
      'GameResults',
      where: 'gameType = ? AND details LIKE ? AND userId = ?',
      whereArgs: [gameType, '%$levelTitle%', activeUserId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Toplam İçerik Sayıları (Motivasyonel Progress Bar için) - userId ile
  // ════════════════════════════════════════════════════════════════════════════

  /// Uygulamadaki toplam test sayısı - userId filtresi ile
  Future<int> getTotalTestCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM Testler WHERE userId = ?',
      [activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Uygulamadaki toplam çözülmüş test sayısı
  Future<int> getTotalSolvedTestCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT testId) as count FROM TestResults WHERE userId = ?',
      [activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Uygulamadaki toplam bilgi kartı seti sayısı - userId filtresi ile
  Future<int> getTotalFlashcardSetCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM BilgiKartlari WHERE userId = ?',
      [activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Uygulamadaki toplam görüntülenen bilgi kartı seti sayısı - userId filtresi ile
  Future<int> getTotalViewedFlashcardSetCount() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ViewedFlashcardSets WHERE userId = ?',
      [activeUserId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DÜELLO GÖRÜLEN İÇERİK TAKİBİ - userId ile
  // ═══════════════════════════════════════════════════════════════════════════

  /// Düelloda gösterilen içeriği işaretle - userId ile
  Future<void> markDuelContentAsSeen(
    String contentType,
    String contentId,
  ) async {
    Database db = await database;
    await db.insert('SeenDuelContent', {
      'userId': activeUserId,
      'contentType': contentType,
      'contentId': contentId,
      'seenAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Belirli türdeki görülen içerik ID'lerini getir - userId filtresi ile
  Future<List<String>> getSeenDuelContentIds(String contentType) async {
    Database db = await database;
    final results = await db.query(
      'SeenDuelContent',
      columns: ['contentId'],
      where: 'contentType = ? AND userId = ?',
      whereArgs: [contentType, activeUserId],
    );
    return results.map((r) => r['contentId'] as String).toList();
  }

  /// Belirli türdeki görülen içerikleri sıfırla - userId filtresi ile
  Future<void> resetSeenDuelContent(String contentType) async {
    Database db = await database;
    await db.delete(
      'SeenDuelContent',
      where: 'contentType = ? AND userId = ?',
      whereArgs: [contentType, activeUserId],
    );
  }

  /// Tüm düello içeriklerinin görülüp görülmediğini kontrol et - userId filtresi ile
  Future<bool> isAllDuelContentSeen(String contentType, int totalCount) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM SeenDuelContent WHERE contentType = ? AND userId = ?',
      [contentType, activeUserId],
    );
    final seenCount = Sqflite.firstIntValue(result) ?? 0;
    return seenCount >= totalCount;
  }

  // ==================== SÜRE TAKİBİ METOTLARI - userId ile ====================

  /// Bugünün süresini kaydet veya güncelle (saniye cinsinden) - userId ile
  Future<void> saveDailyTime(String date, int durationSeconds) async {
    Database db = await database;
    await db.insert('DailyTimeTracking', {
      'userId': activeUserId,
      'date': date,
      'durationSeconds': durationSeconds,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Belirli bir günün süresini getir (saniye cinsinden) - userId filtresi ile
  Future<int> getDailyTime(String date) async {
    Database db = await database;
    final result = await db.query(
      'DailyTimeTracking',
      where: 'date = ? AND userId = ?',
      whereArgs: [date, activeUserId],
    );
    if (result.isEmpty) return 0;
    return (result.first['durationSeconds'] as int?) ?? 0;
  }

  /// Bu haftanın verilerini getir (Pazartesi-Pazar) - userId filtresi ile
  Future<List<Map<String, dynamic>>> getWeeklyTimeData() async {
    final now = DateTime.now();
    // Haftanın Pazartesi gününü bul (weekday: 1 = Pazartesi)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final List<Map<String, dynamic>> weekData = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
      case 1:
        return 'Pzt';
      case 2:
        return 'Sal';
      case 3:
        return 'Çar';
      case 4:
        return 'Per';
      case 5:
        return 'Cum';
      case 6:
        return 'Cmt';
      case 7:
        return 'Paz';
      default:
        return '';
    }
  }
}
