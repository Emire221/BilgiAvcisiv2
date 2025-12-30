import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../services/database_helper.dart';
import '../domain/entities/duel_entities.dart';

/// Düello için veri sağlayan repository
/// Görülen içerik takibi ile aynı dosyanın tekrar gösterilmesini engeller
class DuelRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Random _random = Random();

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST SORULARI
  // ═══════════════════════════════════════════════════════════════════════════

  /// Test sorularını çeker - görülmemiş testlerden seçer
  Future<List<DuelQuestion>> getTestQuestions() async {
    try {
      final db = await _dbHelper.database;

      // Testler ve Konular tablolarını JOIN ile çek
      final tests = await db.rawQuery('''
        SELECT t.*, k.konuAdi 
        FROM Testler t 
        LEFT JOIN Konular k ON t.konuID = k.konuID
      ''');

      // DEBUG: Her zaman log yazdır
      debugPrint('🔍 [DUEL] Testler tablosu sorgulandı: ${tests.length} test bulundu');
      
      if (tests.isNotEmpty) {
        final firstTest = tests.first;
        debugPrint('🔍 [DUEL] İlk test örneği: testID=${firstTest['testID']}, konuAdi=${firstTest['konuAdi']}');
        debugPrint('🔍 [DUEL] Sorular JSON: ${(firstTest['sorular'] as String?)?.substring(0, 100) ?? 'BOŞ'}...');
      }

      if (tests.isEmpty) {
        debugPrint('❌ [DUEL] Hiç test bulunamadı - mock kullanılıyor');
        return _getDefaultTestQuestions();
      }

      debugPrint('✅ [DUEL] Testler tablosunda ${tests.length} test bulundu');
      if (tests.isNotEmpty) {
        debugPrint('🔍 [DUEL] Test tablosu kolonları: ${tests.first.keys.toList()}');
      }

      // Görülen test ID'lerini al
      final seenIds = await _dbHelper.getSeenDuelContentIds('test');
      
      // Görülmemiş testleri filtrele
      var unseenTests = tests.where((t) => !seenIds.contains(t['testID'])).toList();
      
      // Tüm testler görülmüşse sıfırla
      if (unseenTests.isEmpty) {
        if (kDebugMode) debugPrint('🔄 Tüm testler görüldü, sıfırlanıyor');
        await _dbHelper.resetSeenDuelContent('test');
        unseenTests = tests;
      }

      // Konu bazlı çeşitlilik sağla
      // 1. Testleri konularına göre grupla
      final Map<String, List<Map<String, Object?>>> testsByTopic = {};
      for (var test in unseenTests) {
        final topic = test['konuAdi'] as String? ?? 'Diğer';
        if (!testsByTopic.containsKey(topic)) {
          testsByTopic[topic] = [];
        }
        testsByTopic[topic]!.add(test);
      }
      
      debugPrint('🔍 [DUEL] Konu dağılımı: ${testsByTopic.keys.length} farklı konu var');
      testsByTopic.forEach((key, value) {
        if (value.length < 5) debugPrint('   - $key: ${value.length} test');
      });

      // 2. Önce rastgele bir konu seç
      final topics = testsByTopic.keys.toList();
      final randomTopic = topics[_random.nextInt(topics.length)];
      
      // 3. O konudan rastgele bir test seç
      final possibleTests = testsByTopic[randomTopic]!;
      final selectedTest = possibleTests[_random.nextInt(possibleTests.length)];
      
      debugPrint('🎲 [DUEL] Seçilen konu: $randomTopic (Bu konuda ${possibleTests.length} test var)');
      final testId = selectedTest['testID'] as String;
      final topicName = selectedTest['konuAdi'] as String? ?? 'Bilinmeyen Konu';
      
      // Bu testi görüldü olarak işaretle
      await _dbHelper.markDuelContentAsSeen('test', testId);
      
      if (kDebugMode) {
        debugPrint('📝 Seçilen test: $testId - Konu: $topicName');
      }

      // Seçilen testten soruları çıkar
      final List<DuelQuestion> questions = [];
      final questionsJson = selectedTest['sorular'] as String?;
      
      if (questionsJson != null && questionsJson.isNotEmpty) {
        try {
          final List<dynamic> parsed = json.decode(questionsJson);
          debugPrint('🔍 [TEST] Parse edilen soru sayısı: ${parsed.length}');
          
          for (int i = 0; i < parsed.length; i++) {
            final q = parsed[i];
            
            // DEBUG: Soru yapısını gör
            if (i == 0) {
              debugPrint('🔍 [TEST] İlk soru keys: ${q.keys.toList()}');
              debugPrint('🔍 [TEST] İlk soru q["soru"]: ${q["soru"]}');
              debugPrint('🔍 [TEST] İlk soru q["soruMetni"]: ${q["soruMetni"]}');
            }
            
            // Soru metni farklı alanlarda olabilir
            final soruMetni = q['soru'] ?? q['soruMetni'] ?? q['question'] ?? q['text'] ?? '';
            
            // Seçenekleri hazırla
            final options = List<String>.from(q['secenekler'] ?? []);

            // dogruCevap analizi (İnt, Harf veya Metin olabilir)
            final dogruCevap = q['dogruCevap'];
            int correctIndex = 0;
            
            if (dogruCevap is int) {
              correctIndex = dogruCevap;
            } else if (dogruCevap != null) {
              final val = dogruCevap.toString().trim();
              
              // 1. Önce şıkların içinde metin olarak ara (Tam eşleşme)
              final textIndex = options.indexOf(val);
              
              if (textIndex != -1) {
                correctIndex = textIndex;
                debugPrint('🔍 [TEST] Soru $i: Cevap metin olarak bulundu -> Index $correctIndex');
              } else {
                // 2. Harf veya sayı kontrolü
                final upperVal = val.toUpperCase();
                if (int.tryParse(val) != null) {
                  correctIndex = int.parse(val);
                } else {
                  switch (upperVal) {
                    case 'A': correctIndex = 0; break;
                    case 'B': correctIndex = 1; break;
                    case 'C': correctIndex = 2; break;
                    case 'D': correctIndex = 3; break;
                    case 'E': correctIndex = 4; break;
                    default: correctIndex = 0;
                  }
                  debugPrint('🔍 [TEST] Soru $i: Cevap harf/sayı olarak işlendi -> Index $correctIndex');
                }
              }
            }
            
            questions.add(
              DuelQuestion(
                id: '${testId}_$i',
                question: soruMetni.toString(),
                options: options,
                correctIndex: correctIndex,
                imageUrl: q['resim'],
                topicName: topicName,
              ),
            );
          }
        } catch (e) {
          debugPrint('❌ [TEST] Soru parse hatası: $e');
        }
      }

      if (questions.isEmpty) {
        if (kDebugMode) debugPrint('❌ Testte soru bulunamadı - mock kullanılıyor');
        return _getDefaultTestQuestions();
      }

      // Rastgele karıştır ve döndür
      questions.shuffle(_random);
      return questions;
    } catch (e) {
      if (kDebugMode) debugPrint('Test soruları çekme hatası: $e');
      return _getDefaultTestQuestions();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CÜMLE TAMAMLAMA SORULARI
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cümle tamamlama sorularını çeker - görülmemiş levellerden seçer
  Future<List<DuelFillBlankQuestion>> getFillBlankQuestions() async {
    try {
      final db = await _dbHelper.database;

      // Fill Blanks levellarını çek
      final levels = await db.query('FillBlanksLevels');

      if (kDebugMode) {
        debugPrint('🔍 FillBlanksLevels: ${levels.length} level bulundu');
      }

      if (levels.isEmpty) {
        if (kDebugMode) debugPrint('❌ Hiç fill blanks level bulunamadı');
        return _getDefaultFillBlankQuestions();
      }

      // Görülen level ID'lerini al
      final seenIds = await _dbHelper.getSeenDuelContentIds('fillblank');
      
      // Görülmemiş levelleri filtrele
      var unseenLevels = levels.where((l) => !seenIds.contains(l['levelID'])).toList();
      
      // Tüm leveller görülmüşse sıfırla
      if (unseenLevels.isEmpty) {
        if (kDebugMode) debugPrint('🔄 Tüm fill blank levelları görüldü, sıfırlanıyor');
        await _dbHelper.resetSeenDuelContent('fillblank');
        unseenLevels = levels;
      }

      // Rastgele bir level seç
      unseenLevels.shuffle(_random);
      final selectedLevel = unseenLevels.first;
      final levelId = selectedLevel['levelID'] as String;
      final topicName = selectedLevel['title'] as String? ?? 
                        selectedLevel['category'] as String? ?? 
                        'Cümle Tamamlama';
      
      // Bu leveli görüldü olarak işaretle
      await _dbHelper.markDuelContentAsSeen('fillblank', levelId);
      
      if (kDebugMode) {
        debugPrint('📝 Seçilen fill blank level: $levelId - Konu: $topicName');
      }

      // Seçilen leveldan soruları çıkar
      final List<DuelFillBlankQuestion> questions = [];
      final questionsJson = selectedLevel['questions'] as String?;
      
      debugPrint('🔍 [FILLBLANK] questionsJson uzunluk: ${questionsJson?.length ?? 0}');
      
      if (questionsJson != null && questionsJson.isNotEmpty) {
        try {
          final List<dynamic> parsed = json.decode(questionsJson);
          debugPrint('🔍 [FILLBLANK] Parse edilen soru sayısı: ${parsed.length}');
          
          for (int i = 0; i < parsed.length; i++) {
            final q = parsed[i];
            
            // DEBUG: İlk soruda tüm keys'i göster
            if (i == 0) {
              debugPrint('🔍 [FILLBLANK] İlk soru keys: ${q.keys.toList()}');
              q.forEach((key, value) {
                debugPrint('🔍 [FILLBLANK] $key = $value');
              });
            }
            
            final sentence = q['sentence'] ?? q['cumle'] ?? q['text'] ?? q['soru'] ?? q['question'] ?? '';
            final answer = q['answer'] ?? q['cevap'] ?? q['correctAnswer'] ?? q['dogruCevap'] ?? '';

            debugPrint('🔍 [FILLBLANK] Soru $i: sentence="${sentence.toString().substring(0, sentence.toString().length > 50 ? 50 : sentence.toString().length)}...", answer="$answer"');

            List<String> options = [];
            if (q['options'] != null) {
              options = List<String>.from(q['options']);
            } else if (q['secenekler'] != null) {
              options = List<String>.from(q['secenekler']);
            } else if (q['choices'] != null) {
              options = List<String>.from(q['choices']);
            }

            if (options.isEmpty && answer.toString().isNotEmpty) {
              options = [answer.toString()];
              if (q['wrongAnswers'] != null) {
                options.addAll(List<String>.from(q['wrongAnswers']));
              }
            }
            
            debugPrint('🔍 [FILLBLANK] Soru $i options: $options');

            if (sentence.toString().isNotEmpty) {
              questions.add(
                DuelFillBlankQuestion(
                  id: '${levelId}_$i',
                  sentence: sentence.toString(),
                  answer: answer.toString(),
                  options: options,
                  topicName: topicName,
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('❌ [FILLBLANK] Soru parse hatası: $e');
        }
      }

      debugPrint('✅ [FILLBLANK] Toplam eklenen soru: ${questions.length}');
      
      if (questions.isEmpty) {
        debugPrint('❌ [FILLBLANK] Sorular boş - mock kullanılıyor');
        return _getDefaultFillBlankQuestions();
      }

      // Rastgele karıştır ve döndür
      questions.shuffle(_random);
      return questions;
    } catch (e) {
      if (kDebugMode) debugPrint('Fill blank soruları çekme hatası: $e');
      return _getDefaultFillBlankQuestions();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SALLA BAKALIM SORULARI
  // ═══════════════════════════════════════════════════════════════════════════

  /// Salla Bakalım (Guess) sorularını çeker - görülmemiş levellerden seçer
  Future<List<DuelGuessQuestion>> getGuessQuestions() async {
    try {
      final db = await _dbHelper.database;

      // GuessLevels tablosundan veri çek
      final levels = await db.query('GuessLevels');

      if (kDebugMode) {
        debugPrint('🔍 GuessLevels: ${levels.length} level bulundu');
      }

      if (levels.isEmpty) {
        if (kDebugMode) debugPrint('❌ Hiç guess level bulunamadı');
        return _getDefaultGuessQuestions();
      }

      // Görülen level ID'lerini al
      final seenIds = await _dbHelper.getSeenDuelContentIds('guess');
      
      // Görülmemiş levelleri filtrele
      var unseenLevels = levels.where((l) {
        final id = l['guessID'] ?? l['levelID'];
        return !seenIds.contains(id);
      }).toList();
      
      // Tüm leveller görülmüşse sıfırla
      if (unseenLevels.isEmpty) {
        if (kDebugMode) debugPrint('🔄 Tüm guess levelları görüldü, sıfırlanıyor');
        await _dbHelper.resetSeenDuelContent('guess');
        unseenLevels = levels;
      }

      // Rastgele bir level seç
      unseenLevels.shuffle(_random);
      final selectedLevel = unseenLevels.first;
      final levelId = (selectedLevel['guessID'] ?? selectedLevel['levelID']) as String;
      final topicName = selectedLevel['title'] as String? ?? 
                        selectedLevel['description'] as String? ?? 
                        'Salla Bakalım';
      
      // Bu leveli görüldü olarak işaretle
      await _dbHelper.markDuelContentAsSeen('guess', levelId);
      
      if (kDebugMode) {
        debugPrint('📝 Seçilen guess level: $levelId - Konu: $topicName');
      }

      // Seçilen leveldan soruları çıkar
      final List<DuelGuessQuestion> questions = [];
      final questionsJson = selectedLevel['questions'] as String?;
      
      if (questionsJson != null && questionsJson.isNotEmpty) {
        try {
          final List<dynamic> parsed = json.decode(questionsJson);
          for (int i = 0; i < parsed.length; i++) {
            final q = parsed[i];
            questions.add(
              DuelGuessQuestion(
                id: '${levelId}_$i',
                question: q['question'] ?? q['soru'] ?? '',
                answer: q['answer'] ?? q['cevap'] ?? 0,
                tolerance: q['tolerance'] ?? 100,
                hint: q['hint'] ?? q['ipucu'],
                info: q['info'] ?? q['bilgi'],
                topicName: topicName,
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) debugPrint('Guess soru parse hatası: $e');
        }
      }

      if (questions.isEmpty) {
        return _getDefaultGuessQuestions();
      }

      // Rastgele karıştır ve döndür
      questions.shuffle(_random);
      return questions;
    } catch (e) {
      if (kDebugMode) debugPrint('Guess soruları çekme hatası: $e');
      return _getDefaultGuessQuestions();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VARSAYILAN SORULAR (Sadece veritabanı boşsa kullanılır)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Varsayılan test soruları (veri yoksa)
  List<DuelQuestion> _getDefaultTestQuestions() {
    return [
      const DuelQuestion(
        id: 'default_1',
        question: 'Türkiye\'nin başkenti neresidir?',
        options: ['İstanbul', 'Ankara', 'İzmir', 'Bursa'],
        correctIndex: 1,
      ),
      const DuelQuestion(
        id: 'default_2',
        question: '2 + 2 kaç eder?',
        options: ['3', '4', '5', '6'],
        correctIndex: 1,
      ),
      const DuelQuestion(
        id: 'default_3',
        question: 'Güneş sisteminde kaç gezegen vardır?',
        options: ['7', '8', '9', '10'],
        correctIndex: 1,
      ),
      const DuelQuestion(
        id: 'default_4',
        question: 'Su hangi elementlerden oluşur?',
        options: [
          'Karbon ve Oksijen',
          'Hidrojen ve Oksijen',
          'Azot ve Oksijen',
          'Helyum ve Hidrojen',
        ],
        correctIndex: 1,
      ),
      const DuelQuestion(
        id: 'default_5',
        question: 'Türkiye\'nin en uzun nehri hangisidir?',
        options: ['Fırat', 'Kızılırmak', 'Dicle', 'Sakarya'],
        correctIndex: 1,
      ),
    ];
  }

  /// Varsayılan cümle tamamlama soruları (veri yoksa)
  List<DuelFillBlankQuestion> _getDefaultFillBlankQuestions() {
    return [
      const DuelFillBlankQuestion(
        id: 'fb_default_1',
        sentence: 'Güneş ___ dan doğar.',
        answer: 'doğu',
        options: ['doğu', 'batı', 'kuzey', 'güney'],
      ),
      const DuelFillBlankQuestion(
        id: 'fb_default_2',
        sentence: 'Kuşlar ___ ile uçar.',
        answer: 'kanatları',
        options: ['kanatları', 'ayakları', 'gagaları', 'tüyleri'],
      ),
      const DuelFillBlankQuestion(
        id: 'fb_default_3',
        sentence: 'Yılda ___ mevsim vardır.',
        answer: 'dört',
        options: ['üç', 'dört', 'beş', 'altı'],
      ),
      const DuelFillBlankQuestion(
        id: 'fb_default_4',
        sentence: 'Kitap okumak ___ geliştirir.',
        answer: 'zekayı',
        options: ['kasları', 'zekayı', 'sesi', 'boyunu'],
      ),
      const DuelFillBlankQuestion(
        id: 'fb_default_5',
        sentence: 'Balıklar ___ de yaşar.',
        answer: 'su',
        options: ['hava', 'toprak', 'su', 'ateş'],
      ),
    ];
  }

  /// Varsayılan Salla Bakalım soruları (veri yoksa)
  List<DuelGuessQuestion> _getDefaultGuessQuestions() {
    return [
      const DuelGuessQuestion(
        id: 'guess_default_1',
        question: 'Türkiye\'nin nüfusu kaç milyondur?',
        answer: 85,
        tolerance: 20,
        hint: '80 milyonun üzerinde',
      ),
      const DuelGuessQuestion(
        id: 'guess_default_2',
        question: 'Everest Dağı\'nın yüksekliği kaç metredir?',
        answer: 8849,
        tolerance: 500,
        hint: '8000 metrenin üzerinde',
      ),
      const DuelGuessQuestion(
        id: 'guess_default_3',
        question: 'Bir yılda kaç gün vardır?',
        answer: 365,
        tolerance: 10,
        hint: '360\'tan fazla',
      ),
      const DuelGuessQuestion(
        id: 'guess_default_4',
        question: 'İstanbul\'un kaç ilçesi vardır?',
        answer: 39,
        tolerance: 10,
        hint: '30\'dan fazla',
      ),
      const DuelGuessQuestion(
        id: 'guess_default_5',
        question: 'Türkiye\'nin kaç ili vardır?',
        answer: 81,
        tolerance: 10,
        hint: '80 civarında',
      ),
    ];
  }
}
