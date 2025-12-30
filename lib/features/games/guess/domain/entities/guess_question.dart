/// Salla Bakalım oyunu soru modeli
class GuessQuestion {
  final String id;
  final String question;
  final int answer;
  final int tolerance; // Tolerans değeri (default 100)
  final String? hint;
  final String? info; // Doğru cevap sonrası gösterilecek bilgi

  const GuessQuestion({
    required this.id,
    required this.question,
    required this.answer,
    this.tolerance = 100,
    this.hint,
    this.info,
  });

  factory GuessQuestion.fromJson(Map<String, dynamic> json) {
    return GuessQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as int? ?? 0,
      tolerance: json['tolerance'] as int? ?? 100,
      hint: json['hint'] as String?,
      info: json['info'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'tolerance': tolerance,
      'hint': hint,
      'info': info,
    };
  }

  @override
  String toString() => 'GuessQuestion(id: $id, answer: $answer)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuessQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
