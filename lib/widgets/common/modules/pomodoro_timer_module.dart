import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/notification_utils.dart';
import '../../../utils/widget_mods.dart';
import '../../../features/log_screen/controllers/log_controller.dart';
import '../../../features/task_management/models/task_model.dart';
import '../../../features/habit_screen/habit_model.dart';

/// 🍅 **PomodoroTimerModule** - Módulo plugável de timer/pomodoro
///
/// **FUNCIONALIDADE:**
/// - Timer com countdown regressivo
/// - Notificações do sistema quando completa
/// - Interface visual customizável (ícones, cores, tamanhos)
/// - Controles play/stop com animação
/// - Formatação automática de tempo
///
/// **USADO POR:**
/// - HabitCard - para cronometrar hábitos
/// - TaskCard - para pomodoros de tarefas
/// - Qualquer widget que precise de timer
///
/// **EXEMPLO DE USO:**
/// ```dart
/// // Para Task
/// PomodoroTimerModule(
///   task: myTask,
///   listTitle: myList.name,
///   targetSeconds: 1500, // 25 minutos
///   color: Colors.blue,
///   shouldLog: true,
/// )
/// 
/// // Para Habit
/// PomodoroTimerModule(
///   habit: myHabit,
///   targetSeconds: 1200, // 20 minutos
///   color: Colors.green,
///   shouldLog: true,
/// )
/// ```
class PomodoroTimerModule extends StatefulWidget {
  // 🆕 Recebe objetos diretamente (muito mais limpo!)
  final Task? task;           // Para tarefas
  final Habit? habit;         // Para hábitos
  final String? listTitle;    // Contexto da lista (só para tasks)
  
  // Parâmetros básicos
  final int targetSeconds;
  final Color color;
  final bool shouldLog;
  final VoidCallback? onComplete;
  final VoidCallback? onToggleCompletion;

  // 🔄 Mantido para compatibilidade (será removido em versões futuras)
  final String? habitTitle;

  const PomodoroTimerModule({
    super.key,
    this.task,
    this.habit,
    this.listTitle,
    required this.targetSeconds,
    required this.color,
    this.shouldLog = false,
    this.onComplete,
    this.onToggleCompletion,
    @Deprecated('Use task.title ou habit.title') this.habitTitle,
  }) : assert(
         task != null || habit != null || habitTitle != null,
         'Deve fornecer task, habit ou habitTitle (legacy)',
       );

  @override
  State<PomodoroTimerModule> createState() => _PomodoroTimerModuleState();
}

class _PomodoroTimerModuleState extends State<PomodoroTimerModule> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  bool _isHovered = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() async {
    // 🆕 Acionar log se habilitado
    if (widget.shouldLog && mounted) {
      try {
        final logController = Provider.of<LogController>(context, listen: false);
        
        if (widget.task != null) {
          // 🎯 Mapeia Task para startEntityLog
          await logController.startEntityLog(
            entityId: widget.task!.id,
            entityType: 'task',
            entityTitle: widget.task!.title,
            listId: widget.task!.listId,
            listTitle: widget.listTitle,
            parentId: widget.task!.parentTaskId,
            tags: widget.task!.tags,
            metrics: {
              'priority': widget.task!.priority.name,
              'isImportant': widget.task!.isImportant,
            },
            pomodoroTimeMinutes: widget.task!.pomodoroTimeMinutes,
          );
        } else if (widget.habit != null) {
          // 🎯 Mapeia Habit para startEntityLog
          await logController.startEntityLog(
            entityId: widget.habit!.id,
            entityType: 'habit',
            entityTitle: widget.habit!.title,
            listTitle: 'Hábito',
            tags: [], // Hábitos não têm tags por enquanto
            metrics: {
              'streak': widget.habit!.streak,
              'bestStreak': widget.habit!.bestStreak,
              'hasTimer': widget.habit!.hasTimer,
            },
            pomodoroTimeMinutes: widget.habit!.targetTime ?? 25,
          );
        }
      } catch (e) {
        debugPrint('Erro ao iniciar log: $e');
      }
    }
    
    setState(() {
      _remainingSeconds = widget.targetSeconds;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer();
          _showTimerCompleteNotification();
        }
      });
    });
  }

  void _stopTimer() async {
    // 🆕 Parar log se habilitado
    if (widget.shouldLog && mounted) {
      try {
        final logController = Provider.of<LogController>(context, listen: false);
        
        String? entityId;
        if (widget.task != null) {
          entityId = widget.task!.id;
        } else if (widget.habit != null) {
          entityId = widget.habit!.id;
        }
        
        if (entityId != null && logController.isTaskBeingLogged(entityId)) {
          await logController.stopTaskLog(entityId);
        }
      } catch (e) {
        debugPrint('Erro ao parar log: $e');
      }
    }
    
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
    });
  }

  void _showTimerCompleteNotification() async {
    // 🔔 Título da entidade (Task, Habit ou fallback)
    String entityTitle = 'Timer';
    if (widget.task != null) {
      entityTitle = widget.task!.title;
    } else if (widget.habit != null) {
      entityTitle = widget.habit!.title;
    } else if (widget.habitTitle != null) {
      entityTitle = widget.habitTitle!;
    }

    await showCustomNotification(
      context: context,
      title: '⏰ Timer Concluído!',
      message: '🎉 $entityTitle - Timer finalizado!',
      color: widget.color,
      icon: Icons.timer_off,
      actionLabel: 'Marcar como feito',
      onAction: widget.onToggleCompletion,
    );

    // Callback customizado
    widget.onComplete?.call();
  }

  /// ⏱️ Formata tempo em MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer label à esquerda do botão
          if (_isTimerRunning || _isHovered)
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: widget.color),
                Text(
                  _isTimerRunning 
                    ? _formatTime(_remainingSeconds)
                    : _formatTime(widget.targetSeconds),
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ).padOnly(l: 4),
              ],
            ).padOnly(r: 8), // Espaço entre timer e botão

          // Botão play/stop (replicando o visual exato do HabitCard)
          Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child:
                    _isTimerRunning
                        ? Container(
                          key: const ValueKey('stop'),
                          child: Icon(Icons.stop, color: Colors.white)
                              .container(
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  shape: BoxShape.circle,
                                ),
                              )
                              .sized(width: 40, height: 40)
                              .tappable(_stopTimer),
                        )
                        : Container(
                          key: const ValueKey('play'),
                          child: Icon(Icons.play_arrow, color: widget.color)
                              .container(
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                              )
                              .sized(width: 40, height: 40)
                              .tappable(_startTimer),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}