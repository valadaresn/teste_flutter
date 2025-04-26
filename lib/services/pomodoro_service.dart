import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class PomodoroService {
  final Map<String, Timer> _timers = {};
  final Map<String, int> _elapsedTimes = {};
  final Function(String) onPomodoroComplete;
  final VoidCallback onTick;

  PomodoroService({required this.onPomodoroComplete, required this.onTick});

  void startPomodoro(String taskId, String taskTitle, int duration) {
    // Cancela timer existente se houver
    stopPomodoro(taskId);

    _elapsedTimes[taskId] = 0;

    // Cria novo timer
    _timers[taskId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTimes[taskId] = (_elapsedTimes[taskId] ?? 0) + 1;
      onTick();

      if (_elapsedTimes[taskId]! >= duration) {
        timer.cancel();
        _timers.remove(taskId);
        _elapsedTimes.remove(taskId);
        onPomodoroComplete(taskId);

        showNotification(
          'Pomodoro Concluído',
          'Tarefa: $taskTitle - Tempo finalizado!',
        );
      }
    });
  }

  void stopPomodoro(String taskId) {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
    _elapsedTimes.remove(taskId);
  }

  int? getRemainingTime(String taskId, int totalTime) {
    final elapsedTime = _elapsedTimes[taskId];
    if (elapsedTime == null) return null;
    return totalTime - elapsedTime;
  }

  static String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _elapsedTimes.clear();
  }
}
