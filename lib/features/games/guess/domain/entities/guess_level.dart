import 'guess_question.dart';

/// Salla Bakalım oyunu seviye modeli
class GuessLevel {
  final String id;
  final String title;
  final String description;
  final int difficulty; // 1-3 arası
  final List<GuessQuestion> questions;

  const GuessLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questions,
  });

  factory GuessLevel.fromJson(Map<String, dynamic> json) {
    return GuessLevel(
      id:
          (json['guessID'] ?? json['sallaID'] ?? json['levelID'] ?? json['id'])
              as String,
      title: json['title'] as String? ?? 'Seviye',
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as int? ?? 1,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => GuessQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  /// Zorluk seviyesine göre metin
  String get difficultyText {
    switch (difficulty) {
      case 1:
        return 'Kolay';
      case 2:
        return 'Orta';
      case 3:
        return 'Zor';
      default:
        return 'Kolay';
    }
  }

  /// Zorluk seviyesine göre yıldız
  String get difficultyStars {
    switch (difficulty) {
      case 1:
        return '⭐';
      case 2:
        return '⭐⭐';
      case 3:
        return '⭐⭐⭐';
      default:
        return '⭐';
    }
  }

  @override
  String toString() =>
      'GuessLevel(id: $id, title: $title, questions: ${questions.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuessLevel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
