import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilgici/widgets/common/question_card.dart';

void main() {
  group('QuestionCard Widget Tests', () {
    testWidgets('should display question text', (WidgetTester tester) async {
      const questionText = 'Test sorusu: 2+2=?';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: QuestionCard(questionText: questionText)),
        ),
      );

      expect(find.text(questionText), findsOneWidget);
    });

    testWidgets('should have correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: QuestionCard(questionText: 'Test')),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test'));
      expect(textWidget.style?.fontSize, 20);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.white);
    });
  });
}
