import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/list_model.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../repositories/task_repository.dart';
import '../repositories/project_repository.dart';

class TaskController extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  final ProjectRepository _projectRepository = ProjectRepository();
  final _uuid = Uuid();

  // StreamSubscriptions - CRÍTICO para evitar piscar
  StreamSubscription? _listsSubscription;
  StreamSubscription? _tasksSubscription;
  StreamSubscription? _projectsSubscription;

  // Estado da UI
  bool _isLoading = false;
  String? _error;

  // Dados principais
  List<TaskList> _lists = [];
  List<Task> _tasks = [];
  List<Project> _projects = [];
  // Estado de filtros e busca
  String _searchQuery = '';
  String? _selectedListId;
  String? _selectedTaskId;
  String? _selectedProjectId;
  bool _showCompletedTasks = true;
  TaskPriority? _selectedPriority;
  bool _showOnlyImportant = false;
  bool _showTodayView = false; // Estado para visualização "Hoje"

  // Getters públicos
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TaskList> get lists => _getFilteredLists();
  List<Task> get tasks => _getFilteredTasks();
  List<Project> get projects => _projects;
  String get searchQuery => _searchQuery;
  String? get selectedListId => _selectedListId;
  String? get selectedTaskId => _selectedTaskId;
  String? get selectedProjectId => _selectedProjectId;
  bool get showCompletedTasks => _showCompletedTasks;
  TaskPriority? get selectedPriority => _selectedPriority;
  bool get showOnlyImportant => _showOnlyImportant;
  bool get showTodayView => _showTodayView;
  // Constructor com StreamSubscription - ITEM #2 das instruções
  TaskController() {
    _subscribeToStreams();
    _repository.createDefaultListIfNeeded();
    _projectRepository.createDefaultProjectIfNeeded();
  }

  // ============================================================================
  // STREAM SUBSCRIPTIONS - CRÍTICO PARA NÃO PISCAR
  // ============================================================================
  void _subscribeToStreams() {
    _setLoading(true);

    // Subscription para projetos
    _projectsSubscription = _projectRepository.getProjectsStream().listen(
      (projects) {
        _projects = projects;
        _setLoading(false);
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Erro ao carregar projetos: $error');
        _setLoading(false);
      },
    );

    // Subscription para listas
    _listsSubscription = _repository.getListsStream().listen(
      (lists) {
        _lists = lists;
        _setLoading(false);
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Erro ao carregar listas: $error');
        _setLoading(false);
      },
    );

    // Subscription para tarefas
    _tasksSubscription = _repository.getTasksStream().listen(
      (tasks) {
        _tasks = tasks;
        _setLoading(false);
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Erro ao carregar tarefas: $error');
        _setLoading(false);
      },
    );
  }

  @override
  void dispose() {
    // ITEM #8 das instruções - SEMPRE cancelar StreamSubscription
    _listsSubscription?.cancel();
    _tasksSubscription?.cancel();
    _projectsSubscription?.cancel();
    super.dispose();
  }

  // ============================================================================
  // MÉTODOS ESPECÍFICOS PARA GenericSelectorList - ITEM #5 das instruções
  // ============================================================================
  /// Método específico para GenericSelectorList - retorna mesma instância
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Método específico para GenericSelectorList - retorna mesma instância
  TaskList? getListById(String id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Método específico para GenericSelectorList - retorna mesma instância
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
  // ============================================================================
  // MÉTODOS PRIVADOS PARA FILTROS - ITEM #9 das instruções
  // ============================================================================

  /// Método privado para filtrar listas por projeto selecionado
  List<TaskList> _getFilteredLists() {
    List<TaskList> filtered = _lists;

    // Filtro por projeto selecionado
    if (_selectedProjectId != null) {
      filtered =
          filtered
              .where((list) => list.projectId == _selectedProjectId)
              .toList();
    }

    return filtered;
  }

  /// Método privado para filtros - NUNCA use where().toList() direto em getters
  List<Task> _getFilteredTasks() {
    List<Task> filtered = _tasks;

    // PRIORIDADE: Se visualização "Hoje" está ativa, retornar tarefas combinadas
    if (_showTodayView) {
      List<Task> todayTasks = [];

      // Adicionar tarefas atrasadas primeiro (prioridade)
      todayTasks.addAll(getOverdueTasks());

      // Adicionar tarefas de hoje
      todayTasks.addAll(getTodayTasks());

      // Aplicar filtros que ainda fazem sentido na visualização "Hoje"
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        todayTasks =
            todayTasks
                .where(
                  (task) =>
                      task.title.toLowerCase().contains(query) ||
                      task.description.toLowerCase().contains(query),
                )
                .toList();
      }

      // Filtro por prioridade (se aplicável)
      if (_selectedPriority != null) {
        todayTasks =
            todayTasks
                .where((task) => task.priority == _selectedPriority)
                .toList();
      }

      return todayTasks;
    }

    // Lógica de filtros normal (quando não está na visualização "Hoje")

    // Filtro por lista selecionada
    if (_selectedListId != null) {
      filtered =
          filtered.where((task) => task.listId == _selectedListId).toList();
    }

    // Filtro por busca
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered
              .where(
                (task) =>
                    task.title.toLowerCase().contains(query) ||
                    task.description.toLowerCase().contains(query),
              )
              .toList();
    }

    // Filtro por tarefas completas
    if (!_showCompletedTasks) {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }

    // Filtro por prioridade
    if (_selectedPriority != null) {
      filtered =
          filtered.where((task) => task.priority == _selectedPriority).toList();
    }

    // Filtro por importantes
    if (_showOnlyImportant) {
      filtered = filtered.where((task) => task.isImportant).toList();
    }

    // Retornar apenas tarefas principais (não subtarefas) por padrão
    return filtered.where((task) => task.parentTaskId == null).toList();
  }

  /// Obter subtarefas de uma tarefa específica
  List<Task> getSubtasks(String parentTaskId) {
    return _tasks.where((task) => task.parentTaskId == parentTaskId).toList();
  }

  /// Obter tarefas de uma lista específica
  List<Task> getTasksByList(String listId) {
    return _tasks
        .where((task) => task.listId == listId && task.parentTaskId == null)
        .toList();
  }

  /// Contar tarefas pendentes em uma lista
  int countPendingTasksInList(String listId) {
    return _tasks
        .where(
          (task) =>
              task.listId == listId &&
              !task.isCompleted &&
              task.parentTaskId == null,
        )
        .length;
  }

  // ============================================================================
  // MÉTODOS PARA VISUALIZAÇÃO "HOJE" - ETAPA 2
  // ============================================================================  /// Obter tarefas com prazo para hoje (não concluídas)
  List<Task> getTodayTasks() {
    final today = DateTime.now();
    return _tasks
        .where(
          (task) =>
              task.dueDate != null &&
              _isSameDay(task.dueDate!, today) &&
              !task.isCompleted &&
              task.parentTaskId == null,
        )
        .toList()
      ..sort((a, b) {
        // 1. Primeiro ordenar por lista
        final listA = getListById(a.listId);
        final listB = getListById(b.listId);

        if (listA != null && listB != null) {
          int listComparison = listA.name.compareTo(listB.name);
          if (listComparison != 0) return listComparison;
        }

        // 2. Depois por prioridade: urgente > alta > média > baixa
        final priorityOrder = {
          TaskPriority.urgent: 0,
          TaskPriority.high: 1,
          TaskPriority.medium: 2,
          TaskPriority.low: 3,
        };

        int priorityComparison = (priorityOrder[a.priority] ?? 2).compareTo(
          priorityOrder[b.priority] ?? 2,
        );
        if (priorityComparison != 0) return priorityComparison;

        // 3. Depois por importância
        if (a.isImportant && !b.isImportant) return -1;
        if (!a.isImportant && b.isImportant) return 1;

        // 4. Por fim, por ordem de criação (mais recentes primeiro)
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  /// Obter tarefas atrasadas (vencidas e não concluídas)
  List<Task> getOverdueTasks() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    return _tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.isBefore(todayStart) &&
              !task.isCompleted &&
              task.parentTaskId == null,
        )
        .toList()
      ..sort((a, b) {
        // 1. Primeiro ordenar por lista
        final listA = getListById(a.listId);
        final listB = getListById(b.listId);

        if (listA != null && listB != null) {
          int listComparison = listA.name.compareTo(listB.name);
          if (listComparison != 0) return listComparison;
        }

        // 2. Depois por data de vencimento (mais recentes primeiro = menos atrasadas)
        int dateComparison = b.dueDate!.compareTo(a.dueDate!);
        if (dateComparison != 0) return dateComparison;

        // 3. Depois por prioridade
        final priorityOrder = {
          TaskPriority.urgent: 0,
          TaskPriority.high: 1,
          TaskPriority.medium: 2,
          TaskPriority.low: 3,
        };

        int priorityComparison = (priorityOrder[a.priority] ?? 2).compareTo(
          priorityOrder[b.priority] ?? 2,
        );
        if (priorityComparison != 0) return priorityComparison;

        // 4. Por fim, por importância
        if (a.isImportant && !b.isImportant) return -1;
        if (!a.isImportant && b.isImportant) return 1;

        return 0;
      });
  }

  /// Obter tarefas importantes para visualização hoje
  List<Task> getImportantTasks() {
    return _tasks
        .where(
          (task) =>
              task.isImportant &&
              !task.isCompleted &&
              task.parentTaskId == null,
        )
        .toList();
  }

  /// Contar tarefas para hoje
  int countTodayTasks() {
    return getTodayTasks().length;
  }

  /// Contar tarefas atrasadas
  int countOverdueTasks() {
    return getOverdueTasks().length;
  }

  /// Contar tarefas importantes
  int countImportantTasks() {
    return getImportantTasks().length;
  }

  /// Verificar se duas datas são do mesmo dia
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Verificar se uma tarefa tem prazo para hoje
  bool isTaskDueToday(Task task) {
    if (task.dueDate == null) return false;
    return _isSameDay(task.dueDate!, DateTime.now());
  }

  /// Verificar se uma tarefa está atrasada
  bool isTaskOverdue(Task task) {
    if (task.dueDate == null) return false;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    return task.dueDate!.isBefore(todayStart) && !task.isCompleted;
  }
  // ============================================================================
  // CRUD - LISTAS
  // ============================================================================

  Future<void> addList(Map<String, dynamic> formData) async {
    try {
      _setLoading(true);
      final id = _uuid.v4();
      final list = TaskList.fromFormData(formData, id);
      await _repository.addList(list);
      _clearError();
    } catch (e) {
      _setError('Erro ao criar lista: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateList(String listId, Map<String, dynamic> formData) async {
    try {
      _setLoading(true);
      final currentList = getListById(listId);
      if (currentList == null) {
        throw Exception('Lista não encontrada');
      }

      final updatedList = currentList.copyWith(
        name: formData['name'],
        color: formData['color'],
        emoji: formData['emoji'],
        sortOrder: formData['sortOrder'],
      );

      await _repository.updateList(updatedList);
      _clearError();
    } catch (e) {
      _setError('Erro ao atualizar lista: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      _setLoading(true);
      await _repository.deleteList(listId);

      // Se a lista deletada era a selecionada, limpar seleção
      if (_selectedListId == listId) {
        _selectedListId = null;
      }

      _clearError();
    } catch (e) {
      _setError('Erro ao deletar lista: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // CRUD - PROJETOS
  // ============================================================================

  Future<void> addProject(Map<String, dynamic> formData) async {
    try {
      _setLoading(true);
      final id = _uuid.v4();
      final project = Project.fromFormData(formData, id);
      await _projectRepository.addProject(project);
      _clearError();
    } catch (e) {
      _setError('Erro ao criar projeto: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> formData,
  ) async {
    try {
      _setLoading(true);
      final currentProject = getProjectById(projectId);
      if (currentProject == null) {
        throw Exception('Projeto não encontrado');
      }

      final updatedProject = currentProject.copyWith(
        name: formData['name'],
        description: formData['description'],
        color: formData['color'],
        emoji: formData['emoji'],
        sortOrder: formData['sortOrder'],
        isArchived: formData['isArchived'],
      );

      await _projectRepository.updateProject(updatedProject);
      _clearError();
    } catch (e) {
      _setError('Erro ao atualizar projeto: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      _setLoading(true);
      await _projectRepository.deleteProject(projectId);

      // Se o projeto deletado era o selecionado, limpar seleção
      if (_selectedProjectId == projectId) {
        _selectedProjectId = null;
        _selectedListId = null;
      }

      _clearError();
    } catch (e) {
      _setError('Erro ao deletar projeto: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // CRUD - TAREFAS
  // ============================================================================

  Future<void> addTask(Map<String, dynamic> formData) async {
    try {
      _setLoading(true);
      final id = _uuid.v4();
      final task = Task.fromFormData(formData, id);
      await _repository.addTask(task);
      _clearError();
    } catch (e) {
      _setError('Erro ao criar tarefa: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> formData) async {
    try {
      _setLoading(true);
      final currentTask = getTaskById(taskId);
      if (currentTask == null) {
        throw Exception('Tarefa não encontrada');
      }

      final updatedTask = currentTask.copyWith(
        title: formData['title'],
        description: formData['description'],
        priority: formData['priority'],
        dueDate: formData['dueDate'],
        tags: formData['tags'],
        isImportant: formData['isImportant'],
        notes: formData['notes'],
      );

      await _repository.updateTask(updatedTask);
      _clearError();
    } catch (e) {
      _setError('Erro ao atualizar tarefa: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      _setLoading(true);
      await _repository.deleteTask(taskId);
      _clearError();
    } catch (e) {
      _setError('Erro ao deletar tarefa: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final task = getTaskById(taskId);
      if (task == null) return;

      await _repository.toggleTaskCompletion(taskId, !task.isCompleted);
      _clearError();
    } catch (e) {
      _setError('Erro ao alterar status da tarefa: $e');
    }
  }

  Future<void> toggleTaskImportant(String taskId) async {
    try {
      final task = getTaskById(taskId);
      if (task == null) return;

      await _repository.toggleTaskImportant(taskId, !task.isImportant);
      _clearError();
    } catch (e) {
      _setError('Erro ao alterar favorito da tarefa: $e');
    }
  }

  Future<void> moveTaskToList(String taskId, String newListId) async {
    try {
      await _repository.moveTaskToList(taskId, newListId);
      _clearError();
    } catch (e) {
      _setError('Erro ao mover tarefa: $e');
    }
  }

  // ============================================================================
  // FILTROS E BUSCA
  // ============================================================================

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      notifyListeners();
    }
  }

  void selectProject(String? projectId) {
    if (_selectedProjectId != projectId) {
      _selectedProjectId = projectId;
      // Limpar seleção de lista quando mudar de projeto
      _selectedListId = null;
      _selectedTaskId = null;
      // Sair da visualização "Hoje" quando um projeto for selecionado
      if (_showTodayView) {
        _showTodayView = false;
      }
      notifyListeners();
    }
  }

  void selectList(String? listId) {
    if (_selectedListId != listId) {
      _selectedListId = listId;
      // Limpar tarefa selecionada ao mudar de lista
      _selectedTaskId = null;
      // Sair da visualização "Hoje" quando uma lista específica for selecionada
      if (listId != null && _showTodayView) {
        _showTodayView = false;
      }
      notifyListeners();
    }
  }

  void selectTask(String? taskId) {
    if (_selectedTaskId != taskId) {
      _selectedTaskId = taskId;
      notifyListeners();
    }
  }

  /// Navegar para uma tarefa específica (útil quando clicada na visualização "Hoje")
  void navigateToTask(String taskId) {
    final task = getTaskById(taskId);
    if (task == null) return;

    // Sair da visualização "Hoje"
    if (_showTodayView) {
      _showTodayView = false;
    }

    // Selecionar a lista da tarefa
    _selectedListId = task.listId;

    // Selecionar a tarefa
    _selectedTaskId = taskId;

    // Limpar outros filtros para garantir que a tarefa seja visível
    _searchQuery = '';
    _selectedPriority = null;
    _showOnlyImportant = false;
    _showCompletedTasks = true;

    notifyListeners();
  }

  Task? getSelectedTask() {
    if (_selectedTaskId == null) return null;
    try {
      return _tasks.firstWhere((task) => task.id == _selectedTaskId);
    } catch (e) {
      return null;
    }
  }

  void toggleShowCompletedTasks() {
    _showCompletedTasks = !_showCompletedTasks;
    notifyListeners();
  }

  void setSelectedPriority(TaskPriority? priority) {
    if (_selectedPriority != priority) {
      _selectedPriority = priority;
      notifyListeners();
    }
  }

  void toggleShowOnlyImportant() {
    _showOnlyImportant = !_showOnlyImportant;
    notifyListeners();
  }

  /// Alternar visualização "Hoje"
  void toggleTodayView() {
    _showTodayView = !_showTodayView;

    // Se ativar a visualização de hoje, limpar outros filtros
    if (_showTodayView) {
      _selectedListId = null;
      _selectedProjectId = null;
      _selectedTaskId = null;
    }

    notifyListeners();
  }

  void clearAllFilters() {
    bool hasChanges = false;

    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      hasChanges = true;
    }

    if (_selectedProjectId != null) {
      _selectedProjectId = null;
      hasChanges = true;
    }

    if (_selectedListId != null) {
      _selectedListId = null;
      hasChanges = true;
    }

    if (!_showCompletedTasks) {
      _showCompletedTasks = true;
      hasChanges = true;
    }

    if (_selectedPriority != null) {
      _selectedPriority = null;
      hasChanges = true;
    }
    if (_showOnlyImportant) {
      _showOnlyImportant = false;
      hasChanges = true;
    }

    if (_showTodayView) {
      _showTodayView = false;
      hasChanges = true;
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  // ============================================================================
  // CRUD - LISTAS
  // ============================================================================
  Future<void> createList(TaskList list) async {
    try {
      final newList = TaskList.create(
        id: _uuid.v4(),
        name: list.name,
        color: list.color,
        emoji: list.emoji,
        isDefault: list.isDefault,
        sortOrder: list.sortOrder,
        projectId: list.projectId,
      );

      await _repository.addList(newList);
    } catch (e) {
      _setError('Erro ao criar lista: $e');
      rethrow;
    }
  }

  Future<void> createTask(Task task) async {
    try {
      final newTask = Task.create(
        id: _uuid.v4(),
        title: task.title,
        description: task.description,
        listId: task.listId,
        priority: task.priority,
        isImportant: task.isImportant,
        dueDate: task.dueDate,
        tags: task.tags,
        parentTaskId: task.parentTaskId,
        notes: task.notes,
      );

      await _repository.addTask(newTask);
    } catch (e) {
      _setError('Erro ao criar tarefa: $e');
      rethrow;
    }
  }

  // ============================================================================
  // MÉTODOS UTILITÁRIOS PRIVADOS
  // ============================================================================

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // ============================================================================
  // MÉTODOS PARA DEBUG
  // ============================================================================
  void debugPrintState() {
    print('🔍 TaskController Debug:');
    print('  Projects: ${_projects.length}');
    print('  Lists: ${_lists.length}');
    print('  Filtered Lists: ${lists.length}');
    print('  Tasks: ${_tasks.length}');
    print('  Filtered Tasks: ${tasks.length}');
    print('  Selected Project: $_selectedProjectId');
    print('  Selected List: $_selectedListId');
    print('  Search Query: "$_searchQuery"');
    print('  Loading: $_isLoading');
    print('  Error: $_error');
  }

  /// Método de conveniência para criar uma tarefa com prazo para hoje
  Future<void> addQuickTaskForToday(String title, String? listId) async {
    final today = DateTime.now();
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final formData = {
      'title': title,
      'description': '',
      'listId': listId ?? getDefaultListId(),
      'dueDate': todayEnd,
      'priority': TaskPriority.medium,
      'isImportant': false,
      'tags': <String>[],
      'notes': null,
    };

    await addTask(formData);
  }

  /// Obter ID da lista padrão
  String getDefaultListId() {
    if (_lists.isEmpty) return '';
    // Retornar a primeira lista como padrão
    return _lists.first.id;
  }
}
