import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../log_model.dart';

/// **LogListItem** - Widget para exibir um item individual de log
///
/// Mostra informações do log com design consistente
class LogListItem extends StatelessWidget {
  final Log log;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const LogListItem({
    Key? key,
    required this.log,
    this.onTap,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = log.endTime != null;
    final duration = log.durationMinutes ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com título e status
              Row(
                children: [
                  // Ícone de status
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Título da tarefa
                  Expanded(
                    child: Text(
                      log.entityTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Duração
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDuration(duration),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Informações detalhadas
              Row(
                children: [
                  // Lista/Projeto
                  if (log.listTitle != null) ...[
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log.listTitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Data/Hora de início
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(log.startTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? theme.colorScheme.primaryContainer.withOpacity(
                                0.5,
                              )
                              : theme.colorScheme.secondaryContainer
                                  .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCompleted ? 'Concluído' : 'Em andamento',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            isCompleted
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Tags (se houver)
              if (log.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      log.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],

              // Ações (se fornecidas)
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        iconSize: 20,
                        tooltip: 'Editar',
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 20,
                        tooltip: 'Excluir',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Formata duração em minutos para formato legível
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

  /// Formata data/hora para exibição
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (logDate == today) {
      return 'Hoje ${DateFormat('HH:mm').format(dateTime)}';
    } else if (logDate == yesterday) {
      return 'Ontem ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd/MM HH:mm').format(dateTime);
    }
  }
}
