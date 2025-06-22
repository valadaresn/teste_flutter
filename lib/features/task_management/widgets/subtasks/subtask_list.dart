import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import 'subtask_item.dart';

class SubtaskList extends StatelessWidget {
  final Task parentTask;
  final TaskController controller;

  const SubtaskList({
    Key? key,
    required this.parentTask,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtasks = controller.getSubtasks(parentTask.id);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com botão adicionar
          Row(
            children: [
              Text(
                'Subtarefas (${subtasks.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddSubtaskDialog(context),
                tooltip: 'Adicionar subtarefa',
              ),
            ],
          ),          const SizedBox(height: 12),

          // Progresso das subtarefas
          if (subtasks.isNotEmpty) ...[
            _buildProgressIndicator(subtasks, context),
            const SizedBox(height: 16),
          ],

          // Lista de subtarefas
          Expanded(
            child: subtasks.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    itemCount: subtasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final subtask = subtasks[index];
                      return SubtaskItem(
                        subtask: subtask,
                        controller: controller,
                        onToggleComplete: () => controller.toggleTaskCompletion(subtask.id),
                        onEdit: () => _editSubtask(context, subtask),
                        onDelete: () => _deleteSubtask(context, subtask),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(List<Task> subtasks, BuildContext context) {
    final completedCount = subtasks.where((task) => task.isCompleted).length;
    final progress = completedCount / subtasks.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$completedCount de ${subtasks.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(
              progress == 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma subtarefa',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione subtarefas para dividir esta tarefa em etapas menores',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddSubtaskDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Subtarefa'),
          ),
        ],
      ),
    );
  }

  void _showAddSubtaskDialog(BuildContext context) {
    String title = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Subtarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => title = value,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título da subtarefa',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => description = value,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Digite uma descrição',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.trim().isNotEmpty) {
                _createSubtask(title.trim(), description.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _createSubtask(String title, String description) {
    final formData = {
      'title': title,
      'description': description,
      'listId': parentTask.listId,
      'parentTaskId': parentTask.id,
      'priority': TaskPriority.medium,
      'tags': <String>[],
      'sortOrder': 0,
      'isImportant': false,
    };

    controller.addTask(formData);
  }

  void _editSubtask(BuildContext context, Task subtask) {
    String title = subtask.title;
    String description = subtask.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Subtarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: title),
              onChanged: (value) => title = value,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: description),
              onChanged: (value) => description = value,
              decoration: const InputDecoration(
                labelText: 'Descrição',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.trim().isNotEmpty) {
                final formData = {
                  'title': title.trim(),
                  'description': description.trim(),
                  'priority': subtask.priority,
                  'dueDate': subtask.dueDate,
                  'tags': subtask.tags,
                  'isImportant': subtask.isImportant,
                  'notes': subtask.notes,
                };
                controller.updateTask(subtask.id, formData);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _deleteSubtask(BuildContext context, Task subtask) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a subtarefa "${subtask.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              controller.deleteTask(subtask.id);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
