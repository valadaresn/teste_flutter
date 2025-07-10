import 'package:flutter/material.dart';
import '../log_model.dart';

/// **TimelineView** - Widget de visualização em linha do tempo
///
/// Mostra atividades em formato de timeline com blocos visuais
class TimelineView extends StatelessWidget {
  final List<Log> logs;
  final bool showEmptySlots;

  const TimelineView({
    Key? key,
    required this.logs,
    this.showEmptySlots = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (logs.isEmpty) {
      return _buildEmptyTimeline(context);
    }

    // Ordenar logs por horário
    final sortedLogs = List<Log>.from(logs)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              Icon(Icons.timeline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Timeline do Dia',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timeline visual
          _buildTimeline(context, sortedLogs),
        ],
      ),
    );
  }

  /// Constrói a timeline visual
  Widget _buildTimeline(BuildContext context, List<Log> sortedLogs) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Cabeçalho com escala de horas
          _buildTimeScale(context),

          // Separador
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),

          // Área de atividades
          Container(
            height: 400,
            child: _buildTimelineContent(context, sortedLogs),
          ),
        ],
      ),
    );
  }

  /// Constrói a escala de horas
  Widget _buildTimeScale(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(24, (hour) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '${hour.toString().padLeft(2, '0')}h',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Constrói o conteúdo da timeline
  Widget _buildTimelineContent(BuildContext context, List<Log> sortedLogs) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // Linhas de grade das horas
        _buildHourGrid(context),

        // Blocos de atividades
        ...sortedLogs.map((log) => _buildActivityBlock(context, log)),
      ],
    );
  }

  /// Constrói a grade de horas
  Widget _buildHourGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(24, (hour) {
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Constrói um bloco de atividade
  Widget _buildActivityBlock(BuildContext context, Log log) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calcular posição e tamanho
    final startHour = log.startTime.hour + (log.startTime.minute / 60);
    final endHour = log.endTime?.hour ?? DateTime.now().hour;
    final endMinute = log.endTime?.minute ?? DateTime.now().minute;
    final actualEndHour = endHour + (endMinute / 60);

    final duration = actualEndHour - startHour;
    final left = startHour / 24;
    final width = duration / 24;

    final isActive = log.endTime == null;
    final color = isActive ? colorScheme.primary : Colors.green;

    return Positioned(
      left: left * MediaQuery.of(context).size.width * 0.9,
      width: width * MediaQuery.of(context).size.width * 0.9,
      top: 20,
      height: 60,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.entityTitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatTime(log.startTime)} - ${log.endTime != null ? _formatTime(log.endTime!) : 'Agora'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                ),
              ),
              if (log.listTitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  log.listTitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói timeline vazia
  Widget _buildEmptyTimeline(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Timeline Vazia',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione atividades para visualizar a timeline do dia',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Formata horário
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
