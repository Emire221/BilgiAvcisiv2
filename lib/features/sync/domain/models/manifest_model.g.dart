// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ManifestImpl _$$ManifestImplFromJson(Map<String, dynamic> json) =>
    _$ManifestImpl(
      version: json['version'] as String,
      files: (json['files'] as List<dynamic>)
          .map((e) => ManifestFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ManifestImplToJson(_$ManifestImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'files': instance.files,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$ManifestFileImpl _$$ManifestFileImplFromJson(Map<String, dynamic> json) =>
    _$ManifestFileImpl(
      path: json['path'] as String,
      type: json['type'] as String,
      version: json['version'] as String,
      hash: json['hash'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$$ManifestFileImplToJson(_$ManifestFileImpl instance) =>
    <String, dynamic>{
      'path': instance.path,
      'type': instance.type,
      'version': instance.version,
      'hash': instance.hash,
      'addedAt': instance.addedAt.toIso8601String(),
    };
