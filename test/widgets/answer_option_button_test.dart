import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilgici/widgets/common/answer_option_button.dart';

void main() {
  group('AnswerOptionButton Widget Tests', () {
    testWidgets('should display option text and label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerOptionButton(optionText: '4', label: 'A', onTap: () {}),
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('should trigger onTap when tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerOptionButton(
              optionText: 'Test Answer',
              label: 'B',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnswerOptionButton));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('should display label in circle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerOptionButton(
              optionText: 'Answer',
              label: 'C',
              onTap: () {},
            ),
          ),
        ),
      );

      // Label bulunmalı
      expect(find.text('C'), findsOneWidget);

      // Container circle shape'de olmalı
      final container = tester.widget<Container>(
        find
            .ancestor(of: find.text('C'), matching: find.byType(Container))
            .first,
      );

      expect((container.decoration as BoxDecoration).shape, BoxShape.circle);
    });
  });
}
