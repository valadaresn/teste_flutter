import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/task_filters.dart';

/// Widget responsável por exibir o conteúdo da tarefa (título e descrição)
class TaskContent extends StatelessWidget {
  final Task task;
  final DateFilter? activeFilter;

  const TaskContent({super.key, required this.task, this.activeFilter});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    bool isToday = false;
    bool isTomorrow = false;
    bool isOverdue = false;

    if (task.dueDate != null) {
      final dueDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      isToday = dueDate.isAtSameMomentAs(today);
      isTomorrow = dueDate.isAtSameMomentAs(tomorrow);
      isOverdue = dueDate.isBefore(today);
    }

    // Formatar data quando não for hoje/amanhã/atrasada
    String getFormattedDate() {
      final day = task.dueDate!.day.toString().padLeft(2, '0');
      final month = task.dueDate!.month.toString().padLeft(2, '0');
      final year = task.dueDate!.year.toString();
      return '$day/$month/$year';
    }

    // Determinar se deve mostrar o indicador de data
    bool shouldShowDateIndicator() {
      if (task.dueDate == null) return false;

      // Se não tem filtro ativo ou o filtro é "todas", sempre mostra
      if (activeFilter == null || activeFilter == DateFilter.all) return true;

      // Se tem um filtro específico ativo, não mostra o indicador correspondente
      if ((activeFilter == DateFilter.today && isToday) ||
          (activeFilter == DateFilter.tomorrow && isTomorrow)) {
        return false;
      }

      // Em outros casos (como tarefa de outro dia em um filtro específico), mostra
      return true;
    }

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
            if (task.dueDate != null && shouldShowDateIndicator())
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color:
                          isOverdue && !task.isCompleted
                              ? Colors.red
                              : isToday
                              ? Colors.green
                              : isTomorrow
                              ? Colors.orange
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isToday
                          ? 'Hoje'
                          : isTomorrow
                          ? 'Amanhã'
                          : isOverdue
                          ? 'Atrasada'
                          : getFormattedDate(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            isOverdue && !task.isCompleted
                                ? Colors.red
                                : isToday
                                ? Colors.green
                                : isTomorrow
                                ? Colors.orange
                                : Colors.grey[600],
                      ),
                    ),
                  ],
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
