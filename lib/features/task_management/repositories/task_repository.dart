import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/list_model.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _listsCollection = 'task_lists';
  final String _tasksCollection = 'tasks';
  bool _debugMode = false;

  void _debugPrint(String message) {
    if (_debugMode) {
      print('🔵 TaskRepository: $message');
    }
  }

  // ============================================================================
  // STREAMS - Métodos principais que retornam Streams
  // ============================================================================
  /// Stream de todas as listas de tarefas
  Stream<List<TaskList>> getListsStream() {
    _debugPrint('📊 Iniciando stream de listas');
    return _firestore
        .collection(_listsCollection)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          final lists =
              snapshot.docs
                  .map((doc) => TaskList.fromMap(doc.data(), doc.id))
                  .toList();

          // Ordenação no cliente para evitar índices compostos
          lists.sort((a, b) {
            final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
            if (sortOrderComparison != 0) return sortOrderComparison;
            return a.createdAt.compareTo(b.createdAt);
          });

          _debugPrint('📊 Stream listas: ${lists.length} itens');
          return lists;
        });
  }

  /// Stream de todas as tarefas
  Stream<List<Task>> getTasksStream() {
    _debugPrint('📋 Iniciando stream de tarefas');
    return _firestore
        .collection(_tasksCollection)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          final tasks =
              snapshot.docs
                  .map((doc) => Task.fromMap(doc.data(), doc.id))
                  .toList();

          // Ordenação no cliente para evitar índices compostos
          tasks.sort((a, b) {
            final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
            if (sortOrderComparison != 0) return sortOrderComparison;
            return a.createdAt.compareTo(b.createdAt);
          });

          _debugPrint('📋 Stream tarefas: ${tasks.length} itens');
          return tasks;
        });
  }

  /// Stream de tarefas de uma lista específica
  Stream<List<Task>> getTasksByListStream(String listId) {
    _debugPrint('📋 Iniciando stream de tarefas da lista: $listId');
    return _firestore
        .collection(_tasksCollection)
        .where('listId', isEqualTo: listId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          final tasks =
              snapshot.docs
                  .map((doc) => Task.fromMap(doc.data(), doc.id))
                  .toList();

          // Ordenação no cliente para evitar índices compostos
          tasks.sort((a, b) {
            final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
            if (sortOrderComparison != 0) return sortOrderComparison;
            return a.createdAt.compareTo(b.createdAt);
          });

          _debugPrint(
            '📋 Stream tarefas da lista $listId: ${tasks.length} itens',
          );
          return tasks;
        });
  }

  /// Stream de subtarefas de uma tarefa específica
  Stream<List<Task>> getSubtasksByParentStream(String parentTaskId) {
    _debugPrint('📋 Iniciando stream de subtarefas da tarefa: $parentTaskId');
    return _firestore
        .collection(_tasksCollection)
        .where('parentTaskId', isEqualTo: parentTaskId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          final subtasks =
              snapshot.docs
                  .map((doc) => Task.fromMap(doc.data(), doc.id))
                  .toList();

          // Ordenação no cliente para evitar índices compostos
          subtasks.sort((a, b) {
            final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
            if (sortOrderComparison != 0) return sortOrderComparison;
            return a.createdAt.compareTo(b.createdAt);
          });

          _debugPrint(
            '📋 Stream subtarefas da tarefa $parentTaskId: ${subtasks.length} itens',
          );
          return subtasks;
        });
  }

  // ============================================================================
  // CRUD - LISTAS
  // ============================================================================

  /// Adicionar nova lista
  Future<void> addList(TaskList list) async {
    try {
      _debugPrint('➕ Adicionando lista: ${list.name}');
      await _firestore
          .collection(_listsCollection)
          .doc(list.id)
          .set(list.toMap());
      _debugPrint('✅ Lista adicionada com sucesso: ${list.id}');
    } catch (e) {
      _debugPrint('❌ Erro ao adicionar lista: $e');
      rethrow;
    }
  }

  /// Atualizar lista existente
  Future<void> updateList(TaskList list) async {
    try {
      _debugPrint('🔄 Atualizando lista: ${list.name}');
      await _firestore
          .collection(_listsCollection)
          .doc(list.id)
          .update(list.toMap());
      _debugPrint('✅ Lista atualizada com sucesso: ${list.id}');
    } catch (e) {
      _debugPrint('❌ Erro ao atualizar lista: $e');
      rethrow;
    }
  }

  /// Deletar lista (e todas suas tarefas)
  Future<void> deleteList(String listId) async {
    try {
      _debugPrint('🗑️ Deletando lista: $listId');

      // Primeiro, deletar todas as tarefas da lista
      final tasksQuery =
          await _firestore
              .collection(_tasksCollection)
              .where('listId', isEqualTo: listId)
              .get();

      final batch = _firestore.batch();

      // Adicionar todas as tarefas ao batch para deletar
      for (final doc in tasksQuery.docs) {
        batch.delete(doc.reference);
      }

      // Adicionar a lista ao batch para deletar
      batch.delete(_firestore.collection(_listsCollection).doc(listId));

      // Executar o batch
      await batch.commit();

      _debugPrint(
        '✅ Lista e ${tasksQuery.docs.length} tarefas deletadas: $listId',
      );
    } catch (e) {
      _debugPrint('❌ Erro ao deletar lista: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CRUD - TAREFAS
  // ============================================================================

  /// Adicionar nova tarefa
  Future<void> addTask(Task task) async {
    try {
      _debugPrint('➕ Adicionando tarefa: ${task.title}');
      await _firestore
          .collection(_tasksCollection)
          .doc(task.id)
          .set(task.toMap());
      _debugPrint('✅ Tarefa adicionada com sucesso: ${task.id}');
    } catch (e) {
      _debugPrint('❌ Erro ao adicionar tarefa: $e');
      rethrow;
    }
  }

  /// Atualizar tarefa existente
  Future<void> updateTask(Task task) async {
    try {
      _debugPrint('🔄 Atualizando tarefa: ${task.title}');
      await _firestore
          .collection(_tasksCollection)
          .doc(task.id)
          .update(task.toMap());
      _debugPrint('✅ Tarefa atualizada com sucesso: ${task.id}');
    } catch (e) {
      _debugPrint('❌ Erro ao atualizar tarefa: $e');
      rethrow;
    }
  }

  /// Deletar tarefa (e todas suas subtarefas)
  Future<void> deleteTask(String taskId) async {
    try {
      _debugPrint('🗑️ Deletando tarefa: $taskId');

      // Primeiro, deletar todas as subtarefas
      final subtasksQuery =
          await _firestore
              .collection(_tasksCollection)
              .where('parentTaskId', isEqualTo: taskId)
              .get();

      final batch = _firestore.batch();

      // Adicionar todas as subtarefas ao batch para deletar
      for (final doc in subtasksQuery.docs) {
        batch.delete(doc.reference);
      }

      // Adicionar a tarefa principal ao batch para deletar
      batch.delete(_firestore.collection(_tasksCollection).doc(taskId));

      // Executar o batch
      await batch.commit();

      _debugPrint(
        '✅ Tarefa e ${subtasksQuery.docs.length} subtarefas deletadas: $taskId',
      );
    } catch (e) {
      _debugPrint('❌ Erro ao deletar tarefa: $e');
      rethrow;
    }
  }

  /// Toggle status de conclusão da tarefa
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      _debugPrint('🔄 Toggle tarefa: $taskId -> $isCompleted');
      final updateData = {
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? Timestamp.fromDate(DateTime.now()) : null,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore
          .collection(_tasksCollection)
          .doc(taskId)
          .update(updateData);
      _debugPrint('✅ Status da tarefa alterado: $taskId');
    } catch (e) {
      _debugPrint('❌ Erro ao alterar status da tarefa: $e');
      rethrow;
    }
  }

  /// Toggle favorito da tarefa
  Future<void> toggleTaskImportant(String taskId, bool isImportant) async {
    try {
      _debugPrint('⭐ Toggle favorito: $taskId -> $isImportant');
      final updateData = {
        'isImportant': isImportant,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore
          .collection(_tasksCollection)
          .doc(taskId)
          .update(updateData);
      _debugPrint('✅ Favorito da tarefa alterado: $taskId');
    } catch (e) {
      _debugPrint('❌ Erro ao alterar favorito da tarefa: $e');
      rethrow;
    }
  }

  /// Mover tarefa para outra lista
  Future<void> moveTaskToList(String taskId, String newListId) async {
    try {
      _debugPrint('📁 Movendo tarefa $taskId para lista $newListId');
      final updateData = {
        'listId': newListId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore
          .collection(_tasksCollection)
          .doc(taskId)
          .update(updateData);
      _debugPrint('✅ Tarefa movida com sucesso: $taskId');
    } catch (e) {
      _debugPrint('❌ Erro ao mover tarefa: $e');
      rethrow;
    }
  }

  // ============================================================================
  // MÉTODOS UTILITÁRIOS
  // ============================================================================

  /// Criar lista padrão se não existir
  Future<void> createDefaultListIfNeeded() async {
    try {
      final listsSnapshot =
          await _firestore
              .collection(_listsCollection)
              .where('isDefault', isEqualTo: true)
              .limit(1)
              .get();

      if (listsSnapshot.docs.isEmpty) {
        _debugPrint('📋 Criando lista padrão');
        final defaultList = TaskList.create(
          id: 'default',
          name: 'Minhas Tarefas',
          color: Colors.blue,
          emoji: '📋',
          isDefault: true,
        );
        await addList(defaultList);
      }
    } catch (e) {
      _debugPrint('❌ Erro ao criar lista padrão: $e');
      rethrow;
    }
  }

  /// Contar tarefas pendentes em uma lista
  Future<int> countPendingTasksInList(String listId) async {
    try {
      final snapshot =
          await _firestore
              .collection(_tasksCollection)
              .where('listId', isEqualTo: listId)
              .where('isCompleted', isEqualTo: false)
              .where('parentTaskId', isNull: true) // Apenas tarefas principais
              .get();

      return snapshot.docs.length;
    } catch (e) {
      _debugPrint('❌ Erro ao contar tarefas pendentes: $e');
      return 0;
    }
  }

  /// Buscar tarefas por texto
  Stream<List<Task>> searchTasksStream(String searchQuery) {
    if (searchQuery.isEmpty) {
      return const Stream.empty();
    }

    _debugPrint('🔍 Buscando tarefas: "$searchQuery"');
    return _firestore
        .collection(_tasksCollection)
        .where('title', isGreaterThanOrEqualTo: searchQuery)
        .where('title', isLessThan: searchQuery + '\uf8ff')
        .snapshots()
        .map((snapshot) {
          final tasks =
              snapshot.docs
                  .map((doc) => Task.fromMap(doc.data(), doc.id))
                  .toList();
          _debugPrint(
            '🔍 Encontradas ${tasks.length} tarefas para "$searchQuery"',
          );
          return tasks;
        });
  }
}
