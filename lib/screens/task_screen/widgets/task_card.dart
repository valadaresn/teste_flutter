import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/project.dart';
import '../../../models/task_filters.dart';
import '../../../services/pomodoro_service.dart';
import '../../task_screen/task_edit_screen.dart';
import 'task_content.dart';
import 'pomodoro_controls.dart';

/// Widget principal que representa um card de tarefa,
/// agora delegando responsabilidades para sub-componentes
class TaskCard extends StatelessWidget {
  final Task task;
  final PomodoroService pomodoroService;
  final Function(String) onToggleComplete;
  final Function(String, bool) onTogglePomodoro;
  final Function(Task)? onTaskUpdated;
  final List<Project>? projects;
  final DateFilter? activeFilter;

  const TaskCard({
    super.key,
    required this.task,
    required this.pomodoroService,
    required this.onToggleComplete,
    required this.onTogglePomodoro,
    this.onTaskUpdated,
    this.projects,
    this.activeFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Se temos os projetos e a função de callback,
          // navegamos para a tela de edição
          if (projects != null && onTaskUpdated != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TaskEditScreen(
                      task: task,
                      projects: projects!,
                      onTaskUpdated: onTaskUpdated!,
                    ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox de completar tarefa
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggleComplete(task.id),
                  shape: const CircleBorder(),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              // Conteúdo da tarefa (título e descrição)
              TaskContent(task: task, activeFilter: activeFilter),

              // Controles do pomodoro (timer e botões)
              PomodoroControls(
                task: task,
                pomodoroService: pomodoroService,
                onTogglePomodoro: onTogglePomodoro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
