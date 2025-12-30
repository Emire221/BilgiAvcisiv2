// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicModelImpl _$$TopicModelImplFromJson(Map<String, dynamic> json) =>
    _$TopicModelImpl(
      konuID: json['konuID'] as String,
      dersID: json['dersID'] as String,
      konuAdi: json['konuAdi'] as String,
      sira: (json['sira'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TopicModelImplToJson(_$TopicModelImpl instance) =>
    <String, dynamic>{
      'konuID': instance.konuID,
      'dersID': instance.dersID,
      'konuAdi': instance.konuAdi,
      'sira': instance.sira,
    };
