import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../themes/theme_provider.dart';
import '../../services/task_dialog_service.dart';
import '../../../log_screen/controllers/log_controller.dart';
import 'components/sidebar_main_section.dart';
import 'components/sidebar_projects_section.dart';
import 'components/sidebar_config_section.dart';
import 'components/sidebar_item.dart';

/// **TaskSidebar** - Componente principal da sidebar
///
/// Este componente é responsável por:
/// - Compor todas as seções da sidebar
/// - Aplicar tema automaticamente através dos componentes
/// - Gerenciar o DialogService centralizado
/// - Fornecer navegação e funcionalidades completas
class TaskSidebar extends StatelessWidget {
  final TaskController controller;
  late final TaskDialogService _dialogService;

  TaskSidebar({Key? key, required this.controller}) : super(key: key) {
    _dialogService = TaskDialogService(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return SafeArea(
          child: Container(
            width: 280,
            color: themeProvider.getSidebarColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção principal (Hoje, Importantes, etc.)
                SidebarMainSection(controller: controller),

                // Logs section
                _buildLogsSection(context),

                // Seção de projetos
                SidebarProjectsSection(
                  controller: controller,
                  dialogService: _dialogService,
                ),

                // Seção de configurações
                SidebarConfigSection(dialogService: _dialogService),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Seção de logs (temporária até migrar para componente)
  Widget _buildLogsSection(BuildContext context) {
    return Consumer<LogController>(
      builder: (context, logController, child) {
        final activeLogs = logController.getActiveLogsList();

        return SidebarItem(
          title: 'Logs de Atividade',
          icon: Icons.access_time,
          count: activeLogs.length,
          onTap: () => _dialogService.navigateToLogs(context),
        );
      },
    );
  }
}
