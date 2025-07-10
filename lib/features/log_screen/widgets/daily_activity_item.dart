import 'package:flutter/material.dart';
import '../log_model.dart';

/// **DailyActivityItem** - Item de atividade na lista diária
///
/// Mostra informações detalhadas de uma atividade com horário,
/// duração, status e ações disponíveis
class DailyActivityItem extends StatelessWidget {
  final Log log;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DailyActivityItem({
    Key? key,
    required this.log,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = log.endTime == null;
    final statusColor = _getStatusColor(colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna de horário
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(log.startTime),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (log.endTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(log.endTime!),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getDurationText(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Linha vertical conectora
              Container(
                width: 3,
                height: 60,
                margin: const EdgeInsets.only(left: 8, right: 16),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Conteúdo principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da atividade
                    Text(
                      log.entityTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Informações da lista/projeto
                    Row(
                      children: [
                        Icon(
                          _getEntityIcon(),
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            log.listTitle ?? 'Sem categoria',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(theme, colorScheme),
                      ],
                    ),

                    // Tags (se existirem)
                    if (log.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children:
                            log.tags.take(3).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall,
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Botões de ação
              PopupMenuButton<String>(
                onSelected: (action) {
                  switch (action) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                    case 'continue':
                      // TODO: Implementar continuar atividade
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      if (isActive) ...[
                        const PopupMenuItem(
                          value: 'continue',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow, size: 16),
                              SizedBox(width: 8),
                              Text('Continuar'),
                            ],
                          ),
                        ),
                      ],
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o chip de status
  Widget _buildStatusChip(ThemeData theme, ColorScheme colorScheme) {
    final isActive = log.endTime == null;
    final statusColor = _getStatusColor(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Em andamento' : 'Concluída',
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtém a cor baseada no status
  Color _getStatusColor(ColorScheme colorScheme) {
    final isActive = log.endTime == null;

    if (isActive) {
      return colorScheme.primary; // Azul para ativo
    } else {
      return Colors.green; // Verde para concluído
    }
  }

  /// Obtém o ícone baseado no tipo de entidade
  IconData _getEntityIcon() {
    switch (log.entityType.toLowerCase()) {
      case 'task':
        return Icons.task_alt;
      case 'habit':
        return Icons.repeat;
      case 'note':
        return Icons.note;
      case 'project':
        return Icons.work;
      default:
        return Icons.circle;
    }
  }

  /// Obtém o texto de duração
  String _getDurationText() {
    if (log.endTime == null) {
      // Atividade em andamento - calcular tempo decorrido
      final elapsed = DateTime.now().difference(log.startTime);
      return _formatDuration(elapsed.inMinutes);
    } else {
      // Atividade concluída - usar duração armazenada
      final duration = log.durationMinutes ?? 0;
      return _formatDuration(duration);
    }
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

  /// Formata horário para exibição
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
