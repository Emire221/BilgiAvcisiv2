// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trial_exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrialExamImpl _$$TrialExamImplFromJson(Map<String, dynamic> json) =>
    _$TrialExamImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      duration: (json['duration'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => ExamQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TrialExamImplToJson(_$TrialExamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'duration': instance.duration,
      'questions': instance.questions,
    };

_$ExamQuestionImpl _$$ExamQuestionImplFromJson(Map<String, dynamic> json) =>
    _$ExamQuestionImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswer: json['correctAnswer'] as String,
      topicId: json['topicId'] as String,
    );

Map<String, dynamic> _$$ExamQuestionImplToJson(_$ExamQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'topicId': instance.topicId,
    };

_$TrialResultImpl _$$TrialResultImplFromJson(Map<String, dynamic> json) =>
    _$TrialResultImpl(
      id: (json['id'] as num?)?.toInt(),
      examId: json['examId'] as String,
      userId: json['userId'] as String,
      rawAnswers: Map<String, String>.from(json['rawAnswers'] as Map),
      score: (json['score'] as num?)?.toInt(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$TrialResultImplToJson(_$TrialResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examId': instance.examId,
      'userId': instance.userId,
      'rawAnswers': instance.rawAnswers,
      'score': instance.score,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
