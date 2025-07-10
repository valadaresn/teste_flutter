import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../log_model.dart';
import '../models/filter_state.dart';
import '../repositories/log_repository.dart';
import '../../task_management/models/task_model.dart';
import '../../task_management/models/list_model.dart';
import '../../../services/pomodoro_service.dart';
import '../../../services/notification_service.dart';

class LogController extends ChangeNotifier {
  final LogRepository _repository = LogRepository();

  // StreamSubscriptions para evitar vazamentos
  StreamSubscription? _activeLogsSubscription;
  StreamSubscription? _allLogsSubscription;

  // Estado da UI
  bool _isLoading = false;
  String? _error;

  // Dados principais
  List<Log> _logs = [];
  List<Log> _activeLogs = [];

  // Logs ativos (Map<taskId, logId>)
  Map<String, String> _activeLogIds = {};

  // Tempos decorridos em tempo real (Map<taskId, seconds>)
  Map<String, int> _elapsedTimes = {};

  // Timers para atualizar tempos em tempo real
  final Map<String, Timer> _timers = {};

  // Métricas calculadas
  Map<String, Map<String, int>> _taskMetrics = {};
  Map<String, int> _dailyMetrics = {};

  // Referência ao PomodoroService (será injetado)
  PomodoroService? _pomodoroService;

  // Getters públicos
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Log> get logs => _logs;
  List<Log> get activeLogs => _activeLogs;
  Map<String, String> get activeLogIds => Map.unmodifiable(_activeLogIds);
  Map<String, int> get elapsedTimes => Map.unmodifiable(_elapsedTimes);
  Map<String, Map<String, int>> get taskMetrics =>
      Map.unmodifiable(_taskMetrics);
  Map<String, int> get dailyMetrics => Map.unmodifiable(_dailyMetrics);

  // Construtor
  LogController() {
    _initialize();
    _initializePomodoroService();
  }

  /// Inicializa o PomodoroService com callbacks
  void _initializePomodoroService() {
    _pomodoroService = PomodoroService(
      onPomodoroComplete: onPomodoroComplete,
      onTick: () => notifyListeners(), // Atualiza UI a cada segundo
      onPomodoroStart: (taskId) {
        // Log opcional quando Pomodoro inicia
        debugPrint('🍅 Pomodoro iniciado para tarefa: $taskId');
      },
      onPomodoroStop: (taskId) {
        // Log opcional quando Pomodoro para
        debugPrint('🍅 Pomodoro parado para tarefa: $taskId');
      },
      onPomodoroPause: (taskId) {
        // Pausa o timer local também
        _pauseLocalTimer(taskId);
      },
      onPomodoroResume: (taskId) {
        // Retoma o timer local também
        _resumeLocalTimer(taskId);
      },
    );
  }

  /// Inicialização do controller
  Future<void> _initialize() async {
    await _loadInitialData();
    _startListeningToStreams();
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    try {
      _setLoading(true);

      // Carrega logs ativos iniciais
      final activeLogs = await _repository.getActiveLogs();
      _activeLogs = activeLogs;

      // Reconstrói mapa de logs ativos
      _rebuildActiveLogsMap();

      // Inicia timers para logs ativos
      _startTimersForActiveLogs();

      _setLoading(false);
    } catch (e) {
      _setError('Erro ao carregar dados iniciais: $e');
      _setLoading(false);
    }
  }

  /// Inicia streams para atualizações em tempo real
  void _startListeningToStreams() {
    // Stream de logs ativos
    _activeLogsSubscription = _repository.getActiveLogsStream().listen(
      (activeLogs) {
        _activeLogs = activeLogs;
        _rebuildActiveLogsMap();
        _startTimersForActiveLogs();
        notifyListeners();
      },
      onError: (error) {
        _setError('Erro no stream de logs ativos: $error');
      },
    );

    // Stream de todos os logs (para métricas)
    _allLogsSubscription = _repository.getLogsStream().listen(
      (logs) {
        _logs = logs;
        _calculateMetrics();
        notifyListeners();
      },
      onError: (error) {
        _setError('Erro no stream de logs: $error');
      },
    );
  }

  /// Reconstrói o mapa de logs ativos
  void _rebuildActiveLogsMap() {
    _activeLogIds.clear();
    for (final log in _activeLogs) {
      _activeLogIds[log.entityId] = log.id;
    }
  }

  /// Inicia timers para logs ativos
  void _startTimersForActiveLogs() {
    // Para todos os timers existentes
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _elapsedTimes.clear();

    // Inicia novos timers para logs ativos
    for (final log in _activeLogs) {
      _startTimerForLog(log);
    }
  }

  /// Inicia timer para um log específico
  void _startTimerForLog(Log log) {
    final now = DateTime.now();
    final initialElapsed = now.difference(log.startTime).inSeconds;
    _elapsedTimes[log.entityId] = initialElapsed;

    _timers[log.entityId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTimes[log.entityId] = (_elapsedTimes[log.entityId] ?? 0) + 1;
      notifyListeners();
    });
  }

  /// Para timer de um log específico
  void _stopTimerForLog(String taskId) {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
    _elapsedTimes.remove(taskId);
  }

  /// Pausa timer local (para integração com Pomodoro)
  void _pauseLocalTimer(String taskId) {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
    // Mantém o tempo decorrido para poder retomar
  }

  /// Retoma timer local (para integração com Pomodoro)
  void _resumeLocalTimer(String taskId) {
    // Busca o log ativo para retomar
    final logId = _activeLogIds[taskId];
    if (logId == null) return;

    final activeLog = _activeLogs.where((log) => log.id == logId).firstOrNull;
    if (activeLog != null) {
      _startTimerForLog(activeLog);
    }
  }

  // ============================================================================
  // CONTROLE DE LOGS
  // ============================================================================

  /// Iniciar log para uma tarefa
  Future<void> startTaskLog(Task task, {TaskList? taskList}) async {
    try {
      _setLoading(true);

      // Verifica se já existe log ativo para essa tarefa
      if (_activeLogIds.containsKey(task.id)) {
        throw Exception('Já existe um log ativo para esta tarefa');
      }

      // Cria novo log
      final log = Log.create(
        entityId: task.id,
        entityType: 'task',
        entityTitle: task.title,
        listId: task.listId,
        listTitle: taskList?.name,
        parentTaskId: task.parentTaskId,
        parentTaskTitle:
            null, // TODO: Buscar título da tarefa pai se necessário
        startTime: DateTime.now(),
        tags: task.tags,
        metrics: {
          'priority': task.priority.name,
          'isImportant': task.isImportant,
        },
      );

      // Salva no repository
      final logId = await _repository.startLog(log);

      // Atualiza estado local
      _activeLogIds[task.id] = logId;

      // Inicia timer local
      _startTimerForLog(log);

      // Integra com PomodoroService se disponível
      if (_pomodoroService != null) {
        // Inicia pomodoro de 25 minutos por padrão
        _pomodoroService!.startPomodoro(task.id, task.title, 25 * 60);
      }

      // Notifica sucesso
      await showNotification(
        'Log Iniciado',
        'Iniciando cronômetro para: ${task.title}',
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao iniciar log: $e');
      _setLoading(false);
    }
  }

  /// Parar log de uma tarefa
  Future<void> stopTaskLog(String taskId) async {
    try {
      _setLoading(true);

      // Verifica se existe log ativo
      final logId = _activeLogIds[taskId];
      if (logId == null) {
        throw Exception('Nenhum log ativo encontrado para esta tarefa');
      }

      // Finaliza log no repository
      await _repository.endLog(logId, DateTime.now());

      // Remove do estado local
      _activeLogIds.remove(taskId);

      // Para timer
      _stopTimerForLog(taskId);

      // Para PomodoroService se disponível
      if (_pomodoroService != null) {
        _pomodoroService!.stopPomodoro(taskId);
      }

      // Notifica sucesso
      await showNotification(
        'Log Finalizado',
        'Cronômetro parado para a tarefa',
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao parar log: $e');
      _setLoading(false);
    }
  }

  /// Pausar log de uma tarefa
  Future<void> pauseTaskLog(String taskId) async {
    try {
      // Para timer local
      _pauseLocalTimer(taskId);

      // Para PomodoroService se disponível
      if (_pomodoroService != null) {
        _pomodoroService!.pausePomodoro(taskId);
      }

      // TODO: Implementar pausa no Firestore se necessário
      // Por enquanto, apenas para os timers locais

      notifyListeners();
    } catch (e) {
      _setError('Erro ao pausar log: $e');
    }
  }

  /// Retomar log de uma tarefa
  Future<void> resumeTaskLog(String taskId) async {
    try {
      // Busca log ativo
      final logId = _activeLogIds[taskId];
      if (logId == null) return;

      // Reinicia timer local
      _resumeLocalTimer(taskId);

      // Reinicia PomodoroService se disponível
      if (_pomodoroService != null) {
        _pomodoroService!.resumePomodoro(taskId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Erro ao retomar log: $e');
    }
  }

  // ============================================================================
  // CONSULTAS DE ESTADO
  // ============================================================================

  /// Verifica se uma tarefa está sendo cronometrada
  bool isTaskBeingLogged(String taskId) {
    return _activeLogIds.containsKey(taskId);
  }

  /// Obtém tempo decorrido para uma tarefa
  int? getElapsedTime(String taskId) {
    return _elapsedTimes[taskId];
  }

  /// Obtém tempo decorrido formatado
  String? getElapsedTimeFormatted(String taskId) {
    final elapsed = _elapsedTimes[taskId];
    if (elapsed == null) return null;
    return _formatTime(elapsed);
  }

  /// Obtém lista de logs ativos
  List<Log> getActiveLogsList() {
    return List.unmodifiable(_activeLogs);
  }

  /// Obtém log ativo para uma tarefa
  Log? getActiveLogForTask(String taskId) {
    final logId = _activeLogIds[taskId];
    if (logId == null) return null;

    try {
      return _activeLogs.firstWhere((log) => log.id == logId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // INTEGRAÇÃO COM POMODORO SERVICE
  // ============================================================================

  /// Verifica se Pomodoro está rodando para uma tarefa
  bool isPomodoroRunning(String taskId) {
    return _pomodoroService?.isRunning(taskId) ?? false;
  }

  /// Verifica se Pomodoro está pausado para uma tarefa
  bool isPomodoroPaused(String taskId) {
    return _pomodoroService?.isPaused(taskId) ?? false;
  }

  /// Obtém tempo restante do Pomodoro
  int? getPomodoroRemainingTime(String taskId) {
    if (_pomodoroService == null) return null;
    const defaultDuration = 25 * 60; // 25 minutos
    return _pomodoroService!.getRemainingTime(taskId, defaultDuration);
  }

  /// Obtém tempo decorrido do Pomodoro
  int? getPomodoroElapsedTime(String taskId) {
    return _pomodoroService?.getElapsedTime(taskId);
  }

  /// Para todos os Pomodoros ativos
  void stopAllPomodoros() {
    _pomodoroService?.stopAllPomodoros();
  }

  // ============================================================================
  // MÉTRICAS E ESTATÍSTICAS
  // ============================================================================

  /// Calcula métricas gerais
  void _calculateMetrics() {
    _calculateTaskMetrics();
    _calculateDailyMetrics();
  }

  /// Calcula métricas por tarefa
  void _calculateTaskMetrics() {
    _taskMetrics.clear();

    final taskGroups = <String, List<Log>>{};

    // Agrupa logs por tarefa
    for (final log in _logs) {
      if (log.durationMinutes != null) {
        taskGroups.putIfAbsent(log.entityId, () => []).add(log);
      }
    }

    // Calcula métricas para cada tarefa
    for (final entry in taskGroups.entries) {
      final taskId = entry.key;
      final taskLogs = entry.value;

      int totalMinutes = 0;
      int totalSessions = taskLogs.length;
      int longestSession = 0;

      for (final log in taskLogs) {
        final duration = log.durationMinutes!;
        totalMinutes += duration;
        if (duration > longestSession) {
          longestSession = duration;
        }
      }

      _taskMetrics[taskId] = {
        'totalMinutes': totalMinutes,
        'totalSessions': totalSessions,
        'averageMinutes': totalMinutes ~/ totalSessions,
        'longestSession': longestSession,
      };
    }
  }

  /// Calcula métricas diárias
  void _calculateDailyMetrics() {
    _dailyMetrics.clear();

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final todayLogs =
        _logs.where((log) {
          return log.startTime.isAfter(startOfDay) &&
              log.startTime.isBefore(endOfDay);
        }).toList();

    int totalMinutes = 0;
    int completedSessions = 0;
    Set<String> uniqueTasks = {};

    for (final log in todayLogs) {
      if (log.durationMinutes != null) {
        totalMinutes += log.durationMinutes!;
        completedSessions++;
      }
      uniqueTasks.add(log.entityId);
    }

    _dailyMetrics = {
      'totalMinutes': totalMinutes,
      'completedSessions': completedSessions,
      'totalSessions': todayLogs.length,
      'uniqueTasks': uniqueTasks.length,
      'averageSessionMinutes':
          completedSessions > 0 ? totalMinutes ~/ completedSessions : 0,
    };
  }

  /// Obtém métricas de uma tarefa
  Map<String, int>? getTaskMetrics(String taskId) {
    return _taskMetrics[taskId];
  }

  /// Obtém métricas diárias
  Map<String, int> getDailyMetrics() {
    return Map.unmodifiable(_dailyMetrics);
  }

  /// Obtém tempo total de uma tarefa por período
  Future<Map<String, int>> getTaskTimeByDateRange(
    String taskId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final logs = await _repository.getLogsByDateRange(startDate, endDate);
      final taskLogs = logs.where((log) => log.entityId == taskId).toList();

      int totalMinutes = 0;
      int completedSessions = 0;

      for (final log in taskLogs) {
        if (log.durationMinutes != null) {
          totalMinutes += log.durationMinutes!;
          completedSessions++;
        }
      }

      return {
        'totalMinutes': totalMinutes,
        'completedSessions': completedSessions,
        'totalSessions': taskLogs.length,
      };
    } catch (e) {
      _setError('Erro ao calcular tempo da tarefa: $e');
      return {};
    }
  }

  // ============================================================================
  // INTEGRAÇÃO COM POMODORO SERVICE
  // ============================================================================

  /// Callback para quando Pomodoro completa
  void onPomodoroComplete(String taskId) {
    // Automaticamente para o log quando o pomodoro termina
    stopTaskLog(taskId);
  }

  // ============================================================================
  // MÉTODOS UTILITÁRIOS
  // ============================================================================

  /// Formata tempo em segundos para MM:SS
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  // ============================================================================
  // GERENCIAMENTO DE ESTADO
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  @override
  void dispose() {
    // Cancela subscriptions
    _activeLogsSubscription?.cancel();
    _allLogsSubscription?.cancel();

    // Cancela timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    super.dispose();
  }

  // ============================================================================
  // STREAMS PARA UI
  // ============================================================================

  /// Stream de todos os logs
  Stream<List<Log>> getLogsStream() {
    return _repository.getLogsStream();
  }

  /// Stream de logs por intervalo de data
  Stream<List<Log>> getLogsByDateRangeStream(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _repository.getLogsByDateRangeStream(startDate, endDate);
  }

  /// Stream de logs filtrados
  Stream<List<Log>> getFilteredLogsStream({
    required DateTime startDate,
    required DateTime endDate,
    Set<String>? projectIds,
    Set<String>? listIds,
    LogFilterStatus status = LogFilterStatus.all,
  }) {
    return _repository.getLogsByDateRangeStream(startDate, endDate).map((logs) {
      return _applyFilters(logs, projectIds, listIds, status);
    });
  }

  /// Stream de logs por tarefa
  Stream<List<Log>> getLogsByTaskStream(String taskId) {
    return _repository.getLogsByEntityStream(taskId);
  }

  /// Stream de logs ativos
  Stream<List<Log>> getActiveLogsStream() {
    return _repository.getActiveLogsStream();
  }

  // ============================================================================
  // OPERAÇÕES CRUD
  // ============================================================================

  /// Deleta um log
  Future<void> deleteLog(String logId) async {
    try {
      await _repository.deleteLog(logId);

      // Remove dos caches locais
      _logs.removeWhere((log) => log.id == logId);
      _activeLogs.removeWhere((log) => log.id == logId);

      // Remove do mapeamento de logs ativos
      _activeLogIds.removeWhere((taskId, activeLogId) => activeLogId == logId);

      // Atualiza métricas
      _calculateTaskMetrics();
      _calculateDailyMetrics();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao deletar log: $e');
      rethrow;
    }
  }

  /// Atualiza um log
  Future<void> updateLog(Log log) async {
    try {
      await _repository.updateLog(log);

      // Atualiza nos caches locais
      final index = _logs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _logs[index] = log;
      }

      final activeIndex = _activeLogs.indexWhere((l) => l.id == log.id);
      if (activeIndex != -1) {
        _activeLogs[activeIndex] = log;
      }

      // Atualiza métricas
      _calculateTaskMetrics();
      _calculateDailyMetrics();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao atualizar log: $e');
      rethrow;
    }
  }

  /// Aplica filtros na lista de logs
  List<Log> _applyFilters(
    List<Log> logs,
    Set<String>? projectIds,
    Set<String>? listIds,
    LogFilterStatus status,
  ) {
    var filteredLogs = logs;

    // Filtrar por status
    if (status != LogFilterStatus.all) {
      filteredLogs =
          filteredLogs.where((log) {
            switch (status) {
              case LogFilterStatus.active:
                return log.endTime == null;
              case LogFilterStatus.completed:
                return log.endTime != null;
              case LogFilterStatus.all:
                return true;
            }
          }).toList();
    }

    // Filtrar por listas
    if (listIds != null && listIds.isNotEmpty) {
      filteredLogs =
          filteredLogs.where((log) {
            return log.listId != null && listIds.contains(log.listId);
          }).toList();
    }

    // Filtrar por projetos (se implementado no futuro)
    // Nota: O modelo Log atual não tem projectId diretamente
    // Seria necessário buscar através da lista ou implementar no modelo
    if (projectIds != null && projectIds.isNotEmpty) {
      // TODO: Implementar filtro por projeto quando disponível
    }

    return filteredLogs;
  }
}
