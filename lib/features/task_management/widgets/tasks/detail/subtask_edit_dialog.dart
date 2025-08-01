import 'package:flutter/material.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';

class SubtaskEditDialog extends StatefulWidget {
  final Task subtask;
  final TaskController controller;

  const SubtaskEditDialog({
    super.key,
    required this.subtask,
    required this.controller,
  });

  @override
  State<SubtaskEditDialog> createState() => _SubtaskEditDialogState();
}

class _SubtaskEditDialogState extends State<SubtaskEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _priority;
  late int _pomodoroTime;
  late bool _isImportant;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.subtask.title);
    _descriptionController = TextEditingController(
      text: widget.subtask.description,
    );
    _priority = widget.subtask.priority;
    _pomodoroTime = widget.subtask.pomodoroTimeMinutes;
    _isImportant = widget.subtask.isImportant;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Subtarefa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de título
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de descrição
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Seletor de prioridade
            Text('Prioridade:', style: Theme.of(context).textTheme.titleSmall),
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              items:
                  TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(_getPriorityLabel(priority)),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Checkbox para importante
            CheckboxListTile(
              title: const Text('Marcar como importante'),
              value: _isImportant,
              onChanged: (value) {
                setState(() {
                  _isImportant = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Configuração de tempo do pomodoro
            Text(
              'Tempo do Pomodoro:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            // Valor atual do tempo
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Duração:'),
                  Text(
                    '$_pomodoroTime minutos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Slider para ajuste fácil do tempo
            Row(
              children: [
                const Text('5'),
                Expanded(
                  child: Slider(
                    value: _pomodoroTime.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '$_pomodoroTime min',
                    onChanged: (value) {
                      setState(() {
                        _pomodoroTime = value.round();
                      });
                    },
                  ),
                ),
                const Text('120'),
              ],
            ),
            const SizedBox(height: 8),

            // Botões de tempo predefinido
            Text(
              'Presets rápidos:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTimeChip(context, 25),
                _buildTimeChip(context, 40),
                _buildTimeChip(context, 60),
                _buildTimeChip(context, 90),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _saveSubtask, child: const Text('Salvar')),
      ],
    );
  }

  Widget _buildTimeChip(BuildContext context, int minutes) {
    final isSelected = _pomodoroTime == minutes;

    return ChoiceChip(
      label: Text('$minutes min'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _pomodoroTime = minutes;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }

  void _saveSubtask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('O título é obrigatório')));
      return;
    }

    final formData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'priority': _priority,
      'isImportant': _isImportant,
      'pomodoroTimeMinutes': _pomodoroTime,
    };

    widget.controller.updateTask(widget.subtask.id, formData);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subtarefa atualizada com sucesso!')),
    );
  }
}
