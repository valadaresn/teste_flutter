import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task_controller.dart';
import '../widgets/common/app_state_handler.dart'; // Novo componente extraído
import '../widgets/common/task_app_bar.dart'; // Novo componente extraído
import '../widgets/lists/list_panel.dart'; // Novo componente extraído
import '../widgets/projects/project_panel.dart'; // Novo componente extraído
import '../widgets/tasks/task_panel.dart'; // Novo componente extraído
import '../widgets/tasks/task_detail_panel.dart';
import '../widgets/today/today_panel.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: TaskAppBar(controller: controller),
          body: AppStateHandler(
            controller: controller,
            child: _buildMainContent(context, controller),
          ),
          floatingActionButton: _buildFloatingActionButton(context, controller),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, TaskController controller) {
    return Row(
      children: [
        // Painel lateral esquerdo - Projetos e Listas
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
          child: Column(
            children: [
              // SEÇÃO HOJE - Botão sempre visível na sidebar
              _buildTodaySection(context, controller),
              Container(height: 1, color: Theme.of(context).dividerColor),

              // SEÇÃO DE PROJETOS - Extraída para componente separado
              ProjectPanel(controller: controller),

              // DIVISOR
              Container(height: 1, color: Theme.of(context).dividerColor),

              // SEÇÃO DE LISTAS - Extraída para componente separado
              ListPanel(controller: controller),
            ],
          ),
        ), // Área principal - Tarefas ou Visualização Hoje
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child:
                controller.showTodayView
                    ? _buildTodayPanel(context, controller)
                    : TaskPanel(
                      controller: controller,
                      onShowSearch:
                          () => _showSearchDialog(context, controller),
                      onShowFilter:
                          () => _showFilterDialog(context, controller),
                    ),
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

  Widget _buildFloatingActionButton(
    BuildContext context,
    TaskController controller,
  ) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Implementar diálogo de criação de tarefa
        print('➕ Criar nova tarefa');
      },
      tooltip: 'Nova Tarefa',
      child: const Icon(Icons.add),
    );
  }

  void _showSearchDialog(BuildContext context, TaskController controller) {
    // TODO: Implementar diálogo de busca
    print('🔍 Mostrar diálogo de busca');
  }

  void _showFilterDialog(BuildContext context, TaskController controller) {
    // TODO: Implementar diálogo de filtros
    print('🔽 Mostrar diálogo de filtros');
  }

  /// Constrói a seção "Hoje" na sidebar
  Widget _buildTodaySection(BuildContext context, TaskController controller) {
    final todayTasks = controller.getTodayTasks();
    final overdueTasks = controller.getOverdueTasks();
    final totalCount = todayTasks.length + overdueTasks.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.today,
          size: 20,
          color:
              controller.showTodayView ? Theme.of(context).primaryColor : null,
        ),
        title: Text(
          'Hoje',
          style: TextStyle(
            fontWeight:
                controller.showTodayView ? FontWeight.bold : FontWeight.normal,
            color:
                controller.showTodayView
                    ? Theme.of(context).primaryColor
                    : null,
          ),
        ),
        trailing:
            totalCount > 0
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        controller.showTodayView
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalCount',
                    style: TextStyle(
                      color:
                          controller.showTodayView
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : null,
        selected: controller.showTodayView,
        onTap: () => controller.toggleTodayView(),
      ),
    );
  }

  /// Constrói o painel da visualização "Hoje" na área principal
  Widget _buildTodayPanel(BuildContext context, TaskController controller) {
    return TodayPanel(controller: controller);
  }
}
