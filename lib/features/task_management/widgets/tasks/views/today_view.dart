import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/task_controller.dart';
import '../../../themes/theme_provider.dart';
import '../../input/quick_add_task_input.dart';
import '../task_group/expansible_group.dart';
//import '../tasks/quick_add_task_input.dart';
import '../../input/mobile_quick_add_task_input.dart';

/// **TodayView** - Painel principal da guia Hoje (renomeado de TodayPanel)
///
/// Este componente exibe tarefas relevantes para o dia atual,
/// organizadas em grupos expansíveis (Hoje, Atrasado)
class TodayView extends StatelessWidget {
  final TaskController controller;
  final VoidCallback? onToggleSidebar;

  const TodayView({Key? key, required this.controller, this.onToggleSidebar})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactScreen = screenWidth < 400;
    final isMobile = screenWidth < 600; // Detectar se é mobile

    // 🚀 OTIMIZAÇÃO: Usar Selector para rebuilds mais granulares
    return Selector<ThemeProvider, Color>(
      selector:
          (context, themeProvider) => themeProvider.getBackgroundColor(
            context,
            listColor:
                controller.selectedListId != null
                    ? controller.getListById(controller.selectedListId!)?.color
                    : null,
          ),
      builder: (context, backgroundColor, child) {
        return Container(
          color: backgroundColor,
          padding: EdgeInsets.all(isCompactScreen ? 4.0 : 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da seção Hoje
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    // Botão hambúrguer para recolher/expandir sidebar (opcional)
                    if (onToggleSidebar != null)
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: onToggleSidebar,
                        tooltip: 'Recolher/Expandir painel lateral',
                      ),
                    if (onToggleSidebar != null) const SizedBox(width: 8),
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
                    const Spacer(),
                    // FAB para adicionar tarefa - APENAS NO MOBILE
                    if (isMobile)
                      Material(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => _showMobileAddTask(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Verificar se há tarefas para exibir
              Expanded(child: _buildTaskGroups(context)),

              // Campo de entrada rápida de tarefas - APENAS NO DESKTOP
              if (!isMobile) QuickAddTaskInput(controller: controller),
            ],
          ),
        );
      },
    );
  }

  /// Mostrar modal de adicionar tarefa no mobile
  void _showMobileAddTask(BuildContext context) {
    debugPrint('🚀 Tentando abrir modal mobile add task');
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          debugPrint('🚀 Builder do modal sendo executado');
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: MobileQuickAddTaskInput(controller: controller),
          );
        },
      );
    } catch (e) {
      debugPrint('🚨 Erro ao abrir modal: $e');
    }
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
        ExpansibleGroup(
          title: 'Atrasado',
          icon: Icons.warning_outlined,
          controller: controller,
          taskType: TaskGroupType.overdue,
          iconColor: Colors.red.shade600,
        ),

        ExpansibleGroup(
          title: 'Hoje',
          icon: Icons.today_outlined,
          controller: controller,
          taskType: TaskGroupType.today,
          iconColor: Theme.of(context).colorScheme.primary,
        ),

        // Grupo de tarefas concluídas (sempre colapsado inicialmente)
        if (completedCount > 0)
          ExpansibleGroup(
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
