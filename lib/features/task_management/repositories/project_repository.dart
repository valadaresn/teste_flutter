import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/project_model.dart';

class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _projectsCollection = 'projects';
  bool _debugMode = true;

  void _debugPrint(String message) {
    if (_debugMode) {
      print('🟢 ProjectRepository: $message');
    }
  }

  // ============================================================================
  // STREAMS - Métodos principais que retornam Streams
  // ============================================================================

  /// Stream de todos os projetos
  Stream<List<Project>> getProjectsStream() {
    _debugPrint('📊 Iniciando stream de projetos');
    return _firestore
        .collection(_projectsCollection)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          final projects =
              snapshot.docs
                  .map((doc) => Project.fromMap(doc.data(), doc.id))
                  .toList();

          // Ordenação no cliente para evitar índices compostos
          projects.sort((a, b) {
            final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
            if (sortOrderComparison != 0) return sortOrderComparison;
            return a.createdAt.compareTo(b.createdAt);
          });

          _debugPrint('📊 Stream projetos: ${projects.length} itens');
          return projects;
        });
  }

  // ============================================================================
  // CRUD - CREATE
  // ============================================================================

  /// Adicionar um novo projeto
  Future<void> addProject(Project project) async {
    try {
      _debugPrint('➕ Adicionando projeto: ${project.name}');
      await _firestore
          .collection(_projectsCollection)
          .doc(project.id)
          .set(project.toMap());
      _debugPrint('✅ Projeto adicionado com sucesso: ${project.id}');
    } catch (e) {
      _debugPrint('❌ Erro ao adicionar projeto: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CRUD - READ
  // ============================================================================

  /// Obter um projeto por ID
  Future<Project?> getProject(String projectId) async {
    try {
      _debugPrint('🔍 Buscando projeto: $projectId');
      final doc =
          await _firestore.collection(_projectsCollection).doc(projectId).get();

      if (doc.exists) {
        final project = Project.fromMap(doc.data()!, doc.id);
        _debugPrint('✅ Projeto encontrado: ${project.name}');
        return project;
      } else {
        _debugPrint('❌ Projeto não encontrado: $projectId');
        return null;
      }
    } catch (e) {
      _debugPrint('❌ Erro ao buscar projeto: $e');
      rethrow;
    }
  }

  /// Obter todos os projetos (snapshot único)
  Future<List<Project>> getAllProjects() async {
    try {
      _debugPrint('🔍 Buscando todos os projetos');
      final snapshot =
          await _firestore
              .collection(_projectsCollection)
              .orderBy('createdAt')
              .get();

      final projects =
          snapshot.docs
              .map((doc) => Project.fromMap(doc.data(), doc.id))
              .toList();

      // Ordenação no cliente
      projects.sort((a, b) {
        final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
        if (sortOrderComparison != 0) return sortOrderComparison;
        return a.createdAt.compareTo(b.createdAt);
      });

      _debugPrint('✅ ${projects.length} projetos encontrados');
      return projects;
    } catch (e) {
      _debugPrint('❌ Erro ao buscar projetos: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CRUD - UPDATE
  // ============================================================================

  /// Atualizar um projeto existente
  Future<void> updateProject(Project project) async {
    try {
      _debugPrint('📝 Atualizando projeto: ${project.name}');
      await _firestore
          .collection(_projectsCollection)
          .doc(project.id)
          .update(project.toMap());
      _debugPrint('✅ Projeto atualizado com sucesso: ${project.id}');
    } catch (e) {
      _debugPrint('❌ Erro ao atualizar projeto: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CRUD - DELETE
  // ============================================================================

  /// Deletar um projeto
  Future<void> deleteProject(String projectId) async {
    try {
      _debugPrint('🗑️ Deletando projeto: $projectId');
      await _firestore.collection(_projectsCollection).doc(projectId).delete();
      _debugPrint('✅ Projeto deletado com sucesso: $projectId');
    } catch (e) {
      _debugPrint('❌ Erro ao deletar projeto: $e');
      rethrow;
    }
  }

  // ============================================================================
  // MÉTODOS UTILITÁRIOS
  // ============================================================================

  /// Criar projeto padrão se não existir nenhum
  Future<void> createDefaultProjectIfNeeded() async {
    try {
      final projects = await getAllProjects();
      if (projects.isEmpty) {
        _debugPrint('📁 Criando projeto padrão');
        final defaultProject = Project.create(
          id: 'default_project',
          name: 'Tarefas Pessoais',
          description: 'Projeto padrão para tarefas pessoais',
          color: Colors.blue,
          emoji: '📋',
          isDefault: true,
        );
        await addProject(defaultProject);
        _debugPrint('✅ Projeto padrão criado');
      }
    } catch (e) {
      _debugPrint('❌ Erro ao criar projeto padrão: $e');
    }
  }

  /// Verificar se um projeto existe
  Future<bool> projectExists(String projectId) async {
    try {
      final doc =
          await _firestore.collection(_projectsCollection).doc(projectId).get();
      return doc.exists;
    } catch (e) {
      _debugPrint('❌ Erro ao verificar existência do projeto: $e');
      return false;
    }
  }

  /// Obter projeto padrão
  Future<Project?> getDefaultProject() async {
    try {
      final snapshot =
          await _firestore
              .collection(_projectsCollection)
              .where('isDefault', isEqualTo: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return Project.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      _debugPrint('❌ Erro ao buscar projeto padrão: $e');
      return null;
    }
  }

  // ============================================================================
  // CONFIGURAÇÕES
  // ============================================================================

  /// Ativar/desativar modo debug
  void setDebugMode(bool enabled) {
    _debugMode = enabled;
    _debugPrint('Debug mode ${enabled ? 'ativado' : 'desativado'}');
  }
}
