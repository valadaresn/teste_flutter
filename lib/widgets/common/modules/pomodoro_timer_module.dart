import 'dart:async';
import 'package:flutter/material.dart';
import '../../../utils/notification_utils.dart';
import '../../../utils/widget_mods.dart';

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
/// PomodoroTimerModule(
///   targetSeconds: 1500, // 25 minutos
///   color: Colors.blue,
///   onComplete: () => print('Timer finalizado!'),
///   onToggleCompletion: () => markTaskAsDone(),
///   habitTitle: 'Exercitar-se',
/// )
/// ```
class PomodoroTimerModule extends StatefulWidget {
  final int targetSeconds;
  final Color color;
  final VoidCallback? onComplete;
  final VoidCallback? onToggleCompletion;
  final String habitTitle;

  const PomodoroTimerModule({
    super.key,
    required this.targetSeconds,
    required this.color,
    this.onComplete,
    this.onToggleCompletion,
    required this.habitTitle,
  });

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

  void _startTimer() {
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

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
    });
  }

  void _showTimerCompleteNotification() async {
    // 🔔 Notificação genérica com ação customizada
    await showCustomNotification(
      context: context,
      title: '⏰ Timer Concluído!',
      message: '🎉 ${widget.habitTitle} - Timer finalizado!',
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