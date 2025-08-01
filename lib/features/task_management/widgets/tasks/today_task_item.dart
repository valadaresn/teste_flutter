import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../models/list_model.dart';
import '../../themes/theme_provider.dart';
import '../../themes/app_theme.dart';
import '../../../log_screen/controllers/log_controller.dart';
import '../../../log_screen/widgets/timer_display.dart';
import 'expansible_group.dart';

/// **TodayTaskItem** - Item de tarefa para a visualização Hoje
///
/// Este componente exibe uma tarefa individual seguindo o padrão:
/// [Checkbox] [Ícone da Lista] [Título da Tarefa] com animação de conclusão
class TodayTaskItem extends StatefulWidget {
  final Task task;
  final TaskController controller;
  final TaskGroupType groupType;
  final bool isSelected;

  const TodayTaskItem({
    Key? key,
    required this.task,
    required this.controller,
    required this.groupType,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<TodayTaskItem> createState() => _TodayTaskItemState();
}

class _TodayTaskItemState extends State<TodayTaskItem>
    with SingleTickerProviderStateMixin {
  bool _isCompletingAnimation = false;
  bool _tempCheckedState = false; // Estado temporário para feedback visual
  bool _isHovered = false; // 🎨 Estado para hover
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Estados para controle do log
  bool _isLoggingAction = false; // Previne cliques múltiplos no botão log

  @override
  void initState() {
    super.initState();

    // Configurar animação
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Determina o estado do checkbox baseado no tipo de grupo
  bool get _checkboxState {
    switch (widget.groupType) {
      case TaskGroupType.today:
      case TaskGroupType.overdue:
        // Durante animação, mostrar estado temporário marcado
        // Caso contrário, sempre desmarcado
        return _isCompletingAnimation ? _tempCheckedState : false;
      case TaskGroupType.completed:
        // No grupo "Concluído", sempre mostrar checked
        return true;
    }
  }

  /// Determina se o checkbox deve estar habilitado baseado no tipo de grupo
  bool get _canToggleCompletion {
    switch (widget.groupType) {
      case TaskGroupType.today:
      case TaskGroupType.overdue:
        // Pode marcar como concluído
        return !_isCompletingAnimation;
      case TaskGroupType.completed:
        // Pode desmarcar (mover de volta para não concluído)
        return !_isCompletingAnimation;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Encontrar a lista à qual a tarefa pertence
    TaskList? list = widget.controller.getListById(widget.task.listId);

    return Consumer<LogController>(
      builder: (context, logController, child) {
        // Estados do log
        final isBeingLogged = logController.isTaskBeingLogged(widget.task.id);
        final elapsedTime = logController.getElapsedTimeFormatted(
          widget.task.id,
        );

        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  // Determinar se deve aplicar borda colorida
                  final shouldShowColorBorder =
                      themeProvider.todayCardStyle ==
                          TodayCardStyle.withColorBorder &&
                      list != null;

                  // Widget com hover que funciona - usando MouseRegion + GestureDetector
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter:
                        (_) =>
                            setState(() => _isHovered = true), // 🎨 Hover enter
                    onExit:
                        (_) =>
                            setState(() => _isHovered = false), // 🎨 Hover exit
                    child: GestureDetector(
                      onTap:
                          () =>
                              _handleCardTap(), // 🚀 Nova função para feedback imediato
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration:
                            widget.isSelected
                                ? BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withOpacity(0.06), // 🎨 Seleção visível
                                  borderRadius: BorderRadius.circular(6.0),
                                  // Adicionar borda colorida se necessário
                                  border:
                                      shouldShowColorBorder
                                          ? Border(
                                            left: BorderSide(
                                              color: list.color,
                                              width: 4,
                                            ),
                                          )
                                          : null,
                                )
                                : _isHovered
                                ? BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withOpacity(0.03), // 🎨 Hover mais claro
                                  borderRadius: BorderRadius.circular(6.0),
                                  border:
                                      shouldShowColorBorder
                                          ? Border(
                                            left: BorderSide(
                                              color: list.color,
                                              width: 4,
                                            ),
                                          )
                                          : null,
                                )
                                : shouldShowColorBorder
                                ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border(
                                    left: BorderSide(
                                      color: list.color,
                                      width: 4,
                                    ),
                                  ),
                                )
                                : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 16.0,
                          ),
                          child: Row(
                            children: [
                              // Checkbox circular
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _checkboxState,
                                  onChanged:
                                      _canToggleCompletion
                                          ? (value) => _toggleTaskCompletion()
                                          : null,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: const CircleBorder(),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Ícone/borda da lista - baseado na preferência do usuário
                              if (list != null)
                                Consumer<ThemeProvider>(
                                  builder: (context, themeProvider, child) {
                                    switch (themeProvider.todayCardStyle) {
                                      case TodayCardStyle.withEmoji:
                                        // Estilo atual - exibe emoji
                                        return Row(
                                          children: [
                                            Text(
                                              list.emoji,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        );
                                      case TodayCardStyle.withColorBorder:
                                        // Novo estilo - apenas espaçamento
                                        // (a borda colorida será aplicada no container principal)
                                        return const SizedBox.shrink();
                                    }
                                  },
                                ),

                              // Título da tarefa
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.task.title,
                                      style: TextStyle(
                                        decoration:
                                            widget.groupType ==
                                                    TaskGroupType.completed
                                                ? TextDecoration.lineThrough
                                                : null,
                                        color:
                                            widget.groupType ==
                                                    TaskGroupType.completed
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color
                                                    ?.withOpacity(0.6)
                                                : Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium?.color,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),

                                    // Timer display (apenas se estiver sendo cronometrado)
                                    if (isBeingLogged &&
                                        elapsedTime != null) ...[
                                      const SizedBox(height: 2),
                                      TimerDisplay(
                                        formattedTime: elapsedTime,
                                        isActive: isBeingLogged,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Botões de controle (apenas para tarefas não concluídas)
                              if (widget.groupType !=
                                  TaskGroupType.completed) ...[
                                const SizedBox(width: 8),

                                // Botão Pause/Resume (apenas se log estiver ativo)
                                if (isBeingLogged) ...[
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap:
                                          _isLoggingAction
                                              ? null
                                              : _pauseResumeTaskLog,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        child: Icon(
                                          logController.isPomodoroPaused(
                                                widget.task.id,
                                              )
                                              ? Icons.play_arrow
                                              : Icons.pause,
                                          size: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface.withOpacity(
                                            0.7,
                                          ), // 🎨 Cor mais suave consistente
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],

                                // Botão Play/Stop principal
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap:
                                        _isLoggingAction
                                            ? null
                                            : _toggleTaskLog,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child:
                                            _isLoggingAction
                                                ? SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                        ),
                                                  ),
                                                )
                                                : Icon(
                                                  isBeingLogged
                                                      ? Icons.stop
                                                      : Icons.play_arrow,
                                                  size: 16,
                                                  color:
                                                      isBeingLogged
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .error
                                                              .withOpacity(
                                                                0.8,
                                                              ) // 🎨 Stop mais suave
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withOpacity(
                                                                0.7,
                                                              ), // 🎨 Play mais suave
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// 🚀 FEEDBACK VISUAL IMEDIATO - Seleciona o card primeiro, depois processa
  void _handleCardTap() {
    // PRIMEIRO: Seleção visual imediata (setState síncrono)
    widget.controller.setSelectedTaskImmediate(widget.task.id);

    // DEPOIS: Processamento das informações (microtask assíncrono)
    Future.microtask(() {
      widget.controller.openTaskInToday(widget.task.id);
    });
  }

  /// Toggle do estado de conclusão da tarefa com animação
  Future<void> _toggleTaskCompletion() async {
    if (_isCompletingAnimation) return; // Evitar cliques múltiplos

    // Determinar se estamos marcando como concluído ou não
    bool willBeCompleted = widget.groupType != TaskGroupType.completed;

    setState(() {
      _isCompletingAnimation = true;
      if (willBeCompleted) {
        // Imediatamente marcar o checkbox como checked para feedback visual
        _tempCheckedState = true;
      }
    });
    if (willBeCompleted) {
      // Delay para mostrar o feedback visual (checkbox marcado)
      await Future.delayed(const Duration(milliseconds: 400));

      // Iniciar animação de fade após o delay visual
      _animationController.forward();

      // Delay adicional para ver a animação antes de atualizar o estado global
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      // Para desmarcar (do grupo concluído), animação reversa
      _animationController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Atualizar o estado global no controller
    widget.controller.toggleTaskCompletion(widget.task.id);

    // Reset do estado de animação
    setState(() {
      _isCompletingAnimation = false;
      _tempCheckedState = false;
    });
  }

  /// Toggle do log da tarefa (Play/Stop)
  Future<void> _toggleTaskLog() async {
    if (_isLoggingAction) return; // Evitar cliques múltiplos

    setState(() {
      _isLoggingAction = true;
    });

    try {
      final logController = context.read<LogController>();
      final isLogged = logController.isTaskBeingLogged(widget.task.id);

      if (isLogged) {
        // Parar log
        await logController.stopTaskLog(widget.task.id);
      } else {
        // Iniciar log
        final taskList = widget.controller.getListById(widget.task.listId);
        await logController.startTaskLog(widget.task, taskList: taskList);
      }
    } catch (e) {
      // Mostrar erro se necessário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerenciar log: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingAction = false;
        });
      }
    }
  }

  /// Pausar/retomar log da tarefa
  Future<void> _pauseResumeTaskLog() async {
    if (_isLoggingAction) return; // Evitar cliques múltiplos

    setState(() {
      _isLoggingAction = true;
    });

    try {
      final logController = context.read<LogController>();
      final isPaused = logController.isPomodoroPaused(widget.task.id);

      if (isPaused) {
        // Retomar log
        await logController.resumeTaskLog(widget.task.id);
      } else {
        // Pausar log
        await logController.pauseTaskLog(widget.task.id);
      }
    } catch (e) {
      // Mostrar erro se necessário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao pausar/retomar log: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingAction = false;
        });
      }
    }
  }
}
