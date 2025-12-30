// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) {
  return _QuestionModel.fromJson(json);
}

/// @nodoc
mixin _$QuestionModel {
  String get soruMetni => throw _privateConstructorUsedError;
  List<String> get secenekler => throw _privateConstructorUsedError;
  String get dogruCevap => throw _privateConstructorUsedError;
  String? get cozumMetni => throw _privateConstructorUsedError;
  String? get resimURL => throw _privateConstructorUsedError;
  String? get aciklama => throw _privateConstructorUsedError;

  /// Serializes this QuestionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionModelCopyWith<QuestionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionModelCopyWith<$Res> {
  factory $QuestionModelCopyWith(
    QuestionModel value,
    $Res Function(QuestionModel) then,
  ) = _$QuestionModelCopyWithImpl<$Res, QuestionModel>;
  @useResult
  $Res call({
    String soruMetni,
    List<String> secenekler,
    String dogruCevap,
    String? cozumMetni,
    String? resimURL,
    String? aciklama,
  });
}

/// @nodoc
class _$QuestionModelCopyWithImpl<$Res, $Val extends QuestionModel>
    implements $QuestionModelCopyWith<$Res> {
  _$QuestionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? soruMetni = null,
    Object? secenekler = null,
    Object? dogruCevap = null,
    Object? cozumMetni = freezed,
    Object? resimURL = freezed,
    Object? aciklama = freezed,
  }) {
    return _then(
      _value.copyWith(
            soruMetni: null == soruMetni
                ? _value.soruMetni
                : soruMetni // ignore: cast_nullable_to_non_nullable
                      as String,
            secenekler: null == secenekler
                ? _value.secenekler
                : secenekler // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dogruCevap: null == dogruCevap
                ? _value.dogruCevap
                : dogruCevap // ignore: cast_nullable_to_non_nullable
                      as String,
            cozumMetni: freezed == cozumMetni
                ? _value.cozumMetni
                : cozumMetni // ignore: cast_nullable_to_non_nullable
                      as String?,
            resimURL: freezed == resimURL
                ? _value.resimURL
                : resimURL // ignore: cast_nullable_to_non_nullable
                      as String?,
            aciklama: freezed == aciklama
                ? _value.aciklama
                : aciklama // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionModelImplCopyWith<$Res>
    implements $QuestionModelCopyWith<$Res> {
  factory _$$QuestionModelImplCopyWith(
    _$QuestionModelImpl value,
    $Res Function(_$QuestionModelImpl) then,
  ) = __$$QuestionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String soruMetni,
    List<String> secenekler,
    String dogruCevap,
    String? cozumMetni,
    String? resimURL,
    String? aciklama,
  });
}

/// @nodoc
class __$$QuestionModelImplCopyWithImpl<$Res>
    extends _$QuestionModelCopyWithImpl<$Res, _$QuestionModelImpl>
    implements _$$QuestionModelImplCopyWith<$Res> {
  __$$QuestionModelImplCopyWithImpl(
    _$QuestionModelImpl _value,
    $Res Function(_$QuestionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? soruMetni = null,
    Object? secenekler = null,
    Object? dogruCevap = null,
    Object? cozumMetni = freezed,
    Object? resimURL = freezed,
    Object? aciklama = freezed,
  }) {
    return _then(
      _$QuestionModelImpl(
        soruMetni: null == soruMetni
            ? _value.soruMetni
            : soruMetni // ignore: cast_nullable_to_non_nullable
                  as String,
        secenekler: null == secenekler
            ? _value._secenekler
            : secenekler // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dogruCevap: null == dogruCevap
            ? _value.dogruCevap
            : dogruCevap // ignore: cast_nullable_to_non_nullable
                  as String,
        cozumMetni: freezed == cozumMetni
            ? _value.cozumMetni
            : cozumMetni // ignore: cast_nullable_to_non_nullable
                  as String?,
        resimURL: freezed == resimURL
            ? _value.resimURL
            : resimURL // ignore: cast_nullable_to_non_nullable
                  as String?,
        aciklama: freezed == aciklama
            ? _value.aciklama
            : aciklama // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionModelImpl implements _QuestionModel {
  const _$QuestionModelImpl({
    required this.soruMetni,
    final List<String> secenekler = const [],
    required this.dogruCevap,
    this.cozumMetni,
    this.resimURL,
    this.aciklama,
  }) : _secenekler = secenekler;

  factory _$QuestionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionModelImplFromJson(json);

  @override
  final String soruMetni;
  final List<String> _secenekler;
  @override
  @JsonKey()
  List<String> get secenekler {
    if (_secenekler is EqualUnmodifiableListView) return _secenekler;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_secenekler);
  }

  @override
  final String dogruCevap;
  @override
  final String? cozumMetni;
  @override
  final String? resimURL;
  @override
  final String? aciklama;

  @override
  String toString() {
    return 'QuestionModel(soruMetni: $soruMetni, secenekler: $secenekler, dogruCevap: $dogruCevap, cozumMetni: $cozumMetni, resimURL: $resimURL, aciklama: $aciklama)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionModelImpl &&
            (identical(other.soruMetni, soruMetni) ||
                other.soruMetni == soruMetni) &&
            const DeepCollectionEquality().equals(
              other._secenekler,
              _secenekler,
            ) &&
            (identical(other.dogruCevap, dogruCevap) ||
                other.dogruCevap == dogruCevap) &&
            (identical(other.cozumMetni, cozumMetni) ||
                other.cozumMetni == cozumMetni) &&
            (identical(other.resimURL, resimURL) ||
                other.resimURL == resimURL) &&
            (identical(other.aciklama, aciklama) ||
                other.aciklama == aciklama));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    soruMetni,
    const DeepCollectionEquality().hash(_secenekler),
    dogruCevap,
    cozumMetni,
    resimURL,
    aciklama,
  );

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionModelImplCopyWith<_$QuestionModelImpl> get copyWith =>
      __$$QuestionModelImplCopyWithImpl<_$QuestionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionModelImplToJson(this);
  }
}

abstract class _QuestionModel implements QuestionModel {
  const factory _QuestionModel({
    required final String soruMetni,
    final List<String> secenekler,
    required final String dogruCevap,
    final String? cozumMetni,
    final String? resimURL,
    final String? aciklama,
  }) = _$QuestionModelImpl;

  factory _QuestionModel.fromJson(Map<String, dynamic> json) =
      _$QuestionModelImpl.fromJson;

  @override
  String get soruMetni;
  @override
  List<String> get secenekler;
  @override
  String get dogruCevap;
  @override
  String? get cozumMetni;
  @override
  String? get resimURL;
  @override
  String? get aciklama;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionModelImplCopyWith<_$QuestionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
