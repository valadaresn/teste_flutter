import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../models/list_model.dart';
import '../models/project_model.dart';
import '../widgets/lists/list_form_dialog.dart';
import '../widgets/lists/list_context_menu.dart';
import '../widgets/projects/project_form_dialog.dart';
import '../widgets/projects/project_context_menu.dart';
import '../../log_screen/screens/log_screen.dart';
import '../widgets/settings/settings_screen.dart';

/// **TaskDialogService** - Serviço centralizado para diálogos da feature task_management
///
/// Este serviço é responsável por:
/// - Centralizar a lógica de abertura de diálogos
/// - Gerenciar navegação dentro da feature
/// - Evitar duplicação de código entre componentes
/// - Facilitar manutenção e testes
class TaskDialogService {
  final TaskController controller;

  TaskDialogService(this.controller);

  // ============================================================================
  // DIÁLOGOS DE LISTA
  // ============================================================================

  /// Exibe o diálogo para criar uma nova lista
  void showCreateListDialog(BuildContext context, {String? projectId}) {
    showDialog(
      context: context,
      builder:
          (context) => ListFormDialog(
            controller: controller,
            // list: null (modo criação)
          ),
    );
  }

  /// Exibe o diálogo para editar uma lista existente
  void showEditListDialog(BuildContext context, TaskList list) {
    showDialog(
      context: context,
      builder:
          (context) => ListFormDialog(
            controller: controller,
            list: list, // modo edição
          ),
    );
  }

  /// Exibe o menu de contexto para uma lista
  void showListContextMenu(
    BuildContext context,
    TaskList list, {
    Offset? position,
  }) {
    ListContextMenu.show(
      context: context,
      controller: controller,
      list: list,
      position: position,
    );
  }

  // ============================================================================
  // DIÁLOGOS DE PROJETO
  // ============================================================================

  /// Exibe o diálogo para criar um novo projeto
  void showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            controller: controller,
            // project: null (modo criação)
          ),
    );
  }

  /// Exibe o diálogo para editar um projeto existente
  void showEditProjectDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            controller: controller,
            project: project, // modo edição
          ),
    );
  }

  /// Exibe o menu de contexto para um projeto (placeholder)
  void showProjectContextMenu(
    BuildContext context,
    Project project, {
    Offset? position,
  }) {
    ProjectContextMenu.show(
      context: context,
      controller: controller,
      project: project,
      position: position,
    );
  }

  // ============================================================================
  // NAVEGAÇÃO
  // ============================================================================

  /// Navega para a tela de configurações
  void navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  /// Navega para a tela de logs
  void navigateToLogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogScreen()),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  /// Verifica se uma lista pode ser excluída (vazia)
  bool canDeleteList(String listId) {
    return controller.tasks.where((task) => task.listId == listId).isEmpty;
  }

  /// Obtém a contagem de tarefas de um projeto
  int getProjectTaskCount(String projectId) {
    return controller.tasks.where((task) {
      final taskList = controller.lists.firstWhere(
        (list) => list.id == task.listId,
        orElse:
            () => TaskList(
              id: '',
              name: '',
              color: Colors.grey,
              emoji: '📝',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isDefault: false,
              sortOrder: 0,
              projectId: null,
            ),
      );
      return taskList.projectId == projectId;
    }).length;
  }
}
