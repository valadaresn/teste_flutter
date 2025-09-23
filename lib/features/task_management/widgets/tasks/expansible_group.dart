import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../themes/theme_provider.dart';
import '../../../../../widgets/common/cards/task_card.dart';

/// Enum para identificar os tipos de grupos de tarefas
enum TaskGroupType {
  today, // Tarefas com prazo para hoje
  overdue, // Tarefas atrasadas
  completed, // Tarefas concluídas recentemente
}

/// **ExpansibleTaskGroup** - Componente expansível para grupos de tarefas
///
/// Este componente exibe um grupo de tarefas em um container expansível,
/// seguindo o padrão visual mostrado nas referências do usuário
class ExpansibleGroup extends StatefulWidget {
  final String title;
  final IconData icon;
  final TaskController controller;
  final TaskGroupType taskType;
  final Color? iconColor;

  const ExpansibleGroup({
    Key? key,
    required this.title,
    required this.icon,
    required this.controller,
    required this.taskType,
    this.iconColor,
  }) : super(key: key);

  @override
  State<ExpansibleGroup> createState() => _ExpansibleGroupState();
}

class _ExpansibleGroupState extends State<ExpansibleGroup> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Grupo de concluídas inicia colapsado, outros expandidos
    _isExpanded = widget.taskType != TaskGroupType.completed;
  }

  @override
  Widget build(BuildContext context) {
    // Obter tarefas baseado no tipo
    List<Task> tasks = _getTasksByType();
    int count = tasks.length;

    // Se não há tarefas, não exibir o grupo
    if (count == 0) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        // Header expansível - minimalista
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Lista de tarefas - minimalista
        if (_isExpanded) ...[
          // Lista de tarefas sem padding excessivo
          Column(
            children:
                tasks.asMap().entries.map((entry) {
                  int index = entry.key;
                  Task task = entry.value;

                  return Column(
                    children: [
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          // Obter cor da lista selecionada
                          final selectedList =
                              widget.controller.selectedListId != null
                                  ? widget.controller.getListById(
                                    widget.controller.selectedListId!,
                                  )
                                  : null;
                          final listColor = selectedList?.color ?? Colors.blue;

                          return TaskCard(
                            title: task.title,
                            description:
                                task.description.isNotEmpty
                                    ? task.description
                                    : null,
                            listColor: listColor,
                            isSelected:
                                widget.controller.selectedTaskId == task.id,
                            onTap: () => widget.controller.selectTask(task.id),
                            // TODO: Implementar timer quando necessário
                            timerLabel: null,
                            isRunning: false,
                            onPlay: null,
                            onStop: null,
                          );
                        },
                      ),

                      // Divisor sutil entre itens (exceto o último)
                      if (index < tasks.length - 1)
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.2),
                        ),
                    ],
                  );
                }).toList(),
          ),
        ],
      ],
    );
  }

  /// Obter tarefas baseado no tipo do grupo
  List<Task> _getTasksByType() {
    switch (widget.taskType) {
      case TaskGroupType.today:
        return widget.controller.getTodayTasks();
      case TaskGroupType.overdue:
        return widget.controller.getOverdueTasks();
      case TaskGroupType.completed:
        return widget.controller.getCompletedTasks();
    }
  }
}
