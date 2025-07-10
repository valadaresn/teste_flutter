import 'package:flutter/material.dart';
import '../log_model.dart';

/// **DaySummaryCard** - Card com resumo das atividades do dia
///
/// Mostra: ⏱️ 4h 30min | 📝 8 atividades | 🎯 6 tarefas
class DaySummaryCard extends StatelessWidget {
  final List<Log> logs;
  final DateTime date;

  const DaySummaryCard({Key? key, required this.logs, required this.date})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metrics = _calculateMetrics();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Métricas
          if (logs.isEmpty)
            _buildEmptyState(theme, colorScheme)
          else
            _buildMetrics(theme, colorScheme, metrics),
        ],
      ),
    );
  }

  /// Constrói o estado vazio
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Nenhuma atividade registrada',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// Constrói as métricas
  Widget _buildMetrics(
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, dynamic> metrics,
  ) {
    return Row(
      children: [
        // Tempo total
        _buildMetricItem(
          theme,
          colorScheme,
          Icons.access_time,
          metrics['totalTime'],
          'Tempo total',
        ),

        const SizedBox(width: 24),

        // Número de atividades
        _buildMetricItem(
          theme,
          colorScheme,
          Icons.list,
          '${metrics['totalActivities']}',
          'Atividades',
        ),

        const SizedBox(width: 24),

        // Número de tarefas únicas
        _buildMetricItem(
          theme,
          colorScheme,
          Icons.task,
          '${metrics['uniqueTasks']}',
          'Tarefas',
        ),
      ],
    );
  }

  /// Constrói um item de métrica
  Widget _buildMetricItem(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Calcula as métricas do dia
  Map<String, dynamic> _calculateMetrics() {
    if (logs.isEmpty) {
      return {'totalTime': '0min', 'totalActivities': 0, 'uniqueTasks': 0};
    }

    // Calcular tempo total
    final totalMinutes = logs.fold<int>(
      0,
      (sum, log) => sum + (log.durationMinutes ?? 0),
    );

    // Formatar tempo
    final totalTime = _formatDuration(totalMinutes);

    // Contar atividades
    final totalActivities = logs.length;

    // Contar tarefas únicas
    final uniqueTasks = logs.map((log) => log.entityId).toSet().length;

    return {
      'totalTime': totalTime,
      'totalActivities': totalActivities,
      'uniqueTasks': uniqueTasks,
    };
  }

  /// Formata a duração em formato legível
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${remainingMinutes}min';
    }
  }
}
