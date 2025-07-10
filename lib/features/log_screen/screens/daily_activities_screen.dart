import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/log_controller.dart';
import '../log_model.dart';
import '../widgets/daily_activity_item.dart';
import '../widgets/date_selector.dart';
import '../widgets/daily_summary.dart';
import '../widgets/timeline_view.dart';

/// **DailyActivitiesScreen** - Tela de atividades diárias
///
/// Mostra todas as atividades do dia selecionado em formato cronológico
/// com navegação entre dias e resumo de métricas
class DailyActivitiesScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const DailyActivitiesScreen({Key? key, this.selectedDate}) : super(key: key);

  @override
  State<DailyActivitiesScreen> createState() => _DailyActivitiesScreenState();
}

class _DailyActivitiesScreenState extends State<DailyActivitiesScreen> {
  late DateTime _selectedDate;
  LogFilterStatus _statusFilter = LogFilterStatus.all;
  bool _showTimelineView = false;
  bool _showSummary = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();

    // Garantir que a data selecionada seja apenas dia/mês/ano (sem hora)
    _selectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividades do Dia'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          // Alternar visualização
          IconButton(
            onPressed: () {
              setState(() {
                _showTimelineView = !_showTimelineView;
              });
            },
            icon: Icon(_showTimelineView ? Icons.view_list : Icons.timeline),
            tooltip:
                _showTimelineView
                    ? 'Visualização em Lista'
                    : 'Visualização Timeline',
          ),

          // Alternar resumo
          IconButton(
            onPressed: () {
              setState(() {
                _showSummary = !_showSummary;
              });
            },
            icon: Icon(_showSummary ? Icons.visibility_off : Icons.visibility),
            tooltip: _showSummary ? 'Ocultar Resumo' : 'Mostrar Resumo',
          ),

          // Menu de filtros
          PopupMenuButton<LogFilterStatus>(
            onSelected: (status) {
              setState(() {
                _statusFilter = status;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: LogFilterStatus.all,
                    child: Text('Todas as atividades'),
                  ),
                  const PopupMenuItem(
                    value: LogFilterStatus.active,
                    child: Text('Em andamento'),
                  ),
                  const PopupMenuItem(
                    value: LogFilterStatus.completed,
                    child: Text('Concluídas'),
                  ),
                ],
            icon: Icon(
              Icons.filter_list,
              color:
                  _statusFilter != LogFilterStatus.all
                      ? colorScheme.primary
                      : colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Seletor de data
          DateSelector(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),

          // Conteúdo principal
          Expanded(
            child: Consumer<LogController>(
              builder: (context, logController, child) {
                return StreamBuilder<List<Log>>(
                  stream: _getDailyLogsStream(logController),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar atividades',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final allLogs = snapshot.data ?? [];
                    final filteredLogs = _filterLogs(allLogs);

                    return _buildContent(filteredLogs, logController);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityDialog(),
        tooltip: 'Adicionar atividade',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Obtém o stream de logs para o dia selecionado
  Stream<List<Log>> _getDailyLogsStream(LogController logController) {
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return logController.getLogsByDateRangeStream(startOfDay, endOfDay);
  }

  /// Filtra logs baseado no filtro de status selecionado
  List<Log> _filterLogs(List<Log> logs) {
    if (_statusFilter == LogFilterStatus.all) {
      return logs;
    }

    return logs.where((log) {
      switch (_statusFilter) {
        case LogFilterStatus.active:
          return log.endTime == null;
        case LogFilterStatus.completed:
          return log.endTime != null;
        case LogFilterStatus.all:
          return true;
      }
    }).toList();
  }

  /// Constrói o conteúdo principal baseado nos logs
  Widget _buildContent(List<Log> logs, LogController logController) {
    if (logs.isEmpty) {
      return _buildEmptyState();
    }

    // Ordenar logs por horário de início
    logs.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: [
        // Resumo do dia (se habilitado)
        if (_showSummary) ...[
          DailySummary(logs: logs, date: _selectedDate),
          const Divider(),
        ],

        // Lista de atividades
        Expanded(
          child:
              _showTimelineView
                  ? TimelineView(logs: logs, showEmptySlots: false)
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return DailyActivityItem(
                        log: log,
                        onTap: () => _showLogDetails(log),
                        onEdit: () => _editLog(log),
                        onDelete: () => _deleteLog(log, logController),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  /// Constrói o estado vazio quando não há atividades
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Nenhuma atividade encontrada',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusFilter == LogFilterStatus.all
                ? 'Adicione uma atividade para começar'
                : 'Tente ajustar o filtro para ver mais atividades',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddActivityDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Atividade'),
          ),
        ],
      ),
    );
  }

  /// Mostra detalhes de um log
  void _showLogDetails(Log log) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(log.entityTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo: ${log.entityType}'),
                Text('Lista: ${log.listTitle ?? 'N/A'}'),
                Text('Início: ${_formatTime(log.startTime)}'),
                if (log.endTime != null)
                  Text('Fim: ${_formatTime(log.endTime!)}'),
                if (log.durationMinutes != null)
                  Text('Duração: ${log.durationMinutes} min'),
                if (log.tags.isNotEmpty) Text('Tags: ${log.tags.join(', ')}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  /// Edita um log
  void _editLog(Log log) {
    // TODO: Implementar edição de log
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edição em desenvolvimento')));
  }

  /// Deleta um log
  void _deleteLog(Log log, LogController logController) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text('Deseja excluir a atividade "${log.entityTitle}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  logController.deleteLog(log.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Atividade excluída')),
                  );
                },
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  /// Mostra dialog para adicionar nova atividade
  void _showAddActivityDialog() {
    // TODO: Implementar dialog de adicionar atividade
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adicionar atividade em desenvolvimento')),
    );
  }

  /// Formata horário para exibição
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
