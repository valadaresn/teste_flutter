import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class TaskCreationDialog extends StatefulWidget {
  final TaskController controller;
  final String? preselectedListId;

  const TaskCreationDialog({
    Key? key,
    required this.controller,
    this.preselectedListId,
  }) : super(key: key);

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedListId;
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _isImportant = false;
  DateTime? _dueDate;
  List<String> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedListId =
        widget.preselectedListId ?? widget.controller.selectedListId;

    // Se não há lista selecionada, usar a primeira disponível
    if (_selectedListId == null && widget.controller.lists.isNotEmpty) {
      _selectedListId = widget.controller.lists.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.lists.isEmpty) {
      return AlertDialog(
        title: const Text('Criar Tarefa'),
        content: const Text(
          'Você precisa criar uma lista primeiro antes de adicionar tarefas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Nova Tarefa'),
      content: SizedBox(
        width: 400,
        height: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título da Tarefa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Título é obrigatório';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo descrição
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Seleção de lista
                DropdownButtonFormField<String>(
                  value: _selectedListId,
                  decoration: const InputDecoration(
                    labelText: 'Lista',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.list),
                  ),
                  items:
                      widget.controller.lists.map((list) {
                        return DropdownMenuItem(
                          value: list.id,
                          child: Row(
                            children: [
                              Text(list.emoji),
                              const SizedBox(width: 8),
                              Expanded(child: Text(list.name)),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedListId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione uma lista';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Prioridade
                const Text(
                  'Prioridade:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      TaskPriority.values.map((priority) {
                        final isSelected = _selectedPriority == priority;
                        return FilterChip(
                          label: Text(_getPriorityLabel(priority)),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          },
                          avatar: Icon(
                            _getPriorityIcon(priority),
                            size: 18,
                            color:
                                isSelected
                                    ? Colors.white
                                    : _getPriorityColor(priority),
                          ),
                          selectedColor: _getPriorityColor(priority),
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                ),

                const SizedBox(height: 16),

                // Importante
                CheckboxListTile(
                  title: const Text('Marcar como importante'),
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: Icon(
                    Icons.star,
                    color: _isImportant ? Colors.amber : Colors.grey,
                  ),
                ),

                const SizedBox(height: 16),

                // Data de vencimento
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _dueDate == null
                        ? 'Adicionar data de vencimento'
                        : 'Vence em: ${_formatDate(_dueDate!)}',
                  ),
                  trailing:
                      _dueDate == null
                          ? null
                          : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _dueDate = null;
                              });
                            },
                          ),
                  onTap: _selectDueDate,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTask,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Criar Tarefa'),
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        setState(() {
          _dueDate = DateTime(date.year, date.month, date.day, 23, 59);
        });
      }
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedListId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma lista para a tarefa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newTask = Task.create(
        id: '', // Será gerado pelo controller
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        listId: _selectedListId!,
        priority: _selectedPriority,
        isImportant: _isImportant,
        dueDate: _dueDate,
        tags: _tags,
      );

      await widget.controller.createTask(newTask);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarefa "${newTask.title}" criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hoje às ${TimeOfDay.fromDateTime(date).format(context)}';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Amanhã às ${TimeOfDay.fromDateTime(date).format(context)}';
    } else {
      return '${date.day}/${date.month}/${date.year} às ${TimeOfDay.fromDateTime(date).format(context)}';
    }
  }
}
