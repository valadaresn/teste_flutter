import 'package:flutter/material.dart';
import '../log_model.dart';

/// **DailySummary** - Widget de resumo do dia
///
/// Mostra métricas e estatísticas das atividades do dia
class DailySummary extends StatelessWidget {
  final List<Log> logs;
  final DateTime date;

  const DailySummary({Key? key, required this.logs, required this.date})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final metrics = _calculateMetrics();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(Icons.analytics, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Resumo do Dia',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Métricas principais
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.access_time,
                  title: 'Tempo Total',
                  value: metrics['totalTimeText'],
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.list_alt,
                  title: 'Atividades',
                  value: '${metrics['totalActivities']}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.task_alt,
                  title: 'Tarefas',
                  value: '${metrics['uniqueTasks']}',
                  color: Colors.green,
                ),
              ),
            ],
          ),

          // Métricas secundárias
          if (logs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryMetric(
                    context,
                    'Atividade mais longa',
                    metrics['longestActivityText'],
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSecondaryMetric(
                    context,
                    'Tempo médio',
                    metrics['averageTimeText'],
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ],

          // Distribuição por categoria
          if (metrics['categoryDistribution'].isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Distribuição por Categoria',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildCategoryDistribution(
              context,
              metrics['categoryDistribution'],
            ),
          ],
        ],
      ),
    );
  }

  /// Constrói um card de métrica principal
  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Constrói uma métrica secundária
  Widget _buildSecondaryMetric(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói a distribuição por categoria
  Widget _buildCategoryDistribution(
    BuildContext context,
    Map<String, int> distribution,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final total = distribution.values.fold(0, (sum, value) => sum + value);

    return Column(
      children:
          distribution.entries.map((entry) {
            final percentage = (entry.value / total * 100).round();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(entry.key, style: theme.textTheme.bodySmall),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: colorScheme.outline.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// Calcula métricas do dia
  Map<String, dynamic> _calculateMetrics() {
    if (logs.isEmpty) {
      return {
        'totalMinutes': 0,
        'totalTimeText': '0min',
        'totalActivities': 0,
        'uniqueTasks': 0,
        'longestActivityText': '-',
        'averageTimeText': '-',
        'categoryDistribution': <String, int>{},
      };
    }

    // Calcular tempo total usando getters da model
    final totalMinutes = logs.fold(0, (sum, log) {
      if (log.isCompleted) {
        return sum + (log.durationInMinutes ?? 0);
      } else {
        // Atividade em andamento
        final elapsed = DateTime.now().difference(log.startTime);
        return sum + elapsed.inMinutes;
      }
    });

    // Atividades únicas
    final uniqueTasks = logs.map((log) => log.entityId).toSet().length;

    // Atividade mais longa usando getters da model
    final longestActivity = logs.reduce((a, b) {
      final aDuration = a.durationInMinutes ?? 0;
      final bDuration = b.durationInMinutes ?? 0;
      return aDuration > bDuration ? a : b;
    });

    // Tempo médio
    final averageMinutes = totalMinutes / logs.length;

    // Distribuição por categoria
    final categoryDistribution = <String, int>{};
    for (final log in logs) {
      final category = log.listTitle ?? 'Sem categoria';
      categoryDistribution[category] =
          (categoryDistribution[category] ?? 0) + 1;
    }

    return {
      'totalMinutes': totalMinutes,
      'totalTimeText': _formatDuration(totalMinutes),
      'totalActivities': logs.length,
      'uniqueTasks': uniqueTasks,
      'longestActivityText': _formatDuration(
        longestActivity.durationInMinutes ?? 0,
      ),
      'averageTimeText': _formatDuration(averageMinutes.round()),
      'categoryDistribution': categoryDistribution,
    };
  }

  /// Formata duração em minutos para string legível
  String _formatDuration(int minutes) {
    if (minutes == 0) return '0min';

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
