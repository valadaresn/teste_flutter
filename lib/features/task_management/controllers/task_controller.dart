import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/list_model.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  final _uuid = Uuid();

  // StreamSubscriptions - CRÍTICO para evitar piscar
  StreamSubscription? _listsSubscription;
  StreamSubscription? _tasksSubscription;

  // Estado da UI
  bool _isLoading = false;
  String? _error;

  // Dados principais
  List<TaskList> _lists = [];
  List<Task> _tasks = [];
  // Estado de filtros e busca
  String _searchQuery = '';
  String? _selectedListId;
  String? _selectedTaskId;
  bool _showCompletedTasks = true;
  TaskPriority? _selectedPriority;
  bool _showOnlyImportant = false;
  // Getters públicos
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TaskList> get lists => _lists;
  List<Task> get tasks => _getFilteredTasks();
  String get searchQuery => _searchQuery;
  String? get selectedListId => _selectedListId;
  String? get selectedTaskId => _selectedTaskId;
  bool get showCompletedTasks => _showCompletedTasks;
  TaskPriority? get selectedPriority => _selectedPriority;
  bool get showOnlyImportant => _showOnlyImportant;

  // Constructor com StreamSubscription - ITEM #2 das instruções
  TaskController() {
    _subscribeToStreams();
    _repository.createDefaultListIfNeeded();
  }

  // ============================================================================
  // STREAM SUBSCRIPTIONS - CRÍTICO PARA NÃO PISCAR
  // ============================================================================

  void _subscribeToStreams() {
    _setLoading(true);

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
    super.dispose();
  }

  // ============================================================================
  // MÉTODOS ESPECÍFICOS PARA GenericSelectorList - ITEM #5 das instruções
  // ============================================================================

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

  /// Método privado para filtros - NUNCA use where().toList() direto em getters
  List<Task> _getFilteredTasks() {
    List<Task> filtered = _tasks;

    // Filtro por lista selecionada
    if (_selectedListId != null) {
      filtered = filtered.where((task) => task.listId == _selectedListId).toList();
    }

    // Filtro por busca
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((task) => 
        task.title.toLowerCase().contains(query) ||
        task.description.toLowerCase().contains(query)
      ).toList();
    }

    // Filtro por tarefas completas
    if (!_showCompletedTasks) {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }

    // Filtro por prioridade
    if (_selectedPriority != null) {
      filtered = filtered.where((task) => task.priority == _selectedPriority).toList();
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
    return _tasks.where((task) => 
      task.listId == listId && task.parentTaskId == null
    ).toList();
  }

  /// Contar tarefas pendentes em uma lista
  int countPendingTasksInList(String listId) {
    return _tasks.where((task) => 
      task.listId == listId && 
      !task.isCompleted && 
      task.parentTaskId == null
    ).length;
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
  void selectList(String? listId) {
    if (_selectedListId != listId) {
      _selectedListId = listId;
      // Limpar tarefa selecionada ao mudar de lista
      _selectedTaskId = null;
      notifyListeners();
    }
  }

  void selectTask(String? taskId) {
    if (_selectedTaskId != taskId) {
      _selectedTaskId = taskId;
      notifyListeners();
    }
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

  void clearAllFilters() {
    bool hasChanges = false;
    
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
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
    print('  Lists: ${_lists.length}');
    print('  Tasks: ${_tasks.length}');
    print('  Filtered Tasks: ${tasks.length}');
    print('  Selected List: $_selectedListId');
    print('  Search Query: "$_searchQuery"');
    print('  Loading: $_isLoading');
    print('  Error: $_error');
  }
}
