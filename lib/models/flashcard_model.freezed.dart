// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FlashcardModel _$FlashcardModelFromJson(Map<String, dynamic> json) {
  return _FlashcardModel.fromJson(json);
}

/// @nodoc
mixin _$FlashcardModel {
  String get kartID => throw _privateConstructorUsedError;
  String get onyuz => throw _privateConstructorUsedError;
  bool get dogruMu => throw _privateConstructorUsedError;

  /// Serializes this FlashcardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardModelCopyWith<FlashcardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardModelCopyWith<$Res> {
  factory $FlashcardModelCopyWith(
    FlashcardModel value,
    $Res Function(FlashcardModel) then,
  ) = _$FlashcardModelCopyWithImpl<$Res, FlashcardModel>;
  @useResult
  $Res call({String kartID, String onyuz, bool dogruMu});
}

/// @nodoc
class _$FlashcardModelCopyWithImpl<$Res, $Val extends FlashcardModel>
    implements $FlashcardModelCopyWith<$Res> {
  _$FlashcardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kartID = null,
    Object? onyuz = null,
    Object? dogruMu = null,
  }) {
    return _then(
      _value.copyWith(
            kartID: null == kartID
                ? _value.kartID
                : kartID // ignore: cast_nullable_to_non_nullable
                      as String,
            onyuz: null == onyuz
                ? _value.onyuz
                : onyuz // ignore: cast_nullable_to_non_nullable
                      as String,
            dogruMu: null == dogruMu
                ? _value.dogruMu
                : dogruMu // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlashcardModelImplCopyWith<$Res>
    implements $FlashcardModelCopyWith<$Res> {
  factory _$$FlashcardModelImplCopyWith(
    _$FlashcardModelImpl value,
    $Res Function(_$FlashcardModelImpl) then,
  ) = __$$FlashcardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String kartID, String onyuz, bool dogruMu});
}

/// @nodoc
class __$$FlashcardModelImplCopyWithImpl<$Res>
    extends _$FlashcardModelCopyWithImpl<$Res, _$FlashcardModelImpl>
    implements _$$FlashcardModelImplCopyWith<$Res> {
  __$$FlashcardModelImplCopyWithImpl(
    _$FlashcardModelImpl _value,
    $Res Function(_$FlashcardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kartID = null,
    Object? onyuz = null,
    Object? dogruMu = null,
  }) {
    return _then(
      _$FlashcardModelImpl(
        kartID: null == kartID
            ? _value.kartID
            : kartID // ignore: cast_nullable_to_non_nullable
                  as String,
        onyuz: null == onyuz
            ? _value.onyuz
            : onyuz // ignore: cast_nullable_to_non_nullable
                  as String,
        dogruMu: null == dogruMu
            ? _value.dogruMu
            : dogruMu // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardModelImpl implements _FlashcardModel {
  const _$FlashcardModelImpl({
    required this.kartID,
    required this.onyuz,
    required this.dogruMu,
  });

  factory _$FlashcardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardModelImplFromJson(json);

  @override
  final String kartID;
  @override
  final String onyuz;
  @override
  final bool dogruMu;

  @override
  String toString() {
    return 'FlashcardModel(kartID: $kartID, onyuz: $onyuz, dogruMu: $dogruMu)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardModelImpl &&
            (identical(other.kartID, kartID) || other.kartID == kartID) &&
            (identical(other.onyuz, onyuz) || other.onyuz == onyuz) &&
            (identical(other.dogruMu, dogruMu) || other.dogruMu == dogruMu));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, kartID, onyuz, dogruMu);

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardModelImplCopyWith<_$FlashcardModelImpl> get copyWith =>
      __$$FlashcardModelImplCopyWithImpl<_$FlashcardModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardModelImplToJson(this);
  }
}

abstract class _FlashcardModel implements FlashcardModel {
  const factory _FlashcardModel({
    required final String kartID,
    required final String onyuz,
    required final bool dogruMu,
  }) = _$FlashcardModelImpl;

  factory _FlashcardModel.fromJson(Map<String, dynamic> json) =
      _$FlashcardModelImpl.fromJson;

  @override
  String get kartID;
  @override
  String get onyuz;
  @override
  bool get dogruMu;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardModelImplCopyWith<_$FlashcardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FlashcardSetModel _$FlashcardSetModelFromJson(Map<String, dynamic> json) {
  return _FlashcardSetModel.fromJson(json);
}

/// @nodoc
mixin _$FlashcardSetModel {
  String get kartSetID => throw _privateConstructorUsedError;
  String get konuID => throw _privateConstructorUsedError;
  String get kartAdi => throw _privateConstructorUsedError;
  List<FlashcardModel> get kartlar => throw _privateConstructorUsedError;

  /// Serializes this FlashcardSetModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashcardSetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardSetModelCopyWith<FlashcardSetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardSetModelCopyWith<$Res> {
  factory $FlashcardSetModelCopyWith(
    FlashcardSetModel value,
    $Res Function(FlashcardSetModel) then,
  ) = _$FlashcardSetModelCopyWithImpl<$Res, FlashcardSetModel>;
  @useResult
  $Res call({
    String kartSetID,
    String konuID,
    String kartAdi,
    List<FlashcardModel> kartlar,
  });
}

/// @nodoc
class _$FlashcardSetModelCopyWithImpl<$Res, $Val extends FlashcardSetModel>
    implements $FlashcardSetModelCopyWith<$Res> {
  _$FlashcardSetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashcardSetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kartSetID = null,
    Object? konuID = null,
    Object? kartAdi = null,
    Object? kartlar = null,
  }) {
    return _then(
      _value.copyWith(
            kartSetID: null == kartSetID
                ? _value.kartSetID
                : kartSetID // ignore: cast_nullable_to_non_nullable
                      as String,
            konuID: null == konuID
                ? _value.konuID
                : konuID // ignore: cast_nullable_to_non_nullable
                      as String,
            kartAdi: null == kartAdi
                ? _value.kartAdi
                : kartAdi // ignore: cast_nullable_to_non_nullable
                      as String,
            kartlar: null == kartlar
                ? _value.kartlar
                : kartlar // ignore: cast_nullable_to_non_nullable
                      as List<FlashcardModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlashcardSetModelImplCopyWith<$Res>
    implements $FlashcardSetModelCopyWith<$Res> {
  factory _$$FlashcardSetModelImplCopyWith(
    _$FlashcardSetModelImpl value,
    $Res Function(_$FlashcardSetModelImpl) then,
  ) = __$$FlashcardSetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String kartSetID,
    String konuID,
    String kartAdi,
    List<FlashcardModel> kartlar,
  });
}

/// @nodoc
class __$$FlashcardSetModelImplCopyWithImpl<$Res>
    extends _$FlashcardSetModelCopyWithImpl<$Res, _$FlashcardSetModelImpl>
    implements _$$FlashcardSetModelImplCopyWith<$Res> {
  __$$FlashcardSetModelImplCopyWithImpl(
    _$FlashcardSetModelImpl _value,
    $Res Function(_$FlashcardSetModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlashcardSetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kartSetID = null,
    Object? konuID = null,
    Object? kartAdi = null,
    Object? kartlar = null,
  }) {
    return _then(
      _$FlashcardSetModelImpl(
        kartSetID: null == kartSetID
            ? _value.kartSetID
            : kartSetID // ignore: cast_nullable_to_non_nullable
                  as String,
        konuID: null == konuID
            ? _value.konuID
            : konuID // ignore: cast_nullable_to_non_nullable
                  as String,
        kartAdi: null == kartAdi
            ? _value.kartAdi
            : kartAdi // ignore: cast_nullable_to_non_nullable
                  as String,
        kartlar: null == kartlar
            ? _value._kartlar
            : kartlar // ignore: cast_nullable_to_non_nullable
                  as List<FlashcardModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardSetModelImpl implements _FlashcardSetModel {
  const _$FlashcardSetModelImpl({
    required this.kartSetID,
    required this.konuID,
    required this.kartAdi,
    final List<FlashcardModel> kartlar = const [],
  }) : _kartlar = kartlar;

  factory _$FlashcardSetModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardSetModelImplFromJson(json);

  @override
  final String kartSetID;
  @override
  final String konuID;
  @override
  final String kartAdi;
  final List<FlashcardModel> _kartlar;
  @override
  @JsonKey()
  List<FlashcardModel> get kartlar {
    if (_kartlar is EqualUnmodifiableListView) return _kartlar;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_kartlar);
  }

  @override
  String toString() {
    return 'FlashcardSetModel(kartSetID: $kartSetID, konuID: $konuID, kartAdi: $kartAdi, kartlar: $kartlar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardSetModelImpl &&
            (identical(other.kartSetID, kartSetID) ||
                other.kartSetID == kartSetID) &&
            (identical(other.konuID, konuID) || other.konuID == konuID) &&
            (identical(other.kartAdi, kartAdi) || other.kartAdi == kartAdi) &&
            const DeepCollectionEquality().equals(other._kartlar, _kartlar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    kartSetID,
    konuID,
    kartAdi,
    const DeepCollectionEquality().hash(_kartlar),
  );

  /// Create a copy of FlashcardSetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardSetModelImplCopyWith<_$FlashcardSetModelImpl> get copyWith =>
      __$$FlashcardSetModelImplCopyWithImpl<_$FlashcardSetModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardSetModelImplToJson(this);
  }
}

abstract class _FlashcardSetModel implements FlashcardSetModel {
  const factory _FlashcardSetModel({
    required final String kartSetID,
    required final String konuID,
    required final String kartAdi,
    final List<FlashcardModel> kartlar,
  }) = _$FlashcardSetModelImpl;

  factory _FlashcardSetModel.fromJson(Map<String, dynamic> json) =
      _$FlashcardSetModelImpl.fromJson;

  @override
  String get kartSetID;
  @override
  String get konuID;
  @override
  String get kartAdi;
  @override
  List<FlashcardModel> get kartlar;

  /// Create a copy of FlashcardSetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardSetModelImplCopyWith<_$FlashcardSetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
