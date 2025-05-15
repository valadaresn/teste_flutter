import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/task_filters.dart';
import '../../../services/pomodoro_service.dart';
import 'task_content.dart';
import 'task_actions.dart';
import 'pomodoro_controls.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(String) onToggleComplete;
  final Function(String) onDelete;
  final Function(String, bool) onTogglePomodoro;
  final PomodoroService pomodoroService;
  final DateFilter? activeFilter;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onTogglePomodoro,
    required this.pomodoroService,
    this.activeFilter,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Implementação do Dismissible para swipe para deletar
    return Dismissible(
      key: Key('dismissible-${widget.task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => widget.onDelete(widget.task.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Checkbox circular para marcar tarefa como concluída
                    Checkbox(
                      value: widget.task.isCompleted,
                      onChanged: (_) => widget.onToggleComplete(widget.task.id),
                      shape: const CircleBorder(),
                    ),

                    // Conteúdo principal da tarefa
                    TaskContent(
                      task: widget.task,
                      activeFilter: widget.activeFilter,
                    ),

                    // Adicionar os controles do pomodoro (restauração da seleção de tempo)
                    PomodoroControls(
                      task: widget.task,
                      pomodoroService: widget.pomodoroService,
                      onTogglePomodoro: widget.onTogglePomodoro,
                    ),

                    // Indicador de expansão
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),

              // Ações expandidas
              if (_isExpanded)
                TaskActions(
                  task: widget.task,
                  onDelete: () => widget.onDelete(widget.task.id),
                  onTogglePomodoro:
                      (start) => widget.onTogglePomodoro(widget.task.id, start),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
