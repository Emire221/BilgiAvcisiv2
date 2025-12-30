import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_model.freezed.dart';
part 'flashcard_model.g.dart';

@freezed
class FlashcardModel with _$FlashcardModel {
  const factory FlashcardModel({
    required String kartID,
    required String onyuz,
    required bool dogruMu,
  }) = _FlashcardModel;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);
}

@freezed
class FlashcardSetModel with _$FlashcardSetModel {
  const factory FlashcardSetModel({
    required String kartSetID,
    required String konuID,
    required String kartAdi,
    @Default([]) List<FlashcardModel> kartlar,
  }) = _FlashcardSetModel;

  factory FlashcardSetModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardSetModelFromJson(json);
}
