import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../log_model.dart';
import '../models/filter_state.dart';
import '../repositories/log_repository.dart';
import '../../task_management/models/task_model.dart';
import '../../task_management/models/list_model.dart';
import '../../task_management/controllers/task_controller.dart';
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

  // Referência ao TaskController para atualizar tempo acumulado
  TaskController? _taskController;

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

  /// Define TaskController para integração de tempo acumulado
  void setTaskController(TaskController taskController) {
    debugPrint(
      '🔵 LogController.setTaskController - Recebendo TaskController: $taskController',
    );
    _taskController = taskController;
    debugPrint(
      '🔵 LogController.setTaskController - _taskController definido: ${_taskController != null}',
    );
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
        // Se existe log ativo mas timer pausado, retoma
        if (!_timers.containsKey(task.id)) {
          await resumeTaskLog(task.id);
          _setLoading(false);
          return;
        } else {
          // Log já está rodando
          throw Exception('Já existe um log ativo para esta tarefa');
        }
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
        // Usa o tempo de pomodoro configurado na tarefa (convertendo minutos para segundos)
        final pomodoroSeconds = task.pomodoroTimeMinutes * 60;
        _pomodoroService!.startPomodoro(task.id, task.title, pomodoroSeconds);
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

  /// Método genérico para iniciar log de qualquer entidade (Task, Habit, etc.)
  Future<void> startEntityLog({
    required String entityId,
    required String entityType, // "task" ou "habit"
    required String entityTitle,
    String? listId,
    String? listTitle,
    String? parentId,
    String? parentTitle,
    List<String> tags = const [],
    Map<String, dynamic> metrics = const {},
    int? pomodoroTimeMinutes,
  }) async {
    try {
      _setLoading(true);

      // Verifica se já existe log ativo para essa entidade
      if (_activeLogIds.containsKey(entityId)) {
        // Se existe log ativo mas timer pausado, retoma
        if (!_timers.containsKey(entityId)) {
          await resumeTaskLog(entityId);
          _setLoading(false);
          return;
        } else {
          // Log já está rodando
          throw Exception('Já existe um log ativo para esta entidade');
        }
      }

      // Cria novo log
      final log = Log.create(
        entityId: entityId,
        entityType: entityType,
        entityTitle: entityTitle,
        listId: listId,
        listTitle: listTitle,
        parentTaskId: parentId,
        parentTaskTitle: parentTitle,
        startTime: DateTime.now(),
        tags: tags,
        metrics: metrics,
      );

      // Salva no repository
      final logId = await _repository.startLog(log);

      // Atualiza estado local
      _activeLogIds[entityId] = logId;

      // Inicia timer local
      _startTimerForLog(log);

      // Integra com PomodoroService se disponível
      if (_pomodoroService != null) {
        // Usa o tempo de pomodoro configurado (convertendo minutos para segundos)
        final pomodoroSeconds = (pomodoroTimeMinutes ?? 25) * 60;
        _pomodoroService!.startPomodoro(entityId, entityTitle, pomodoroSeconds);
      }

      // Notifica sucesso
      await showNotification(
        'Log Iniciado',
        'Iniciando cronômetro para: $entityTitle',
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
      debugPrint(
        '🔴 LogController.stopTaskLog - Iniciando para taskId: $taskId',
      );
      _setLoading(true);

      // Verifica se existe log ativo
      final logId = _activeLogIds[taskId];
      debugPrint('🔴 LogController.stopTaskLog - logId: $logId');
      if (logId == null) {
        debugPrint('🔴 ERRO: Nenhum log ativo encontrado para taskId: $taskId');
        throw Exception('Nenhum log ativo encontrado para esta tarefa');
      }

      // Captura o tempo decorrido antes de parar o timer
      final elapsedSeconds = _elapsedTimes[taskId] ?? 0;
      debugPrint(
        '🔴 LogController.stopTaskLog - elapsedSeconds: $elapsedSeconds',
      );

      // Finaliza log no repository
      debugPrint(
        '🔴 LogController.stopTaskLog - Finalizando log no repository...',
      );
      await _repository.endLog(logId, DateTime.now());
      debugPrint('🔴 LogController.stopTaskLog - Log finalizado no repository');

      // Remove do estado local
      _activeLogIds.remove(taskId);

      // Para timer
      _stopTimerForLog(taskId);

      // Atualiza tempo acumulado na tarefa
      debugPrint(
        '🔴 LogController.stopTaskLog - Verificando TaskController...',
      );
      debugPrint('🔴 _taskController é null? ${_taskController == null}');
      debugPrint('🔴 elapsedSeconds > 0? ${elapsedSeconds > 0}');

      if (_taskController != null && elapsedSeconds > 0) {
        debugPrint(
          '🔴 LogController.stopTaskLog - Chamando updateTaskAccumulatedTime...',
        );
        debugPrint(
          '🔴 Parâmetros: taskId=$taskId, elapsedSeconds=$elapsedSeconds',
        );

        try {
          await _taskController!.updateTaskAccumulatedTime(
            taskId,
            elapsedSeconds,
          );
          debugPrint(
            '🔴 LogController.stopTaskLog - updateTaskAccumulatedTime executado com sucesso',
          );
        } catch (updateError) {
          debugPrint('🔴 ERRO no updateTaskAccumulatedTime: $updateError');
          rethrow;
        }
      } else {
        debugPrint(
          '🔴 LogController.stopTaskLog - NÃO vai chamar updateTaskAccumulatedTime',
        );
        if (_taskController == null) {
          debugPrint('🔴 Motivo: _taskController é null');
        }
        if (elapsedSeconds <= 0) {
          debugPrint('🔴 Motivo: elapsedSeconds <= 0 ($elapsedSeconds)');
        }
      }

      // Para PomodoroService se disponível
      if (_pomodoroService != null) {
        _pomodoroService!.stopPomodoro(taskId);
      }

      // Notifica sucesso
      await showNotification(
        'Log Finalizado',
        'Cronômetro parado para a tarefa',
      );

      debugPrint('🔴 LogController.stopTaskLog - Finalizando com sucesso');
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 ERRO GERAL no stopTaskLog: $e');
      _setError('Erro ao parar log: $e');
      _setLoading(false);
    }
  }

  /// Pausar log de uma tarefa
  Future<void> pauseTaskLog(String taskId) async {
    try {
      // Para timer local mas mantém log como ativo (apenas pausado)
      _pauseLocalTimer(taskId);

      // Para PomodoroService se disponível
      if (_pomodoroService != null) {
        _pomodoroService!.pausePomodoro(taskId);
      }

      // NOTA: NÃO remove de _activeLogIds porque é apenas uma pausa
      // O log continua ativo, apenas o timer está pausado

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

  /// Verifica se uma tarefa está com timer ativo (não pausado)
  bool isTaskTimerRunning(String taskId) {
    return _activeLogIds.containsKey(taskId) && _timers.containsKey(taskId);
  }

  /// Verifica se uma tarefa está pausada
  bool isTaskPaused(String taskId) {
    return _activeLogIds.containsKey(taskId) && !_timers.containsKey(taskId);
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

  /// Obtém log por ID (necessário para GenericSelectorList)
  Log? getLogById(String id) {
    try {
      // Primeiro procura nos logs ativos
      final activeLog = _activeLogs.where((log) => log.id == id).firstOrNull;
      if (activeLog != null) return activeLog;

      // Se não encontrou nos ativos, procura em todos os logs
      return _logs.where((log) => log.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// Obtém logs por range de data de forma síncrona (necessário para GenericSelectorList)
  List<Log> getLogsByDateRange(DateTime startDate, DateTime endDate) {
    return _logs.where((log) {
      return log.startTime.isAfter(startDate) &&
          log.startTime.isBefore(endDate);
    }).toList();
  }

  /// Obtém logs para um dia específico de forma síncrona
  List<Log> getLogsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getLogsByDateRange(startOfDay, endOfDay);
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

  // ============================================================================
  // TIMER E TEMPO ACUMULADO
  // ============================================================================

  /// Obtém tempo total acumulado para uma tarefa (sessões anteriores + sessão atual)
  Future<int> getTotalAccumulatedTime(String taskId) async {
    try {
      // Busca a tarefa para obter o tempo acumulado persistido
      // TODO: Implementar integração com TaskRepository quando disponível
      // Por enquanto, retorna apenas o tempo da sessão atual
      return _elapsedTimes[taskId] ?? 0;
    } catch (e) {
      debugPrint('Erro ao calcular tempo total acumulado: $e');
      return _elapsedTimes[taskId] ?? 0;
    }
  }

  /// Obtém tempo total acumulado de forma síncrona (para exibição)
  int getTotalAccumulatedTimeSync(String taskId, int storedAccumulatedTime) {
    int totalTime = storedAccumulatedTime;

    // Adiciona tempo da sessão atual se houver
    if (_activeLogIds.containsKey(taskId)) {
      final currentSessionTime = _elapsedTimes[taskId] ?? 0;
      totalTime += currentSessionTime;
    }

    return totalTime;
  }
}
