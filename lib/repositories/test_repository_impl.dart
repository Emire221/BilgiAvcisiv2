import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/test_model.dart';
import '../services/database_helper.dart';
import 'test_repository.dart';

class TestRepositoryImpl implements TestRepository {
  final DatabaseHelper _dbHelper;

  TestRepositoryImpl(this._dbHelper);

  @override
  Future<List<TestModel>> getTests(
    String grade,
    String lessonName,
    String topicId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Testler',
      where: 'konuID = ?',
      whereArgs: [topicId],
    );

    return maps.map((e) {
      final Map<String, dynamic> map = Map.from(e);
      if (map['sorular'] is String) {
        map['sorular'] = json.decode(map['sorular']);
      }
      return TestModel.fromJson(map);
    }).toList();
  }

  @override
  Future<void> saveTestResult(
    String testId,
    int score,
    int correct,
    int wrong,
  ) async {
    await _dbHelper.saveTestResult(testId, score, correct, wrong);
    if (kDebugMode) {
      debugPrint('Test Result Saved: $testId - Score: $score');
    }
  }
}
