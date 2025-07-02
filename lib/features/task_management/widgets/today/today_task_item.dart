import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../models/list_model.dart';
import 'expansible_task_group.dart';

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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration:
                widget.isSelected
                    ? BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6.0),
                    )
                    : null,
            child: GestureDetector(
              onTap: () => widget.controller.openTaskInToday(widget.task.id),
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
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Ícone da lista - apenas emoji simples
                    if (list != null) ...[
                      Text(list.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                    ],

                    // Título da tarefa
                    Expanded(
                      child: Text(
                        widget.task.title,
                        style: TextStyle(
                          decoration:
                              widget.groupType == TaskGroupType.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                          color:
                              widget.groupType == TaskGroupType.completed
                                  ? Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color?.withOpacity(0.6)
                                  : Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
}
