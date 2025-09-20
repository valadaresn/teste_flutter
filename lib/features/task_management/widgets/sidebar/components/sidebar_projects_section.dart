import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/task_controller.dart';
import '../../../services/task_dialog_service.dart';
import '../../../themes/theme_provider.dart';
import '../../../themes/app_theme.dart';
import 'sidebar_item.dart';
import '../../settings/samsung_style/samsung_section_header.dart';
import '../../settings/samsung_style/samsung_sidebar_theme.dart';

/// **SidebarProjectsSection** - Seção de projetos da sidebar
///
/// Este componente é responsável por:
/// - Renderizar lista de projetos
/// - Renderizar listas de cada projeto selecionado
/// - Botões para adicionar projetos e listas
/// - Aplicar tema automaticamente
/// - Gerenciar menus de contexto
class SidebarProjectsSection extends StatelessWidget {
  final TaskController controller;
  final TaskDialogService dialogService;

  const SidebarProjectsSection({
    Key? key,
    required this.controller,
    required this.dialogService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isSamsungTheme =
            themeProvider.sidebarTheme == SidebarTheme.samsungNotes;

        return Expanded(
          child: Column(
            children: [
              // Cabeçalho da seção
              _buildSectionHeader(context, isSamsungTheme),

              // Lista de projetos
              Expanded(
                child: ListView.builder(
                  itemCount: controller.projects.length,
                  itemBuilder: (context, index) {
                    final project = controller.projects[index];
                    return _buildProjectWithLists(context, project);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Constrói o cabeçalho da seção baseado no tema
  Widget _buildSectionHeader(BuildContext context, bool isSamsungTheme) {
    if (isSamsungTheme) {
      return SamsungSectionHeader(
        title: 'Projetos',
        trailing: IconButton(
          icon: Icon(Icons.add, color: SamsungSidebarTheme.iconColor, size: 20),
          onPressed: () => dialogService.showCreateProjectDialog(context),
        ),
      );
    } else {
      // Cabeçalho estilo padrão
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Projetos',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => dialogService.showCreateProjectDialog(context),
            ),
          ],
        ),
      );
    }
  }

  /// Constrói um projeto com suas listas aninhadas
  Widget _buildProjectWithLists(BuildContext context, project) {
    final isProjectSelected = controller.selectedProjectId == project.id;
    final projectLists =
        controller.lists.where((list) => list.projectId == project.id).toList();

    return Column(
      children: [
        // Item do projeto
        SidebarItem(
          title: project.name,
          icon: Icons.folder_outlined,
          count: dialogService.getProjectTaskCount(project.id),
          isSelected: isProjectSelected && controller.selectedListId == null,
          onTap: () => controller.selectProject(project.id),
          onLongPress:
              () => dialogService.showProjectContextMenu(context, project),
          onSecondaryTap:
              (position) => dialogService.showProjectContextMenu(
                context,
                project,
                position: position,
              ),
        ),

        // Listas do projeto (se projeto estiver selecionado)
        if (isProjectSelected) ...[
          ...projectLists.map(
            (taskList) => SidebarItem(
              title: taskList.name,
              icon: Icons.list_alt_outlined,
              count: controller.getTasksByList(taskList.id).length,
              isSelected: controller.selectedListId == taskList.id,
              isNested: true,
              onTap: () => controller.selectList(taskList.id),
              onLongPress:
                  () => dialogService.showListContextMenu(context, taskList),
              onSecondaryTap:
                  (position) => dialogService.showListContextMenu(
                    context,
                    taskList,
                    position: position,
                  ),
            ),
          ),

          // Botão para adicionar nova lista
          SidebarItem(
            title: 'Nova lista',
            icon: Icons.add,
            isNested: true,
            onTap:
                () => dialogService.showCreateListDialog(
                  context,
                  projectId: project.id,
                ),
          ),
        ],
      ],
    );
  }
}
