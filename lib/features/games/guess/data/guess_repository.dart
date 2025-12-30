import 'dart:convert';
import '../../../../services/database_helper.dart';
import '../domain/entities/guess_level.dart';

/// Guess Repository - Veritabanı işlemleri
class GuessRepository {
  final DatabaseHelper _dbHelper;

  GuessRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Tüm seviyeleri getir
  Future<List<GuessLevel>> getAllLevels() async {
    final levelsData = await _dbHelper.getGuessLevels();

    return levelsData.map((data) {
      // questions JSON string olarak saklandığı için decode et
      final questionsJson = data['questions'] as String?;
      List<dynamic> questions = [];
      if (questionsJson != null && questionsJson.isNotEmpty) {
        questions = json.decode(questionsJson);
      }

      return GuessLevel.fromJson({...data, 'questions': questions});
    }).toList();
  }

  /// Belirli bir seviyeyi getir
  Future<GuessLevel?> getLevel(String levelId) async {
    final data = await _dbHelper.getGuessLevel(levelId);
    if (data == null) return null;

    final questionsJson = data['questions'] as String?;
    List<dynamic> questions = [];
    if (questionsJson != null && questionsJson.isNotEmpty) {
      questions = json.decode(questionsJson);
    }

    return GuessLevel.fromJson({...data, 'questions': questions});
  }

  /// Rastgele seviye getir
  Future<GuessLevel?> getRandomLevel() async {
    final data = await _dbHelper.getRandomGuessLevel();
    if (data == null) return null;

    final questionsJson = data['questions'] as String?;
    List<dynamic> questions = [];
    if (questionsJson != null && questionsJson.isNotEmpty) {
      questions = json.decode(questionsJson);
    }

    return GuessLevel.fromJson({...data, 'questions': questions});
  }

  /// Belirli zorlukta rastgele seviye getir
  Future<GuessLevel?> getRandomLevelByDifficulty(int difficulty) async {
    final data = await _dbHelper.getRandomGuessByDifficulty(difficulty);
    if (data == null) return null;

    final questionsJson = data['questions'] as String?;
    List<dynamic> questions = [];
    if (questionsJson != null && questionsJson.isNotEmpty) {
      questions = json.decode(questionsJson);
    }

    return GuessLevel.fromJson({...data, 'questions': questions});
  }
}
