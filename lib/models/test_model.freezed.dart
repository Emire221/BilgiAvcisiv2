// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TestModel _$TestModelFromJson(Map<String, dynamic> json) {
  return _TestModel.fromJson(json);
}

/// @nodoc
mixin _$TestModel {
  String get testID => throw _privateConstructorUsedError;
  String get konuID => throw _privateConstructorUsedError;
  String get testAdi => throw _privateConstructorUsedError;
  int get zorluk => throw _privateConstructorUsedError;
  String get cozumVideoURL => throw _privateConstructorUsedError;
  List<QuestionModel> get sorular => throw _privateConstructorUsedError;

  /// Serializes this TestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestModelCopyWith<TestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestModelCopyWith<$Res> {
  factory $TestModelCopyWith(TestModel value, $Res Function(TestModel) then) =
      _$TestModelCopyWithImpl<$Res, TestModel>;
  @useResult
  $Res call({
    String testID,
    String konuID,
    String testAdi,
    int zorluk,
    String cozumVideoURL,
    List<QuestionModel> sorular,
  });
}

/// @nodoc
class _$TestModelCopyWithImpl<$Res, $Val extends TestModel>
    implements $TestModelCopyWith<$Res> {
  _$TestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testID = null,
    Object? konuID = null,
    Object? testAdi = null,
    Object? zorluk = null,
    Object? cozumVideoURL = null,
    Object? sorular = null,
  }) {
    return _then(
      _value.copyWith(
            testID: null == testID
                ? _value.testID
                : testID // ignore: cast_nullable_to_non_nullable
                      as String,
            konuID: null == konuID
                ? _value.konuID
                : konuID // ignore: cast_nullable_to_non_nullable
                      as String,
            testAdi: null == testAdi
                ? _value.testAdi
                : testAdi // ignore: cast_nullable_to_non_nullable
                      as String,
            zorluk: null == zorluk
                ? _value.zorluk
                : zorluk // ignore: cast_nullable_to_non_nullable
                      as int,
            cozumVideoURL: null == cozumVideoURL
                ? _value.cozumVideoURL
                : cozumVideoURL // ignore: cast_nullable_to_non_nullable
                      as String,
            sorular: null == sorular
                ? _value.sorular
                : sorular // ignore: cast_nullable_to_non_nullable
                      as List<QuestionModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TestModelImplCopyWith<$Res>
    implements $TestModelCopyWith<$Res> {
  factory _$$TestModelImplCopyWith(
    _$TestModelImpl value,
    $Res Function(_$TestModelImpl) then,
  ) = __$$TestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String testID,
    String konuID,
    String testAdi,
    int zorluk,
    String cozumVideoURL,
    List<QuestionModel> sorular,
  });
}

/// @nodoc
class __$$TestModelImplCopyWithImpl<$Res>
    extends _$TestModelCopyWithImpl<$Res, _$TestModelImpl>
    implements _$$TestModelImplCopyWith<$Res> {
  __$$TestModelImplCopyWithImpl(
    _$TestModelImpl _value,
    $Res Function(_$TestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testID = null,
    Object? konuID = null,
    Object? testAdi = null,
    Object? zorluk = null,
    Object? cozumVideoURL = null,
    Object? sorular = null,
  }) {
    return _then(
      _$TestModelImpl(
        testID: null == testID
            ? _value.testID
            : testID // ignore: cast_nullable_to_non_nullable
                  as String,
        konuID: null == konuID
            ? _value.konuID
            : konuID // ignore: cast_nullable_to_non_nullable
                  as String,
        testAdi: null == testAdi
            ? _value.testAdi
            : testAdi // ignore: cast_nullable_to_non_nullable
                  as String,
        zorluk: null == zorluk
            ? _value.zorluk
            : zorluk // ignore: cast_nullable_to_non_nullable
                  as int,
        cozumVideoURL: null == cozumVideoURL
            ? _value.cozumVideoURL
            : cozumVideoURL // ignore: cast_nullable_to_non_nullable
                  as String,
        sorular: null == sorular
            ? _value._sorular
            : sorular // ignore: cast_nullable_to_non_nullable
                  as List<QuestionModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TestModelImpl implements _TestModel {
  const _$TestModelImpl({
    required this.testID,
    required this.konuID,
    required this.testAdi,
    this.zorluk = 1,
    this.cozumVideoURL = '',
    final List<QuestionModel> sorular = const [],
  }) : _sorular = sorular;

  factory _$TestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestModelImplFromJson(json);

  @override
  final String testID;
  @override
  final String konuID;
  @override
  final String testAdi;
  @override
  @JsonKey()
  final int zorluk;
  @override
  @JsonKey()
  final String cozumVideoURL;
  final List<QuestionModel> _sorular;
  @override
  @JsonKey()
  List<QuestionModel> get sorular {
    if (_sorular is EqualUnmodifiableListView) return _sorular;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sorular);
  }

  @override
  String toString() {
    return 'TestModel(testID: $testID, konuID: $konuID, testAdi: $testAdi, zorluk: $zorluk, cozumVideoURL: $cozumVideoURL, sorular: $sorular)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestModelImpl &&
            (identical(other.testID, testID) || other.testID == testID) &&
            (identical(other.konuID, konuID) || other.konuID == konuID) &&
            (identical(other.testAdi, testAdi) || other.testAdi == testAdi) &&
            (identical(other.zorluk, zorluk) || other.zorluk == zorluk) &&
            (identical(other.cozumVideoURL, cozumVideoURL) ||
                other.cozumVideoURL == cozumVideoURL) &&
            const DeepCollectionEquality().equals(other._sorular, _sorular));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    testID,
    konuID,
    testAdi,
    zorluk,
    cozumVideoURL,
    const DeepCollectionEquality().hash(_sorular),
  );

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestModelImplCopyWith<_$TestModelImpl> get copyWith =>
      __$$TestModelImplCopyWithImpl<_$TestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestModelImplToJson(this);
  }
}

abstract class _TestModel implements TestModel {
  const factory _TestModel({
    required final String testID,
    required final String konuID,
    required final String testAdi,
    final int zorluk,
    final String cozumVideoURL,
    final List<QuestionModel> sorular,
  }) = _$TestModelImpl;

  factory _TestModel.fromJson(Map<String, dynamic> json) =
      _$TestModelImpl.fromJson;

  @override
  String get testID;
  @override
  String get konuID;
  @override
  String get testAdi;
  @override
  int get zorluk;
  @override
  String get cozumVideoURL;
  @override
  List<QuestionModel> get sorular;

  /// Create a copy of TestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestModelImplCopyWith<_$TestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
