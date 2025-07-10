import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class PomodoroService {
  final Map<String, Timer> _timers = {};
  final Map<String, int> _elapsedTimes = {};
  final Map<String, int> _totalDurations = {};
  final Map<String, bool> _isPaused = {};

  // Callbacks
  final Function(String) onPomodoroComplete;
  final VoidCallback onTick;
  final Function(String)? onPomodoroStart;
  final Function(String)? onPomodoroStop;
  final Function(String)? onPomodoroPause;
  final Function(String)? onPomodoroResume;

  PomodoroService({
    required this.onPomodoroComplete,
    required this.onTick,
    this.onPomodoroStart,
    this.onPomodoroStop,
    this.onPomodoroPause,
    this.onPomodoroResume,
  });

  void startPomodoro(String taskId, String taskTitle, int duration) {
    // Cancela timer existente se houver
    stopPomodoro(taskId);

    _elapsedTimes[taskId] = 0;
    _totalDurations[taskId] = duration;
    _isPaused[taskId] = false;

    // Notifica início
    onPomodoroStart?.call(taskId);

    // Cria novo timer
    _timers[taskId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused[taskId] == true) return; // Não contar se pausado

      _elapsedTimes[taskId] = (_elapsedTimes[taskId] ?? 0) + 1;
      onTick();

      if (_elapsedTimes[taskId]! >= duration) {
        timer.cancel();
        _timers.remove(taskId);
        _elapsedTimes.remove(taskId);
        _totalDurations.remove(taskId);
        _isPaused.remove(taskId);

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
    _totalDurations.remove(taskId);
    _isPaused.remove(taskId);

    // Notifica parada
    onPomodoroStop?.call(taskId);
  }

  void pausePomodoro(String taskId) {
    if (_timers.containsKey(taskId)) {
      _isPaused[taskId] = true;
      onPomodoroPause?.call(taskId);

      showNotification('Pomodoro Pausado', 'Timer pausado temporariamente');
    }
  }

  void resumePomodoro(String taskId) {
    if (_timers.containsKey(taskId) && _isPaused[taskId] == true) {
      _isPaused[taskId] = false;
      onPomodoroResume?.call(taskId);

      showNotification('Pomodoro Retomado', 'Timer retomado');
    }
  }

  bool isPaused(String taskId) {
    return _isPaused[taskId] ?? false;
  }

  bool isRunning(String taskId) {
    return _timers.containsKey(taskId);
  }

  int? getElapsedTime(String taskId) {
    return _elapsedTimes[taskId];
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
    _totalDurations.clear();
    _isPaused.clear();
  }

  // Métodos utilitários adicionais
  List<String> getActiveTaskIds() {
    return _timers.keys.toList();
  }

  Map<String, int> getAllElapsedTimes() {
    return Map.unmodifiable(_elapsedTimes);
  }

  void stopAllPomodoros() {
    final taskIds = _timers.keys.toList();
    for (final taskId in taskIds) {
      stopPomodoro(taskId);
    }
  }
}
