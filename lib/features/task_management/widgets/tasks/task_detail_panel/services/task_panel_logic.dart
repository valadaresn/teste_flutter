import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../controllers/task_controller.dart';
import '../../../../models/task_model.dart';
import '../../../../../../models/diary_entry.dart';
import '../../../../../../screens/diary_screen/diary_controller.dart';

/// **TaskPanelLogic** - Serviço para gerenciar toda a lógica do painel de tarefas
///
/// Centraliza toda a lógica de negócio, controllers, timers e operações,
/// deixando o widget principal apenas para coordenar a UI
class TaskPanelLogic {
  final TaskController taskController;
  final DiaryController diaryController;

  // Controllers para campos editáveis
  late TextEditingController titleController;
  late TextEditingController notesController;
  late TextEditingController newSubtaskController;

  // Debounce timers
  Timer? _titleDebounce;
  Timer? _notesDebounce;

  // Estado das subtarefas
  List<Task> subtasks = [];
  Map<String, TextEditingController> subtaskControllers = {};

  // Estado das entradas de diário
  List<DiaryEntry> diaryEntries = [];
  bool isDiaryExpanded = false;

  // Para detectar mudanças de tarefa
  String? _lastTaskId;

  // Callback para notificar mudanças
  VoidCallback? _onDataChanged;

  TaskPanelLogic({required this.taskController, required this.diaryController});

  Task? get selectedTask => taskController.getSelectedTask();

  /// Define callback para notificação de mudanças nos dados
  void setOnDataChangedCallback(VoidCallback callback) {
    _onDataChanged = callback;
  }

  /// Notifica sobre mudanças nos dados
  void _notifyDataChanged() {
    _onDataChanged?.call();
  }

  void initialize() {
    final task = selectedTask;

    titleController = TextEditingController(text: task?.title ?? '');
    notesController = TextEditingController(text: task?.notes ?? '');
    newSubtaskController = TextEditingController();

    _lastTaskId = task?.id;

    if (task != null) {
      loadSubtasks();
      // Carregar entradas de diário sem callback aqui pois não há widget para notificar ainda
      unawaited(loadDiaryEntries());
    }

    // Add listeners para auto-save
    titleController.addListener(_onTitleChanged);
    notesController.addListener(_onNotesChanged);
  }

  void updateForNewTask(Task? newTask, VoidCallback onStateChanged) {
    // Limpar listeners antigos
    titleController.removeListener(_onTitleChanged);
    notesController.removeListener(_onNotesChanged);

    // Dispose controllers de subtarefas antigos
    for (var controller in subtaskControllers.values) {
      controller.dispose();
    }
    subtaskControllers.clear();

    // Atualizar texto dos controllers principais
    titleController.text = newTask?.title ?? '';
    notesController.text = newTask?.notes ?? '';
    newSubtaskController.clear();

    _lastTaskId = newTask?.id;

    if (newTask != null) {
      loadSubtasks();
      // Carregar entradas de diário e notificar widget quando concluído
      loadDiaryEntries().then((_) {
        onStateChanged(); // Força rebuild do widget
      });
    } else {
      subtasks.clear();
      diaryEntries.clear(); // Limpar entradas de diário
    }

    // Readicionar listeners
    titleController.addListener(_onTitleChanged);
    notesController.addListener(_onNotesChanged);

    onStateChanged();
  }

  void loadSubtasks() {
    final task = selectedTask;
    if (task != null) {
      subtasks = taskController.getSubtasks(task.id);

      subtaskControllers.clear();
      for (var subtask in subtasks) {
        subtaskControllers[subtask.id] = TextEditingController(
          text: subtask.title,
        );
        subtaskControllers[subtask.id]!.addListener(
          () => _onSubtaskChanged(subtask.id),
        );
      }
    }
  }

  bool hasTaskChanged() {
    final currentTask = selectedTask;
    return currentTask?.id != _lastTaskId;
  }

  void _onTitleChanged() {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 500), saveTitle);
  }

  void _onNotesChanged() {
    _notesDebounce?.cancel();
    _notesDebounce = Timer(const Duration(milliseconds: 500), saveNotes);
  }

  void _onSubtaskChanged(String subtaskId) {
    Timer(const Duration(milliseconds: 500), () => saveSubtaskTitle(subtaskId));
  }

  Future<void> saveTitle() async {
    final task = selectedTask;
    if (task != null && titleController.text.trim() != task.title) {
      await taskController.updateTask(task.id, {
        'title': titleController.text.trim(),
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

  Future<void> saveNotes() async {
    final task = selectedTask;
    if (task != null && notesController.text != (task.notes ?? '')) {
      await taskController.updateTask(task.id, {
        'title': task.title,
        'description': task.description,
        'priority': task.priority,
        'dueDate': task.dueDate,
        'tags': task.tags,
        'isImportant': task.isImportant,
        'notes': notesController.text,
        'isCompleted': task.isCompleted,
      });
    }
  }

  Future<void> saveSubtaskTitle(String subtaskId) async {
    final controller = subtaskControllers[subtaskId];
    if (controller != null) {
      final subtask = subtasks.firstWhere((s) => s.id == subtaskId);
      if (controller.text.trim() != subtask.title) {
        await taskController.updateTask(subtaskId, {
          'title': controller.text.trim(),
          'description': subtask.description,
          'priority': subtask.priority,
          'dueDate': subtask.dueDate,
          'tags': subtask.tags,
          'isImportant': subtask.isImportant,
          'notes': subtask.notes,
          'isCompleted': subtask.isCompleted,
        });
        loadSubtasks();
      }
    }
  }

  Future<void> addSubtask() async {
    final task = selectedTask;
    final title = newSubtaskController.text.trim();

    if (task != null && title.isNotEmpty) {
      await taskController.addTask({
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

      newSubtaskController.clear();
      loadSubtasks();
    }
  }

  Future<void> toggleSubtaskCompleted(Task subtask) async {
    await taskController.updateTask(subtask.id, {
      'title': subtask.title,
      'description': subtask.description,
      'priority': subtask.priority,
      'dueDate': subtask.dueDate,
      'tags': subtask.tags,
      'isImportant': subtask.isImportant,
      'notes': subtask.notes,
      'isCompleted': !subtask.isCompleted,
    });
    loadSubtasks();
  }

  Future<void> deleteSubtask(String subtaskId) async {
    await taskController.deleteTask(subtaskId);
    loadSubtasks();
  }

  Future<void> updateTaskDate(
    Task task,
    DateTime? newDate,
    VoidCallback? onStateChanged,
  ) async {
    if (newDate != task.dueDate) {
      try {
        await taskController.updateTask(task.id, {
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'dueDate': newDate,
          'tags': task.tags,
          'isImportant': task.isImportant,
          'notes': task.notes,
          'isCompleted': task.isCompleted,
        });

        _lastTaskId = null; // Forçar reload
        onStateChanged?.call();
      } catch (e) {
        debugPrint('Erro ao atualizar data: $e');
      }
    }
  }

  Future<void> updatePomodoroTime(Task task, int newTimeMinutes) async {
    try {
      await taskController.updateTask(task.id, {
        'title': task.title,
        'description': task.description,
        'priority': task.priority,
        'dueDate': task.dueDate,
        'tags': task.tags,
        'isImportant': task.isImportant,
        'notes': task.notes,
        'isCompleted': task.isCompleted,
        'pomodoroTimeMinutes': newTimeMinutes,
      });
    } catch (e) {
      debugPrint('Erro ao atualizar tempo do pomodoro: $e');
    }
  }

  Future<void> updateTaskList(Task task, String newListId) async {
    if (newListId != task.listId) {
      try {
        await taskController.updateTask(task.id, {
          'title': task.title,
          'description': task.description,
          'priority': task.priority,
          'dueDate': task.dueDate,
          'tags': task.tags,
          'isImportant': task.isImportant,
          'notes': task.notes,
          'isCompleted': task.isCompleted,
          'listId': newListId,
        });
      } catch (e) {
        debugPrint('Erro ao atualizar lista: $e');
      }
    }
  }

  Future<bool> deleteTask(BuildContext context) async {
    final task = selectedTask;
    if (task == null) return false;

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
      taskController.selectTask(null);
      await taskController.deleteTask(task.id);
      return true;
    }
    return false;
  }

  void dispose() {
    titleController.dispose();
    notesController.dispose();
    newSubtaskController.dispose();
    _titleDebounce?.cancel();
    _notesDebounce?.cancel();

    for (var controller in subtaskControllers.values) {
      controller.dispose();
    }
  }

  // === MÉTODOS PARA GERENCIAR ENTRADAS DE DIÁRIO ===

  /// Carrega entradas de diário relacionadas à tarefa atual
  Future<void> loadDiaryEntries() async {
    final task = selectedTask;
    if (task != null) {
      try {
        // Buscar entradas específicas da tarefa no Firebase
        final entries = await diaryController.getEntriesForTask(task.id);
        diaryEntries = entries;
        debugPrint(
          '✅ ${entries.length} entradas de diário carregadas para tarefa ${task.title}',
        );
        // Notificar mudança nos dados
        _notifyDataChanged();
      } catch (e) {
        debugPrint('❌ Erro ao carregar entradas de diário: $e');
        diaryEntries.clear();
      }
    } else {
      diaryEntries.clear();
    }
  }

  /// Adiciona uma nova entrada de diário
  Future<void> addDiaryEntry(String content, String mood) async {
    final task = selectedTask;
    if (task == null) {
      debugPrint(
        '❌ Nenhuma tarefa selecionada para adicionar entrada de diário',
      );
      return;
    }

    try {
      debugPrint('🔄 Iniciando adição de entrada de diário...');
      debugPrint('📝 Tarefa: ${task.title} (ID: ${task.id})');
      debugPrint('💬 Conteúdo: $content');
      debugPrint('😊 Humor: $mood');

      // Criar nova entrada
      final newEntry = DiaryEntry.forTask(
        id: const Uuid().v4(), // ID único real
        content: content,
        mood: mood,
        taskId: task.id,
        taskName: task.title,
        projectId: task.listId, // Usar listId como referência de projeto
        projectName:
            'Lista: ${task.listId}', // TODO: Buscar nome real da lista/projeto
      );

      debugPrint('🆔 Nova entrada criada com ID: ${newEntry.id}');
      debugPrint('📄 Dados da entrada: ${newEntry.toMap()}');

      // Salvar no Firebase via controller
      debugPrint('🔥 Tentando salvar no Firebase...');
      final success = await diaryController.addDiaryEntry(newEntry);

      if (success) {
        // Adicionar localmente para atualização imediata da UI
        diaryEntries.insert(0, newEntry); // Mais recente primeiro
        debugPrint('✅ Nova entrada de diário adicionada com sucesso: $content');
        // Notificar mudança nos dados
        _notifyDataChanged();
      } else {
        debugPrint('❌ Falha ao adicionar entrada de diário no Firebase');
      }
    } catch (e) {
      debugPrint('❌ Erro ao adicionar entrada de diário: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Edita uma entrada de diário existente
  Future<void> editDiaryEntry(DiaryEntry entry) async {
    try {
      // Atualizar no Firebase via controller
      final success = await diaryController.updateEntry(entry, entry.toMap());

      if (success) {
        // Atualizar localmente
        final index = diaryEntries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          diaryEntries[index] = entry;
        }
        debugPrint('✅ Entrada de diário editada: ${entry.id}');
      } else {
        debugPrint('❌ Falha ao editar entrada de diário no Firebase');
      }
    } catch (e) {
      debugPrint('❌ Erro ao editar entrada de diário: $e');
    }
  }

  /// Exclui uma entrada de diário
  Future<void> deleteDiaryEntry(String entryId) async {
    try {
      // Deletar no Firebase via controller
      final success = await diaryController.deleteEntry(entryId);

      if (success) {
        // Remover localmente
        diaryEntries.removeWhere((entry) => entry.id == entryId);
        debugPrint('✅ Entrada de diário excluída: $entryId');
      } else {
        debugPrint('❌ Falha ao excluir entrada de diário no Firebase');
      }
    } catch (e) {
      debugPrint('❌ Erro ao excluir entrada de diário: $e');
    }
  }

  /// Toggle do estado de expansão da seção de diário
  void toggleDiarySection() {
    isDiaryExpanded = !isDiaryExpanded;
    _notifyDataChanged();
  }
}
