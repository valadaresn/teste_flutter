import 'package:flutter/material.dart';
import '../../../models/task.dart';

class TaskActions extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final Function(bool) onTogglePomodoro;

  const TaskActions({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onTogglePomodoro,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botão de excluir
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),

          // Botão para iniciar/parar pomodoro
          TextButton.icon(
            onPressed: () => onTogglePomodoro(!task.isPomodoroActive),
            icon: Icon(
              task.isPomodoroActive ? Icons.timer_off : Icons.timer,
              color: task.isPomodoroActive ? Colors.grey : Colors.green,
            ),
            label: Text(
              task.isPomodoroActive ? 'Parar pomodoro' : 'Iniciar pomodoro',
              style: TextStyle(
                color: task.isPomodoroActive ? Colors.grey : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
