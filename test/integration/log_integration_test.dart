import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:teste_flutter/features/log_screen/controllers/log_controller.dart';
import 'package:teste_flutter/features/log_screen/widgets/active_log_indicator.dart';
import 'package:teste_flutter/features/log_screen/widgets/timer_display.dart';

void main() {
  group('Log Integration Tests', () {
    late LogController logController;

    setUp(() {
      logController = LogController();
    });

    tearDown(() {
      logController.dispose();
    });

    testWidgets('should display active log indicator correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LogController>(
            create: (_) => logController,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Test'),
                actions: [
                  Consumer<LogController>(
                    builder: (context, controller, child) {
                      return ActiveLogIndicator(
                        onTap: () {
                          // Navigate to logs screen
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ActiveLogIndicator), findsOneWidget);
    });

    testWidgets('should display timer display widget correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerDisplay(formattedTime: '05:30', isActive: true),
          ),
        ),
      );

      expect(find.text('05:30'), findsOneWidget);
      expect(find.byType(TimerDisplay), findsOneWidget);
    });

    testWidgets('should handle provider state changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LogController>(
            create: (_) => logController,
            child: Scaffold(
              body: Consumer<LogController>(
                builder: (context, controller, child) {
                  return Column(
                    children: [
                      Text('Active Logs: ${controller.activeLogs.length}'),
                      Text('Total Logs: ${controller.logs.length}'),
                      if (controller.isLoading) CircularProgressIndicator(),
                      if (controller.error != null)
                        Text('Error: ${controller.error}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Active Logs: 0'), findsOneWidget);
      expect(find.text('Total Logs: 0'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display multiple timer displays', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TimerDisplay(formattedTime: '01:30', isActive: true),
                TimerDisplay(formattedTime: '02:45', isActive: false),
                TimerDisplay(formattedTime: '00:15', isActive: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('01:30'), findsOneWidget);
      expect(find.text('02:45'), findsOneWidget);
      expect(find.text('00:15'), findsOneWidget);
      expect(find.byType(TimerDisplay), findsNWidgets(3));
    });

    testWidgets('should handle empty state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LogController>(
            create: (_) => logController,
            child: Scaffold(
              body: Consumer<LogController>(
                builder: (context, controller, child) {
                  if (controller.logs.isEmpty) {
                    return Center(child: Text('No logs available'));
                  }
                  return ListView.builder(
                    itemCount: controller.logs.length,
                    itemBuilder: (context, index) {
                      final log = controller.logs[index];
                      return ListTile(
                        title: Text(log.entityTitle),
                        subtitle: Text(log.entityType),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('No logs available'), findsOneWidget);
    });

    testWidgets('should format time correctly in integration', (
      WidgetTester tester,
    ) async {
      // Test time formatting utility
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TimerDisplay(
                  formattedTime: formatTime(90), // 1:30
                  isActive: true,
                ),
                TimerDisplay(
                  formattedTime: formatTime(3665), // 1:01:05
                  isActive: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('01:30'), findsOneWidget);
      expect(find.text('1:01:05'), findsOneWidget);
    });

    testWidgets('should handle widget rebuilds correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LogController>(
            create: (_) => logController,
            child: Scaffold(
              body: Consumer<LogController>(
                builder: (context, controller, child) {
                  return Column(
                    children: [
                      Text('Loading: ${controller.isLoading}'),
                      Text('Error: ${controller.error ?? 'None'}'),
                      Text('Active Logs: ${controller.activeLogs.length}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('Error: None'), findsOneWidget);
      expect(find.text('Active Logs: 0'), findsOneWidget);

      // Trigger rebuild
      await tester.pump();

      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('Error: None'), findsOneWidget);
      expect(find.text('Active Logs: 0'), findsOneWidget);
    });

    testWidgets('should handle navigation and state correctly', (
      WidgetTester tester,
    ) async {
      bool navigated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LogController>(
            create: (_) => logController,
            child: Scaffold(
              appBar: AppBar(
                actions: [
                  Consumer<LogController>(
                    builder: (context, controller, child) {
                      return ActiveLogIndicator(
                        onTap: () {
                          navigated = true;
                        },
                      );
                    },
                  ),
                ],
              ),
              body: Text('Main Content'),
            ),
          ),
        ),
      );

      // Find and tap the active log indicator
      final indicator = find.byType(ActiveLogIndicator);
      expect(indicator, findsOneWidget);

      await tester.tap(indicator);
      await tester.pump();

      expect(navigated, true);
    });

    testWidgets('should handle multiple provider updates', (
      WidgetTester tester,
    ) async {
      final controller1 = LogController();
      final controller2 = LogController();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<LogController>.value(value: controller1),
              ChangeNotifierProvider<LogController>.value(value: controller2),
            ],
            child: Scaffold(
              body: Consumer2<LogController, LogController>(
                builder: (context, ctrl1, ctrl2, child) {
                  return Column(
                    children: [
                      Text('Controller 1 Logs: ${ctrl1.logs.length}'),
                      Text('Controller 2 Logs: ${ctrl2.logs.length}'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Controller 1 Logs: 0'), findsOneWidget);
      expect(find.text('Controller 2 Logs: 0'), findsOneWidget);

      // Dispose controllers
      controller1.dispose();
      controller2.dispose();
    });
  });
}
