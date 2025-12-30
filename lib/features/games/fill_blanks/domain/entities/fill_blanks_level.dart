import 'fill_blanks_question.dart';

/// Cümle tamamlama oyunu seviye modeli
class FillBlanksLevel {
  final String id;
  final String title;
  final String description;
  final int difficulty;
  final List<FillBlanksQuestion> questions;

  const FillBlanksLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questions,
  });

  /// JSON'dan model oluşturma
  factory FillBlanksLevel.fromJson(Map<String, dynamic> json) {
    return FillBlanksLevel(
      // 'levelID' veya 'id' alanını destekle (geriye uyumluluk için)
      id: (json['levelID'] ?? json['id']) as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as int? ?? 1,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => FillBlanksQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Model'den JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'FillBlanksLevel(id: $id, title: $title, questions: ${questions.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FillBlanksLevel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        difficulty.hashCode;
  }
}
