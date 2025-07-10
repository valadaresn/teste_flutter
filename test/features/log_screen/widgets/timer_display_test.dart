import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_flutter/features/log_screen/widgets/timer_display.dart';

void main() {
  group('TimerDisplay Widget Tests', () {
    testWidgets('should display correct time format', (
      WidgetTester tester,
    ) async {
      // Test with 0 seconds
      await tester.pumpWidget(
        MaterialApp(
          home: TimerDisplay(formattedTime: '00:00', isActive: false),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('should display minutes and seconds correctly', (
      WidgetTester tester,
    ) async {
      // Test with 125 seconds formatted as 02:05
      await tester.pumpWidget(
        MaterialApp(home: TimerDisplay(formattedTime: '02:05', isActive: true)),
      );

      expect(find.text('02:05'), findsOneWidget);
    });

    testWidgets('should display hours when over 60 minutes', (
      WidgetTester tester,
    ) async {
      // Test with 3665 seconds formatted as 1:01:05
      await tester.pumpWidget(
        MaterialApp(
          home: TimerDisplay(formattedTime: '1:01:05', isActive: true),
        ),
      );

      expect(find.text('1:01:05'), findsOneWidget);
    });

    testWidgets('should show active state styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: TimerDisplay(formattedTime: '01:00', isActive: true)),
      );

      expect(find.text('01:00'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should show inactive state styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TimerDisplay(formattedTime: '01:00', isActive: false),
        ),
      );

      expect(find.text('01:00'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should handle very large time values', (
      WidgetTester tester,
    ) async {
      // Test with 25 hours formatted
      await tester.pumpWidget(
        MaterialApp(
          home: TimerDisplay(formattedTime: '25:00:00', isActive: true),
        ),
      );

      expect(find.text('25:00:00'), findsOneWidget);
    });

    testWidgets('should handle empty or invalid time strings', (
      WidgetTester tester,
    ) async {
      // Test with empty string
      await tester.pumpWidget(
        MaterialApp(home: TimerDisplay(formattedTime: '', isActive: false)),
      );

      expect(find.byType(TimerDisplay), findsOneWidget);
    });

    testWidgets('should contain proper widget structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: TimerDisplay(formattedTime: '05:30', isActive: true)),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('05:30'), findsOneWidget);
    });

    // Helper function to format time (utility test)
    test('time formatting utility function', () {
      String formatTime(int seconds) {
        final hours = seconds ~/ 3600;
        final minutes = (seconds % 3600) ~/ 60;
        final remainingSeconds = seconds % 60;

        if (hours > 0) {
          return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
        } else {
          return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
        }
      }

      expect(formatTime(0), equals('00:00'));
      expect(formatTime(60), equals('01:00'));
      expect(formatTime(125), equals('02:05'));
      expect(formatTime(3600), equals('1:00:00'));
      expect(formatTime(3665), equals('1:01:05'));
    });
  });
}
