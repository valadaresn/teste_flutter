import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

enum DateFilter { all, today, tomorrow, custom }

class TaskFilters extends ChangeNotifier {
  DateFilter _dateFilter = DateFilter.all;
  bool _showCompleted = true;
  bool _showPending = true;
  DateTime? _customDate;

  DateFilter get dateFilter => _dateFilter;
  bool get showCompleted => _showCompleted;
  bool get showPending => _showPending;
  DateTime? get customDate => _customDate;

  // Construtor com valores iniciais
  TaskFilters({
    DateFilter dateFilter = DateFilter.all,
    bool showCompleted = true,
    bool showPending = true,
    DateTime? customDate,
  }) {
    _dateFilter = dateFilter;
    _showCompleted = showCompleted;
    _showPending = showPending;
    _customDate = customDate;
  }

  // Método para atualizar o filtro de data
  void setDateFilter(DateFilter filter, {DateTime? customDate}) {
    bool changed = false;

    if (_dateFilter != filter) {
      _dateFilter = filter;
      changed = true;
    }

    if (filter == DateFilter.custom &&
        customDate != null &&
        (_customDate == null || !_isSameDay(_customDate!, customDate))) {
      _customDate = customDate;
      changed = true;
    }

    if (changed) {
      _saveFilters();
      notifyListeners();
    }
  }

  // Verificar se duas datas são o mesmo dia (ignorando hora)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Método para atualizar o filtro de tarefas concluídas
  void setShowCompleted(bool show) {
    if (_showCompleted != show) {
      _showCompleted = show;
      _saveFilters();
      notifyListeners();
    }
  }

  // Método para atualizar o filtro de tarefas pendentes
  void setShowPending(bool show) {
    if (_showPending != show) {
      _showPending = show;
      _saveFilters();
      notifyListeners();
    }
  }

  // Método para salvar os filtros nas preferências
  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('date_filter', _dateFilter.index);
    prefs.setBool('show_completed', _showCompleted);
    prefs.setBool('show_pending', _showPending);

    // Salvar a data personalizada, se existir
    if (_customDate != null && _dateFilter == DateFilter.custom) {
      prefs.setInt('custom_date_year', _customDate!.year);
      prefs.setInt('custom_date_month', _customDate!.month);
      prefs.setInt('custom_date_day', _customDate!.day);
      prefs.setBool('has_custom_date', true);
    } else {
      prefs.setBool('has_custom_date', false);
    }
  }

  // Método para carregar filtros salvos
  static Future<TaskFilters> loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();

    final dateFilterIndex = prefs.getInt('date_filter') ?? 0;
    final dateFilter = DateFilter.values[dateFilterIndex];

    final showCompleted = prefs.getBool('show_completed') ?? true;
    final showPending = prefs.getBool('show_pending') ?? true;

    // Carregar data personalizada, se existir
    DateTime? customDate;
    if (prefs.getBool('has_custom_date') == true) {
      final year = prefs.getInt('custom_date_year');
      final month = prefs.getInt('custom_date_month');
      final day = prefs.getInt('custom_date_day');

      if (year != null && month != null && day != null) {
        customDate = DateTime(year, month, day);
      }
    }

    return TaskFilters(
      dateFilter: dateFilter,
      showCompleted: showCompleted,
      showPending: showPending,
      customDate: customDate,
    );
  }

  // Método para verificar se um filtro está ativo
  bool isFilterActive() {
    return _dateFilter != DateFilter.all || !_showCompleted || !_showPending;
  }

  // Método para obter descrição da data selecionada
  String getSelectedDateDescription() {
    switch (_dateFilter) {
      case DateFilter.all:
        return 'Todas';
      case DateFilter.today:
        return 'Hoje';
      case DateFilter.tomorrow:
        return 'Amanhã';
      case DateFilter.custom:
        if (_customDate != null) {
          final day = _customDate!.day.toString().padLeft(2, '0');
          final month = _customDate!.month.toString().padLeft(2, '0');
          final year = _customDate!.year.toString();
          return '$day/$month/$year';
        }
        return 'Data específica';
    }
  }

  // Método para aplicar os filtros a uma lista de tarefas
  List<Task> applyFilters(List<Task> tasks) {
    return tasks.where((task) {
      // Filtrar por status
      if (task.isCompleted && !_showCompleted) return false;
      if (!task.isCompleted && !_showPending) return false;

      // Filtrar por data
      if (_dateFilter != DateFilter.all) {
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final tomorrowStart = todayStart.add(const Duration(days: 1));

        if (_dateFilter == DateFilter.today) {
          if (task.dueDate == null) return false;
          return _isSameDay(task.dueDate!, todayStart);
        }

        if (_dateFilter == DateFilter.tomorrow) {
          if (task.dueDate == null) return false;
          return _isSameDay(task.dueDate!, tomorrowStart);
        }

        if (_dateFilter == DateFilter.custom && _customDate != null) {
          if (task.dueDate == null) return false;
          return _isSameDay(task.dueDate!, _customDate!);
        }
      }

      return true;
    }).toList();
  }
}
