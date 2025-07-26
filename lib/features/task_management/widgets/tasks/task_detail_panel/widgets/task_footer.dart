import 'package:flutter/material.dart';
import '../../../../controllers/task_controller.dart';
import '../../../../models/task_model.dart';
import '../../quick_date_selector.dart';
import '../../quick_pomodoro_selector.dart';
import '../../quick_list_selector.dart';

/// **TaskFooter** - Rodapé com seletores e opções
///
/// Componente independente que contém os seletores de data,
/// pomodoro, lista, diário e o botão de delete
class TaskFooter extends StatelessWidget {
  final Task task;
  final TaskController taskController;
  final Function(DateTime?) onDateChanged;
  final Function(int) onPomodoroTimeChanged;
  final Function(String) onListChanged;
  final VoidCallback? onDeleteTask;
  final VoidCallback? onToggleDiary;
  final bool isDiaryExpanded;

  const TaskFooter({
    Key? key,
    required this.task,
    required this.taskController,
    required this.onDateChanged,
    required this.onPomodoroTimeChanged,
    required this.onListChanged,
    this.onDeleteTask,
    this.onToggleDiary,
    this.isDiaryExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          // Botão de delete (lado esquerdo)
          if (onDeleteTask != null)
            IconButton(
              onPressed: onDeleteTask,
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red.shade600,
              ),
              splashRadius: 20,
            ),

          const SizedBox(width: 8),

          // Seletor de lista
          QuickListSelector(
            selectedListId: task.listId,
            controller: taskController,
            onListChanged: onListChanged,
          ),

          const Spacer(),

          // Seletores rápidos
          Row(
            children: [
              // Seletor de data
              QuickDateSelector(
                selectedDate: task.dueDate,
                onDateChanged: onDateChanged,
              ),

              const SizedBox(width: 12),

              // Seletor de pomodoro
              QuickPomodoroSelector(
                pomodoroTime: task.pomodoroTimeMinutes,
                onTimeChanged: onPomodoroTimeChanged,
              ),

              const SizedBox(width: 12),

              // Botão de diário
              if (onToggleDiary != null)
                GestureDetector(
                  onTap: onToggleDiary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isDiaryExpanded ? Icons.book : Icons.book_outlined,
                      size: 16,
                      color: isDiaryExpanded ? Colors.blue.shade600 : Colors.grey.shade500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
