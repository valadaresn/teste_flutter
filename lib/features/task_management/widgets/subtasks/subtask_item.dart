import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../../log_screen/controllers/log_controller.dart';
import 'subtask_edit_dialog.dart';

class SubtaskItem extends StatelessWidget {
  final Task subtask;
  final TaskController controller;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubtaskItem({
    Key? key,
    required this.subtask,
    required this.controller,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LogController>(
      builder: (context, logController, child) {
        final isBeingLogged = logController.isTaskBeingLogged(subtask.id);
        final elapsedTime = logController.getElapsedTimeFormatted(subtask.id);

        return GestureDetector(
          onSecondaryTap: () => _showContextMenu(context),
          onLongPress: () => _showContextMenu(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    subtask.isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: subtask.isCompleted,
                    onChanged: (_) => onToggleComplete(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Conteúdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        subtask.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration:
                              subtask.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                          color:
                              subtask.isCompleted
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6)
                                  : null,
                        ),
                      ),

                      // Descrição (se houver)
                      if (subtask.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtask.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                            decoration:
                                subtask.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Informações extras + tempo decorrido
                      if (_hasExtraInfo() ||
                          isBeingLogged ||
                          subtask.accumulatedTimeSeconds > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (_hasExtraInfo())
                              Expanded(child: _buildExtraInfo(context)),

                            // Mostra tempo se estiver ativo OU se tiver tempo acumulado
                            if ((isBeingLogged && elapsedTime != null) ||
                                subtask.accumulatedTimeSeconds > 0) ...[
                              if (_hasExtraInfo()) const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isBeingLogged
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        isBeingLogged
                                            ? Colors.green.withOpacity(0.5)
                                            : Colors.grey.withOpacity(0.5),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isBeingLogged
                                          ? Icons.timer
                                          : Icons.access_time,
                                      size: 10,
                                      color:
                                          isBeingLogged
                                              ? Colors.green.shade700
                                              : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      isBeingLogged && elapsedTime != null
                                          ? elapsedTime
                                          : _formatAccumulatedTime(
                                            subtask.accumulatedTimeSeconds,
                                          ),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isBeingLogged
                                                ? Colors.green.shade700
                                                : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Botão play/pause
                _buildPlayButton(context, logController),

                const SizedBox(width: 4),

                // Botão editar
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: onEdit,
                  tooltip: 'Editar subtarefa',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton(BuildContext context, LogController logController) {
    final isBeingLogged = logController.isTaskBeingLogged(subtask.id);
    final isPaused = logController.isPomodoroPaused(subtask.id);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color:
            isBeingLogged
                ? (isPaused ? Colors.orange : Colors.green)
                : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(
          isBeingLogged
              ? (isPaused ? Icons.play_arrow : Icons.pause)
              : Icons.play_arrow,
          color: Colors.white,
          size: 16,
        ),
        onPressed: () => _handlePlayPause(context, logController),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        tooltip: isBeingLogged ? (isPaused ? 'Retomar' : 'Pausar') : 'Iniciar',
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + renderBox.size.width,
        position.dy + renderBox.size.height,
      ),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _editSubtask(context);
      } else if (value == 'delete') {
        onDelete();
      }
    });
  }

  Future<void> _handlePlayPause(
    BuildContext context,
    LogController logController,
  ) async {
    try {
      final taskList = controller.getListById(subtask.listId);
      final isLogged = logController.isTaskBeingLogged(subtask.id);

      if (!isLogged) {
        // Iniciar log
        await logController.startTaskLog(subtask, taskList: taskList);
      } else {
        final isPaused = logController.isPomodoroPaused(subtask.id);

        if (isPaused) {
          // Retomar
          await logController.resumeTaskLog(subtask.id);
        } else {
          // Pausar
          await logController.pauseTaskLog(subtask.id);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    }
  }

  bool _hasExtraInfo() {
    return subtask.dueDate != null ||
        subtask.priority != TaskPriority.medium ||
        subtask.isImportant;
  }

  Widget _buildExtraInfo(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 2,
      children: [
        // Prioridade (se não for média)
        if (subtask.priority != TaskPriority.medium)
          _buildPriorityChip(context),

        // Data de prazo
        if (subtask.dueDate != null) _buildDueDateChip(context),

        // Importante
        if (subtask.isImportant) _buildImportantChip(context),
      ],
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: subtask.priorityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: subtask.priorityColor.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        subtask.priorityLabel,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: subtask.priorityColor,
        ),
      ),
    );
  }

  Widget _buildDueDateChip(BuildContext context) {
    final isOverdue = subtask.isOverdue;
    final isDueToday = subtask.isDueToday;

    Color chipColor;
    IconData icon;

    if (isOverdue) {
      chipColor = Colors.red;
      icon = Icons.schedule;
    } else if (isDueToday) {
      chipColor = Colors.orange;
      icon = Icons.today;
    } else {
      chipColor = Theme.of(context).colorScheme.primary;
      icon = Icons.calendar_today;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: chipColor.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: chipColor),
          const SizedBox(width: 2),
          Text(
            _formatDueDate(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 0.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 10, color: Colors.amber),
          SizedBox(width: 2),
          Text(
            'Importante',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDueDate() {
    if (subtask.dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      subtask.dueDate!.year,
      subtask.dueDate!.month,
      subtask.dueDate!.day,
    );

    if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Amanhã';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else {
      return '${subtask.dueDate!.day}/${subtask.dueDate!.month}';
    }
  }

  String _formatAccumulatedTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  void _editSubtask(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) =>
              SubtaskEditDialog(subtask: subtask, controller: controller),
    );
  }
}
