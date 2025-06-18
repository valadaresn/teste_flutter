import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'habit_model.dart';
import 'firebase_habit_repository.dart';

class HabitController extends ChangeNotifier {
  final FirebaseHabitRepository _repository = FirebaseHabitRepository();
  final _uuid = Uuid();
  StreamSubscription? _habitsSubscription;

  // Estado da UI
  bool _isLoading = false;
  String? _error;
  String? _successMessage; // ✅ NOVO: mensagem de sucesso separada
  List<Habit> _habits = [];
  List<String> _selectedFilterTags = [];
  String _searchQuery = '';

  // Opções para formulários
  final List<String> emojiOptions = [
    '💪',
    '🏃',
    '🥗',
    '💧',
    '📚',
    '🧘',
    '😴',
    '🎯',
    '🚫',
    '🎵',
    '🎨',
    '🔥',
    '⭐',
    '🌱',
    '🏆',
    '💡',
  ];

  final List<Color> colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
  ];

  final List<String> dayNames = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];
  final List<String> dayLabels = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage; // ✅ NOVO getter
  List<Habit> get habits => _getFilteredHabits();
  List<String> get selectedFilterTags => _selectedFilterTags;
  String get searchQuery => _searchQuery;
  bool get hasActiveFilters =>
      _selectedFilterTags.isNotEmpty || _searchQuery.isNotEmpty;

  HabitController() {
    _subscribeToHabits();
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToHabits() {
    _setLoading(true);
    _setError(null);

    _habitsSubscription = _repository.getHabitsStream().listen(
      (habits) {
        _habits = habits;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError('Erro ao carregar hábitos: $e');
        _setLoading(false);
      },
    );
  }

  List<Habit> _getFilteredHabits() {
    List<Habit> filtered = _habits;

    // Aplicar filtro de tags
    if (_selectedFilterTags.isNotEmpty) {
      filtered =
          filtered.where((habit) {
            if (_selectedFilterTags.contains('active') && !habit.isActive) {
              return false;
            }
            if (_selectedFilterTags.contains('today') &&
                !habit.shouldShowToday()) {
              return false;
            }
            return true;
          }).toList();
    }

    // Aplicar busca de texto
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered
              .where((habit) => habit.title.toLowerCase().contains(query))
              .toList();
    }

    return filtered;
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  // Métodos de filtro e busca
  void toggleFilterTag(String tag) {
    if (_selectedFilterTags.contains(tag)) {
      _selectedFilterTags.remove(tag);
    } else {
      _selectedFilterTags.add(tag);
    }
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedFilterTags.clear();
    _searchQuery = '';
    notifyListeners();
  }

  // ✅ NOVO: Limpar mensagens
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // CRUD Operations
  Future<bool> addHabitFromDialog(Map<String, dynamic> formData) async {
    try {
      final id = _uuid.v4();
      final habit = Habit.fromFormData(formData, id);
      await _repository.addHabit(habit);
      return true;
    } catch (e) {
      _setError('Erro ao adicionar hábito: $e');
      return false;
    }
  }

  Future<bool> updateHabitFromDialog(
    Habit habit,
    Map<String, dynamic> formData,
  ) async {
    try {
      final updatedHabit = Habit.updateFromForm(habit, formData);
      await _repository.updateHabit(updatedHabit);
      return true;
    } catch (e) {
      _setError('Erro ao atualizar hábito: $e');
      return false;
    }
  }

  Future<bool> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      return true;
    } catch (e) {
      _setError('Erro ao remover hábito: $e');
      return false;
    }
  }

  Future<bool> toggleActive(String id) async {
    try {
      final habit = getHabitById(id);
      if (habit == null) return false;

      await _repository.toggleActive(id, !habit.isActive);

      // ✅ CORRIGIDO: usar successMessage em vez de error
      if (!habit.isActive) {
        _setSuccessMessage('✅ Hábito ativado!');
      } else {
        _setSuccessMessage('⏸️ Hábito pausado!');
      }

      return true;
    } catch (e) {
      _setError('Erro ao alterar status: $e');
      return false;
    }
  }

  Future<bool> toggleTodayCompletion(String id) async {
    try {
      final habit = getHabitById(id);
      if (habit == null) return false;

      final updatedHabit =
          habit.isDoneToday()
              ? habit.unmarkAsDoneToday()
              : habit.markAsDoneToday();

      await _repository.updateHabit(updatedHabit);

      // ✅ FEEDBACK de sucesso
      if (updatedHabit.isDoneToday()) {
        _setSuccessMessage('✅ Hábito marcado como feito hoje!');
      } else {
        _setSuccessMessage('↩️ Hábito desmarcado!');
      }

      return true;
    } catch (e) {
      _setError('Erro ao marcar como feito: $e');
      return false;
    }
  }

  Future<bool> incrementStreak(String id) async {
    try {
      final habit = getHabitById(id);
      if (habit == null) return false;
      await _repository.updateStreak(id, habit.streak + 1);
      return true;
    } catch (e) {
      _setError('Erro ao incrementar sequência: $e');
      return false;
    }
  }

  Future<bool> resetStreak(String id) async {
    try {
      // ✅ CORRIGIDO: usar updateStreak em vez de resetStreak inexistente
      await _repository.updateStreak(id, 0);
      _setSuccessMessage('🔄 Sequência resetada!');
      return true;
    } catch (e) {
      _setError('Erro ao resetar sequência: $e');
      return false;
    }
  }

  String? validateHabitForm(Map<String, dynamic> formData) {
    if (formData['title']?.isEmpty ?? true) {
      return 'Título é obrigatório';
    }
    if (formData['emoji']?.isEmpty ?? true) {
      return 'Emoji é obrigatório';
    }
    if (formData['daysOfWeek']?.isEmpty ?? true) {
      return 'Selecione pelo menos um dia da semana';
    }
    return null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMsg) {
    _error = errorMsg;
    _successMessage = null; // ✅ Limpar success ao setar erro
    notifyListeners();
  }

  // ✅ NOVO: Método para setar mensagem de sucesso
  void _setSuccessMessage(String? message) {
    _successMessage = message;
    _error = null; // ✅ Limpar erro ao setar sucesso
    notifyListeners();
  }
}
