import 'package:flutter/material.dart';
import '../log_model.dart';

/// **TodayLogItem** - Item individual da lista de logs do dia
///
/// Mostra um log em formato de linha simples:
/// 🕘 09:00 - 09:25 (25min) | 📋 Título | 📂 Categoria • Status
class TodayLogItem extends StatelessWidget {
  final Log log;
  final VoidCallback? onTap;

  const TodayLogItem({Key? key, required this.log, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calcular duração
    final durationText = _formatDuration();

    // Cor do fundo baseada no status
    final backgroundColor = _getStatusColor(colorScheme);

    // Formatação do horário
    final startTime = _formatTime(log.startTime);
    final endTime = log.endTime != null ? _formatTime(log.endTime!) : 'Agora';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Horário e duração
                Text(
                  '$startTime-$endTime $durationText',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(width: 16),

                // Título da tarefa
                Expanded(
                  child: Text(
                    log.entityTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 12),

                // Emoji da lista
                _getListEmoji(),

                const SizedBox(width: 12),

                // Status (apenas ícone)
                _buildStatusIcon(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retorna a cor de fundo baseada no status
  Color _getStatusColor(ColorScheme colorScheme) {
    if (log.endTime == null) {
      // Em andamento
      return colorScheme.primaryContainer.withOpacity(0.3);
    } else {
      // Concluído
      return colorScheme.secondaryContainer.withOpacity(0.3);
    }
  }

  /// Constrói apenas o ícone de status
  Widget _buildStatusIcon(ColorScheme colorScheme) {
    final isActive = log.endTime == null;
    final statusIcon = isActive ? Icons.play_circle : Icons.check_circle;
    final statusColor = isActive ? colorScheme.primary : colorScheme.secondary;

    return Icon(statusIcon, size: 18, color: statusColor);
  }

  /// Retorna o emoji da lista
  Widget _getListEmoji() {
    // Por enquanto, vamos usar um emoji padrão baseado no nome da lista
    // TODO: Implementar busca real do emoji quando o TaskController for integrado
    final listTitle = log.listTitle?.toLowerCase() ?? '';

    if (listTitle.contains('trabalho') || listTitle.contains('work')) {
      return const Text('💼', style: TextStyle(fontSize: 16));
    } else if (listTitle.contains('estudo') || listTitle.contains('study')) {
      return const Text('📚', style: TextStyle(fontSize: 16));
    } else if (listTitle.contains('pessoal') ||
        listTitle.contains('personal')) {
      return const Text('👤', style: TextStyle(fontSize: 16));
    } else if (listTitle.contains('exercicio') ||
        listTitle.contains('fitness')) {
      return const Text('🏃', style: TextStyle(fontSize: 16));
    } else if (listTitle.contains('casa') || listTitle.contains('home')) {
      return const Text('🏠', style: TextStyle(fontSize: 16));
    } else if (listTitle.contains('compras') ||
        listTitle.contains('shopping')) {
      return const Text('🛒', style: TextStyle(fontSize: 16));
    } else {
      return const Text('📁', style: TextStyle(fontSize: 16));
    }
  }

  /// Formata a duração do log
  String _formatDuration() {
    // Se temos durationMinutes, usar diretamente
    if (log.durationMinutes != null && log.durationMinutes! > 0) {
      final hours = log.durationMinutes! ~/ 60;
      final minutes = log.durationMinutes! % 60;

      if (hours > 0) {
        return '(${hours}h ${minutes}min)';
      } else {
        return '(${minutes}min)';
      }
    }
    // Se não temos durationMinutes mas temos startTime e endTime
    else if (log.endTime != null) {
      final duration = log.endTime!.difference(log.startTime);
      final totalMinutes = duration.inMinutes;
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;

      if (hours > 0) {
        return '(${hours}h ${minutes}min)';
      } else {
        return '(${totalMinutes}min)';
      }
    }
    // Se estiver em andamento
    else {
      return '(ativo)';
    }
  }

  /// Formata o horário no formato HH:MM
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
