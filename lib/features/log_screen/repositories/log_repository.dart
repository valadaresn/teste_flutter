import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../log_model.dart';

class LogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _logsCollection = 'logs';
  bool _debugMode = false;

  void _debugPrint(String message) {
    if (_debugMode) {
      print('🟡 LogRepository: $message');
    }
  }

  // ============================================================================
  // STREAMS - Métodos principais que retornam Streams
  // ============================================================================

  /// Stream de todos os logs
  Stream<List<Log>> getLogsStream() {
    _debugPrint('📊 Iniciando stream de logs');
    return _firestore
        .collection(_logsCollection)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
          final logs =
              snapshot.docs
                  .map((doc) => Log.fromMap(doc.data(), doc.id))
                  .toList();

          _debugPrint('📊 Stream logs: ${logs.length} itens');
          return logs;
        });
  }

  /// Stream de logs de uma entidade específica (task/habit)
  Stream<List<Log>> getLogsByEntityStream(String entityId) {
    _debugPrint('📊 Iniciando stream de logs da entidade: $entityId');
    return _firestore
        .collection(_logsCollection)
        .where('entityId', isEqualTo: entityId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
          final logs =
              snapshot.docs
                  .map((doc) => Log.fromMap(doc.data(), doc.id))
                  .toList();

          _debugPrint(
            '📊 Stream logs da entidade $entityId: ${logs.length} itens',
          );
          return logs;
        });
  }

  /// Stream de logs ativos (sem endTime)
  Stream<List<Log>> getActiveLogsStream() {
    _debugPrint('📊 Iniciando stream de logs ativos');
    return _firestore
        .collection(_logsCollection)
        .where('endTime', isNull: true)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
          final logs =
              snapshot.docs
                  .map((doc) => Log.fromMap(doc.data(), doc.id))
                  .toList();

          _debugPrint('📊 Stream logs ativos: ${logs.length} itens');
          return logs;
        });
  }

  /// Stream de logs por período de tempo
  Stream<List<Log>> getLogsByDateRangeStream(
    DateTime startDate,
    DateTime endDate,
  ) {
    _debugPrint(
      '📊 Iniciando stream de logs por período: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}',
    );
    return _firestore
        .collection(_logsCollection)
        .where(
          'startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
          final logs =
              snapshot.docs
                  .map((doc) => Log.fromMap(doc.data(), doc.id))
                  .toList();

          _debugPrint('📊 Stream logs por período: ${logs.length} itens');
          return logs;
        });
  }

  /// Stream de logs de uma lista específica
  Stream<List<Log>> getLogsByListStream(String listId) {
    _debugPrint('📊 Iniciando stream de logs da lista: $listId');
    return _firestore
        .collection(_logsCollection)
        .where('listId', isEqualTo: listId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
          final logs =
              snapshot.docs
                  .map((doc) => Log.fromMap(doc.data(), doc.id))
                  .toList();

          _debugPrint('📊 Stream logs da lista $listId: ${logs.length} itens');
          return logs;
        });
  }

  // ============================================================================
  // CRUD - LOGS
  // ============================================================================

  /// Iniciar novo log
  Future<String> startLog(Log log) async {
    try {
      _debugPrint('➕ Iniciando log: ${log.entityTitle}');
      await _firestore.collection(_logsCollection).doc(log.id).set(log.toMap());
      _debugPrint('✅ Log iniciado com sucesso: ${log.id}');
      return log.id;
    } catch (e) {
      _debugPrint('❌ Erro ao iniciar log: $e');
      rethrow;
    }
  }

  /// Atualizar log existente
  Future<void> updateLog(Log log) async {
    try {
      _debugPrint('🔄 Atualizando log: ${log.entityTitle}');
      await _firestore
          .collection(_logsCollection)
          .doc(log.id)
          .update(log.toMap());
      _debugPrint('✅ Log atualizado com sucesso: ${log.id}');
    } catch (e) {
      _debugPrint('❌ Erro ao atualizar log: $e');
      rethrow;
    }
  }

  /// Finalizar log com endTime
  Future<void> endLog(String logId, DateTime endTime) async {
    try {
      _debugPrint('⏹️ Finalizando log: $logId');

      // Buscar o log atual para calcular a duração
      final logDoc =
          await _firestore.collection(_logsCollection).doc(logId).get();

      if (!logDoc.exists) {
        throw Exception('Log não encontrado: $logId');
      }

      final logData = logDoc.data()!;
      final startTime = (logData['startTime'] as Timestamp).toDate();
      final durationMinutes = endTime.difference(startTime).inMinutes;

      await _firestore.collection(_logsCollection).doc(logId).update({
        'endTime': Timestamp.fromDate(endTime),
        'durationMinutes': durationMinutes,
      });

      _debugPrint(
        '✅ Log finalizado com sucesso: $logId (${durationMinutes} minutos)',
      );
    } catch (e) {
      _debugPrint('❌ Erro ao finalizar log: $e');
      rethrow;
    }
  }

  /// Deletar log
  Future<void> deleteLog(String logId) async {
    try {
      _debugPrint('🗑️ Deletando log: $logId');
      await _firestore.collection(_logsCollection).doc(logId).delete();
      _debugPrint('✅ Log deletado com sucesso: $logId');
    } catch (e) {
      _debugPrint('❌ Erro ao deletar log: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CONSULTAS ESPECÍFICAS
  // ============================================================================

  /// Buscar logs de uma tarefa específica
  Future<List<Log>> getLogsByTask(String taskId) async {
    try {
      _debugPrint('🔍 Buscando logs da tarefa: $taskId');
      final querySnapshot =
          await _firestore
              .collection(_logsCollection)
              .where('entityId', isEqualTo: taskId)
              .where('entityType', isEqualTo: 'task')
              .orderBy('startTime', descending: true)
              .get();

      final logs =
          querySnapshot.docs
              .map((doc) => Log.fromMap(doc.data(), doc.id))
              .toList();

      _debugPrint('✅ Encontrados ${logs.length} logs para tarefa $taskId');
      return logs;
    } catch (e) {
      _debugPrint('❌ Erro ao buscar logs da tarefa: $e');
      rethrow;
    }
  }

  /// Calcular tempo total por tarefa
  Future<Map<String, int>> getTotalTimeByTask(String taskId) async {
    try {
      _debugPrint('📊 Calculando tempo total da tarefa: $taskId');
      final logs = await getLogsByTask(taskId);

      int totalMinutes = 0;
      int completedLogs = 0;

      for (final log in logs) {
        if (log.durationMinutes != null) {
          totalMinutes += log.durationMinutes!;
          completedLogs++;
        }
      }

      _debugPrint(
        '✅ Tempo total da tarefa $taskId: ${totalMinutes} minutos (${completedLogs} logs completos)',
      );
      return {
        'totalMinutes': totalMinutes,
        'completedLogs': completedLogs,
        'totalLogs': logs.length,
      };
    } catch (e) {
      _debugPrint('❌ Erro ao calcular tempo total: $e');
      rethrow;
    }
  }

  /// Buscar logs ativos
  Future<List<Log>> getActiveLogs() async {
    try {
      _debugPrint('🔍 Buscando logs ativos');
      final querySnapshot =
          await _firestore
              .collection(_logsCollection)
              .where('endTime', isNull: true)
              .orderBy('startTime', descending: true)
              .get();

      final logs =
          querySnapshot.docs
              .map((doc) => Log.fromMap(doc.data(), doc.id))
              .toList();

      _debugPrint('✅ Encontrados ${logs.length} logs ativos');
      return logs;
    } catch (e) {
      _debugPrint('❌ Erro ao buscar logs ativos: $e');
      rethrow;
    }
  }

  /// Buscar logs por período (método auxiliar)
  Future<List<Log>> getLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _debugPrint(
        '🔍 Buscando logs por período: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}',
      );
      final querySnapshot =
          await _firestore
              .collection(_logsCollection)
              .where(
                'startTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'startTime',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .orderBy('startTime', descending: true)
              .get();

      final logs =
          querySnapshot.docs
              .map((doc) => Log.fromMap(doc.data(), doc.id))
              .toList();

      _debugPrint('✅ Encontrados ${logs.length} logs no período');
      return logs;
    } catch (e) {
      _debugPrint('❌ Erro ao buscar logs por período: $e');
      rethrow;
    }
  }

  /// Calcular estatísticas diárias
  Future<Map<String, int>> getDailyStatistics(DateTime date) async {
    try {
      _debugPrint(
        '📊 Calculando estatísticas do dia: ${date.toIso8601String()}',
      );
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final logs = await getLogsByDateRange(startOfDay, endOfDay);

      int totalMinutes = 0;
      int completedLogs = 0;
      Set<String> uniqueTasks = {};

      for (final log in logs) {
        if (log.durationMinutes != null) {
          totalMinutes += log.durationMinutes!;
          completedLogs++;
        }
        uniqueTasks.add(log.entityId);
      }

      _debugPrint(
        '✅ Estatísticas do dia: ${totalMinutes} minutos, ${completedLogs} logs completos, ${uniqueTasks.length} tarefas únicas',
      );
      return {
        'totalMinutes': totalMinutes,
        'completedLogs': completedLogs,
        'totalLogs': logs.length,
        'uniqueTasks': uniqueTasks.length,
      };
    } catch (e) {
      _debugPrint('❌ Erro ao calcular estatísticas diárias: $e');
      rethrow;
    }
  }

  /// Buscar log ativo por entidade
  Future<Log?> getActiveLogByEntity(String entityId) async {
    try {
      _debugPrint('🔍 Buscando log ativo da entidade: $entityId');
      final querySnapshot =
          await _firestore
              .collection(_logsCollection)
              .where('entityId', isEqualTo: entityId)
              .where('endTime', isNull: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        _debugPrint('ℹ️ Nenhum log ativo encontrado para entidade $entityId');
        return null;
      }

      final log = Log.fromMap(
        querySnapshot.docs.first.data(),
        querySnapshot.docs.first.id,
      );
      _debugPrint('✅ Log ativo encontrado para entidade $entityId: ${log.id}');
      return log;
    } catch (e) {
      _debugPrint('❌ Erro ao buscar log ativo da entidade: $e');
      rethrow;
    }
  }

  // ============================================================================
  // MÉTODOS UTILITÁRIOS
  // ============================================================================

  /// Verificar se existe log ativo para uma entidade
  Future<bool> hasActiveLog(String entityId) async {
    try {
      final activeLog = await getActiveLogByEntity(entityId);
      return activeLog != null;
    } catch (e) {
      _debugPrint('❌ Erro ao verificar log ativo: $e');
      return false;
    }
  }

  /// Limpar logs antigos (opcional - para manutenção)
  Future<void> cleanupOldLogs(DateTime cutoffDate) async {
    try {
      _debugPrint(
        '🧹 Limpando logs anteriores a: ${cutoffDate.toIso8601String()}',
      );
      final querySnapshot =
          await _firestore
              .collection(_logsCollection)
              .where('startTime', isLessThan: Timestamp.fromDate(cutoffDate))
              .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _debugPrint('✅ ${querySnapshot.docs.length} logs antigos removidos');
    } catch (e) {
      _debugPrint('❌ Erro ao limpar logs antigos: $e');
      rethrow;
    }
  }

  /// Habilitar/desabilitar debug
  void setDebugMode(bool enabled) {
    _debugMode = enabled;
    _debugPrint('Debug mode ${enabled ? 'habilitado' : 'desabilitado'}');
  }
}
