import '../models/test_model.dart';

abstract class TestRepository {
  Future<List<TestModel>> getTests(
    String grade,
    String lessonName,
    String topicId,
  );
  Future<void> saveTestResult(String testId, int score, int correct, int wrong);
}
