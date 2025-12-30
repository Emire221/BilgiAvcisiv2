import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_model.dart';

part 'test_model.freezed.dart';
part 'test_model.g.dart';

@freezed
class TestModel with _$TestModel {
  const factory TestModel({
    required String testID,
    required String konuID,
    required String testAdi,
    @Default(1) int zorluk,
    @Default('') String cozumVideoURL,
    @Default([]) List<QuestionModel> sorular,
  }) = _TestModel;

  factory TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);
}
