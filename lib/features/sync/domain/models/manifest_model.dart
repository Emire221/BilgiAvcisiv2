import 'package:freezed_annotation/freezed_annotation.dart';

part 'manifest_model.freezed.dart';
part 'manifest_model.g.dart';

/// Manifest modeli - Firebase Storage'daki tüm dosya/klasörlerin arşivi
@freezed
class Manifest with _$Manifest {
  const factory Manifest({
    required String version,
    required List<ManifestFile> files,
    required DateTime updatedAt,
  }) = _Manifest;

  factory Manifest.fromJson(Map<String, dynamic> json) =>
      _$ManifestFromJson(json);
}

/// Manifest dosya kaydı
@freezed
class ManifestFile with _$ManifestFile {
  const factory ManifestFile({
    required String path, // Örn: "3_Sinif/Matematik/testler/test1.json"
    required String type, // "tar.bz2" veya "json"
    required String version, // Örn: "v1", "v2"
    required String hash, // Dosya hash'i (MD5 veya SHA256)
    required DateTime addedAt, // Eklenme tarihi
  }) = _ManifestFile;

  factory ManifestFile.fromJson(Map<String, dynamic> json) =>
      _$ManifestFileFromJson(json);
}

/// Sync durumu
@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    @Default(false) bool isSyncing,
    @Default(0.0) double progress,
    @Default('') String currentFile,
    @Default('') String message,
    String? error,
    @Default([]) List<String> downloadedFiles,
    @Default([]) List<String> failedFiles,
  }) = _SyncState;
}
