// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manifest_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Manifest _$ManifestFromJson(Map<String, dynamic> json) {
  return _Manifest.fromJson(json);
}

/// @nodoc
mixin _$Manifest {
  String get version => throw _privateConstructorUsedError;
  List<ManifestFile> get files => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Manifest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Manifest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ManifestCopyWith<Manifest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManifestCopyWith<$Res> {
  factory $ManifestCopyWith(Manifest value, $Res Function(Manifest) then) =
      _$ManifestCopyWithImpl<$Res, Manifest>;
  @useResult
  $Res call({String version, List<ManifestFile> files, DateTime updatedAt});
}

/// @nodoc
class _$ManifestCopyWithImpl<$Res, $Val extends Manifest>
    implements $ManifestCopyWith<$Res> {
  _$ManifestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Manifest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? files = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
            files: null == files
                ? _value.files
                : files // ignore: cast_nullable_to_non_nullable
                      as List<ManifestFile>,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ManifestImplCopyWith<$Res>
    implements $ManifestCopyWith<$Res> {
  factory _$$ManifestImplCopyWith(
    _$ManifestImpl value,
    $Res Function(_$ManifestImpl) then,
  ) = __$$ManifestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String version, List<ManifestFile> files, DateTime updatedAt});
}

/// @nodoc
class __$$ManifestImplCopyWithImpl<$Res>
    extends _$ManifestCopyWithImpl<$Res, _$ManifestImpl>
    implements _$$ManifestImplCopyWith<$Res> {
  __$$ManifestImplCopyWithImpl(
    _$ManifestImpl _value,
    $Res Function(_$ManifestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Manifest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? files = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ManifestImpl(
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<ManifestFile>,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ManifestImpl implements _Manifest {
  const _$ManifestImpl({
    required this.version,
    required final List<ManifestFile> files,
    required this.updatedAt,
  }) : _files = files;

  factory _$ManifestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ManifestImplFromJson(json);

  @override
  final String version;
  final List<ManifestFile> _files;
  @override
  List<ManifestFile> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Manifest(version: $version, files: $files, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManifestImpl &&
            (identical(other.version, version) || other.version == version) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    const DeepCollectionEquality().hash(_files),
    updatedAt,
  );

  /// Create a copy of Manifest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ManifestImplCopyWith<_$ManifestImpl> get copyWith =>
      __$$ManifestImplCopyWithImpl<_$ManifestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ManifestImplToJson(this);
  }
}

abstract class _Manifest implements Manifest {
  const factory _Manifest({
    required final String version,
    required final List<ManifestFile> files,
    required final DateTime updatedAt,
  }) = _$ManifestImpl;

  factory _Manifest.fromJson(Map<String, dynamic> json) =
      _$ManifestImpl.fromJson;

  @override
  String get version;
  @override
  List<ManifestFile> get files;
  @override
  DateTime get updatedAt;

  /// Create a copy of Manifest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ManifestImplCopyWith<_$ManifestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ManifestFile _$ManifestFileFromJson(Map<String, dynamic> json) {
  return _ManifestFile.fromJson(json);
}

/// @nodoc
mixin _$ManifestFile {
  String get path =>
      throw _privateConstructorUsedError; // Örn: "3_Sinif/Matematik/testler/test1.json"
  String get type =>
      throw _privateConstructorUsedError; // "tar.bz2" veya "json"
  String get version => throw _privateConstructorUsedError; // Örn: "v1", "v2"
  String get hash =>
      throw _privateConstructorUsedError; // Dosya hash'i (MD5 veya SHA256)
  DateTime get addedAt => throw _privateConstructorUsedError;

  /// Serializes this ManifestFile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ManifestFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ManifestFileCopyWith<ManifestFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManifestFileCopyWith<$Res> {
  factory $ManifestFileCopyWith(
    ManifestFile value,
    $Res Function(ManifestFile) then,
  ) = _$ManifestFileCopyWithImpl<$Res, ManifestFile>;
  @useResult
  $Res call({
    String path,
    String type,
    String version,
    String hash,
    DateTime addedAt,
  });
}

/// @nodoc
class _$ManifestFileCopyWithImpl<$Res, $Val extends ManifestFile>
    implements $ManifestFileCopyWith<$Res> {
  _$ManifestFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ManifestFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? type = null,
    Object? version = null,
    Object? hash = null,
    Object? addedAt = null,
  }) {
    return _then(
      _value.copyWith(
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
            hash: null == hash
                ? _value.hash
                : hash // ignore: cast_nullable_to_non_nullable
                      as String,
            addedAt: null == addedAt
                ? _value.addedAt
                : addedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ManifestFileImplCopyWith<$Res>
    implements $ManifestFileCopyWith<$Res> {
  factory _$$ManifestFileImplCopyWith(
    _$ManifestFileImpl value,
    $Res Function(_$ManifestFileImpl) then,
  ) = __$$ManifestFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String path,
    String type,
    String version,
    String hash,
    DateTime addedAt,
  });
}

/// @nodoc
class __$$ManifestFileImplCopyWithImpl<$Res>
    extends _$ManifestFileCopyWithImpl<$Res, _$ManifestFileImpl>
    implements _$$ManifestFileImplCopyWith<$Res> {
  __$$ManifestFileImplCopyWithImpl(
    _$ManifestFileImpl _value,
    $Res Function(_$ManifestFileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ManifestFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? type = null,
    Object? version = null,
    Object? hash = null,
    Object? addedAt = null,
  }) {
    return _then(
      _$ManifestFileImpl(
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        hash: null == hash
            ? _value.hash
            : hash // ignore: cast_nullable_to_non_nullable
                  as String,
        addedAt: null == addedAt
            ? _value.addedAt
            : addedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ManifestFileImpl implements _ManifestFile {
  const _$ManifestFileImpl({
    required this.path,
    required this.type,
    required this.version,
    required this.hash,
    required this.addedAt,
  });

  factory _$ManifestFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ManifestFileImplFromJson(json);

  @override
  final String path;
  // Örn: "3_Sinif/Matematik/testler/test1.json"
  @override
  final String type;
  // "tar.bz2" veya "json"
  @override
  final String version;
  // Örn: "v1", "v2"
  @override
  final String hash;
  // Dosya hash'i (MD5 veya SHA256)
  @override
  final DateTime addedAt;

  @override
  String toString() {
    return 'ManifestFile(path: $path, type: $type, version: $version, hash: $hash, addedAt: $addedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManifestFileImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, path, type, version, hash, addedAt);

  /// Create a copy of ManifestFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ManifestFileImplCopyWith<_$ManifestFileImpl> get copyWith =>
      __$$ManifestFileImplCopyWithImpl<_$ManifestFileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ManifestFileImplToJson(this);
  }
}

abstract class _ManifestFile implements ManifestFile {
  const factory _ManifestFile({
    required final String path,
    required final String type,
    required final String version,
    required final String hash,
    required final DateTime addedAt,
  }) = _$ManifestFileImpl;

  factory _ManifestFile.fromJson(Map<String, dynamic> json) =
      _$ManifestFileImpl.fromJson;

  @override
  String get path; // Örn: "3_Sinif/Matematik/testler/test1.json"
  @override
  String get type; // "tar.bz2" veya "json"
  @override
  String get version; // Örn: "v1", "v2"
  @override
  String get hash; // Dosya hash'i (MD5 veya SHA256)
  @override
  DateTime get addedAt;

  /// Create a copy of ManifestFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ManifestFileImplCopyWith<_$ManifestFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SyncState {
  bool get isSyncing => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  String get currentFile => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  List<String> get downloadedFiles => throw _privateConstructorUsedError;
  List<String> get failedFiles => throw _privateConstructorUsedError;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncStateCopyWith<SyncState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStateCopyWith<$Res> {
  factory $SyncStateCopyWith(SyncState value, $Res Function(SyncState) then) =
      _$SyncStateCopyWithImpl<$Res, SyncState>;
  @useResult
  $Res call({
    bool isSyncing,
    double progress,
    String currentFile,
    String message,
    String? error,
    List<String> downloadedFiles,
    List<String> failedFiles,
  });
}

/// @nodoc
class _$SyncStateCopyWithImpl<$Res, $Val extends SyncState>
    implements $SyncStateCopyWith<$Res> {
  _$SyncStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSyncing = null,
    Object? progress = null,
    Object? currentFile = null,
    Object? message = null,
    Object? error = freezed,
    Object? downloadedFiles = null,
    Object? failedFiles = null,
  }) {
    return _then(
      _value.copyWith(
            isSyncing: null == isSyncing
                ? _value.isSyncing
                : isSyncing // ignore: cast_nullable_to_non_nullable
                      as bool,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double,
            currentFile: null == currentFile
                ? _value.currentFile
                : currentFile // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            downloadedFiles: null == downloadedFiles
                ? _value.downloadedFiles
                : downloadedFiles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            failedFiles: null == failedFiles
                ? _value.failedFiles
                : failedFiles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncStateImplCopyWith<$Res>
    implements $SyncStateCopyWith<$Res> {
  factory _$$SyncStateImplCopyWith(
    _$SyncStateImpl value,
    $Res Function(_$SyncStateImpl) then,
  ) = __$$SyncStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isSyncing,
    double progress,
    String currentFile,
    String message,
    String? error,
    List<String> downloadedFiles,
    List<String> failedFiles,
  });
}

/// @nodoc
class __$$SyncStateImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncStateImpl>
    implements _$$SyncStateImplCopyWith<$Res> {
  __$$SyncStateImplCopyWithImpl(
    _$SyncStateImpl _value,
    $Res Function(_$SyncStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSyncing = null,
    Object? progress = null,
    Object? currentFile = null,
    Object? message = null,
    Object? error = freezed,
    Object? downloadedFiles = null,
    Object? failedFiles = null,
  }) {
    return _then(
      _$SyncStateImpl(
        isSyncing: null == isSyncing
            ? _value.isSyncing
            : isSyncing // ignore: cast_nullable_to_non_nullable
                  as bool,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
        currentFile: null == currentFile
            ? _value.currentFile
            : currentFile // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        downloadedFiles: null == downloadedFiles
            ? _value._downloadedFiles
            : downloadedFiles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        failedFiles: null == failedFiles
            ? _value._failedFiles
            : failedFiles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$SyncStateImpl implements _SyncState {
  const _$SyncStateImpl({
    this.isSyncing = false,
    this.progress = 0.0,
    this.currentFile = '',
    this.message = '',
    this.error,
    final List<String> downloadedFiles = const [],
    final List<String> failedFiles = const [],
  }) : _downloadedFiles = downloadedFiles,
       _failedFiles = failedFiles;

  @override
  @JsonKey()
  final bool isSyncing;
  @override
  @JsonKey()
  final double progress;
  @override
  @JsonKey()
  final String currentFile;
  @override
  @JsonKey()
  final String message;
  @override
  final String? error;
  final List<String> _downloadedFiles;
  @override
  @JsonKey()
  List<String> get downloadedFiles {
    if (_downloadedFiles is EqualUnmodifiableListView) return _downloadedFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_downloadedFiles);
  }

  final List<String> _failedFiles;
  @override
  @JsonKey()
  List<String> get failedFiles {
    if (_failedFiles is EqualUnmodifiableListView) return _failedFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_failedFiles);
  }

  @override
  String toString() {
    return 'SyncState(isSyncing: $isSyncing, progress: $progress, currentFile: $currentFile, message: $message, error: $error, downloadedFiles: $downloadedFiles, failedFiles: $failedFiles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStateImpl &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.currentFile, currentFile) ||
                other.currentFile == currentFile) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(
              other._downloadedFiles,
              _downloadedFiles,
            ) &&
            const DeepCollectionEquality().equals(
              other._failedFiles,
              _failedFiles,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isSyncing,
    progress,
    currentFile,
    message,
    error,
    const DeepCollectionEquality().hash(_downloadedFiles),
    const DeepCollectionEquality().hash(_failedFiles),
  );

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStateImplCopyWith<_$SyncStateImpl> get copyWith =>
      __$$SyncStateImplCopyWithImpl<_$SyncStateImpl>(this, _$identity);
}

abstract class _SyncState implements SyncState {
  const factory _SyncState({
    final bool isSyncing,
    final double progress,
    final String currentFile,
    final String message,
    final String? error,
    final List<String> downloadedFiles,
    final List<String> failedFiles,
  }) = _$SyncStateImpl;

  @override
  bool get isSyncing;
  @override
  double get progress;
  @override
  String get currentFile;
  @override
  String get message;
  @override
  String? get error;
  @override
  List<String> get downloadedFiles;
  @override
  List<String> get failedFiles;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncStateImplCopyWith<_$SyncStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
