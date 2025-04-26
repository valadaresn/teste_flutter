import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../services/pomodoro_service.dart';

/// Widget responsável pelos controles do pomodoro (timer, menu de opções e botão play/pause)
class PomodoroControls extends StatelessWidget {
  final Task task;
  final PomodoroService pomodoroService;
  final Function(String, bool) onTogglePomodoro;

  static const _pomodoroOptions = [
    {'title': '3 segundos (teste)', 'value': 3},
    {'title': '5 minutos', 'value': 5 * 60},
    {'title': '15 minutos', 'value': 15 * 60},
    {'title': '25 minutos', 'value': 25 * 60},
    {'title': '30 minutos', 'value': 30 * 60},
  ];

  const PomodoroControls({
    super.key,
    required this.task,
    required this.pomodoroService,
    required this.onTogglePomodoro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (task.isPomodoroActive)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              _getPomodoroTime(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

        PopupMenuButton<int>(
          position: PopupMenuPosition.under,
          tooltip: 'Configurar pomodoro',
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            final selected = _pomodoroOptions.firstWhere(
              (option) => option['value'] == value,
              orElse: () => _pomodoroOptions[3],
            );
            task.pomodoroTime = value;
            task.selectedPomodoroLabel = selected['title'] as String;
          },
          itemBuilder: (context) {
            return _pomodoroOptions.map((option) {
              return PopupMenuItem<int>(
                value: option['value'] as int,
                child: Text(option['title'] as String),
              );
            }).toList();
          },
        ),

        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(
              task.isPomodoroActive ? Icons.pause : Icons.play_arrow,
              color: Colors.green,
              size: 24,
            ),
            onPressed: () {
              onTogglePomodoro(task.id, !task.isPomodoroActive);
            },
            tooltip:
                task.isPomodoroActive ? 'Pausar pomodoro' : 'Iniciar pomodoro',
          ),
        ),
      ],
    );
  }

  String _getPomodoroTime() {
    final remaining = pomodoroService.getRemainingTime(
      task.id,
      task.pomodoroTime,
    );
    if (remaining == null || remaining < 0) return '';
    return PomodoroService.formatTime(remaining);
  }
}
