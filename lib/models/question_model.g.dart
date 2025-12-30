// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionModelImpl _$$QuestionModelImplFromJson(Map<String, dynamic> json) =>
    _$QuestionModelImpl(
      soruMetni: json['soruMetni'] as String,
      secenekler:
          (json['secenekler'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dogruCevap: json['dogruCevap'] as String,
      cozumMetni: json['cozumMetni'] as String?,
      resimURL: json['resimURL'] as String?,
      aciklama: json['aciklama'] as String?,
    );

Map<String, dynamic> _$$QuestionModelImplToJson(_$QuestionModelImpl instance) =>
    <String, dynamic>{
      'soruMetni': instance.soruMetni,
      'secenekler': instance.secenekler,
      'dogruCevap': instance.dogruCevap,
      'cozumMetni': instance.cozumMetni,
      'resimURL': instance.resimURL,
      'aciklama': instance.aciklama,
    };
