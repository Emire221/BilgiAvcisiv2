// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TestModelImpl _$$TestModelImplFromJson(Map<String, dynamic> json) =>
    _$TestModelImpl(
      testID: json['testID'] as String,
      konuID: json['konuID'] as String,
      testAdi: json['testAdi'] as String,
      zorluk: (json['zorluk'] as num?)?.toInt() ?? 1,
      cozumVideoURL: json['cozumVideoURL'] as String? ?? '',
      sorular:
          (json['sorular'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TestModelImplToJson(_$TestModelImpl instance) =>
    <String, dynamic>{
      'testID': instance.testID,
      'konuID': instance.konuID,
      'testAdi': instance.testAdi,
      'zorluk': instance.zorluk,
      'cozumVideoURL': instance.cozumVideoURL,
      'sorular': instance.sorular,
    };
