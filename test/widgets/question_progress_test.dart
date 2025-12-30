import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilgici/widgets/common/question_progress.dart';

void main() {
  group('QuestionProgress Widget Tests', () {
    testWidgets('should display current and total questions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuestionProgress(currentIndex: 2, totalQuestions: 10),
          ),
        ),
      );

      // Index 0-based olduğu için 2+1=3 gösterilmeli
      expect(find.text('3/10'), findsOneWidget);
    });

    testWidgets('should show 1/5 for first question', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuestionProgress(currentIndex: 0, totalQuestions: 5),
          ),
        ),
      );

      expect(find.text('1/5'), findsOneWidget);
    });

    testWidgets('should update when index changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuestionProgress(currentIndex: 0, totalQuestions: 3),
          ),
        ),
      );

      expect(find.text('1/3'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuestionProgress(currentIndex: 2, totalQuestions: 3),
          ),
        ),
      );

      expect(find.text('3/3'), findsOneWidget);
    });
  });
}
