// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyExamQuestionImpl _$$WeeklyExamQuestionImplFromJson(
  Map<String, dynamic> json,
) => _$WeeklyExamQuestionImpl(
  questionId: json['questionId'] as String,
  questionText: json['questionText'] as String,
  optionA: json['optionA'] as String,
  optionB: json['optionB'] as String,
  optionC: json['optionC'] as String,
  optionD: json['optionD'] as String,
  correctAnswer: json['correctAnswer'] as String,
  topicId: json['topicId'] as String?,
  lessonName: json['lessonName'] as String?,
);

Map<String, dynamic> _$$WeeklyExamQuestionImplToJson(
  _$WeeklyExamQuestionImpl instance,
) => <String, dynamic>{
  'questionId': instance.questionId,
  'questionText': instance.questionText,
  'optionA': instance.optionA,
  'optionB': instance.optionB,
  'optionC': instance.optionC,
  'optionD': instance.optionD,
  'correctAnswer': instance.correctAnswer,
  'topicId': instance.topicId,
  'lessonName': instance.lessonName,
};

_$WeeklyExamResultImpl _$$WeeklyExamResultImplFromJson(
  Map<String, dynamic> json,
) => _$WeeklyExamResultImpl(
  id: (json['id'] as num?)?.toInt(),
  examId: json['examId'] as String,
  odaId: json['odaId'] as String,
  odaIsmi: json['odaIsmi'] as String,
  odaBaslangic: json['odaBaslangic'] as String,
  odaBitis: json['odaBitis'] as String,
  sonucTarihi: json['sonucTarihi'] as String,
  odaDurumu: json['odaDurumu'] as String,
  kullaniciId: json['kullaniciId'] as String,
  cevaplar: Map<String, String>.from(json['cevaplar'] as Map),
  dogru: (json['dogru'] as num?)?.toInt(),
  yanlis: (json['yanlis'] as num?)?.toInt(),
  bos: (json['bos'] as num?)?.toInt(),
  puan: (json['puan'] as num?)?.toInt(),
  siralama: (json['siralama'] as num?)?.toInt(),
  toplamKatilimci: (json['toplamKatilimci'] as num?)?.toInt(),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  resultViewed: json['resultViewed'] as bool? ?? false,
);

Map<String, dynamic> _$$WeeklyExamResultImplToJson(
  _$WeeklyExamResultImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'examId': instance.examId,
  'odaId': instance.odaId,
  'odaIsmi': instance.odaIsmi,
  'odaBaslangic': instance.odaBaslangic,
  'odaBitis': instance.odaBitis,
  'sonucTarihi': instance.sonucTarihi,
  'odaDurumu': instance.odaDurumu,
  'kullaniciId': instance.kullaniciId,
  'cevaplar': instance.cevaplar,
  'dogru': instance.dogru,
  'yanlis': instance.yanlis,
  'bos': instance.bos,
  'puan': instance.puan,
  'siralama': instance.siralama,
  'toplamKatilimci': instance.toplamKatilimci,
  'completedAt': instance.completedAt?.toIso8601String(),
  'resultViewed': instance.resultViewed,
};
