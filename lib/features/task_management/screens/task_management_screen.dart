import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task_controller.dart';
import '../widgets/lists/list_panel.dart';
import '../widgets/tasks/task_list.dart';
import '../widgets/tasks/task_detail_panel.dart';
import '../widgets/tasks/simple_task_dialog.dart';
import 'settings_screen.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ITEM #3 das instruções - Consumer envolvendo TODO o Scaffold
    return Consumer<TaskController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: _buildAppBar(context, controller),
          body: _buildBody(context, controller), // ITEM #4 - controller como parâmetro
          floatingActionButton: _buildFloatingActionButton(context, controller),
        );
      },
    );
  }

  // ITEM #4 das instruções - buildBody recebe controller como parâmetro
  Widget _buildBody(BuildContext context, TaskController controller) {
    if (controller.isLoading && controller.lists.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              controller.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Recriar o controller para tentar novamente
                context.read<TaskController>();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }    return Row(
      children: [
        // Painel lateral esquerdo - Listas
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: ListPanel(controller: controller),
        ),
        
        // Área principal - Tarefas
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child: _buildTaskArea(context, controller),
          ),
        ),
        
        // Painel lateral direito - Detalhes da tarefa (se houver tarefa selecionada)
        if (controller.selectedTaskId != null)
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: TaskDetailPanel(
              task: controller.getSelectedTask()!,
              controller: controller,
              onClose: () => controller.selectTask(null),
            ),
          ),
      ],
    );
  }
  Widget _buildTaskArea(BuildContext context, TaskController controller) {
    final selectedList = controller.selectedListId != null 
        ? controller.getListById(controller.selectedListId!)
        : null;

    return Column(
      children: [
        // Cabeçalho da área de tarefas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (selectedList != null) ...[
                Text(
                  selectedList.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedList.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${controller.countPendingTasksInList(selectedList.id)} tarefas pendentes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.inbox,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Todas as Tarefas',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${controller.tasks.where((t) => !t.isCompleted).length} tarefas pendentes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Botões de ação do cabeçalho
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearchDialog(context, controller),
                tooltip: 'Buscar',
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context, controller),
                tooltip: 'Filtros',
              ),
            ],
          ),        ),        // Área da lista com fundo colorido baseado na lista selecionada
        Expanded(
          child: Container(
            color: selectedList?.color ?? Theme.of(context).colorScheme.background,
            child: TaskList(controller: controller),
          ),
        ),
      ],
    );
  }
  PreferredSizeWidget _buildAppBar(BuildContext context, TaskController controller) {
    return AppBar(
      title: const Text('Gerenciador de Tarefas'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,      actions: [
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

        // Botão de limpar filtros
        if (controller.searchQuery.isNotEmpty || 
            controller.selectedListId != null ||
            !controller.showCompletedTasks ||
            controller.selectedPriority != null ||
            controller.showOnlyImportant)
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: controller.clearAllFilters,
            tooltip: 'Limpar filtros',
          ),

        // Menu de opções
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, controller, value),
          itemBuilder: (context) => [
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
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, TaskController controller) {
    return FloatingActionButton(
      onPressed: () => _showCreateTaskDialog(context, controller),
      tooltip: 'Nova Tarefa',
      child: const Icon(Icons.add),
    );
  }

  void _handleMenuAction(BuildContext context, TaskController controller, String action) {
    switch (action) {
      case 'toggle_completed':
        controller.toggleShowCompletedTasks();
        break;
      case 'show_important':
        controller.toggleShowOnlyImportant();
        break;
      case 'debug':
        controller.debugPrintState();
        _showDebugDialog(context, controller);
        break;
    }
  }
  void _showSearchDialog(BuildContext context, TaskController controller) {
    // TODO: Implementar diálogo de busca
    print('🔍 Mostrar diálogo de busca');
  }
  void _showFilterDialog(BuildContext context, TaskController controller) {
    // TODO: Implementar diálogo de filtros
    print('🔽 Mostrar diálogo de filtros');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }void _showCreateTaskDialog(BuildContext context, TaskController controller) {
    showDialog(
      context: context,
      builder: (context) => TaskCreationDialog(
        controller: controller,
      ),
    );
  }

  void _showDebugDialog(BuildContext context, TaskController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Listas: ${controller.lists.length}'),
            Text('Tarefas: ${controller.tasks.length}'),
            Text('Lista selecionada: ${controller.selectedListId ?? "Todas"}'),
            Text('Busca: "${controller.searchQuery}"'),
            Text('Mostrar concluídas: ${controller.showCompletedTasks}'),
            Text('Apenas importantes: ${controller.showOnlyImportant}'),
            Text('Prioridade: ${controller.selectedPriority?.name ?? "Todas"}'),
            Text('Loading: ${controller.isLoading}'),
            if (controller.error != null) Text('Erro: ${controller.error}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
