// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TestState {
  List<QuestionModel> get questions => throw _privateConstructorUsedError;
  int get currentQuestionIndex => throw _privateConstructorUsedError;
  int get timeLeft => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;
  int get wrongCount => throw _privateConstructorUsedError;
  Map<int, String> get userAnswers => throw _privateConstructorUsedError;
  TestStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of TestState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestStateCopyWith<TestState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestStateCopyWith<$Res> {
  factory $TestStateCopyWith(TestState value, $Res Function(TestState) then) =
      _$TestStateCopyWithImpl<$Res, TestState>;
  @useResult
  $Res call({
    List<QuestionModel> questions,
    int currentQuestionIndex,
    int timeLeft,
    int score,
    int correctCount,
    int wrongCount,
    Map<int, String> userAnswers,
    TestStatus status,
    String? errorMessage,
  });
}

/// @nodoc
class _$TestStateCopyWithImpl<$Res, $Val extends TestState>
    implements $TestStateCopyWith<$Res> {
  _$TestStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? currentQuestionIndex = null,
    Object? timeLeft = null,
    Object? score = null,
    Object? correctCount = null,
    Object? wrongCount = null,
    Object? userAnswers = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<QuestionModel>,
            currentQuestionIndex: null == currentQuestionIndex
                ? _value.currentQuestionIndex
                : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            timeLeft: null == timeLeft
                ? _value.timeLeft
                : timeLeft // ignore: cast_nullable_to_non_nullable
                      as int,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            wrongCount: null == wrongCount
                ? _value.wrongCount
                : wrongCount // ignore: cast_nullable_to_non_nullable
                      as int,
            userAnswers: null == userAnswers
                ? _value.userAnswers
                : userAnswers // ignore: cast_nullable_to_non_nullable
                      as Map<int, String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TestStatus,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TestStateImplCopyWith<$Res>
    implements $TestStateCopyWith<$Res> {
  factory _$$TestStateImplCopyWith(
    _$TestStateImpl value,
    $Res Function(_$TestStateImpl) then,
  ) = __$$TestStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<QuestionModel> questions,
    int currentQuestionIndex,
    int timeLeft,
    int score,
    int correctCount,
    int wrongCount,
    Map<int, String> userAnswers,
    TestStatus status,
    String? errorMessage,
  });
}

/// @nodoc
class __$$TestStateImplCopyWithImpl<$Res>
    extends _$TestStateCopyWithImpl<$Res, _$TestStateImpl>
    implements _$$TestStateImplCopyWith<$Res> {
  __$$TestStateImplCopyWithImpl(
    _$TestStateImpl _value,
    $Res Function(_$TestStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TestState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? currentQuestionIndex = null,
    Object? timeLeft = null,
    Object? score = null,
    Object? correctCount = null,
    Object? wrongCount = null,
    Object? userAnswers = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$TestStateImpl(
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<QuestionModel>,
        currentQuestionIndex: null == currentQuestionIndex
            ? _value.currentQuestionIndex
            : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        timeLeft: null == timeLeft
            ? _value.timeLeft
            : timeLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        wrongCount: null == wrongCount
            ? _value.wrongCount
            : wrongCount // ignore: cast_nullable_to_non_nullable
                  as int,
        userAnswers: null == userAnswers
            ? _value._userAnswers
            : userAnswers // ignore: cast_nullable_to_non_nullable
                  as Map<int, String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TestStatus,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TestStateImpl extends _TestState {
  const _$TestStateImpl({
    final List<QuestionModel> questions = const [],
    this.currentQuestionIndex = 0,
    this.timeLeft = 60,
    this.score = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    final Map<int, String> userAnswers = const {},
    this.status = TestStatus.loading,
    this.errorMessage,
  }) : _questions = questions,
       _userAnswers = userAnswers,
       super._();

  final List<QuestionModel> _questions;
  @override
  @JsonKey()
  List<QuestionModel> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  @JsonKey()
  final int currentQuestionIndex;
  @override
  @JsonKey()
  final int timeLeft;
  @override
  @JsonKey()
  final int score;
  @override
  @JsonKey()
  final int correctCount;
  @override
  @JsonKey()
  final int wrongCount;
  final Map<int, String> _userAnswers;
  @override
  @JsonKey()
  Map<int, String> get userAnswers {
    if (_userAnswers is EqualUnmodifiableMapView) return _userAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_userAnswers);
  }

  @override
  @JsonKey()
  final TestStatus status;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'TestState(questions: $questions, currentQuestionIndex: $currentQuestionIndex, timeLeft: $timeLeft, score: $score, correctCount: $correctCount, wrongCount: $wrongCount, userAnswers: $userAnswers, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestStateImpl &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ) &&
            (identical(other.currentQuestionIndex, currentQuestionIndex) ||
                other.currentQuestionIndex == currentQuestionIndex) &&
            (identical(other.timeLeft, timeLeft) ||
                other.timeLeft == timeLeft) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.wrongCount, wrongCount) ||
                other.wrongCount == wrongCount) &&
            const DeepCollectionEquality().equals(
              other._userAnswers,
              _userAnswers,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_questions),
    currentQuestionIndex,
    timeLeft,
    score,
    correctCount,
    wrongCount,
    const DeepCollectionEquality().hash(_userAnswers),
    status,
    errorMessage,
  );

  /// Create a copy of TestState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestStateImplCopyWith<_$TestStateImpl> get copyWith =>
      __$$TestStateImplCopyWithImpl<_$TestStateImpl>(this, _$identity);
}

abstract class _TestState extends TestState {
  const factory _TestState({
    final List<QuestionModel> questions,
    final int currentQuestionIndex,
    final int timeLeft,
    final int score,
    final int correctCount,
    final int wrongCount,
    final Map<int, String> userAnswers,
    final TestStatus status,
    final String? errorMessage,
  }) = _$TestStateImpl;
  const _TestState._() : super._();

  @override
  List<QuestionModel> get questions;
  @override
  int get currentQuestionIndex;
  @override
  int get timeLeft;
  @override
  int get score;
  @override
  int get correctCount;
  @override
  int get wrongCount;
  @override
  Map<int, String> get userAnswers;
  @override
  TestStatus get status;
  @override
  String? get errorMessage;

  /// Create a copy of TestState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestStateImplCopyWith<_$TestStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
