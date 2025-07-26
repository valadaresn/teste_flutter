import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../controllers/task_controller.dart';
import '../../../models/task_model.dart';
import '../../../themes/theme_provider.dart';
import '../task_detail_panel/clean_subtask_item.dart';

/// **CleanTaskPanel** - Painel clean de edição de tarefas
///
/// Painel inspirado no TickTick/MS Todo com design minimalista,
/// salvamento automático e sem botões de confirmação
class CleanTaskPanel extends StatefulWidget {
  final TaskController controller;

  const CleanTaskPanel({Key? key, required this.controller}) : super(key: key);

  @override
  State<CleanTaskPanel> createState() => _CleanTaskPanelState();
}

class _CleanTaskPanelState extends State<CleanTaskPanel> {
  // Controllers para campos editáveis
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _newSubtaskController;

  // Debounce timers
  Timer? _titleDebounce;
  Timer? _notesDebounce;

  // Estado das subtarefas
  List<Task> _subtasks = [];
  Map<String, TextEditingController> _subtaskControllers = {};

  // Para detectar mudanças de tarefa
  String? _lastTaskId;

  Task? get _selectedTask => widget.controller.getSelectedTask();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(CleanTaskPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Verificar se a tarefa selecionada mudou
    final currentTask = _selectedTask;
    if (currentTask?.id != _lastTaskId) {
      _updateControllersForNewTask(currentTask);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _newSubtaskController.dispose();
    _titleDebounce?.cancel();
    _notesDebounce?.cancel();

    // Dispose subtask controllers
    for (var controller in _subtaskControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _initializeControllers() {
    final task = _selectedTask;

    _titleController = TextEditingController(text: task?.title ?? '');
    _notesController = TextEditingController(text: task?.notes ?? '');
    _newSubtaskController = TextEditingController();

    // Definir tarefa atual
    _lastTaskId = task?.id;

    // Load subtasks
    if (task != null) {
      _loadSubtasks();
    }

    // Add listeners para auto-save
    _titleController.addListener(_onTitleChanged);
    _notesController.addListener(_onNotesChanged);
  }

  void _updateControllersForNewTask(Task? newTask) {
    // Limpar listeners antigos
    _titleController.removeListener(_onTitleChanged);
    _notesController.removeListener(_onNotesChanged);

    // Dispose controllers de subtarefas antigos
    for (var controller in _subtaskControllers.values) {
      controller.dispose();
    }
    _subtaskControllers.clear();

    // Atualizar texto dos controllers principais
    _titleController.text = newTask?.title ?? '';
    _notesController.text = newTask?.notes ?? '';
    _newSubtaskController.clear();

    // Atualizar tarefa atual
    _lastTaskId = newTask?.id;

    // Carregar subtarefas da nova tarefa
    if (newTask != null) {
      _loadSubtasks();
    } else {
      _subtasks.clear();
    }

    // Readicionar listeners
    _titleController.addListener(_onTitleChanged);
    _notesController.addListener(_onNotesChanged);
  }

  void _loadSubtasks() {
    final task = _selectedTask;
    if (task != null) {
      setState(() {
        _subtasks = widget.controller.getSubtasks(task.id);

        // Create controllers for existing subtasks
        _subtaskControllers.clear();
        for (var subtask in _subtasks) {
          _subtaskControllers[subtask.id] = TextEditingController(
            text: subtask.title,
          );
          _subtaskControllers[subtask.id]!.addListener(
            () => _onSubtaskChanged(subtask.id),
          );
        }
      });
    }
  }

  void _onTitleChanged() {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveTitle();
    });
  }

  void _onNotesChanged() {
    _notesDebounce?.cancel();
    _notesDebounce = Timer(const Duration(milliseconds: 500), () {
      _saveNotes();
    });
  }

  void _onSubtaskChanged(String subtaskId) {
    Timer(const Duration(milliseconds: 500), () {
      _saveSubtaskTitle(subtaskId);
    });
  }

  Future<void> _saveTitle() async {
    final task = _selectedTask;
    if (task != null && _titleController.text.trim() != task.title) {
      await widget.controller.updateTask(task.id, {
        'title': _titleController.text.trim(),
        'description': task.description,
        'priority': task.priority,
        'dueDate': task.dueDate,
        'tags': task.tags,
        'isImportant': task.isImportant,
        'notes': task.notes,
        'isCompleted': task.isCompleted,
      });
    }
  }

  Future<void> _saveNotes() async {
    final task = _selectedTask;
    if (task != null && _notesController.text != (task.notes ?? '')) {
      await widget.controller.updateTask(task.id, {
        'title': task.title,
        'description': task.description,
        'priority': task.priority,
        'dueDate': task.dueDate,
        'tags': task.tags,
        'isImportant': task.isImportant,
        'notes': _notesController.text,
        'isCompleted': task.isCompleted,
      });
    }
  }

  Future<void> _saveSubtaskTitle(String subtaskId) async {
    final controller = _subtaskControllers[subtaskId];
    if (controller != null) {
      final subtask = _subtasks.firstWhere((s) => s.id == subtaskId);
      if (controller.text.trim() != subtask.title) {
        await widget.controller.updateTask(subtaskId, {
          'title': controller.text.trim(),
          'description': subtask.description,
          'priority': subtask.priority,
          'dueDate': subtask.dueDate,
          'tags': subtask.tags,
          'isImportant': subtask.isImportant,
          'notes': subtask.notes,
          'isCompleted': subtask.isCompleted,
        });
        _loadSubtasks(); // Reload to get updated data
      }
    }
  }

  Future<void> _addSubtask() async {
    final task = _selectedTask;
    final title = _newSubtaskController.text.trim();

    if (task != null && title.isNotEmpty) {
      await widget.controller.addTask({
        'title': title,
        'description': '',
        'listId': task.listId,
        'parentTaskId': task.id,
        'priority': TaskPriority.medium,
        'dueDate': null,
        'tags': <String>[],
        'isImportant': false,
        'notes': null,
        'isCompleted': false,
      });

      _newSubtaskController.clear();
      _loadSubtasks();
    }
  }

  Future<void> _toggleSubtaskCompleted(Task subtask) async {
    await widget.controller.updateTask(subtask.id, {
      'title': subtask.title,
      'description': subtask.description,
      'priority': subtask.priority,
      'dueDate': subtask.dueDate,
      'tags': subtask.tags,
      'isImportant': subtask.isImportant,
      'notes': subtask.notes,
      'isCompleted': !subtask.isCompleted,
    });
    _loadSubtasks();
  }

  Future<void> _deleteSubtask(String subtaskId) async {
    await widget.controller.deleteTask(subtaskId);
    _loadSubtasks();
  }

  /// Excluir a tarefa atual
  Future<void> _deleteTask() async {
    final task = _selectedTask;
    if (task != null) {
      // Confirmar antes de excluir
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Excluir tarefa'),
            content: Text('Tem certeza que deseja excluir "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // Fechar o painel primeiro
        widget.controller.selectTask(null);

        // Excluir a tarefa
        await widget.controller.deleteTask(task.id);
      }
    }
  }

  /// Abrir DatePicker nativo do Flutter com localização
  Future<void> _showDatePicker(Task task) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: task.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('pt', 'BR'),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (selectedDate != null) {
      await _updateTaskDate(task, selectedDate);
    }
  }

  /// Atualizar a data da tarefa com auto-save silencioso
  Future<void> _updateTaskDate(Task task, DateTime? newDate) async {
    // Só atualizar se a data realmente mudou
    if (newDate != task.dueDate) {
      try {
        await widget.controller.updateTask(task.id, {
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'dueDate': newDate,
          'tags': task.tags,
          'isImportant': task.isImportant,
          'notes': task.notes,
          'isCompleted': task.isCompleted,
        });

        // Forçar atualização da UI para refletir mudanças nos grupos
        if (mounted) {
          setState(() {
            // A tarefa pode ter mudado de grupo (Hoje ↔ Atrasado ↔ Futuro)
            _lastTaskId = null; // Forçar reload dos controllers
          });
        }
      } catch (e) {
        // Falha silenciosa - sem mensagens para UX mais limpa
        debugPrint('Erro ao atualizar data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final task = _selectedTask;

        // Se não há tarefa selecionada, não mostrar o painel
        if (task == null) {
          return const SizedBox.shrink();
        }

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              width: 400,
              height: MediaQuery.of(context).size.height,
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
                  // Header com botão de fechar
                  _buildHeader(context),

                  // Conteúdo principal
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Seção 1: Data e Título
                          _buildDateAndTitleSection(task),

                          const SizedBox(height: 32),

                          // Seção 2: Subtarefas
                          _buildSubtasksSection(task),

                          const SizedBox(height: 32),

                          // Seção 3: Anotações
                          _buildNotesSection(task),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Rodapé com informações da lista e opções
                  _buildFooter(task),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Header com botão de fechar
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => widget.controller.selectTask(null),
            icon: const Icon(Icons.close, size: 20),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  /// Seção de data e título
  Widget _buildDateAndTitleSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Data (antes do título conforme mockup)
        _buildDateDisplay(task),

        const SizedBox(height: 16),

        // Título editável
        _buildTitleField(task),

        // Divisor sutil
        Container(
          margin: const EdgeInsets.only(top: 24),
          height: 1,
          color: Colors.grey.shade200,
        ),
      ],
    );
  }

  /// Display da data clicável clean (estilo TickTick/MS To Do)
  Widget _buildDateDisplay(Task task) {
    String dateText = _formatTaskDate(task);
    bool isOverdue =
        task.dueDate != null &&
        !task.isCompleted &&
        DateTime.now().isAfter(task.dueDate!);

    return GestureDetector(
      onTap: () => _showDatePicker(task),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: isOverdue ? Colors.red.shade600 : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              dateText,
              style: TextStyle(
                fontSize: 14,
                color: isOverdue ? Colors.red.shade700 : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Campo de título editável
  Widget _buildTitleField(Task task) {
    return TextField(
      controller: _titleController,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        hintText: 'Título da tarefa',
        hintStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Seção de subtarefas
  Widget _buildSubtasksSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista de subtarefas existentes
        ..._subtasks.map((subtask) => _buildSubtaskItem(subtask)),

        // Campo para nova subtarefa
        _buildNewSubtaskField(),

        const SizedBox(height: 16),

        // Divisor sutil
        Container(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  /// Item de subtarefa
  Widget _buildSubtaskItem(Task subtask) {
    final controller = _subtaskControllers[subtask.id];
    if (controller == null) return const SizedBox.shrink();

    return CleanSubtaskItem(
      subtask: subtask,
      taskController: widget.controller,
      textController: controller,
      onToggleComplete: () => _toggleSubtaskCompleted(subtask),
      onDelete: () => _deleteSubtask(subtask.id),
      onTitleChanged: (subtaskId) => _onSubtaskChanged(subtaskId),
    );
  }

  /// Campo para nova subtarefa
  Widget _buildNewSubtaskField() {
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
              controller: _newSubtaskController,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: 'Adicionar etapass',
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _addSubtask(),
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de anotações
  Widget _buildNotesSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de anotações
        TextField(
          controller: _notesController,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            hintText: 'Adicionar anotação',
            hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          maxLines: null,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),

        const SizedBox(height: 16),

        // Divisor sutil
        Container(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  /// Rodapé com lista e opções
  Widget _buildFooter(Task task) {
    final taskList = widget.controller.getListById(task.listId);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          // Excluir tarefa (lado esquerdo)
          IconButton(
            onPressed: _deleteTask,
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.red.shade600,
            ),
            splashRadius: 20,
          ),

          const SizedBox(width: 8),

          // Ícone e nome da lista
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                taskList?.name ?? 'Lista',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Botões de ação
          Row(
            children: [
              // Prioridade
              IconButton(
                onPressed: () {
                  // TODO: Implementar seleção de prioridade
                },
                icon: Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                splashRadius: 20,
              ),

              // Comentários/Tags
              IconButton(
                onPressed: () {
                  // TODO: Implementar tags/comentários
                },
                icon: Icon(
                  Icons.label_outline,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                splashRadius: 20,
              ),

              // Mais opções
              IconButton(
                onPressed: () {
                  // TODO: Implementar menu de opções
                },
                icon: Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formatar data da tarefa
  /// Formatar data da tarefa com contexto inteligente
  String _formatTaskDate(Task task) {
    if (task.dueDate == null) {
      return 'Sem prazo';
    }

    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = taskDate.difference(today).inDays;

    // Datas próximas com contexto
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference == -1) {
      return 'Ontem (atrasado)';
    } else if (difference > 1 && difference <= 7) {
      // Dias da semana para próximos 7 dias
      final weekdays = [
        '',
        'Segunda',
        'Terça',
        'Quarta',
        'Quinta',
        'Sexta',
        'Sábado',
        'Domingo',
      ];
      return weekdays[dueDate.weekday];
    } else if (difference < -1) {
      // Tarefas atrasadas
      final daysDiff = difference.abs();
      if (daysDiff <= 7) {
        return '$daysDiff ${daysDiff == 1 ? 'dia' : 'dias'} atrasado';
      } else {
        return _formatDateWithMonth(dueDate) + ' (atrasado)';
      }
    } else {
      // Datas futuras
      return _formatDateWithMonth(dueDate);
    }
  }

  /// Formatar data com mês
  String _formatDateWithMonth(DateTime date) {
    final now = DateTime.now();
    final months = [
      '',
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];

    // Se for do mesmo ano, não mostrar o ano
    if (date.year == now.year) {
      return '${date.day} de ${months[date.month]}';
    } else {
      return '${date.day} de ${months[date.month]}, ${date.year}';
    }
  }
}
