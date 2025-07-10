import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_flutter/features/log_screen/widgets/log_filter_bar.dart';
import 'package:teste_flutter/features/log_screen/log_model.dart';

void main() {
  group('LogFilterBar Widget Tests', () {
    testWidgets('should build LogFilterBar widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogFilterBar(
              selectedPeriod: LogFilterPeriod.today,
              selectedStatus: LogFilterStatus.all,
              searchQuery: '',
              onPeriodChanged: (period) {},
              onStatusChanged: (status) {},
              onSearchChanged: (query) {},
            ),
          ),
        ),
      );

      expect(find.byType(LogFilterBar), findsOneWidget);
    });
  });
}
