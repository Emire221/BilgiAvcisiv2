// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_exam.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WeeklyExam {
  /// JSON'da weeklyExamId olarak gelir
  String get examId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get weekStart =>
      throw _privateConstructorUsedError; // Pazartesi tarihi (ISO 8601)
  int get duration => throw _privateConstructorUsedError; // Dakika cinsinden
  List<WeeklyExamQuestion> get questions => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyExam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyExamCopyWith<WeeklyExam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyExamCopyWith<$Res> {
  factory $WeeklyExamCopyWith(
    WeeklyExam value,
    $Res Function(WeeklyExam) then,
  ) = _$WeeklyExamCopyWithImpl<$Res, WeeklyExam>;
  @useResult
  $Res call({
    String examId,
    String title,
    String weekStart,
    int duration,
    List<WeeklyExamQuestion> questions,
    String? description,
  });
}

/// @nodoc
class _$WeeklyExamCopyWithImpl<$Res, $Val extends WeeklyExam>
    implements $WeeklyExamCopyWith<$Res> {
  _$WeeklyExamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyExam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? examId = null,
    Object? title = null,
    Object? weekStart = null,
    Object? duration = null,
    Object? questions = null,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            examId: null == examId
                ? _value.examId
                : examId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<WeeklyExamQuestion>,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklyExamImplCopyWith<$Res>
    implements $WeeklyExamCopyWith<$Res> {
  factory _$$WeeklyExamImplCopyWith(
    _$WeeklyExamImpl value,
    $Res Function(_$WeeklyExamImpl) then,
  ) = __$$WeeklyExamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String examId,
    String title,
    String weekStart,
    int duration,
    List<WeeklyExamQuestion> questions,
    String? description,
  });
}

/// @nodoc
class __$$WeeklyExamImplCopyWithImpl<$Res>
    extends _$WeeklyExamCopyWithImpl<$Res, _$WeeklyExamImpl>
    implements _$$WeeklyExamImplCopyWith<$Res> {
  __$$WeeklyExamImplCopyWithImpl(
    _$WeeklyExamImpl _value,
    $Res Function(_$WeeklyExamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyExam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? examId = null,
    Object? title = null,
    Object? weekStart = null,
    Object? duration = null,
    Object? questions = null,
    Object? description = freezed,
  }) {
    return _then(
      _$WeeklyExamImpl(
        examId: null == examId
            ? _value.examId
            : examId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<WeeklyExamQuestion>,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$WeeklyExamImpl implements _WeeklyExam {
  const _$WeeklyExamImpl({
    required this.examId,
    required this.title,
    required this.weekStart,
    required this.duration,
    required final List<WeeklyExamQuestion> questions,
    this.description,
  }) : _questions = questions;

  /// JSON'da weeklyExamId olarak gelir
  @override
  final String examId;
  @override
  final String title;
  @override
  final String weekStart;
  // Pazartesi tarihi (ISO 8601)
  @override
  final int duration;
  // Dakika cinsinden
  final List<WeeklyExamQuestion> _questions;
  // Dakika cinsinden
  @override
  List<WeeklyExamQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  final String? description;

  @override
  String toString() {
    return 'WeeklyExam(examId: $examId, title: $title, weekStart: $weekStart, duration: $duration, questions: $questions, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyExamImpl &&
            (identical(other.examId, examId) || other.examId == examId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    examId,
    title,
    weekStart,
    duration,
    const DeepCollectionEquality().hash(_questions),
    description,
  );

  /// Create a copy of WeeklyExam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyExamImplCopyWith<_$WeeklyExamImpl> get copyWith =>
      __$$WeeklyExamImplCopyWithImpl<_$WeeklyExamImpl>(this, _$identity);
}

abstract class _WeeklyExam implements WeeklyExam {
  const factory _WeeklyExam({
    required final String examId,
    required final String title,
    required final String weekStart,
    required final int duration,
    required final List<WeeklyExamQuestion> questions,
    final String? description,
  }) = _$WeeklyExamImpl;

  /// JSON'da weeklyExamId olarak gelir
  @override
  String get examId;
  @override
  String get title;
  @override
  String get weekStart; // Pazartesi tarihi (ISO 8601)
  @override
  int get duration; // Dakika cinsinden
  @override
  List<WeeklyExamQuestion> get questions;
  @override
  String? get description;

  /// Create a copy of WeeklyExam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyExamImplCopyWith<_$WeeklyExamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyExamQuestion _$WeeklyExamQuestionFromJson(Map<String, dynamic> json) {
  return _WeeklyExamQuestion.fromJson(json);
}

/// @nodoc
mixin _$WeeklyExamQuestion {
  String get questionId => throw _privateConstructorUsedError;
  String get questionText => throw _privateConstructorUsedError;
  String get optionA => throw _privateConstructorUsedError;
  String get optionB => throw _privateConstructorUsedError;
  String get optionC => throw _privateConstructorUsedError;
  String get optionD => throw _privateConstructorUsedError;
  String get correctAnswer =>
      throw _privateConstructorUsedError; // "A", "B", "C" veya "D"
  String? get topicId => throw _privateConstructorUsedError;
  String? get lessonName => throw _privateConstructorUsedError;

  /// Serializes this WeeklyExamQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyExamQuestionCopyWith<WeeklyExamQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyExamQuestionCopyWith<$Res> {
  factory $WeeklyExamQuestionCopyWith(
    WeeklyExamQuestion value,
    $Res Function(WeeklyExamQuestion) then,
  ) = _$WeeklyExamQuestionCopyWithImpl<$Res, WeeklyExamQuestion>;
  @useResult
  $Res call({
    String questionId,
    String questionText,
    String optionA,
    String optionB,
    String optionC,
    String optionD,
    String correctAnswer,
    String? topicId,
    String? lessonName,
  });
}

/// @nodoc
class _$WeeklyExamQuestionCopyWithImpl<$Res, $Val extends WeeklyExamQuestion>
    implements $WeeklyExamQuestionCopyWith<$Res> {
  _$WeeklyExamQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? questionText = null,
    Object? optionA = null,
    Object? optionB = null,
    Object? optionC = null,
    Object? optionD = null,
    Object? correctAnswer = null,
    Object? topicId = freezed,
    Object? lessonName = freezed,
  }) {
    return _then(
      _value.copyWith(
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String,
            questionText: null == questionText
                ? _value.questionText
                : questionText // ignore: cast_nullable_to_non_nullable
                      as String,
            optionA: null == optionA
                ? _value.optionA
                : optionA // ignore: cast_nullable_to_non_nullable
                      as String,
            optionB: null == optionB
                ? _value.optionB
                : optionB // ignore: cast_nullable_to_non_nullable
                      as String,
            optionC: null == optionC
                ? _value.optionC
                : optionC // ignore: cast_nullable_to_non_nullable
                      as String,
            optionD: null == optionD
                ? _value.optionD
                : optionD // ignore: cast_nullable_to_non_nullable
                      as String,
            correctAnswer: null == correctAnswer
                ? _value.correctAnswer
                : correctAnswer // ignore: cast_nullable_to_non_nullable
                      as String,
            topicId: freezed == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lessonName: freezed == lessonName
                ? _value.lessonName
                : lessonName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklyExamQuestionImplCopyWith<$Res>
    implements $WeeklyExamQuestionCopyWith<$Res> {
  factory _$$WeeklyExamQuestionImplCopyWith(
    _$WeeklyExamQuestionImpl value,
    $Res Function(_$WeeklyExamQuestionImpl) then,
  ) = __$$WeeklyExamQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String questionId,
    String questionText,
    String optionA,
    String optionB,
    String optionC,
    String optionD,
    String correctAnswer,
    String? topicId,
    String? lessonName,
  });
}

/// @nodoc
class __$$WeeklyExamQuestionImplCopyWithImpl<$Res>
    extends _$WeeklyExamQuestionCopyWithImpl<$Res, _$WeeklyExamQuestionImpl>
    implements _$$WeeklyExamQuestionImplCopyWith<$Res> {
  __$$WeeklyExamQuestionImplCopyWithImpl(
    _$WeeklyExamQuestionImpl _value,
    $Res Function(_$WeeklyExamQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? questionText = null,
    Object? optionA = null,
    Object? optionB = null,
    Object? optionC = null,
    Object? optionD = null,
    Object? correctAnswer = null,
    Object? topicId = freezed,
    Object? lessonName = freezed,
  }) {
    return _then(
      _$WeeklyExamQuestionImpl(
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionText: null == questionText
            ? _value.questionText
            : questionText // ignore: cast_nullable_to_non_nullable
                  as String,
        optionA: null == optionA
            ? _value.optionA
            : optionA // ignore: cast_nullable_to_non_nullable
                  as String,
        optionB: null == optionB
            ? _value.optionB
            : optionB // ignore: cast_nullable_to_non_nullable
                  as String,
        optionC: null == optionC
            ? _value.optionC
            : optionC // ignore: cast_nullable_to_non_nullable
                  as String,
        optionD: null == optionD
            ? _value.optionD
            : optionD // ignore: cast_nullable_to_non_nullable
                  as String,
        correctAnswer: null == correctAnswer
            ? _value.correctAnswer
            : correctAnswer // ignore: cast_nullable_to_non_nullable
                  as String,
        topicId: freezed == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lessonName: freezed == lessonName
            ? _value.lessonName
            : lessonName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyExamQuestionImpl implements _WeeklyExamQuestion {
  const _$WeeklyExamQuestionImpl({
    required this.questionId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.topicId,
    this.lessonName,
  });

  factory _$WeeklyExamQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyExamQuestionImplFromJson(json);

  @override
  final String questionId;
  @override
  final String questionText;
  @override
  final String optionA;
  @override
  final String optionB;
  @override
  final String optionC;
  @override
  final String optionD;
  @override
  final String correctAnswer;
  // "A", "B", "C" veya "D"
  @override
  final String? topicId;
  @override
  final String? lessonName;

  @override
  String toString() {
    return 'WeeklyExamQuestion(questionId: $questionId, questionText: $questionText, optionA: $optionA, optionB: $optionB, optionC: $optionC, optionD: $optionD, correctAnswer: $correctAnswer, topicId: $topicId, lessonName: $lessonName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyExamQuestionImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.optionA, optionA) || other.optionA == optionA) &&
            (identical(other.optionB, optionB) || other.optionB == optionB) &&
            (identical(other.optionC, optionC) || other.optionC == optionC) &&
            (identical(other.optionD, optionD) || other.optionD == optionD) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.lessonName, lessonName) ||
                other.lessonName == lessonName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionId,
    questionText,
    optionA,
    optionB,
    optionC,
    optionD,
    correctAnswer,
    topicId,
    lessonName,
  );

  /// Create a copy of WeeklyExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyExamQuestionImplCopyWith<_$WeeklyExamQuestionImpl> get copyWith =>
      __$$WeeklyExamQuestionImplCopyWithImpl<_$WeeklyExamQuestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyExamQuestionImplToJson(this);
  }
}

abstract class _WeeklyExamQuestion implements WeeklyExamQuestion {
  const factory _WeeklyExamQuestion({
    required final String questionId,
    required final String questionText,
    required final String optionA,
    required final String optionB,
    required final String optionC,
    required final String optionD,
    required final String correctAnswer,
    final String? topicId,
    final String? lessonName,
  }) = _$WeeklyExamQuestionImpl;

  factory _WeeklyExamQuestion.fromJson(Map<String, dynamic> json) =
      _$WeeklyExamQuestionImpl.fromJson;

  @override
  String get questionId;
  @override
  String get questionText;
  @override
  String get optionA;
  @override
  String get optionB;
  @override
  String get optionC;
  @override
  String get optionD;
  @override
  String get correctAnswer; // "A", "B", "C" veya "D"
  @override
  String? get topicId;
  @override
  String? get lessonName;

  /// Create a copy of WeeklyExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyExamQuestionImplCopyWith<_$WeeklyExamQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyExamResult _$WeeklyExamResultFromJson(Map<String, dynamic> json) {
  return _WeeklyExamResult.fromJson(json);
}

/// @nodoc
mixin _$WeeklyExamResult {
  int? get id => throw _privateConstructorUsedError;
  String get examId => throw _privateConstructorUsedError;
  String get odaId => throw _privateConstructorUsedError; // Sınav oturumu ID'si
  String get odaIsmi =>
      throw _privateConstructorUsedError; // "Hafta 45 - 2025" gibi
  String get odaBaslangic => throw _privateConstructorUsedError; // ISO 8601
  String get odaBitis =>
      throw _privateConstructorUsedError; // ISO 8601 (Çarşamba 23:59)
  String get sonucTarihi => throw _privateConstructorUsedError; // Pazar 12:00
  String get odaDurumu =>
      throw _privateConstructorUsedError; // "aktif", "kapali", "sonuclanmis"
  String get kullaniciId => throw _privateConstructorUsedError;
  Map<String, String> get cevaplar =>
      throw _privateConstructorUsedError; // {"1": "A", "2": "EMPTY"}
  int? get dogru => throw _privateConstructorUsedError;
  int? get yanlis => throw _privateConstructorUsedError;
  int? get bos => throw _privateConstructorUsedError;
  int? get puan => throw _privateConstructorUsedError;
  int? get siralama => throw _privateConstructorUsedError; // Türkiye sıralaması
  int? get toplamKatilimci => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this WeeklyExamResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyExamResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyExamResultCopyWith<WeeklyExamResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyExamResultCopyWith<$Res> {
  factory $WeeklyExamResultCopyWith(
    WeeklyExamResult value,
    $Res Function(WeeklyExamResult) then,
  ) = _$WeeklyExamResultCopyWithImpl<$Res, WeeklyExamResult>;
  @useResult
  $Res call({
    int? id,
    String examId,
    String odaId,
    String odaIsmi,
    String odaBaslangic,
    String odaBitis,
    String sonucTarihi,
    String odaDurumu,
    String kullaniciId,
    Map<String, String> cevaplar,
    int? dogru,
    int? yanlis,
    int? bos,
    int? puan,
    int? siralama,
    int? toplamKatilimci,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$WeeklyExamResultCopyWithImpl<$Res, $Val extends WeeklyExamResult>
    implements $WeeklyExamResultCopyWith<$Res> {
  _$WeeklyExamResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyExamResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? examId = null,
    Object? odaId = null,
    Object? odaIsmi = null,
    Object? odaBaslangic = null,
    Object? odaBitis = null,
    Object? sonucTarihi = null,
    Object? odaDurumu = null,
    Object? kullaniciId = null,
    Object? cevaplar = null,
    Object? dogru = freezed,
    Object? yanlis = freezed,
    Object? bos = freezed,
    Object? puan = freezed,
    Object? siralama = freezed,
    Object? toplamKatilimci = freezed,
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
            odaId: null == odaId
                ? _value.odaId
                : odaId // ignore: cast_nullable_to_non_nullable
                      as String,
            odaIsmi: null == odaIsmi
                ? _value.odaIsmi
                : odaIsmi // ignore: cast_nullable_to_non_nullable
                      as String,
            odaBaslangic: null == odaBaslangic
                ? _value.odaBaslangic
                : odaBaslangic // ignore: cast_nullable_to_non_nullable
                      as String,
            odaBitis: null == odaBitis
                ? _value.odaBitis
                : odaBitis // ignore: cast_nullable_to_non_nullable
                      as String,
            sonucTarihi: null == sonucTarihi
                ? _value.sonucTarihi
                : sonucTarihi // ignore: cast_nullable_to_non_nullable
                      as String,
            odaDurumu: null == odaDurumu
                ? _value.odaDurumu
                : odaDurumu // ignore: cast_nullable_to_non_nullable
                      as String,
            kullaniciId: null == kullaniciId
                ? _value.kullaniciId
                : kullaniciId // ignore: cast_nullable_to_non_nullable
                      as String,
            cevaplar: null == cevaplar
                ? _value.cevaplar
                : cevaplar // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            dogru: freezed == dogru
                ? _value.dogru
                : dogru // ignore: cast_nullable_to_non_nullable
                      as int?,
            yanlis: freezed == yanlis
                ? _value.yanlis
                : yanlis // ignore: cast_nullable_to_non_nullable
                      as int?,
            bos: freezed == bos
                ? _value.bos
                : bos // ignore: cast_nullable_to_non_nullable
                      as int?,
            puan: freezed == puan
                ? _value.puan
                : puan // ignore: cast_nullable_to_non_nullable
                      as int?,
            siralama: freezed == siralama
                ? _value.siralama
                : siralama // ignore: cast_nullable_to_non_nullable
                      as int?,
            toplamKatilimci: freezed == toplamKatilimci
                ? _value.toplamKatilimci
                : toplamKatilimci // ignore: cast_nullable_to_non_nullable
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
abstract class _$$WeeklyExamResultImplCopyWith<$Res>
    implements $WeeklyExamResultCopyWith<$Res> {
  factory _$$WeeklyExamResultImplCopyWith(
    _$WeeklyExamResultImpl value,
    $Res Function(_$WeeklyExamResultImpl) then,
  ) = __$$WeeklyExamResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String examId,
    String odaId,
    String odaIsmi,
    String odaBaslangic,
    String odaBitis,
    String sonucTarihi,
    String odaDurumu,
    String kullaniciId,
    Map<String, String> cevaplar,
    int? dogru,
    int? yanlis,
    int? bos,
    int? puan,
    int? siralama,
    int? toplamKatilimci,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$WeeklyExamResultImplCopyWithImpl<$Res>
    extends _$WeeklyExamResultCopyWithImpl<$Res, _$WeeklyExamResultImpl>
    implements _$$WeeklyExamResultImplCopyWith<$Res> {
  __$$WeeklyExamResultImplCopyWithImpl(
    _$WeeklyExamResultImpl _value,
    $Res Function(_$WeeklyExamResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyExamResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? examId = null,
    Object? odaId = null,
    Object? odaIsmi = null,
    Object? odaBaslangic = null,
    Object? odaBitis = null,
    Object? sonucTarihi = null,
    Object? odaDurumu = null,
    Object? kullaniciId = null,
    Object? cevaplar = null,
    Object? dogru = freezed,
    Object? yanlis = freezed,
    Object? bos = freezed,
    Object? puan = freezed,
    Object? siralama = freezed,
    Object? toplamKatilimci = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$WeeklyExamResultImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        examId: null == examId
            ? _value.examId
            : examId // ignore: cast_nullable_to_non_nullable
                  as String,
        odaId: null == odaId
            ? _value.odaId
            : odaId // ignore: cast_nullable_to_non_nullable
                  as String,
        odaIsmi: null == odaIsmi
            ? _value.odaIsmi
            : odaIsmi // ignore: cast_nullable_to_non_nullable
                  as String,
        odaBaslangic: null == odaBaslangic
            ? _value.odaBaslangic
            : odaBaslangic // ignore: cast_nullable_to_non_nullable
                  as String,
        odaBitis: null == odaBitis
            ? _value.odaBitis
            : odaBitis // ignore: cast_nullable_to_non_nullable
                  as String,
        sonucTarihi: null == sonucTarihi
            ? _value.sonucTarihi
            : sonucTarihi // ignore: cast_nullable_to_non_nullable
                  as String,
        odaDurumu: null == odaDurumu
            ? _value.odaDurumu
            : odaDurumu // ignore: cast_nullable_to_non_nullable
                  as String,
        kullaniciId: null == kullaniciId
            ? _value.kullaniciId
            : kullaniciId // ignore: cast_nullable_to_non_nullable
                  as String,
        cevaplar: null == cevaplar
            ? _value._cevaplar
            : cevaplar // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        dogru: freezed == dogru
            ? _value.dogru
            : dogru // ignore: cast_nullable_to_non_nullable
                  as int?,
        yanlis: freezed == yanlis
            ? _value.yanlis
            : yanlis // ignore: cast_nullable_to_non_nullable
                  as int?,
        bos: freezed == bos
            ? _value.bos
            : bos // ignore: cast_nullable_to_non_nullable
                  as int?,
        puan: freezed == puan
            ? _value.puan
            : puan // ignore: cast_nullable_to_non_nullable
                  as int?,
        siralama: freezed == siralama
            ? _value.siralama
            : siralama // ignore: cast_nullable_to_non_nullable
                  as int?,
        toplamKatilimci: freezed == toplamKatilimci
            ? _value.toplamKatilimci
            : toplamKatilimci // ignore: cast_nullable_to_non_nullable
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
class _$WeeklyExamResultImpl implements _WeeklyExamResult {
  const _$WeeklyExamResultImpl({
    this.id,
    required this.examId,
    required this.odaId,
    required this.odaIsmi,
    required this.odaBaslangic,
    required this.odaBitis,
    required this.sonucTarihi,
    required this.odaDurumu,
    required this.kullaniciId,
    required final Map<String, String> cevaplar,
    this.dogru,
    this.yanlis,
    this.bos,
    this.puan,
    this.siralama,
    this.toplamKatilimci,
    this.completedAt,
  }) : _cevaplar = cevaplar;

  factory _$WeeklyExamResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyExamResultImplFromJson(json);

  @override
  final int? id;
  @override
  final String examId;
  @override
  final String odaId;
  // Sınav oturumu ID'si
  @override
  final String odaIsmi;
  // "Hafta 45 - 2025" gibi
  @override
  final String odaBaslangic;
  // ISO 8601
  @override
  final String odaBitis;
  // ISO 8601 (Çarşamba 23:59)
  @override
  final String sonucTarihi;
  // Pazar 12:00
  @override
  final String odaDurumu;
  // "aktif", "kapali", "sonuclanmis"
  @override
  final String kullaniciId;
  final Map<String, String> _cevaplar;
  @override
  Map<String, String> get cevaplar {
    if (_cevaplar is EqualUnmodifiableMapView) return _cevaplar;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cevaplar);
  }

  // {"1": "A", "2": "EMPTY"}
  @override
  final int? dogru;
  @override
  final int? yanlis;
  @override
  final int? bos;
  @override
  final int? puan;
  @override
  final int? siralama;
  // Türkiye sıralaması
  @override
  final int? toplamKatilimci;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'WeeklyExamResult(id: $id, examId: $examId, odaId: $odaId, odaIsmi: $odaIsmi, odaBaslangic: $odaBaslangic, odaBitis: $odaBitis, sonucTarihi: $sonucTarihi, odaDurumu: $odaDurumu, kullaniciId: $kullaniciId, cevaplar: $cevaplar, dogru: $dogru, yanlis: $yanlis, bos: $bos, puan: $puan, siralama: $siralama, toplamKatilimci: $toplamKatilimci, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyExamResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.examId, examId) || other.examId == examId) &&
            (identical(other.odaId, odaId) || other.odaId == odaId) &&
            (identical(other.odaIsmi, odaIsmi) || other.odaIsmi == odaIsmi) &&
            (identical(other.odaBaslangic, odaBaslangic) ||
                other.odaBaslangic == odaBaslangic) &&
            (identical(other.odaBitis, odaBitis) ||
                other.odaBitis == odaBitis) &&
            (identical(other.sonucTarihi, sonucTarihi) ||
                other.sonucTarihi == sonucTarihi) &&
            (identical(other.odaDurumu, odaDurumu) ||
                other.odaDurumu == odaDurumu) &&
            (identical(other.kullaniciId, kullaniciId) ||
                other.kullaniciId == kullaniciId) &&
            const DeepCollectionEquality().equals(other._cevaplar, _cevaplar) &&
            (identical(other.dogru, dogru) || other.dogru == dogru) &&
            (identical(other.yanlis, yanlis) || other.yanlis == yanlis) &&
            (identical(other.bos, bos) || other.bos == bos) &&
            (identical(other.puan, puan) || other.puan == puan) &&
            (identical(other.siralama, siralama) ||
                other.siralama == siralama) &&
            (identical(other.toplamKatilimci, toplamKatilimci) ||
                other.toplamKatilimci == toplamKatilimci) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    examId,
    odaId,
    odaIsmi,
    odaBaslangic,
    odaBitis,
    sonucTarihi,
    odaDurumu,
    kullaniciId,
    const DeepCollectionEquality().hash(_cevaplar),
    dogru,
    yanlis,
    bos,
    puan,
    siralama,
    toplamKatilimci,
    completedAt,
  );

  /// Create a copy of WeeklyExamResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyExamResultImplCopyWith<_$WeeklyExamResultImpl> get copyWith =>
      __$$WeeklyExamResultImplCopyWithImpl<_$WeeklyExamResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyExamResultImplToJson(this);
  }
}

abstract class _WeeklyExamResult implements WeeklyExamResult {
  const factory _WeeklyExamResult({
    final int? id,
    required final String examId,
    required final String odaId,
    required final String odaIsmi,
    required final String odaBaslangic,
    required final String odaBitis,
    required final String sonucTarihi,
    required final String odaDurumu,
    required final String kullaniciId,
    required final Map<String, String> cevaplar,
    final int? dogru,
    final int? yanlis,
    final int? bos,
    final int? puan,
    final int? siralama,
    final int? toplamKatilimci,
    final DateTime? completedAt,
  }) = _$WeeklyExamResultImpl;

  factory _WeeklyExamResult.fromJson(Map<String, dynamic> json) =
      _$WeeklyExamResultImpl.fromJson;

  @override
  int? get id;
  @override
  String get examId;
  @override
  String get odaId; // Sınav oturumu ID'si
  @override
  String get odaIsmi; // "Hafta 45 - 2025" gibi
  @override
  String get odaBaslangic; // ISO 8601
  @override
  String get odaBitis; // ISO 8601 (Çarşamba 23:59)
  @override
  String get sonucTarihi; // Pazar 12:00
  @override
  String get odaDurumu; // "aktif", "kapali", "sonuclanmis"
  @override
  String get kullaniciId;
  @override
  Map<String, String> get cevaplar; // {"1": "A", "2": "EMPTY"}
  @override
  int? get dogru;
  @override
  int? get yanlis;
  @override
  int? get bos;
  @override
  int? get puan;
  @override
  int? get siralama; // Türkiye sıralaması
  @override
  int? get toplamKatilimci;
  @override
  DateTime? get completedAt;

  /// Create a copy of WeeklyExamResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyExamResultImplCopyWith<_$WeeklyExamResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
