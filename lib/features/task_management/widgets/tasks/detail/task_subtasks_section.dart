import 'package:flutter/material.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';
import 'clean_subtask_item.dart';

/// **TaskSubtasksSection** - Seção completa de subtarefas
///
/// Componente independente que gerencia a lista de subtarefas
/// e o campo para adicionar novas subtarefas
class TaskSubtasksSection extends StatelessWidget {
  final List<Task> subtasks;
  final Map<String, TextEditingController> subtaskControllers;
  final TaskController taskController;
  final Function(Task) onToggleComplete;
  final Function(String) onDelete;
  final Function(String) onSubtaskChanged;
  final TextEditingController newSubtaskController;
  final VoidCallback onAddSubtask;

  const TaskSubtasksSection({
    Key? key,
    required this.subtasks,
    required this.subtaskControllers,
    required this.taskController,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onSubtaskChanged,
    required this.newSubtaskController,
    required this.onAddSubtask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista de subtarefas existentes
        ...subtasks.map((subtask) => _buildSubtaskItem(subtask)),

        // Campo para nova subtarefa
        _NewSubtaskField(
          controller: newSubtaskController,
          onAddSubtask: onAddSubtask,
        ),

        const SizedBox(height: 16),

        // Divisor sutil
        Container(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildSubtaskItem(Task subtask) {
    final controller = subtaskControllers[subtask.id];
    if (controller == null) return const SizedBox.shrink();

    return CleanSubtaskItem(
      subtask: subtask,
      taskController: taskController,
      textController: controller,
      onToggleComplete: () => onToggleComplete(subtask),
      onDelete: () => onDelete(subtask.id),
      onTitleChanged: (subtaskId) => onSubtaskChanged(subtaskId),
    );
  }
}

/// Campo para nova subtarefa
class _NewSubtaskField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddSubtask;

  const _NewSubtaskField({
    required this.controller,
    required this.onAddSubtask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Ícone de adicionar
          Icon(Icons.add, size: 20, color: Colors.grey.shade600),

          const SizedBox(width: 12),

          // Campo de texto
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: 'Adicionar etapa',
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => onAddSubtask(),
            ),
          ),
        ],
      ),
    );
  }
}
