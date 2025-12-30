// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashcardModelImpl _$$FlashcardModelImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardModelImpl(
      kartID: json['kartID'] as String,
      onyuz: json['onyuz'] as String,
      dogruMu: json['dogruMu'] as bool,
    );

Map<String, dynamic> _$$FlashcardModelImplToJson(
  _$FlashcardModelImpl instance,
) => <String, dynamic>{
  'kartID': instance.kartID,
  'onyuz': instance.onyuz,
  'dogruMu': instance.dogruMu,
};

_$FlashcardSetModelImpl _$$FlashcardSetModelImplFromJson(
  Map<String, dynamic> json,
) => _$FlashcardSetModelImpl(
  kartSetID: json['kartSetID'] as String,
  konuID: json['konuID'] as String,
  kartAdi: json['kartAdi'] as String,
  kartlar:
      (json['kartlar'] as List<dynamic>?)
          ?.map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$FlashcardSetModelImplToJson(
  _$FlashcardSetModelImpl instance,
) => <String, dynamic>{
  'kartSetID': instance.kartSetID,
  'konuID': instance.konuID,
  'kartAdi': instance.kartAdi,
  'kartlar': instance.kartlar,
};
