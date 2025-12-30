import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String soruMetni,
    @Default([]) List<String> secenekler,
    required String dogruCevap,
    String? cozumMetni,
    String? resimURL,
    String? aciklama, // ✨ Cevap sonrası gösterilecek açıklama metni
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}
