import 'package:flutter_test/flutter_test.dart';
import 'package:teste_flutter/features/log_screen/log_model.dart';

void main() {
  group('Log Model Tests', () {
    test('should create log with required fields', () {
      final log = Log(
        id: 'test_id',
        entityId: 'task_123',
        entityType: 'task',
        entityTitle: 'Test Task',
        startTime: DateTime.now(),
        listId: 'list_123',
        listTitle: 'Test List',
        tags: ['work', 'urgent'],
        metrics: {'focus_score': 85},
      );

      expect(log.id, equals('test_id'));
      expect(log.entityId, equals('task_123'));
      expect(log.entityType, equals('task'));
      expect(log.entityTitle, equals('Test Task'));
      expect(log.listId, equals('list_123'));
      expect(log.listTitle, equals('Test List'));
      expect(log.tags, equals(['work', 'urgent']));
      expect(log.metrics['focus_score'], equals(85));
      expect(log.endTime, isNull);
      expect(log.durationMinutes, isNull);
    });

    test('should create completed log with end time and duration', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(minutes: 30));

      final log = Log(
        id: 'test_id_2',
        entityId: 'task_456',
        entityType: 'task',
        entityTitle: 'Completed Task',
        startTime: startTime,
        endTime: endTime,
        durationMinutes: 30,
        listId: 'list_456',
        listTitle: 'Test List 2',
        tags: ['completed'],
        metrics: {'efficiency': 90},
      );

      expect(log.endTime, equals(endTime));
      expect(log.durationMinutes, equals(30));
    });

    test('should handle empty tags and metrics', () {
      final log = Log(
        id: 'test_id_5',
        entityId: 'task_131415',
        entityType: 'task',
        entityTitle: 'Empty Fields Test',
        startTime: DateTime.now(),
        listId: 'list_131415',
        listTitle: 'Test List 5',
        tags: [],
        metrics: {},
      );

      expect(log.tags, isEmpty);
      expect(log.metrics, isEmpty);
    });

    test('should handle different entity types', () {
      final habitLog = Log(
        id: 'habit_log_1',
        entityId: 'habit_123',
        entityType: 'habit',
        entityTitle: 'Morning Exercise',
        startTime: DateTime.now(),
        listId: 'habit_list_1',
        listTitle: 'Daily Habits',
        tags: ['health', 'morning'],
        metrics: {'consistency': 100},
      );

      expect(habitLog.entityType, equals('habit'));
      expect(habitLog.entityTitle, equals('Morning Exercise'));
    });

    test('should handle duration calculations', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(minutes: 45));
      final durationMinutes = endTime.difference(startTime).inMinutes;

      final log = Log(
        id: 'duration_test',
        entityId: 'task_duration',
        entityType: 'task',
        entityTitle: 'Duration Test',
        startTime: startTime,
        endTime: endTime,
        durationMinutes: durationMinutes,
        listId: 'list_duration',
        listTitle: 'Duration List',
        tags: ['test'],
        metrics: {'duration': durationMinutes},
      );

      expect(log.durationMinutes, equals(45));
      expect(log.metrics['duration'], equals(45));
    });

    test('should create log with complex metrics', () {
      final log = Log(
        id: 'complex_metrics',
        entityId: 'task_complex',
        entityType: 'task',
        entityTitle: 'Complex Metrics Task',
        startTime: DateTime.now(),
        listId: 'list_complex',
        listTitle: 'Complex List',
        tags: ['complex', 'metrics'],
        metrics: {
          'focus_score': 85,
          'interruptions': 3,
          'quality_rating': 4.5,
          'energy_level': 'high',
          'satisfaction': true,
        },
      );

      expect(log.metrics['focus_score'], equals(85));
      expect(log.metrics['interruptions'], equals(3));
      expect(log.metrics['quality_rating'], equals(4.5));
      expect(log.metrics['energy_level'], equals('high'));
      expect(log.metrics['satisfaction'], equals(true));
    });

    test('should handle tag operations', () {
      final log = Log(
        id: 'tag_test',
        entityId: 'task_tags',
        entityType: 'task',
        entityTitle: 'Tag Test Task',
        startTime: DateTime.now(),
        listId: 'list_tags',
        listTitle: 'Tag List',
        tags: ['work', 'urgent', 'important', 'project-a'],
        metrics: {},
      );

      expect(log.tags, hasLength(4));
      expect(log.tags, contains('work'));
      expect(log.tags, contains('urgent'));
      expect(log.tags, contains('important'));
      expect(log.tags, contains('project-a'));
    });

    test('should handle time-based properties', () {
      final now = DateTime.now();
      final log = Log(
        id: 'time_test',
        entityId: 'task_time',
        entityType: 'task',
        entityTitle: 'Time Test Task',
        startTime: now,
        listId: 'list_time',
        listTitle: 'Time List',
        tags: ['time'],
        metrics: {'created_at': now.toIso8601String()},
      );

      expect(log.startTime, equals(now));
      expect(log.endTime, isNull);
      expect(log.metrics['created_at'], equals(now.toIso8601String()));
    });
  });
}
