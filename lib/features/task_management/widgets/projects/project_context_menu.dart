import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/project_model.dart';
import '../../models/list_model.dart';
import 'project_form_dialog.dart';
import 'project_delete_dialog.dart';

/// **ProjectContextMenu** - Menu de contexto para ações em projetos
///
/// Este componente é responsável por:
/// - Exibir menu contextual para desktop (clique direito)
/// - Exibir bottom sheet para mobile (toque longo)
/// - Gerenciar ações de editar e excluir projetos
/// - Validar regras de negócio (exclusão apenas de projetos vazios)
/// - Fornecer feedback visual apropriado para cada plataforma
class ProjectContextMenu {
  /// Exibe o menu de contexto para ações do projeto
  static void show({
    required BuildContext context,
    required TaskController controller,
    required Project project,
    Offset?
    position, // null = mobile (toque longo), não-null = desktop (clique direito)
  }) {
    // Contar listas no projeto
    final projectLists =
        controller.lists.where((list) => list.projectId == project.id).toList();
    // Contar tarefas no projeto
    final totalTasksCount =
        controller.tasks.where((task) {
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
          return taskList.projectId == project.id;
        }).length;

    final canDelete =
        projectLists.isEmpty &&
        totalTasksCount == 0; // Só pode excluir projetos vazios

    if (position != null) {
      // Menu para desktop (clique direito) - posição específica
      _showDesktopMenu(
        context: context,
        controller: controller,
        project: project,
        position: position,
        canDelete: canDelete,
        totalTasksCount: totalTasksCount,
        listsCount: projectLists.length,
      );
    } else {
      // Menu para mobile (toque longo) - modal bottom sheet
      _showMobileMenu(
        context: context,
        controller: controller,
        project: project,
        canDelete: canDelete,
        totalTasksCount: totalTasksCount,
        listsCount: projectLists.length,
      );
    }
  }

  /// Menu contextual para desktop (clique direito)
  static void _showDesktopMenu({
    required BuildContext context,
    required TaskController controller,
    required Project project,
    required Offset position,
    required bool canDelete,
    required int totalTasksCount,
    required int listsCount,
  }) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          enabled: canDelete,
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: 16,
                color:
                    canDelete
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 8),
              Text(
                canDelete ? 'Excluir' : 'Excluir (projeto não vazio)',
                style: TextStyle(
                  color:
                      canDelete
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((action) {
      if (action != null) {
        _handleProjectAction(
          context: context,
          controller: controller,
          project: project,
          action: action,
          totalTasksCount: totalTasksCount,
          listsCount: listsCount,
        );
      }
    });
  }

  /// Menu contextual para mobile (toque longo)
  static void _showMobileMenu({
    required BuildContext context,
    required TaskController controller,
    required Project project,
    required bool canDelete,
    required int totalTasksCount,
    required int listsCount,
  }) {
    showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com informações do projeto
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      Text(project.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$listsCount lista${listsCount != 1 ? 's' : ''} • $totalTasksCount tarefa${totalTasksCount != 1 ? 's' : ''}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Opções de ação
                ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Editar projeto'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleProjectAction(
                      context: context,
                      controller: controller,
                      project: project,
                      action: 'edit',
                      totalTasksCount: totalTasksCount,
                      listsCount: listsCount,
                    );
                  },
                ),

                ListTile(
                  enabled: canDelete,
                  leading: Icon(
                    Icons.delete,
                    color:
                        canDelete
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).disabledColor,
                  ),
                  title: Text(
                    canDelete ? 'Excluir projeto' : 'Não é possível excluir',
                    style: TextStyle(
                      color:
                          canDelete
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).disabledColor,
                    ),
                  ),
                  subtitle:
                      canDelete
                          ? null
                          : const Text('O projeto precisa estar vazio'),
                  onTap:
                      canDelete
                          ? () {
                            Navigator.pop(context);
                            _handleProjectAction(
                              context: context,
                              controller: controller,
                              project: project,
                              action: 'delete',
                              totalTasksCount: totalTasksCount,
                              listsCount: listsCount,
                            );
                          }
                          : null,
                ),

                // Espaçamento inferior
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  /// Gerencia as ações do menu de contexto
  static void _handleProjectAction({
    required BuildContext context,
    required TaskController controller,
    required Project project,
    required String action,
    required int totalTasksCount,
    required int listsCount,
  }) {
    switch (action) {
      case 'edit':
        _showEditProjectDialog(context, controller, project);
        break;
      case 'delete':
        if (listsCount == 0 && totalTasksCount == 0) {
          _showDeleteProjectDialog(context, controller, project);
        } else {
          // Aviso de que não pode excluir projeto com listas/tarefas
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não é possível excluir "${project.name}". '
                'O projeto possui $listsCount lista${listsCount != 1 ? 's' : ''} e $totalTasksCount tarefa${totalTasksCount != 1 ? 's' : ''}.',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        break;
    }
  }

  /// Exibe o diálogo para editar um projeto
  static void _showEditProjectDialog(
    BuildContext context,
    TaskController controller,
    Project project,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            controller: controller,
            project: project, // Passa o projeto para modo edição
          ),
    );
  }

  /// Exibe o diálogo para excluir um projeto
  static void _showDeleteProjectDialog(
    BuildContext context,
    TaskController controller,
    Project project,
  ) {
    showDialog(
      context: context,
      builder:
          (context) =>
              ProjectDeleteDialog(controller: controller, project: project),
    );
  }
}
