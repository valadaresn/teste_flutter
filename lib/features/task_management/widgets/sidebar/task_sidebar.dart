import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../themes/theme_provider.dart';
import '../../themes/app_theme.dart';
import '../lists/list_panel.dart';
import '../projects/project_panel.dart';
import '../settings/samsung_style/index.dart';
import '../../../log_screen/controllers/log_controller.dart';
import '../../../log_screen/screens/log_screen.dart';
import '../settings/settings_screen.dart';

/// **TaskSidebar** - Componente de sidebar extraído do TaskManagementScreen
///
/// Este componente é responsável por:
/// - Renderizar a sidebar completa da aplicação
/// - Alternar entre temas padrão e Samsung Notes
/// - Gerenciar seções: Hoje, Atividades, Logs, Projetos, Listas, Configurações
/// - Fornecer navegação e contadores de tarefas
class TaskSidebar extends StatelessWidget {
  final TaskController controller;

  const TaskSidebar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        // Se o tema Samsung Notes estiver selecionado, usar o novo sidebar
        if (themeProvider.sidebarTheme == SidebarTheme.samsungNotes) {
          return SamsungSidebar(controller: controller);
        }

        // Caso contrário, usar o sidebar padrão
        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: themeProvider.getSidebarColor(context),
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

              // SEÇÃO ATIVIDADES DO DIA - Nova seção
              _buildActivitiesSection(context, controller),
              Container(height: 1, color: Theme.of(context).dividerColor),

              // SEÇÃO LOGS - Nova seção para logs
              _buildLogsSection(context, controller),
              Container(height: 1, color: Theme.of(context).dividerColor),

              // SEÇÃO DE PROJETOS - Extraída para componente separado
              ProjectPanel(controller: controller),

              // DIVISOR
              Container(height: 1, color: Theme.of(context).dividerColor),

              // SEÇÃO DE LISTAS - Extraída para componente separado
              ListPanel(controller: controller),

              // DIVISOR
              Container(height: 1, color: Theme.of(context).dividerColor),

              // SEÇÃO CONFIGURAÇÕES
              _buildSettingsSection(context),
            ],
          ),
        );
      },
    );
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

  /// Constrói a seção "Atividades do Dia" na sidebar
  Widget _buildActivitiesSection(
    BuildContext context,
    TaskController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.event_note_outlined,
          size: 20,
          color:
              controller.showActivitiesView
                  ? Theme.of(context).primaryColor
                  : null,
        ),
        title: Text(
          'Atividades do Dia',
          style: TextStyle(
            fontWeight:
                controller.showActivitiesView
                    ? FontWeight.bold
                    : FontWeight.normal,
            color:
                controller.showActivitiesView
                    ? Theme.of(context).primaryColor
                    : null,
          ),
        ),
        selected: controller.showActivitiesView,
        onTap: () => controller.toggleActivitiesView(),
      ),
    );
  }

  /// Constrói a seção "Logs" na sidebar
  Widget _buildLogsSection(BuildContext context, TaskController controller) {
    return Consumer<LogController>(
      builder: (context, logController, child) {
        final activeLogs = logController.getActiveLogsList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            dense: true,
            leading: Icon(
              Icons.access_time,
              size: 20,
              color:
                  activeLogs.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            title: const Text('Logs de Atividade'),
            trailing:
                activeLogs.isNotEmpty
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${activeLogs.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : null,
            onTap: () => _navigateToLogs(context),
          ),
        );
      },
    );
  }

  /// Navega para a tela de logs
  void _navigateToLogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogScreen()),
    );
  }

  /// Constrói a seção "Configurações" na sidebar
  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.settings_outlined, size: 20),
        title: const Text('Configurações'),
        onTap: () => _navigateToSettings(context),
      ),
    );
  }

  /// Navega para a tela de configurações
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}
