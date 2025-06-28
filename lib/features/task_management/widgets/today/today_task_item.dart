import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../models/list_model.dart';

/// **TodayTaskItem** - Item de tarefa para a visualização Hoje
///
/// Este componente exibe uma tarefa individual seguindo o padrão:
/// [Checkbox] [Ícone da Lista] [Título da Tarefa] [Info de prazo]
class TodayTaskItem extends StatelessWidget {
  final Task task;
  final TaskController controller;

  const TodayTaskItem({Key? key, required this.task, required this.controller})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Encontrar a lista à qual a tarefa pertence
    TaskList? list = controller.getListById(task.listId);

    return GestureDetector(
      onTap: () => controller.navigateToTask(task.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        child: Row(
          children: [
            // Checkbox simples
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (value) => _toggleTaskCompletion(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),

            // Ícone da lista - apenas emoji simples
            if (list != null) ...[
              Text(list.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            ],

            // Título da tarefa
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                  color:
                      task.isCompleted
                          ? Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6)
                          : Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle do estado de conclusão da tarefa
  void _toggleTaskCompletion() {
    controller.toggleTaskCompletion(task.id);
  }
}
