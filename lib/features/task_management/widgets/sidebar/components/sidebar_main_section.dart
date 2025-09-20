import 'package:flutter/material.dart';
import '../../../controllers/task_controller.dart';
import 'sidebar_item.dart';

/// **SidebarMainSection** - Seção principal da sidebar
///
/// Este componente é responsável por:
/// - Renderizar itens principais: Hoje, Atividades do Dia, Importantes, Todas as tarefas
/// - Aplicar tema automaticamente através do SidebarItem
/// - Fornecer contadores de tarefas
/// - Gerenciar seleções
class SidebarMainSection extends StatelessWidget {
  final TaskController controller;

  const SidebarMainSection({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hoje
        SidebarItem(
          title: 'Hoje',
          icon: Icons.today_outlined,
          count: _getTodayCount(),
          isSelected: controller.showTodayView,
          onTap: () => controller.toggleTodayView(),
        ),

        // Atividades do Dia
        SidebarItem(
          title: 'Atividades do Dia',
          icon: Icons.event_note_outlined,
          isSelected: controller.showActivitiesView,
          onTap: () => controller.toggleActivitiesView(),
        ),

        // Importantes
        SidebarItem(
          title: 'Importantes',
          icon: Icons.star_border_outlined,
          count: controller.getImportantTasks().length,
          isSelected: controller.showOnlyImportant,
          onTap: () => controller.toggleShowOnlyImportant(),
        ),

        // Todas as tarefas
        SidebarItem(
          title: 'Todas as tarefas',
          icon: Icons.inbox_outlined,
          count: controller.tasks.length,
          isSelected: _isAllTasksSelected(),
          onTap: () => _selectAllTasks(),
        ),
      ],
    );
  }

  /// Calcula o total de tarefas para "Hoje" (hoje + atrasadas)
  int _getTodayCount() {
    final todayTasks = controller.getTodayTasks();
    final overdueTasks = controller.getOverdueTasks();
    return todayTasks.length + overdueTasks.length;
  }

  /// Verifica se "Todas as tarefas" está selecionado
  bool _isAllTasksSelected() {
    return controller.selectedListId == null &&
        controller.selectedProjectId == null &&
        !controller.showTodayView &&
        !controller.showOnlyImportant &&
        !controller.showActivitiesView;
  }

  /// Seleciona visualização de todas as tarefas
  void _selectAllTasks() {
    controller.selectProject(null);
    controller.clearSearch();
  }
}
