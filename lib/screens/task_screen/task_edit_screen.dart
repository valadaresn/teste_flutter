import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/project.dart';

class TaskEditScreen extends StatefulWidget {
  final Task task;
  final List<Project> projects;
  final Function(Task) onTaskUpdated;

  const TaskEditScreen({
    super.key,
    required this.task,
    required this.projects,
    required this.onTaskUpdated,
  });

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime? _dueDate;
  late String _projectId;
  late String _taskListId;
  late bool _isCompleted;
  late bool _isPomodoroActive;
  late int _pomodoroTime;
  late String? _selectedPomodoroLabel;

  Project? get _selectedProject => widget.projects.firstWhere(
    (p) => p.id == _projectId,
    orElse: () => widget.projects.first,
  );

  List<String> get _pomodoroOptions => [
    '5 minutos',
    '15 minutos',
    '25 minutos',
    '30 minutos',
  ];

  Map<String, int> get _pomodoroValues => {
    '5 minutos': 5 * 60,
    '15 minutos': 15 * 60,
    '25 minutos': 25 * 60,
    '30 minutos': 30 * 60,
  };

  @override
  void initState() {
    super.initState();
    // Inicializar controladores com valores da tarefa
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _dueDate = widget.task.dueDate;
    _projectId = widget.task.projectId ?? widget.projects.first.id;
    _isCompleted = widget.task.isCompleted;
    _isPomodoroActive = widget.task.isPomodoroActive;
    _pomodoroTime = widget.task.pomodoroTime;
    _selectedPomodoroLabel = widget.task.selectedPomodoroLabel;

    // Garantir que temos um taskListId válido
    if (widget.task.taskListId != null) {
      _taskListId = widget.task.taskListId!;
    } else {
      final project = _selectedProject;
      _taskListId =
          project?.lists.isNotEmpty == true ? project!.lists.first.id : '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Método para salvar as alterações
  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O título não pode ser vazio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text.trim(),
      description:
          _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
      createdAt: widget.task.createdAt,
      dueDate: _dueDate,
      projectId: _projectId,
      taskListId: _taskListId,
      isCompleted: _isCompleted,
      isPomodoroActive: _isPomodoroActive,
      pomodoroTime: _pomodoroTime,
      selectedPomodoroLabel: _selectedPomodoroLabel,
    );

    widget.onTaskUpdated(updatedTask);
    Navigator.pop(context);
  }

  // Método para selecionar a data
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null && mounted) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarefa'),
        actions: [
          TextButton(onPressed: _saveTask, child: const Text('SALVAR')),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de título
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Campo de descrição
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Seletor de data
              ListTile(
                title: const Text('Data de vencimento'),
                subtitle: Text(
                  _dueDate == null
                      ? 'Sem data definida'
                      : '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}',
                ),
                leading: const Icon(Icons.calendar_today),
                onTap: _selectDate,
                trailing:
                    _dueDate != null
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dueDate = null;
                            });
                          },
                        )
                        : null,
              ),

              const Divider(),

              // Seletor de projeto
              if (widget.projects.length > 1) ...[
                const Text(
                  'Projeto',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _projectId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items:
                      widget.projects.map((project) {
                        return DropdownMenuItem(
                          value: project.id,
                          child: Row(
                            children: [
                              Icon(
                                project.icon,
                                color: project.color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(project.name),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _projectId = value;

                        // Atualizar a lista selecionada
                        final project = widget.projects.firstWhere(
                          (p) => p.id == value,
                          orElse: () => widget.projects.first,
                        );

                        if (project.lists.isNotEmpty) {
                          _taskListId = project.lists.first.id;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Seletor de lista
              if (_selectedProject != null &&
                  _selectedProject!.lists.isNotEmpty) ...[
                const Text(
                  'Lista',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value:
                      _selectedProject!.lists.any((l) => l.id == _taskListId)
                          ? _taskListId
                          : _selectedProject!.lists.first.id,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _selectedProject!.lists.map((list) {
                        return DropdownMenuItem(
                          value: list.id,
                          child: Text(list.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _taskListId = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Status de completude
              CheckboxListTile(
                title: const Text('Tarefa concluída'),
                value: _isCompleted,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _isCompleted = value;
                    });
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const Divider(),

              // Configuração de pomodoro
              const Text(
                'Configuração de Pomodoro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Switch para ativar/desativar pomodoro
              SwitchListTile(
                title: const Text('Usar Pomodoro'),
                value: _isPomodoroActive,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _isPomodoroActive = value;
                  });
                },
              ),

              // Tempo de pomodoro (mostra apenas se o pomodoro estiver ativo)
              if (_isPomodoroActive) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value:
                      _selectedPomodoroLabel ??
                      _pomodoroOptions[2], // Default para 25 minutos
                  decoration: const InputDecoration(
                    labelText: 'Tempo de Pomodoro',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _pomodoroOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPomodoroLabel = value;
                        _pomodoroTime = _pomodoroValues[value] ?? (25 * 60);
                      });
                    }
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Botão de salvar
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar alterações'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
