import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../themes/theme_provider.dart';
import '../subtasks/subtask_list.dart';

class TaskDetailPanel extends StatefulWidget {
  final Task task;
  final TaskController controller;
  final VoidCallback? onClose;

  const TaskDetailPanel({
    Key? key,
    required this.task,
    required this.controller,
    this.onClose,
  }) : super(key: key);

  @override
  State<TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends State<TaskDetailPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;

  bool _isEditing = false;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  List<String> _tags = [];
  bool _isImportant = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _selectedPriority = widget.task.priority;
    _selectedDueDate = widget.task.dueDate;
    _tags = List.from(widget.task.tags);
    _isImportant = widget.task.isImportant;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          width: 400,
          decoration: BoxDecoration(
            color: themeProvider.getBackgroundColor(
              context,
              listColor:
                  widget.controller.selectedListId != null
                      ? widget.controller
                          .getListById(widget.controller.selectedListId!)
                          ?.color
                      : null,
            ),
            border: Border(
              left: BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(),
                    _buildSubtasksTab(),
                    _buildNotesTab(),
                  ],
                ),
              ),
              if (_isEditing) _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Checkbox da tarefa
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: widget.task.isCompleted,
              onChanged:
                  (_) => widget.controller.toggleTaskCompletion(widget.task.id),
            ),
          ),

          const SizedBox(width: 12),

          // Título editável
          Expanded(
            child:
                _isEditing
                    ? TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Título da tarefa',
                      ),
                    )
                    : Text(
                      widget.task.title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration:
                            widget.task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
          ),

          // Botões de ação
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
            tooltip: _isEditing ? 'Salvar' : 'Editar',
          ),

          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEdit,
              tooltip: 'Cancelar',
            ),

          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
              tooltip: 'Fechar',
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Detalhes'),
          Tab(text: 'Subtarefas'),
          Tab(text: 'Notas'),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descrição
          _buildSection(
            title: 'Descrição',
            child:
                _isEditing
                    ? TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Adicione uma descrição...',
                      ),
                    )
                    : widget.task.description.isNotEmpty
                    ? Text(widget.task.description)
                    : Text(
                      'Nenhuma descrição',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
          ),

          const SizedBox(height: 16),

          // Prioridade
          _buildSection(
            title: 'Prioridade',
            child:
                _isEditing
                    ? DropdownButton<TaskPriority>(
                      value: _selectedPriority,
                      isExpanded: true,
                      onChanged: (priority) {
                        setState(() {
                          _selectedPriority = priority!;
                        });
                      },
                      items:
                          TaskPriority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(priority),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_getPriorityLabel(priority)),
                                ],
                              ),
                            );
                          }).toList(),
                    )
                    : Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.task.priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.task.priorityLabel),
                      ],
                    ),
          ),

          const SizedBox(height: 16),

          // Data de prazo
          _buildSection(
            title: 'Prazo',
            child:
                _isEditing
                    ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDueDate != null
                                ? _formatDate(_selectedDueDate!)
                                : 'Nenhum prazo definido',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDueDate,
                        ),
                        if (_selectedDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                              });
                            },
                          ),
                      ],
                    )
                    : widget.task.dueDate != null
                    ? Row(
                      children: [
                        Icon(
                          widget.task.isOverdue
                              ? Icons.warning
                              : Icons.calendar_today,
                          size: 16,
                          color: widget.task.isOverdue ? Colors.red : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.task.dueDate!),
                          style: TextStyle(
                            color: widget.task.isOverdue ? Colors.red : null,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      'Nenhum prazo definido',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
          ),

          const SizedBox(height: 16),

          // Importante
          _buildSection(
            title: 'Importante',
            child: Row(
              children: [
                Switch(
                  value: _isEditing ? _isImportant : widget.task.isImportant,
                  onChanged:
                      _isEditing
                          ? (value) {
                            setState(() {
                              _isImportant = value;
                            });
                          }
                          : (value) => widget.controller.toggleTaskImportant(
                            widget.task.id,
                          ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing
                      ? (_isImportant ? 'Sim' : 'Não')
                      : (widget.task.isImportant ? 'Sim' : 'Não'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tags
          _buildSection(title: 'Tags', child: _buildTagsWidget()),

          const SizedBox(height: 16),

          // Informações do sistema
          _buildSection(
            title: 'Informações',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Criada em: ${_formatDate(widget.task.createdAt)}'),
                Text('Atualizada em: ${_formatDate(widget.task.updatedAt)}'),
                if (widget.task.completedAt != null)
                  Text(
                    'Concluída em: ${_formatDate(widget.task.completedAt!)}',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksTab() {
    return SubtaskList(parentTask: widget.task, controller: widget.controller);
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notas',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Adicione suas notas aqui...',
              ),
              readOnly: !_isEditing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTagsWidget() {
    final displayTags = _isEditing ? _tags : widget.task.tags;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...displayTags.map(
          (tag) => Chip(
            label: Text(tag),
            onDeleted: _isEditing ? () => _removeTag(tag) : null,
            deleteIconColor: Theme.of(context).colorScheme.error,
          ),
        ),
        if (_isEditing)
          ActionChip(
            avatar: const Icon(Icons.add, size: 16),
            label: const Text('Adicionar tag'),
            onPressed: _addTag,
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelEdit,
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _initializeControllers(); // Reset para valores originais
    });
  }

  Future<void> _saveChanges() async {
    final formData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'priority': _selectedPriority,
      'dueDate': _selectedDueDate,
      'tags': _tags,
      'isImportant': _isImportant,
      'notes': _notesController.text.trim(),
    };

    await widget.controller.updateTask(widget.task.id, formData);

    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        String newTag = '';
        return AlertDialog(
          title: const Text('Nova Tag'),
          content: TextField(
            onChanged: (value) => newTag = value,
            decoration: const InputDecoration(hintText: 'Nome da tag'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newTag.trim().isNotEmpty &&
                    !_tags.contains(newTag.trim())) {
                  setState(() {
                    _tags.add(newTag.trim());
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
}
