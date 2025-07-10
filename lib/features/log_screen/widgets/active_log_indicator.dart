import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/log_controller.dart';
import '../log_model.dart';

/// **ActiveLogIndicator** - Indicador visual para logs ativos
///
/// Mostra:
/// - Número de logs ativos
/// - Tempo total sendo cronometrado
/// - Indicador visual pulsante
/// - Acesso rápido aos logs ativos
class ActiveLogIndicator extends StatefulWidget {
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool showDetails;

  const ActiveLogIndicator({
    Key? key,
    this.onTap,
    this.padding,
    this.showDetails = true,
  }) : super(key: key);

  @override
  State<ActiveLogIndicator> createState() => _ActiveLogIndicatorState();
}

class _ActiveLogIndicatorState extends State<ActiveLogIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animação pulsante para logs ativos
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar animação em loop
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogController>(
      builder: (context, logController, child) {
        final activeLogs = logController.getActiveLogsList();

        if (activeLogs.isEmpty) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(8),
            child:
                widget.showDetails
                    ? _buildDetailedIndicator(
                      context,
                      logController,
                      activeLogs,
                    )
                    : _buildSimpleIndicator(context, logController, activeLogs),
          ),
        );
      },
    );
  }

  /// Constrói o indicador detalhado com informações completas
  Widget _buildDetailedIndicator(
    BuildContext context,
    LogController logController,
    List<Log> activeLogs,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalElapsed = _calculateTotalElapsed(logController, activeLogs);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone animado
                Icon(
                  Icons.play_circle_filled,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),

                // Informações dos logs
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Número de logs ativos
                    Text(
                      activeLogs.length == 1
                          ? '1 tarefa ativa'
                          : '${activeLogs.length} tarefas ativas',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Tempo total
                    if (totalElapsed.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Total: $totalElapsed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Seta (se tem onTap)
                if (widget.onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.primary,
                    size: 14,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Constrói o indicador simples (apenas badge)
  Widget _buildSimpleIndicator(
    BuildContext context,
    LogController logController,
    List<Log> activeLogs,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, color: colorScheme.onError, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${activeLogs.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Calcula o tempo total de todos os logs ativos
  String _calculateTotalElapsed(
    LogController logController,
    List<Log> activeLogs,
  ) {
    int totalMinutes = 0;

    for (final log in activeLogs) {
      final elapsed = logController.getElapsedTime(log.entityId);
      if (elapsed != null) {
        totalMinutes += elapsed;
      }
    }

    return _formatDuration(totalMinutes);
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

/// **ActiveLogsBadge** - Badge simples para mostrar número de logs ativos
///
/// Versão simplificada do ActiveLogIndicator para uso em AppBars
class ActiveLogsBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const ActiveLogsBadge({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LogController>(
      builder: (context, logController, child) {
        final activeLogs = logController.getActiveLogsList();

        if (activeLogs.isEmpty) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),

                // Badge com número
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${activeLogs.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onError,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// **ActiveLogsList** - Lista expansível de logs ativos
///
/// Para uso em drawers ou bottom sheets
class ActiveLogsList extends StatelessWidget {
  final VoidCallback? onLogTap;
  final bool showActions;

  const ActiveLogsList({Key? key, this.onLogTap, this.showActions = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LogController>(
      builder: (context, logController, child) {
        final activeLogs = logController.getActiveLogsList();

        if (activeLogs.isEmpty) {
          return const Center(child: Text('Nenhum log ativo'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logs Ativos (${activeLogs.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de logs
            Expanded(
              child: ListView.builder(
                itemCount: activeLogs.length,
                itemBuilder: (context, index) {
                  final log = activeLogs[index];
                  final elapsed = logController.getElapsedTimeFormatted(
                    log.entityId,
                  );

                  return ListTile(
                    leading: Icon(
                      Icons.play_circle_filled,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      log.entityTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (log.listTitle != null && log.listTitle!.isNotEmpty)
                          Text(
                            log.listTitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (elapsed != null)
                          Text(
                            'Tempo: $elapsed',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing:
                        showActions
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Pausar/Retomar
                                IconButton(
                                  icon: Icon(
                                    logController.isPomodoroPaused(log.entityId)
                                        ? Icons.play_arrow
                                        : Icons.pause,
                                    size: 20,
                                  ),
                                  onPressed:
                                      () => _togglePause(
                                        context,
                                        logController,
                                        log,
                                      ),
                                ),

                                // Parar
                                IconButton(
                                  icon: const Icon(Icons.stop, size: 20),
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed:
                                      () =>
                                          _stopLog(context, logController, log),
                                ),
                              ],
                            )
                            : null,
                    onTap: onLogTap,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Pausar/retomar log
  void _togglePause(
    BuildContext context,
    LogController logController,
    Log log,
  ) {
    final isPaused = logController.isPomodoroPaused(log.entityId);

    if (isPaused) {
      logController.resumeTaskLog(log.entityId);
    } else {
      logController.pauseTaskLog(log.entityId);
    }
  }

  /// Parar log
  void _stopLog(BuildContext context, LogController logController, Log log) {
    logController.stopTaskLog(log.entityId);
  }
}
