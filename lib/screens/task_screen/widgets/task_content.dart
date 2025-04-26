import 'package:flutter/material.dart';
import '../../../models/task.dart';

/// Widget responsável por exibir o conteúdo da tarefa (título e descrição)
class TaskContent extends StatelessWidget {
  final Task task;

  const TaskContent({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            if (task.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  task.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            if (task.selectedPomodoroLabel != null && !task.isPomodoroActive)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Tempo: ${task.selectedPomodoroLabel}',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
