// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trial_exam.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrialExam _$TrialExamFromJson(Map<String, dynamic> json) {
  return _TrialExam.fromJson(json);
}

/// @nodoc
mixin _$TrialExam {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError; // Dakika cinsinden
  List<ExamQuestion> get questions => throw _privateConstructorUsedError;

  /// Serializes this TrialExam to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrialExam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrialExamCopyWith<TrialExam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrialExamCopyWith<$Res> {
  factory $TrialExamCopyWith(TrialExam value, $Res Function(TrialExam) then) =
      _$TrialExamCopyWithImpl<$Res, TrialExam>;
  @useResult
  $Res call({
    String id,
    String title,
    DateTime startDate,
    DateTime endDate,
    int duration,
    List<ExamQuestion> questions,
  });
}

/// @nodoc
class _$TrialExamCopyWithImpl<$Res, $Val extends TrialExam>
    implements $TrialExamCopyWith<$Res> {
  _$TrialExamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrialExam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? duration = null,
    Object? questions = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<ExamQuestion>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrialExamImplCopyWith<$Res>
    implements $TrialExamCopyWith<$Res> {
  factory _$$TrialExamImplCopyWith(
    _$TrialExamImpl value,
    $Res Function(_$TrialExamImpl) then,
  ) = __$$TrialExamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    DateTime startDate,
    DateTime endDate,
    int duration,
    List<ExamQuestion> questions,
  });
}

/// @nodoc
class __$$TrialExamImplCopyWithImpl<$Res>
    extends _$TrialExamCopyWithImpl<$Res, _$TrialExamImpl>
    implements _$$TrialExamImplCopyWith<$Res> {
  __$$TrialExamImplCopyWithImpl(
    _$TrialExamImpl _value,
    $Res Function(_$TrialExamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrialExam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? duration = null,
    Object? questions = null,
  }) {
    return _then(
      _$TrialExamImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<ExamQuestion>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrialExamImpl implements _TrialExam {
  const _$TrialExamImpl({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required final List<ExamQuestion> questions,
  }) : _questions = questions;

  factory _$TrialExamImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrialExamImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int duration;
  // Dakika cinsinden
  final List<ExamQuestion> _questions;
  // Dakika cinsinden
  @override
  List<ExamQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  String toString() {
    return 'TrialExam(id: $id, title: $title, startDate: $startDate, endDate: $endDate, duration: $duration, questions: $questions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrialExamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    startDate,
    endDate,
    duration,
    const DeepCollectionEquality().hash(_questions),
  );

  /// Create a copy of TrialExam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrialExamImplCopyWith<_$TrialExamImpl> get copyWith =>
      __$$TrialExamImplCopyWithImpl<_$TrialExamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrialExamImplToJson(this);
  }
}

abstract class _TrialExam implements TrialExam {
  const factory _TrialExam({
    required final String id,
    required final String title,
    required final DateTime startDate,
    required final DateTime endDate,
    required final int duration,
    required final List<ExamQuestion> questions,
  }) = _$TrialExamImpl;

  factory _TrialExam.fromJson(Map<String, dynamic> json) =
      _$TrialExamImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get duration; // Dakika cinsinden
  @override
  List<ExamQuestion> get questions;

  /// Create a copy of TrialExam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrialExamImplCopyWith<_$TrialExamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamQuestion _$ExamQuestionFromJson(Map<String, dynamic> json) {
  return _ExamQuestion.fromJson(json);
}

/// @nodoc
mixin _$ExamQuestion {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  List<String> get options =>
      throw _privateConstructorUsedError; // A, B, C, D şıkları
  String get correctAnswer =>
      throw _privateConstructorUsedError; // "A", "B", "C" veya "D"
  String get topicId => throw _privateConstructorUsedError;

  /// Serializes this ExamQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamQuestionCopyWith<ExamQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamQuestionCopyWith<$Res> {
  factory $ExamQuestionCopyWith(
    ExamQuestion value,
    $Res Function(ExamQuestion) then,
  ) = _$ExamQuestionCopyWithImpl<$Res, ExamQuestion>;
  @useResult
  $Res call({
    String id,
    String text,
    List<String> options,
    String correctAnswer,
    String topicId,
  });
}

/// @nodoc
class _$ExamQuestionCopyWithImpl<$Res, $Val extends ExamQuestion>
    implements $ExamQuestionCopyWith<$Res> {
  _$ExamQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? topicId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctAnswer: null == correctAnswer
                ? _value.correctAnswer
                : correctAnswer // ignore: cast_nullable_to_non_nullable
                      as String,
            topicId: null == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamQuestionImplCopyWith<$Res>
    implements $ExamQuestionCopyWith<$Res> {
  factory _$$ExamQuestionImplCopyWith(
    _$ExamQuestionImpl value,
    $Res Function(_$ExamQuestionImpl) then,
  ) = __$$ExamQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String text,
    List<String> options,
    String correctAnswer,
    String topicId,
  });
}

/// @nodoc
class __$$ExamQuestionImplCopyWithImpl<$Res>
    extends _$ExamQuestionCopyWithImpl<$Res, _$ExamQuestionImpl>
    implements _$$ExamQuestionImplCopyWith<$Res> {
  __$$ExamQuestionImplCopyWithImpl(
    _$ExamQuestionImpl _value,
    $Res Function(_$ExamQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? topicId = null,
  }) {
    return _then(
      _$ExamQuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctAnswer: null == correctAnswer
            ? _value.correctAnswer
            : correctAnswer // ignore: cast_nullable_to_non_nullable
                  as String,
        topicId: null == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamQuestionImpl implements _ExamQuestion {
  const _$ExamQuestionImpl({
    required this.id,
    required this.text,
    required final List<String> options,
    required this.correctAnswer,
    required this.topicId,
  }) : _options = options;

  factory _$ExamQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamQuestionImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  // A, B, C, D şıkları
  @override
  final String correctAnswer;
  // "A", "B", "C" veya "D"
  @override
  final String topicId;

  @override
  String toString() {
    return 'ExamQuestion(id: $id, text: $text, options: $options, correctAnswer: $correctAnswer, topicId: $topicId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.topicId, topicId) || other.topicId == topicId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    text,
    const DeepCollectionEquality().hash(_options),
    correctAnswer,
    topicId,
  );

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamQuestionImplCopyWith<_$ExamQuestionImpl> get copyWith =>
      __$$ExamQuestionImplCopyWithImpl<_$ExamQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamQuestionImplToJson(this);
  }
}

abstract class _ExamQuestion implements ExamQuestion {
  const factory _ExamQuestion({
    required final String id,
    required final String text,
    required final List<String> options,
    required final String correctAnswer,
    required final String topicId,
  }) = _$ExamQuestionImpl;

  factory _ExamQuestion.fromJson(Map<String, dynamic> json) =
      _$ExamQuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  List<String> get options; // A, B, C, D şıkları
  @override
  String get correctAnswer; // "A", "B", "C" veya "D"
  @override
  String get topicId;

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamQuestionImplCopyWith<_$ExamQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrialResult _$TrialResultFromJson(Map<String, dynamic> json) {
  return _TrialResult.fromJson(json);
}

/// @nodoc
mixin _$TrialResult {
  int? get id => throw _privateConstructorUsedError;
  String get examId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  Map<String, String> get rawAnswers =>
      throw _privateConstructorUsedError; // {"1": "A", "2": "EMPTY", "3": "C"}
  int? get score => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this TrialResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrialResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrialResultCopyWith<TrialResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrialResultCopyWith<$Res> {
  factory $TrialResultCopyWith(
    TrialResult value,
    $Res Function(TrialResult) then,
  ) = _$TrialResultCopyWithImpl<$Res, TrialResult>;
  @useResult
  $Res call({
    int? id,
    String examId,
    String userId,
    Map<String, String> rawAnswers,
    int? score,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$TrialResultCopyWithImpl<$Res, $Val extends TrialResult>
    implements $TrialResultCopyWith<$Res> {
  _$TrialResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrialResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? examId = null,
    Object? userId = null,
    Object? rawAnswers = null,
    Object? score = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            examId: null == examId
                ? _value.examId
                : examId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            rawAnswers: null == rawAnswers
                ? _value.rawAnswers
                : rawAnswers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrialResultImplCopyWith<$Res>
    implements $TrialResultCopyWith<$Res> {
  factory _$$TrialResultImplCopyWith(
    _$TrialResultImpl value,
    $Res Function(_$TrialResultImpl) then,
  ) = __$$TrialResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String examId,
    String userId,
    Map<String, String> rawAnswers,
    int? score,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$TrialResultImplCopyWithImpl<$Res>
    extends _$TrialResultCopyWithImpl<$Res, _$TrialResultImpl>
    implements _$$TrialResultImplCopyWith<$Res> {
  __$$TrialResultImplCopyWithImpl(
    _$TrialResultImpl _value,
    $Res Function(_$TrialResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrialResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? examId = null,
    Object? userId = null,
    Object? rawAnswers = null,
    Object? score = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$TrialResultImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        examId: null == examId
            ? _value.examId
            : examId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        rawAnswers: null == rawAnswers
            ? _value._rawAnswers
            : rawAnswers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrialResultImpl implements _TrialResult {
  const _$TrialResultImpl({
    this.id,
    required this.examId,
    required this.userId,
    required final Map<String, String> rawAnswers,
    this.score,
    this.completedAt,
  }) : _rawAnswers = rawAnswers;

  factory _$TrialResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrialResultImplFromJson(json);

  @override
  final int? id;
  @override
  final String examId;
  @override
  final String userId;
  final Map<String, String> _rawAnswers;
  @override
  Map<String, String> get rawAnswers {
    if (_rawAnswers is EqualUnmodifiableMapView) return _rawAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rawAnswers);
  }

  // {"1": "A", "2": "EMPTY", "3": "C"}
  @override
  final int? score;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'TrialResult(id: $id, examId: $examId, userId: $userId, rawAnswers: $rawAnswers, score: $score, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrialResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.examId, examId) || other.examId == examId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(
              other._rawAnswers,
              _rawAnswers,
            ) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    examId,
    userId,
    const DeepCollectionEquality().hash(_rawAnswers),
    score,
    completedAt,
  );

  /// Create a copy of TrialResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrialResultImplCopyWith<_$TrialResultImpl> get copyWith =>
      __$$TrialResultImplCopyWithImpl<_$TrialResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrialResultImplToJson(this);
  }
}

abstract class _TrialResult implements TrialResult {
  const factory _TrialResult({
    final int? id,
    required final String examId,
    required final String userId,
    required final Map<String, String> rawAnswers,
    final int? score,
    final DateTime? completedAt,
  }) = _$TrialResultImpl;

  factory _TrialResult.fromJson(Map<String, dynamic> json) =
      _$TrialResultImpl.fromJson;

  @override
  int? get id;
  @override
  String get examId;
  @override
  String get userId;
  @override
  Map<String, String> get rawAnswers; // {"1": "A", "2": "EMPTY", "3": "C"}
  @override
  int? get score;
  @override
  DateTime? get completedAt;

  /// Create a copy of TrialResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrialResultImplCopyWith<_$TrialResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExamState {
  bool get isLoading => throw _privateConstructorUsedError;
  int get currentQuestionIndex => throw _privateConstructorUsedError;
  Map<String, String> get answers => throw _privateConstructorUsedError;
  int get remainingSeconds => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of ExamState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamStateCopyWith<ExamState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamStateCopyWith<$Res> {
  factory $ExamStateCopyWith(ExamState value, $Res Function(ExamState) then) =
      _$ExamStateCopyWithImpl<$Res, ExamState>;
  @useResult
  $Res call({
    bool isLoading,
    int currentQuestionIndex,
    Map<String, String> answers,
    int remainingSeconds,
    String? error,
  });
}

/// @nodoc
class _$ExamStateCopyWithImpl<$Res, $Val extends ExamState>
    implements $ExamStateCopyWith<$Res> {
  _$ExamStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? currentQuestionIndex = null,
    Object? answers = null,
    Object? remainingSeconds = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentQuestionIndex: null == currentQuestionIndex
                ? _value.currentQuestionIndex
                : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            answers: null == answers
                ? _value.answers
                : answers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            remainingSeconds: null == remainingSeconds
                ? _value.remainingSeconds
                : remainingSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamStateImplCopyWith<$Res>
    implements $ExamStateCopyWith<$Res> {
  factory _$$ExamStateImplCopyWith(
    _$ExamStateImpl value,
    $Res Function(_$ExamStateImpl) then,
  ) = __$$ExamStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    int currentQuestionIndex,
    Map<String, String> answers,
    int remainingSeconds,
    String? error,
  });
}

/// @nodoc
class __$$ExamStateImplCopyWithImpl<$Res>
    extends _$ExamStateCopyWithImpl<$Res, _$ExamStateImpl>
    implements _$$ExamStateImplCopyWith<$Res> {
  __$$ExamStateImplCopyWithImpl(
    _$ExamStateImpl _value,
    $Res Function(_$ExamStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? currentQuestionIndex = null,
    Object? answers = null,
    Object? remainingSeconds = null,
    Object? error = freezed,
  }) {
    return _then(
      _$ExamStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentQuestionIndex: null == currentQuestionIndex
            ? _value.currentQuestionIndex
            : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        answers: null == answers
            ? _value._answers
            : answers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        remainingSeconds: null == remainingSeconds
            ? _value.remainingSeconds
            : remainingSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ExamStateImpl implements _ExamState {
  const _$ExamStateImpl({
    this.isLoading = false,
    this.currentQuestionIndex = 0,
    final Map<String, String> answers = const {},
    this.remainingSeconds = 0,
    this.error,
  }) : _answers = answers;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final int currentQuestionIndex;
  final Map<String, String> _answers;
  @override
  @JsonKey()
  Map<String, String> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  @JsonKey()
  final int remainingSeconds;
  @override
  final String? error;

  @override
  String toString() {
    return 'ExamState(isLoading: $isLoading, currentQuestionIndex: $currentQuestionIndex, answers: $answers, remainingSeconds: $remainingSeconds, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.currentQuestionIndex, currentQuestionIndex) ||
                other.currentQuestionIndex == currentQuestionIndex) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    currentQuestionIndex,
    const DeepCollectionEquality().hash(_answers),
    remainingSeconds,
    error,
  );

  /// Create a copy of ExamState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamStateImplCopyWith<_$ExamStateImpl> get copyWith =>
      __$$ExamStateImplCopyWithImpl<_$ExamStateImpl>(this, _$identity);
}

abstract class _ExamState implements ExamState {
  const factory _ExamState({
    final bool isLoading,
    final int currentQuestionIndex,
    final Map<String, String> answers,
    final int remainingSeconds,
    final String? error,
  }) = _$ExamStateImpl;

  @override
  bool get isLoading;
  @override
  int get currentQuestionIndex;
  @override
  Map<String, String> get answers;
  @override
  int get remainingSeconds;
  @override
  String? get error;

  /// Create a copy of ExamState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamStateImplCopyWith<_$ExamStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
