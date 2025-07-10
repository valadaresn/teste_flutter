import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/log_controller.dart';
import '../log_model.dart';
import '../models/filter_state.dart';
import 'day_summary_card.dart';
import 'today_log_item.dart';
import 'filter_modal.dart';

/// **TodayLogsTab** - Aba que mostra os logs do dia selecionado
///
/// Interface:
/// - AppBar clean com seletor de data integrado
/// - Lista de atividades do dia no topo
/// - Resumo do dia no final
class TodayLogsTab extends StatefulWidget {
  const TodayLogsTab({Key? key}) : super(key: key);

  @override
  State<TodayLogsTab> createState() => _TodayLogsTabState();
}

class _TodayLogsTabState extends State<TodayLogsTab> {
  DateTime _selectedDate = DateTime.now();
  FilterState _filterState = const FilterState();

  @override
  void initState() {
    super.initState();
    _loadSavedFilters();
  }

  /// Carrega os filtros salvos da sessão anterior
  Future<void> _loadSavedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filterData = prefs.getString('log_filters');

      if (filterData != null) {
        // TODO: Implementar carregamento real dos filtros salvos
        // final filterMap = Map<String, dynamic>.from(json.decode(filterData));
        // _filterState = FilterState.fromMap(filterMap);

        if (mounted) {
          setState(() {
            // Por enquanto mantém o estado padrão
          });
        }
      }
    } catch (e) {
      // Ignorar erro e manter filtros padrão
    }
  }

  /// Salva os filtros atuais
  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Por enquanto apenas salva que filtros foram aplicados
      await prefs.setBool('has_filters', _filterState.hasActiveFilters);
    } catch (e) {
      // Ignorar erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCleanAppBar(),
      body: Consumer<LogController>(
        builder: (context, logController, child) {
          return StreamBuilder<List<Log>>(
            stream: _getDailyLogsStream(logController),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }

              final logs = snapshot.data ?? [];
              final sortedLogs = _sortLogsByTime(logs);

              return _buildContent(sortedLogs);
            },
          );
        },
      ),
    );
  }

  /// Obtém o stream de logs baseado nos filtros aplicados
  Stream<List<Log>> _getDailyLogsStream(LogController logController) {
    final dateRange = _filterState.getDateRange();

    // Debug: verificar se os filtros estão sendo aplicados
    print('🔍 Aplicando filtros:');
    print('   Período: ${_filterState.period}');
    print('   Data range: ${dateRange.start} - ${dateRange.end}');
    print('   Projetos: ${_filterState.selectedProjectIds}');
    print('   Listas: ${_filterState.selectedListIds}');
    print('   Status: ${_filterState.status}');

    return logController.getFilteredLogsStream(
      startDate: dateRange.start,
      endDate: dateRange.end,
      projectIds:
          _filterState.selectedProjectIds.isEmpty
              ? null
              : _filterState.selectedProjectIds,
      listIds:
          _filterState.selectedListIds.isEmpty
              ? null
              : _filterState.selectedListIds,
      status: _filterState.status,
    );
  }

  /// Ordena os logs por horário de início
  List<Log> _sortLogsByTime(List<Log> logs) {
    final sortedLogs = List<Log>.from(logs);
    sortedLogs.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sortedLogs;
  }

  /// Constrói o conteúdo principal
  Widget _buildContent(List<Log> logs) {
    return Column(
      children: [
        // Lista de logs (no topo)
        Expanded(
          child: logs.isEmpty ? _buildEmptyState() : _buildLogsList(logs),
        ),

        // Resumo do dia (no final)
        DaySummaryCard(logs: logs, date: _selectedDate),
      ],
    );
  }

  /// Constrói o estado vazio
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma atividade registrada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As atividades que você iniciar aparecerão aqui',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Constrói a lista de logs
  Widget _buildLogsList(List<Log> logs) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return TodayLogItem(log: log, onTap: () => _onLogTap(log));
      },
    );
  }

  /// Constrói o estado de loading
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Constrói o estado de erro
  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar atividades',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Ação quando um log é tocado
  void _onLogTap(Log log) {
    // TODO: Implementar ação ao tocar no log
    // Pode abrir detalhes, editar, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log tocado: ${log.entityTitle}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Constrói o AppBar clean com seletor de data integrado
  PreferredSizeWidget _buildCleanAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: _buildDateSelector(),
      centerTitle: true,
      actions: [_buildFilterButton()],
    );
  }

  /// Constrói o seletor de data para o AppBar
  Widget _buildDateSelector() {
    final today = DateTime.now();
    final isToday = _isSameDay(_selectedDate, today);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão anterior
        IconButton(
          onPressed: () => _navigateToDate(-1),
          icon: const Icon(Icons.chevron_left, color: Colors.black87),
        ),

        // Data atual
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDateText(_selectedDate, isToday),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),

        // Botão próximo
        IconButton(
          onPressed: () => _navigateToDate(1),
          icon: const Icon(Icons.chevron_right, color: Colors.black87),
        ),
      ],
    );
  }

  /// Navega para o dia anterior/próximo
  void _navigateToDate(int dayOffset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + dayOffset,
      );
    });
  }

  /// Mostra o seletor de data
  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Formata o texto da data
  String _formatDateText(DateTime date, bool isToday) {
    if (isToday) {
      return 'Hoje';
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    if (_isSameDay(date, yesterday)) {
      return 'Ontem';
    } else if (_isSameDay(date, tomorrow)) {
      return 'Amanhã';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Verifica se duas datas são do mesmo dia
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Mostra a modal de filtros avançados
  void _showFilterModal() async {
    final newFilters = await showModalBottomSheet<FilterState>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => FilterModal(
            currentFilters: _filterState,
            onFiltersChanged: (newFilters) {
              Navigator.pop(context, newFilters);
            },
          ),
    );

    if (newFilters != null) {
      setState(() {
        _filterState = newFilters;

        // Atualizar a data selecionada baseada no período escolhido
        final dateRange = newFilters.getDateRange();
        _selectedDate = dateRange.start;
      });

      // Mostrar confirmação visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Filtros aplicados: ${_getFilterDescription(newFilters)}',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      // Salvar os filtros aplicados
      _saveFilters();
    }
  }

  /// Constrói o botão de filtros com indicador visual
  Widget _buildFilterButton() {
    final hasFilters = _filterState.hasActiveFilters;
    final filterCount = _getActiveFilterCount();

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: hasFilters ? Colors.blue : Colors.black87,
          ),
          onPressed: _showFilterModal,
        ),
        if (hasFilters)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$filterCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  /// Calcula o número de filtros ativos
  int _getActiveFilterCount() {
    int count = 0;

    if (_filterState.period != LogFilterPeriod.today) count++;
    if (_filterState.selectedProjectIds.isNotEmpty) count++;
    if (_filterState.selectedListIds.isNotEmpty) count++;
    if (_filterState.status != LogFilterStatus.all) count++;

    return count;
  }

  /// Gera uma descrição dos filtros aplicados
  String _getFilterDescription(FilterState filters) {
    final List<String> descriptions = [];

    // Período
    switch (filters.period) {
      case LogFilterPeriod.today:
        descriptions.add('Hoje');
        break;
      case LogFilterPeriod.yesterday:
        descriptions.add('Ontem');
        break;
      case LogFilterPeriod.week:
        descriptions.add('Esta Semana');
        break;
      case LogFilterPeriod.month:
        descriptions.add('Este Mês');
        break;
      case LogFilterPeriod.custom:
        descriptions.add('Período Personalizado');
        break;
    }

    // Projetos
    if (filters.selectedProjectIds.isNotEmpty) {
      descriptions.add('${filters.selectedProjectIds.length} projeto(s)');
    }

    // Listas
    if (filters.selectedListIds.isNotEmpty) {
      descriptions.add('${filters.selectedListIds.length} lista(s)');
    }

    // Status
    if (filters.status != LogFilterStatus.all) {
      switch (filters.status) {
        case LogFilterStatus.active:
          descriptions.add('Ativos');
          break;
        case LogFilterStatus.completed:
          descriptions.add('Concluídos');
          break;
        case LogFilterStatus.all:
          break;
      }
    }

    return descriptions.join(', ');
  }
}
