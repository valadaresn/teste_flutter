import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../controllers/task_controller.dart';
import '../../common/quick_date_selector.dart';
import '../../common/quick_pomodoro_selector.dart';
import '../../common/quick_list_selector.dart';

/// **TaskFooter** - Rodapé do painel de detalhes da tarefa
///
/// Componente que exibe controles de data, pomodoro, lista, diário e exclusão
class TaskFooter extends StatelessWidget {
  final Task task;
  final TaskController taskController;
  final Function(DateTime?) onDateChanged;
  final Function(int?) onPomodoroTimeChanged;
  final Function(String?) onListChanged;
  final VoidCallback onDeleteTask;
  final VoidCallback onToggleDiary;
  final bool isDiaryExpanded;

  const TaskFooter({
    Key? key,
    required this.task,
    required this.taskController,
    required this.onDateChanged,
    required this.onPomodoroTimeChanged,
    required this.onListChanged,
    required this.onDeleteTask,
    required this.onToggleDiary,
    required this.isDiaryExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // 1. Seletor de listas
          Expanded(
            child: QuickListSelector(
              selectedListId: task.listId,
              controller: taskController,
              onListChanged: (listId) => onListChanged(listId),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Seletor de data
          Expanded(
            child: QuickDateSelector(
              selectedDate: task.dueDate,
              onDateChanged: onDateChanged,
            ),
          ),

          const SizedBox(width: 8),

          // 3. Seletor de pomodoro
          Expanded(
            child: QuickPomodoroSelector(
              pomodoroTime: task.pomodoroTimeMinutes,
              onTimeChanged: (time) => onPomodoroTimeChanged(time),
            ),
          ),

          const SizedBox(width: 8),

          // 4. Botão diário
          IconButton(
            icon: Icon(
              isDiaryExpanded ? Icons.book : Icons.book_outlined,
              color: isDiaryExpanded ? Colors.blue : Colors.grey.shade600,
            ),
            onPressed: onToggleDiary,
            tooltip: 'Diário da tarefa',
          ),

          const SizedBox(width: 8),

          // 5. Botão deletar
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red.shade400),
            onPressed: onDeleteTask,
            tooltip: 'Excluir tarefa',
          ),
        ],
      ),
    );
  }
}
