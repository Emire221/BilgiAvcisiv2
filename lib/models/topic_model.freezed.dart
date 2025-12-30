// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TopicModel _$TopicModelFromJson(Map<String, dynamic> json) {
  return _TopicModel.fromJson(json);
}

/// @nodoc
mixin _$TopicModel {
  String get konuID => throw _privateConstructorUsedError;
  String get dersID => throw _privateConstructorUsedError;
  String get konuAdi => throw _privateConstructorUsedError;
  int get sira => throw _privateConstructorUsedError;

  /// Serializes this TopicModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicModelCopyWith<TopicModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicModelCopyWith<$Res> {
  factory $TopicModelCopyWith(
    TopicModel value,
    $Res Function(TopicModel) then,
  ) = _$TopicModelCopyWithImpl<$Res, TopicModel>;
  @useResult
  $Res call({String konuID, String dersID, String konuAdi, int sira});
}

/// @nodoc
class _$TopicModelCopyWithImpl<$Res, $Val extends TopicModel>
    implements $TopicModelCopyWith<$Res> {
  _$TopicModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? konuID = null,
    Object? dersID = null,
    Object? konuAdi = null,
    Object? sira = null,
  }) {
    return _then(
      _value.copyWith(
            konuID: null == konuID
                ? _value.konuID
                : konuID // ignore: cast_nullable_to_non_nullable
                      as String,
            dersID: null == dersID
                ? _value.dersID
                : dersID // ignore: cast_nullable_to_non_nullable
                      as String,
            konuAdi: null == konuAdi
                ? _value.konuAdi
                : konuAdi // ignore: cast_nullable_to_non_nullable
                      as String,
            sira: null == sira
                ? _value.sira
                : sira // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopicModelImplCopyWith<$Res>
    implements $TopicModelCopyWith<$Res> {
  factory _$$TopicModelImplCopyWith(
    _$TopicModelImpl value,
    $Res Function(_$TopicModelImpl) then,
  ) = __$$TopicModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String konuID, String dersID, String konuAdi, int sira});
}

/// @nodoc
class __$$TopicModelImplCopyWithImpl<$Res>
    extends _$TopicModelCopyWithImpl<$Res, _$TopicModelImpl>
    implements _$$TopicModelImplCopyWith<$Res> {
  __$$TopicModelImplCopyWithImpl(
    _$TopicModelImpl _value,
    $Res Function(_$TopicModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? konuID = null,
    Object? dersID = null,
    Object? konuAdi = null,
    Object? sira = null,
  }) {
    return _then(
      _$TopicModelImpl(
        konuID: null == konuID
            ? _value.konuID
            : konuID // ignore: cast_nullable_to_non_nullable
                  as String,
        dersID: null == dersID
            ? _value.dersID
            : dersID // ignore: cast_nullable_to_non_nullable
                  as String,
        konuAdi: null == konuAdi
            ? _value.konuAdi
            : konuAdi // ignore: cast_nullable_to_non_nullable
                  as String,
        sira: null == sira
            ? _value.sira
            : sira // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopicModelImpl implements _TopicModel {
  const _$TopicModelImpl({
    required this.konuID,
    required this.dersID,
    required this.konuAdi,
    this.sira = 0,
  });

  factory _$TopicModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopicModelImplFromJson(json);

  @override
  final String konuID;
  @override
  final String dersID;
  @override
  final String konuAdi;
  @override
  @JsonKey()
  final int sira;

  @override
  String toString() {
    return 'TopicModel(konuID: $konuID, dersID: $dersID, konuAdi: $konuAdi, sira: $sira)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicModelImpl &&
            (identical(other.konuID, konuID) || other.konuID == konuID) &&
            (identical(other.dersID, dersID) || other.dersID == dersID) &&
            (identical(other.konuAdi, konuAdi) || other.konuAdi == konuAdi) &&
            (identical(other.sira, sira) || other.sira == sira));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, konuID, dersID, konuAdi, sira);

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicModelImplCopyWith<_$TopicModelImpl> get copyWith =>
      __$$TopicModelImplCopyWithImpl<_$TopicModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopicModelImplToJson(this);
  }
}

abstract class _TopicModel implements TopicModel {
  const factory _TopicModel({
    required final String konuID,
    required final String dersID,
    required final String konuAdi,
    final int sira,
  }) = _$TopicModelImpl;

  factory _TopicModel.fromJson(Map<String, dynamic> json) =
      _$TopicModelImpl.fromJson;

  @override
  String get konuID;
  @override
  String get dersID;
  @override
  String get konuAdi;
  @override
  int get sira;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicModelImplCopyWith<_$TopicModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
