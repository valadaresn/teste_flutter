import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/project.dart';
import '../../../models/task_filters.dart';
import '../../../services/pomodoro_service.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final PomodoroService pomodoroService;
  final Function(String) onToggleComplete;
  final Function(String) onDelete;
  final Function(String, bool) onTogglePomodoro;
  final Function(Task)? onTaskUpdated;
  final List<Project>? projects;
  final DateFilter? activeFilter;

  const TaskList({
    super.key,
    required this.tasks,
    required this.pomodoroService,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onTogglePomodoro,
    this.onTaskUpdated,
    this.projects,
    this.activeFilter,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // Resolve problema de altura indefinida
      physics:
          NeverScrollableScrollPhysics(), // Desativa o scroll dentro de outro scrollable
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
        top: 4,
      ), // Reduzindo o padding superior
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
            onTaskUpdated: onTaskUpdated,
            projects: projects,
            activeFilter:
                activeFilter, // Passando o filtro ativo para o TaskCard
          ),
        );
      },
    );
  }
}
