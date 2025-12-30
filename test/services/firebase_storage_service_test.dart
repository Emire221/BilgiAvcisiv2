import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bilgici/services/firebase_storage_service.dart';
import 'package:bilgici/services/database_helper.dart';

// Fake sınıflar
class FakeDatabaseHelper extends Fake implements IDatabaseHelper {
  int batchInsertCalled = 0;
  int insertTestCalled = 0;
  int insertFlashcardSetCalled = 0;

  @override
  Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    batchInsertCalled++;
  }

  @override
  Future<void> insertTest(Map<String, dynamic> row) async {
    insertTestCalled++;
  }

  @override
  Future<void> insertFlashcardSet(Map<String, dynamic> row) async {
    insertFlashcardSetCalled++;
  }

  @override
  Future<void> insertDers(Map<String, dynamic> row) async {}

  @override
  Future<void> insertKonu(Map<String, dynamic> row) async {}

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> addDownloadedFile(String path) async {}
}

class FakeFirebaseStorage extends Fake implements FirebaseStorage {}

void main() {
  late FirebaseStorageService storageService;
  late FakeDatabaseHelper fakeDbHelper;
  late FakeFirebaseStorage fakeStorage;
  late Directory tempDir;

  setUp(() async {
    fakeDbHelper = FakeDatabaseHelper();
    fakeStorage = FakeFirebaseStorage();
    storageService = FirebaseStorageService(
      storage: fakeStorage,
      dbHelper: fakeDbHelper,
    );
    tempDir = await Directory.systemTemp.createTemp('test_archive_content');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('processLocalArchiveContent parses and inserts data correctly', () async {
    // 1. Setup dummy files
    final dersListesiFile = File('${tempDir.path}/derslistesi.json');
    await dersListesiFile.writeAsString(
      '{"dersler": [{"dersID": "1", "dersAdi": "Matematik", "ikon": "mat", "renk": "blue"}]}',
    );

    final konuListesiFile = File('${tempDir.path}/konulistesi.json');
    await konuListesiFile.writeAsString(
      '{"konular": [{"konuID": "1", "dersID": "1", "konuAdi": "Sayılar", "sira": 1}]}',
    );

    final testDir = Directory('${tempDir.path}/testler');
    await testDir.create();
    final testFile = File('${testDir.path}/test1.json');
    await testFile.writeAsString(
      '{"testID": "1", "konuID": "1", "testAdi": "Test 1", "zorluk": 1, "cozumVideoURL": "", "sorular": []}',
    );

    final bilgiDir = Directory('${tempDir.path}/bilgi');
    await bilgiDir.create();
    final bilgiFile = File('${bilgiDir.path}/bilgi1.json');
    await bilgiFile.writeAsString(
      '{"kartSetID": "1", "konuID": "1", "kartAdi": "Bilgi 1", "kartlar": []}',
    );

    // 2. Call the method
    await storageService.processLocalArchiveContent(tempDir.path, (msg) {});

    // 3. Verify interactions
    expect(fakeDbHelper.batchInsertCalled, 2); // Dersler ve Konular
    expect(fakeDbHelper.insertTestCalled, 1);
    expect(fakeDbHelper.insertFlashcardSetCalled, 1);
  });
}
