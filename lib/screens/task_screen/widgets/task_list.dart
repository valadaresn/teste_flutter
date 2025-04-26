import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../services/pomodoro_service.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final PomodoroService pomodoroService;
  final Function(String) onToggleComplete;
  final Function(String) onDelete;
  final Function(String, bool) onTogglePomodoro;

  const TaskList({
    super.key,
    required this.tasks,
    required this.pomodoroService,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onTogglePomodoro,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: Key(task.id),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(task.id),
          child: TaskCard(
            task: task,
            pomodoroService: pomodoroService,
            onToggleComplete: onToggleComplete,
            onTogglePomodoro: onTogglePomodoro,
          ),
        );
      },
    );
  }
}
