import 'package:flutter_test/flutter_test.dart';
import 'package:bilgici/features/test/controller/test_controller.dart';
import 'package:bilgici/features/test/models/test_state.dart';
import 'package:bilgici/models/question_model.dart';
import 'package:bilgici/repositories/test_repository.dart';
import 'package:bilgici/models/test_model.dart';

class MockTestRepository implements TestRepository {
  @override
  Future<List<TestModel>> getTests(
    String grade,
    String lessonName,
    String topicId,
  ) async {
    return [];
  }

  @override
  Future<void> saveTestResult(
    String testId,
    int score,
    int correct,
    int wrong,
  ) async {
    // Mock save
  }
}

void main() {
  late TestController controller;
  late MockTestRepository mockRepository;

  setUp(() {
    mockRepository = MockTestRepository();
    controller = TestController(mockRepository);
  });

  tearDown(() {
    controller.dispose();
  });

  group('TestController Tests', () {
    test('initial state should be correct', () {
      expect(controller.state, const TestState());
    });

    test('initializeTest should set correct state', () {
      final questions = [
        const QuestionModel(
          soruMetni: 'Soru 1',
          secenekler: ['A', 'B', 'C', 'D'],
          dogruCevap: 'A',
        ),
      ];

      controller.initializeTest(questions);

      expect(controller.state.status, TestStatus.active);
      expect(controller.state.questions.length, 1);
      expect(controller.state.currentQuestionIndex, 0);
    });

    test('answerQuestion should update score correctly', () {
      final questions = [
        const QuestionModel(
          soruMetni: 'Soru 1',
          secenekler: ['A', 'B', 'C', 'D'],
          dogruCevap: 'A',
        ),
      ];

      controller.initializeTest(questions);
      controller.answerQuestion('A');

      expect(controller.state.score, 10); // Assuming 10 points per question
      expect(controller.state.correctCount, 1);
    });
  });
}
