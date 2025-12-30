import '../models/flashcard_model.dart';

abstract class FlashcardRepository {
  Future<List<FlashcardSetModel>> getFlashcards(
    String grade,
    String lessonName,
    String topicId,
  );
}
