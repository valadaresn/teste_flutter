import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/log_controller.dart';
import '../log_model.dart';

/// **LogStatistics** - Widget para exibir estatísticas e métricas dos logs
///
/// Exibe:
/// - Tempo total trabalhado no período
/// - Distribuição por tarefa/projeto
/// - Gráficos simples de produtividade
/// - Métricas de foco e eficiência
class LogStatistics extends StatelessWidget {
  final List<Log> logs;
  final DateTime startDate;
  final DateTime endDate;

  const LogStatistics({
    Key? key,
    required this.logs,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<LogController>(
      builder: (context, logController, child) {
        final metrics = _calculateMetrics();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Estatísticas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Métricas principais
                _buildMainMetrics(context, metrics),
                const SizedBox(height: 20),

                // Distribuição por tarefa
                if (metrics.taskDistribution.isNotEmpty) ...[
                  _buildTaskDistribution(context, metrics),
                  const SizedBox(height: 20),
                ],

                // Distribuição por lista/projeto
                if (metrics.listDistribution.isNotEmpty) ...[
                  _buildListDistribution(context, metrics),
                  const SizedBox(height: 20),
                ],

                // Gráfico de atividade por dia
                _buildDailyActivity(context, metrics),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Constrói as métricas principais (tempo total, média, etc.)
  Widget _buildMainMetrics(BuildContext context, _LogMetrics metrics) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Tempo total
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.access_time,
            label: 'Tempo Total',
            value: _formatDuration(metrics.totalMinutes),
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),

        // Número de sessões
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.play_circle_outline,
            label: 'Sessões',
            value: '${metrics.sessionCount}',
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),

        // Tempo médio por sessão
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.trending_up,
            label: 'Média/Sessão',
            value: _formatDuration(metrics.averageSessionMinutes),
            color: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  /// Constrói um card de métrica individual
  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Constrói a distribuição por tarefa
  Widget _buildTaskDistribution(BuildContext context, _LogMetrics metrics) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribuição por Tarefa',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Lista das top 5 tarefas
        ...metrics.taskDistribution.entries
            .take(5)
            .map(
              (entry) => _buildDistributionItem(
                context,
                title: entry.key,
                minutes: entry.value,
                total: metrics.totalMinutes,
              ),
            )
            .toList(),
      ],
    );
  }

  /// Constrói a distribuição por lista/projeto
  Widget _buildListDistribution(BuildContext context, _LogMetrics metrics) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribuição por Lista',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Lista das top 5 listas
        ...metrics.listDistribution.entries
            .take(5)
            .map(
              (entry) => _buildDistributionItem(
                context,
                title: entry.key,
                minutes: entry.value,
                total: metrics.totalMinutes,
              ),
            )
            .toList(),
      ],
    );
  }

  /// Constrói um item de distribuição individual
  Widget _buildDistributionItem(
    BuildContext context, {
    required String title,
    required int minutes,
    required int total,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = total > 0 ? (minutes / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Título
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // Barra de progresso
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),

          // Tempo e porcentagem
          SizedBox(
            width: 80,
            child: Text(
              '${_formatDuration(minutes)} (${percentage.toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o gráfico de atividade diária
  Widget _buildDailyActivity(BuildContext context, _LogMetrics metrics) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atividade Diária',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Gráfico simplificado com barras
        Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: _buildSimpleBarChart(context, metrics.dailyMinutes),
        ),
      ],
    );
  }

  /// Constrói um gráfico de barras simples
  Widget _buildSimpleBarChart(
    BuildContext context,
    Map<DateTime, int> dailyData,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (dailyData.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma atividade registrada',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      );
    }

    final maxMinutes = dailyData.values.reduce((a, b) => a > b ? a : b);
    final entries =
        dailyData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          entries.map((entry) {
            final height =
                maxMinutes > 0 ? (entry.value / maxMinutes * 60) : 0.0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tooltip com valor
                    if (entry.value > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(entry.value),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],

                    // Barra
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color:
                            entry.value > 0
                                ? colorScheme.primary
                                : colorScheme.surfaceVariant,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Label do dia
                    Text(
                      '${entry.key.day}',
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  /// Calcula as métricas baseadas na lista de logs
  _LogMetrics _calculateMetrics() {
    final taskDistribution = <String, int>{};
    final listDistribution = <String, int>{};
    final dailyMinutes = <DateTime, int>{};

    int totalMinutes = 0;
    int sessionCount = 0;

    for (final log in logs) {
      if (log.durationMinutes != null && log.durationMinutes! > 0) {
        final minutes = log.durationMinutes!;
        totalMinutes += minutes;
        sessionCount++;

        // Distribuição por tarefa
        taskDistribution[log.entityTitle] =
            (taskDistribution[log.entityTitle] ?? 0) + minutes;

        // Distribuição por lista
        if (log.listTitle != null && log.listTitle!.isNotEmpty) {
          listDistribution[log.listTitle!] =
              (listDistribution[log.listTitle!] ?? 0) + minutes;
        }

        // Distribuição diária
        final date = DateTime(
          log.startTime.year,
          log.startTime.month,
          log.startTime.day,
        );
        dailyMinutes[date] = (dailyMinutes[date] ?? 0) + minutes;
      }
    }

    // Ordenar por valor decrescente
    final sortedTasks = Map.fromEntries(
      taskDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    final sortedLists = Map.fromEntries(
      listDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return _LogMetrics(
      totalMinutes: totalMinutes,
      sessionCount: sessionCount,
      averageSessionMinutes:
          sessionCount > 0 ? (totalMinutes / sessionCount).round() : 0,
      taskDistribution: sortedTasks,
      listDistribution: sortedLists,
      dailyMinutes: dailyMinutes,
    );
  }

  /// Formata duração em minutos para string legível
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }
}

/// Classe para armazenar métricas calculadas
class _LogMetrics {
  final int totalMinutes;
  final int sessionCount;
  final int averageSessionMinutes;
  final Map<String, int> taskDistribution;
  final Map<String, int> listDistribution;
  final Map<DateTime, int> dailyMinutes;

  _LogMetrics({
    required this.totalMinutes,
    required this.sessionCount,
    required this.averageSessionMinutes,
    required this.taskDistribution,
    required this.listDistribution,
    required this.dailyMinutes,
  });
}
