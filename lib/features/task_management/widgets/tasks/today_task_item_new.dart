import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../models/list_model.dart';

/// **TodayTaskItem** - Item de tarefa para a visualização Hoje
///
/// Este componente exibe uma tarefa individual seguindo o padrão:
/// [Checkbox] [Ícone da Lista] [Título da Tarefa] com animação de conclusão
class TodayTaskItem extends StatefulWidget {
  final Task task;
  final TaskController controller;

  const TodayTaskItem({Key? key, required this.task, required this.controller})
    : super(key: key);

  @override
  State<TodayTaskItem> createState() => _TodayTaskItemState();
}

class _TodayTaskItemState extends State<TodayTaskItem>
    with SingleTickerProviderStateMixin {
  bool _isCompletingAnimation = false;
  bool _localCompletionState = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _localCompletionState = widget.task.isCompleted;

    // Configurar animação
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

  @override
  void didUpdateWidget(TodayTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualizar estado local se a tarefa mudou externamente
    if (oldWidget.task.isCompleted != widget.task.isCompleted) {
      _localCompletionState = widget.task.isCompleted;
      _isCompletingAnimation = false;
      _animationController.reset();
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
          child: GestureDetector(
            onTap: () => widget.controller.navigateToTask(widget.task.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              child: Row(
                children: [
                  // Checkbox simples
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _localCompletionState,
                      onChanged:
                          _isCompletingAnimation
                              ? null
                              : (value) => _toggleTaskCompletion(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                            _localCompletionState
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            _localCompletionState
                                ? Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color?.withOpacity(0.6)
                                : Theme.of(context).textTheme.bodyMedium?.color,
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
        );
      },
    );
  }

  /// Toggle do estado de conclusão da tarefa com animação
  Future<void> _toggleTaskCompletion() async {
    if (_isCompletingAnimation) return; // Evitar cliques múltiplos

    setState(() {
      _isCompletingAnimation = true;
      _localCompletionState = !_localCompletionState;
    });

    // Iniciar animação de fade
    if (_localCompletionState) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    // Delay para ver a animação antes de atualizar o estado global
    await Future.delayed(const Duration(milliseconds: 400));

    // Atualizar o estado global no controller
    widget.controller.toggleTaskCompletion(widget.task.id);

    // Reset do estado de animação
    setState(() {
      _isCompletingAnimation = false;
    });
  }
}
