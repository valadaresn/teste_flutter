import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart' as Models;
import 'list_form_dialog.dart';
import 'list_delete_dialog.dart';

/// **ListContextMenu** - Menu de contexto para ações em listas
///
/// Este componente é responsável por:
/// - Exibir menu contextual para desktop (clique direito)
/// - Exibir bottom sheet para mobile (toque longo)
/// - Gerenciar ações de editar e excluir listas
/// - Validar regras de negócio (exclusão apenas de listas vazias)
/// - Fornecer feedback visual apropriado para cada plataforma
///
/// **Funcionalidades:**
/// - Menu popup posicionado para desktop
/// - Bottom sheet responsivo para mobile
/// - Validação de lista vazia para exclusão
/// - Feedback visual sobre ações desabilitadas
/// - Integração com dialogs de edição e exclusão
class ListContextMenu {
  /// Exibe o menu de contexto para ações da lista
  static void show({
    required BuildContext context,
    required TaskController controller,
    required Models.TaskList list,
    Offset?
    position, // null = mobile (toque longo), não-null = desktop (clique direito)
  }) {
    final totalTasksCount =
        controller.tasks.where((t) => t.listId == list.id).length;
    final canDelete = totalTasksCount == 0; // Só pode excluir listas vazias

    if (position != null) {
      // Menu para desktop (clique direito) - posição específica
      _showDesktopMenu(
        context: context,
        controller: controller,
        list: list,
        position: position,
        canDelete: canDelete,
        totalTasksCount: totalTasksCount,
      );
    } else {
      // Menu para mobile (toque longo) - modal bottom sheet
      _showMobileMenu(
        context: context,
        controller: controller,
        list: list,
        canDelete: canDelete,
        totalTasksCount: totalTasksCount,
      );
    }
  }

  /// Menu contextual para desktop (clique direito)
  static void _showDesktopMenu({
    required BuildContext context,
    required TaskController controller,
    required Models.TaskList list,
    required Offset position,
    required bool canDelete,
    required int totalTasksCount,
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
                canDelete ? 'Excluir' : 'Excluir (lista não vazia)',
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
        _handleListAction(
          context: context,
          controller: controller,
          list: list,
          action: action,
          totalTasksCount: totalTasksCount,
        );
      }
    });
  }

  /// Menu contextual para mobile (toque longo)
  static void _showMobileMenu({
    required BuildContext context,
    required TaskController controller,
    required Models.TaskList list,
    required bool canDelete,
    required int totalTasksCount,
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
                // Header com informações da lista
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      Text(list.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$totalTasksCount tarefa${totalTasksCount != 1 ? 's' : ''}',
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
                  title: const Text('Editar lista'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleListAction(
                      context: context,
                      controller: controller,
                      list: list,
                      action: 'edit',
                      totalTasksCount: totalTasksCount,
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
                    canDelete ? 'Excluir lista' : 'Não é possível excluir',
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
                          : const Text('A lista precisa estar vazia'),
                  onTap:
                      canDelete
                          ? () {
                            Navigator.pop(context);
                            _handleListAction(
                              context: context,
                              controller: controller,
                              list: list,
                              action: 'delete',
                              totalTasksCount: totalTasksCount,
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
  static void _handleListAction({
    required BuildContext context,
    required TaskController controller,
    required Models.TaskList list,
    required String action,
    required int totalTasksCount,
  }) {
    switch (action) {
      case 'edit':
        _showEditListDialog(context, controller, list);
        break;
      case 'delete':
        if (totalTasksCount == 0) {
          _showDeleteListDialog(context, controller, list);
        } else {
          // Aviso de que não pode excluir lista com tarefas
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Não é possível excluir "${list.name}". '
                'A lista possui $totalTasksCount tarefa${totalTasksCount != 1 ? 's' : ''}.',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        break;
    }
  }

  /// Exibe o diálogo para editar uma lista
  static void _showEditListDialog(
    BuildContext context,
    TaskController controller,
    Models.TaskList list,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ListFormDialog(
            controller: controller,
            list: list, // Passa a lista para modo edição
          ),
    );
  }

  /// Exibe o diálogo para excluir uma lista
  static void _showDeleteListDialog(
    BuildContext context,
    TaskController controller,
    Models.TaskList list,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ListDeleteDialog(controller: controller, list: list),
    );
  }
}
