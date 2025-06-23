import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../screens/settings_screen.dart';
import '../tasks/simple_task_dialog.dart';

/// **TaskAppBar** - AppBar customizada para o gerenciador de tarefas
///
/// Este componente é responsável por:
/// - Exibir o título da aplicação
/// - Mostrar indicador de loading quando necessário
/// - Fornecer botões de ação (configurações, limpar filtros)
/// - Exibir menu de opções com funcionalidades avançadas
/// - Gerenciar ações do menu (toggle completed, importantes, debug)
///
/// **Funcionalidades:**
/// - Indicador visual de loading
/// - Botão de configurações com navegação
/// - Botão de limpar filtros (aparece condicionalmente)
/// - Menu popup com opções avançadas
/// - Diálogo de debug com informações do sistema
/// - Integração completa com TaskController
class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TaskController controller;

  const TaskAppBar({Key? key, required this.controller}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Gerenciador de Tarefas'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      actions: [
        // Indicador de loading
        if (controller.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),

        // Botão de configurações
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _navigateToSettings(context),
          tooltip: 'Configurações',
        ),

        // Botão de limpar filtros (aparece condicionalmente)
        if (_shouldShowClearFiltersButton())
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: controller.clearAllFilters,
            tooltip: 'Limpar filtros',
          ),

        // Menu de opções
        _buildOptionsMenu(context),
      ],
    );
  }

  /// Verifica se deve mostrar o botão de limpar filtros
  bool _shouldShowClearFiltersButton() {
    return controller.searchQuery.isNotEmpty ||
        controller.selectedListId != null ||
        !controller.showCompletedTasks ||
        controller.selectedPriority != null ||
        controller.showOnlyImportant;
  }

  /// Constrói o menu de opções
  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'toggle_completed',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Mostrar/Ocultar Concluídas'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'show_important',
              child: Row(
                children: [
                  Icon(Icons.star),
                  SizedBox(width: 8),
                  Text('Apenas Importantes'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'create_task',
              child: Row(
                children: [
                  Icon(Icons.add_task),
                  SizedBox(width: 8),
                  Text('Nova Tarefa'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'debug',
              child: Row(
                children: [
                  Icon(Icons.bug_report),
                  SizedBox(width: 8),
                  Text('Debug Info'),
                ],
              ),
            ),
          ],
    );
  }

  /// Navega para a tela de configurações
  void _navigateToSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  /// Gerencia as ações do menu
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'toggle_completed':
        controller.toggleShowCompletedTasks();
        break;
      case 'show_important':
        controller.toggleShowOnlyImportant();
        break;
      case 'create_task':
        _showCreateTaskDialog(context);
        break;
      case 'debug':
        controller.debugPrintState();
        _showDebugDialog(context);
        break;
    }
  }

  /// Exibe o diálogo de criação de tarefa
  void _showCreateTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskCreationDialog(controller: controller),
    );
  }

  /// Exibe o diálogo de debug com informações do sistema
  void _showDebugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Debug Info'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDebugInfo('Projetos', '${controller.projects.length}'),
                  _buildDebugInfo('Listas', '${controller.lists.length}'),
                  _buildDebugInfo('Tarefas', '${controller.tasks.length}'),
                  const Divider(),
                  _buildDebugInfo(
                    'Projeto selecionado',
                    controller.selectedProjectId ?? 'Todos',
                  ),
                  _buildDebugInfo(
                    'Lista selecionada',
                    controller.selectedListId ?? 'Todas',
                  ),
                  _buildDebugInfo(
                    'Tarefa selecionada',
                    controller.selectedTaskId ?? 'Nenhuma',
                  ),
                  const Divider(),
                  _buildDebugInfo('Busca', '"${controller.searchQuery}"'),
                  _buildDebugInfo(
                    'Mostrar concluídas',
                    '${controller.showCompletedTasks}',
                  ),
                  _buildDebugInfo(
                    'Apenas importantes',
                    '${controller.showOnlyImportant}',
                  ),
                  _buildDebugInfo(
                    'Prioridade',
                    controller.selectedPriority?.name ?? 'Todas',
                  ),
                  const Divider(),
                  _buildDebugInfo('Loading', '${controller.isLoading}'),
                  if (controller.error != null)
                    _buildDebugInfo('Erro', controller.error!, isError: true),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  /// Constrói uma linha de informação de debug
  Widget _buildDebugInfo(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : null,
                fontWeight: isError ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
