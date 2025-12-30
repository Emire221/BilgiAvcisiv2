import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilgici/widgets/common/test_timer_display.dart';

void main() {
  group('TestTimerDisplay Widget Tests', () {
    testWidgets('should display time in seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestTimerDisplay(timeLeft: 45))),
      );

      expect(find.text('45 sn'), findsOneWidget);
    });

    testWidgets('should display timer icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestTimerDisplay(timeLeft: 30))),
      );

      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('should update when time changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestTimerDisplay(timeLeft: 60))),
      );

      expect(find.text('60 sn'), findsOneWidget);

      // Widget'ı güncelle
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TestTimerDisplay(timeLeft: 59))),
      );

      expect(find.text('59 sn'), findsOneWidget);
      expect(find.text('60 sn'), findsNothing);
    });
  });
}
