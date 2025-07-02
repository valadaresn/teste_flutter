import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import 'expansible_task_group.dart';

/// **TodayPanel** - Painel principal da guia Hoje
///
/// Este componente exibe tarefas relevantes para o dia atual,
/// organizadas em grupos expansíveis (Hoje, Atrasado)
class TodayPanel extends StatelessWidget {
  final TaskController controller;

  const TodayPanel({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactScreen = screenWidth < 400;
    return Container(
      color: Colors.white, // Fundo branco para teste
      padding: EdgeInsets.all(isCompactScreen ? 4.0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção Hoje
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hoje',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Verificar se há tarefas para exibir
          _buildTaskGroups(context),
        ],
      ),
    );
  }

  /// Construir grupos de tarefas ou estado vazio
  Widget _buildTaskGroups(BuildContext context) {
    final todayCount = controller.countTodayTasks();
    final overdueCount = controller.countOverdueTasks();
    final completedCount = controller.countCompletedTasks();

    // Se não há tarefas para hoje nem atrasadas (concluídas são opcionais)
    if (todayCount == 0 && overdueCount == 0) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Grupos de tarefas expansíveis
        ExpansibleTaskGroup(
          title: 'Atrasado',
          icon: Icons.warning_outlined,
          controller: controller,
          taskType: TaskGroupType.overdue,
          iconColor: Colors.red.shade600,
        ),

        ExpansibleTaskGroup(
          title: 'Hoje',
          icon: Icons.today_outlined,
          controller: controller,
          taskType: TaskGroupType.today,
          iconColor: Theme.of(context).colorScheme.primary,
        ),

        // Grupo de tarefas concluídas (sempre colapsado inicialmente)
        if (completedCount > 0)
          ExpansibleTaskGroup(
            title: 'Concluído',
            icon: Icons.check_circle_outline,
            controller: controller,
            taskType: TaskGroupType.completed,
            iconColor: Colors.green.shade600,
          ),
      ],
    );
  }

  /// Estado vazio quando não há tarefas
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa para hoje! 🎉',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você está em dia com suas tarefas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
