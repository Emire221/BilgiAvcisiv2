/// Cümle tamamlama sorusu entity'si
class FillBlanksQuestion {
  final String
  id; // String olarak güncellendi (JSON'daki "q1", "q2" gibi değerler için)
  final String question;
  final String answer;
  final List<String> options;
  final String? category;

  const FillBlanksQuestion({
    required this.id,
    required this.question,
    required this.answer,
    required this.options,
    this.category,
  });

  factory FillBlanksQuestion.fromMap(Map<String, dynamic> map) {
    return FillBlanksQuestion(
      id: map['id']?.toString() ?? '0',
      question: map['question'] as String,
      answer: map['answer'] as String,
      options: List<String>.from(map['options']),
      category: map['category'] as String?,
    );
  }

  /// JSON'dan model oluşturma (Level sisteminde kullanılıyor)
  factory FillBlanksQuestion.fromJson(Map<String, dynamic> json) {
    return FillBlanksQuestion(
      id: json['id']?.toString() ?? '0',
      question: json['question'] as String,
      answer: json['answer'] as String,
      options: List<String>.from(json['options']),
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'options': options,
      'category': category,
    };
  }

  /// Model'den JSON'a dönüştürme (Level sisteminde kullanılıyor)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'options': options,
      'category': category,
    };
  }
}
