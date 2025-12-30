import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'database_helper.dart';
import '../core/utils/logger.dart';

class DataService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Gömülü şehir listesini oku
  Future<List<String>> getCities() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/cities.json',
      );
      final data = json.decode(response);
      return List<String>.from(data['cities']);
    } catch (e) {
      logger.e('Şehir listesi okuma hatası', e);
      return [];
    }
  }

  // Sınıfa ait ders listesini getir (SQLite)
  Future<List<dynamic>> getLessons(String grade) async {
    try {
      final db = await _dbHelper.database;
      return await db.query('Dersler');
    } catch (e) {
      logger.e('Ders listesi alma hatası', e);
      return [];
    }
  }

  // Sınıfa ait konu listesini getir (SQLite)
  Future<List<dynamic>> getTopics(String grade, String lessonId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'Konular',
        where: 'dersID = ?',
        whereArgs: [lessonId],
        orderBy: 'sira',
      );
    } catch (e) {
      logger.e('Konu listesi alma hatası', e);
      return [];
    }
  }

  // Konuya ait video bilgisini getir (SQLite)
  Future<Map<String, dynamic>?> getTopicVideo(
    String grade,
    String topicId,
  ) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Videolar',
        where: 'konuID = ?',
        whereArgs: [topicId],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      logger.e('Video bilgisi alma hatası', e);
      return null;
    }
  }

  // Belirli bir konuya ait testleri getir (SQLite)
  Future<List<dynamic>> getTests(
    String grade,
    String lessonName,
    String topicId,
  ) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Testler',
        where: 'konuID = ?',
        whereArgs: [topicId],
      );

      // JSON string'i parse et
      return maps.map((e) {
        final Map<String, dynamic> map = Map.from(e);
        if (map['sorular'] is String) {
          map['sorular'] = json.decode(map['sorular']);
        }
        return map;
      }).toList();
    } catch (e) {
      logger.e('Test listesi alma hatası', e);
      return [];
    }
  }

  // Belirli bir konuya ait bilgi kartlarını getir (SQLite)
  Future<List<dynamic>> getFlashcards(
    String grade,
    String lessonName,
    String topicId,
  ) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'BilgiKartlari',
        where: 'konuID = ?',
        whereArgs: [topicId],
      );

      // JSON string'i parse et
      return maps.map((e) {
        final Map<String, dynamic> map = Map.from(e);
        if (map['kartlar'] is String) {
          map['kartlar'] = json.decode(map['kartlar']);
        }
        return map;
      }).toList();
    } catch (e) {
      logger.e('Bilgi kartı listesi alma hatası', e);
      return [];
    }
  }
}
