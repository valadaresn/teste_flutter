import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/project_model.dart';
import '../../../models/list_model.dart';
import '../../../themes/theme_provider.dart';
import '../settings_screen.dart';
import 'samsung_sidebar_theme.dart';
import 'samsung_list_item.dart';
import 'samsung_section_header.dart';

/// Sidebar principal com estilo Samsung Notes
///
/// Este widget implementa o painel lateral esquerdo com o design
/// minimalista inspirado no Samsung Notes
class SamsungSidebar extends StatelessWidget {
  final TaskController controller;

  const SamsungSidebar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SafeArea(
          child: Container(
            width: 280,
            color: themeProvider.getSidebarColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção principal (Hoje, Importantes, etc.)
                _buildMainSection(context),

                // Seção de projetos
                _buildProjectsSection(context),

                // Seção de configurações
                _buildConfigSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Seção principal com itens globais
  Widget _buildMainSection(BuildContext context) {
    return Column(
      children: [
        // Hoje
        SamsungListItem(
          title: 'Hoje',
          icon: Icons.today_outlined,
          count: controller.getTodayTasks().length,
          isSelected: controller.showTodayView,
          onTap: () => _selectToday(),
        ),

        // Atividades do Dia
        SamsungListItem(
          title: 'Atividades do Dia',
          icon: Icons.event_note_outlined,
          isSelected: controller.showActivitiesView,
          onTap: () => _selectActivities(),
        ),

        // Importantes
        SamsungListItem(
          title: 'Importantes',
          icon: Icons.star_border_outlined,
          count: controller.getImportantTasks().length,
          isSelected: controller.showOnlyImportant,
          onTap: () => _selectImportant(),
        ),

        // Todas as tarefas
        SamsungListItem(
          title: 'Todas as tarefas',
          icon: Icons.inbox_outlined,
          count: controller.tasks.length,
          isSelected:
              controller.selectedListId == null &&
              controller.selectedProjectId == null &&
              !controller.showTodayView &&
              !controller.showOnlyImportant,
          onTap: () => _selectAll(),
        ),
      ],
    );
  }

  /// Seção de projetos com suas listas
  Widget _buildProjectsSection(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Cabeçalho da seção
          SamsungSectionHeader(
            title: 'Projetos',
            trailing: IconButton(
              icon: Icon(
                Icons.add,
                color: SamsungSidebarTheme.iconColor,
                size: 20,
              ),
              onPressed: () => _showAddProjectDialog(context),
            ),
          ),

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
  }

  /// Constrói um projeto com suas listas aninhadas
  Widget _buildProjectWithLists(BuildContext context, Project project) {
    final isProjectSelected = controller.selectedProjectId == project.id;
    final projectLists =
        controller.lists.where((list) => list.projectId == project.id).toList();

    return Column(
      children: [
        // Item do projeto
        SamsungListItem(
          title: project.name,
          icon: Icons.folder_outlined,
          count: _getProjectTaskCount(project.id),
          isSelected: isProjectSelected && controller.selectedListId == null,
          onTap: () => _selectProject(project.id),
          onLongPress: () => _showProjectOptions(context, project),
        ),

        // Listas do projeto (se projeto estiver selecionado)
        if (isProjectSelected)
          ...projectLists.map(
            (taskList) => SamsungListItem(
              title: taskList.name,
              icon: Icons.list_alt_outlined,
              count: controller.getTasksByList(taskList.id).length,
              isSelected: controller.selectedListId == taskList.id,
              isNested: true,
              onTap: () => _selectList(taskList.id),
              onLongPress: () => _showListOptions(context, taskList),
            ),
          ),

        // Botão para adicionar nova lista (se projeto estiver selecionado)
        if (isProjectSelected)
          SamsungListItem(
            title: 'Nova lista',
            icon: Icons.add,
            isNested: true,
            onTap: () => _showAddListDialog(context, project.id),
          ),
      ],
    );
  }

  /// Seção de configurações
  Widget _buildConfigSection(BuildContext context) {
    return Column(
      children: [
        SamsungSectionHeader(title: ''),
        SamsungListItem(
          title: 'Configurações',
          icon: Icons.settings_outlined,
          onTap: () => _openSettings(context),
        ),
      ],
    );
  }

  // ============================================================================
  // MÉTODOS DE NAVEGAÇÃO E SELEÇÃO
  // ============================================================================

  void _selectToday() {
    controller.toggleTodayView();
  }

  void _selectActivities() {
    controller.toggleActivitiesView();
  }

  void _selectImportant() {
    controller.toggleShowOnlyImportant();
  }

  void _selectAll() {
    controller.selectProject(null);
    controller.clearSearch();
  }

  void _selectProject(String projectId) {
    controller.selectProject(projectId);
  }

  void _selectList(String listId) {
    controller.selectList(listId);
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  int _getProjectTaskCount(String projectId) {
    // Contar tarefas do projeto através das listas
    return controller.tasks.where((task) {
      final taskList = controller.lists.firstWhere(
        (list) => list.id == task.listId,
        orElse:
            () => TaskList(
              id: '',
              name: '',
              color: Colors.grey,
              emoji: '📝',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isDefault: false,
              sortOrder: 0,
              projectId: null,
            ),
      );
      return taskList.projectId == projectId;
    }).length;
  }

  // ============================================================================
  // MÉTODOS DE DIALOGS E OPÇÕES (PLACEHOLDERS)
  // ============================================================================

  void _showAddProjectDialog(BuildContext context) {
    // TODO: Implementar dialog para adicionar projeto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adicionar projeto - Em desenvolvimento')),
    );
  }

  void _showProjectOptions(BuildContext context, Project project) {
    // TODO: Implementar menu de opções do projeto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opções do projeto - Em desenvolvimento')),
    );
  }

  void _showAddListDialog(BuildContext context, String projectId) {
    // TODO: Implementar dialog para adicionar lista
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adicionar lista - Em desenvolvimento')),
    );
  }

  void _showListOptions(BuildContext context, TaskList taskList) {
    // TODO: Implementar menu de opções da lista
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opções da lista - Em desenvolvimento')),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }
}
