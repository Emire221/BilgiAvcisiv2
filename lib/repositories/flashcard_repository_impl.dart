import 'dart:convert';
import '../models/flashcard_model.dart';
import '../services/database_helper.dart';
import 'flashcard_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final DatabaseHelper _dbHelper;

  FlashcardRepositoryImpl(this._dbHelper);

  @override
  Future<List<FlashcardSetModel>> getFlashcards(
    String grade,
    String lessonName,
    String topicId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'BilgiKartlari',
      where: 'konuID = ?',
      whereArgs: [topicId],
    );

    return maps.map((e) {
      final Map<String, dynamic> map = Map.from(e);
      if (map['kartlar'] is String) {
        map['kartlar'] = json.decode(map['kartlar']);
      }
      return FlashcardSetModel.fromJson(map);
    }).toList();
  }
}
