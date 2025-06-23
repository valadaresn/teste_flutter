import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import 'project_form_dialog.dart';
import 'project_delete_dialog.dart';

/// Widget responsável por toda a seção de projetos no painel lateral
/// Inclui header, lista de projetos e interações (criar, editar, excluir)
class ProjectPanel extends StatelessWidget {
  final TaskController controller;

  const ProjectPanel({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção de projetos
          _buildHeader(context),

          // Lista de projetos com altura fixa para evitar overflow
          _buildProjectList(context),
        ],
      ),
    );
  }

  /// Constrói o cabeçalho da seção com título e botão de adicionar
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Projetos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: () => _showCreateProjectDialog(context),
          tooltip: 'Novo projeto',
        ),
      ],
    );
  }

  /// Constrói a lista de projetos com altura fixa e scroll
  Widget _buildProjectList(BuildContext context) {
    return SizedBox(
      height: 120, // Altura fixa para a seção de projetos
      child: ListView.builder(
        itemCount:
            controller.projects.length + 1, // +1 para "Todos os projetos"
        itemBuilder: (context, index) {
          if (index == 0) {
            // Item especial "Todos os projetos" sempre no topo
            return _buildAllProjectsItem(context);
          } else {
            // Projetos existentes
            final project = controller.projects[index - 1];
            return _buildProjectItem(context, project);
          }
        },
      ),
    );
  }

  /// Item especial para mostrar todos os projetos
  Widget _buildAllProjectsItem(BuildContext context) {
    final isSelected = controller.selectedProjectId == null;

    return ListTile(
      dense: true,
      leading: const Icon(Icons.folder_open, size: 20),
      title: const Text('Todos os projetos'),
      trailing: Text('${controller.projects.length}'),
      selected: isSelected,
      onTap: () => controller.selectProject(null),
    );
  }

  /// Item individual de projeto com opções de ação
  Widget _buildProjectItem(BuildContext context, dynamic project) {
    final isSelected = controller.selectedProjectId == project.id;

    return ListTile(
      dense: true,
      leading: Text(project.emoji, style: const TextStyle(fontSize: 18)),
      title: Text(project.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Contador de listas do projeto
          Text(
            '${controller.lists.where((l) => l.projectId == project.id).length}',
          ),

          // Menu de opções (editar, excluir)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 16),
            onSelected:
                (value) => _handleProjectAction(context, project, value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Excluir', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      selected: isSelected,
      // Toggle de seleção: se já selecionado, deseleciona
      onTap: () => controller.selectProject(isSelected ? null : project.id),
    );
  }

  /// Manipula as ações do menu de contexto dos projetos
  void _handleProjectAction(
    BuildContext context,
    dynamic project,
    String action,
  ) {
    switch (action) {
      case 'edit':
        _showEditProjectDialog(context, project);
        break;
      case 'delete':
        _showDeleteProjectConfirmation(context, project);
        break;
    }
  }

  /// Abre o diálogo para criar um novo projeto
  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            controller: controller,
            // Modo criação: sem projeto inicial
          ),
    );
  }

  /// Abre o diálogo para editar um projeto existente
  void _showEditProjectDialog(BuildContext context, dynamic project) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectFormDialog(
            controller: controller,
            project: project, // Passa o projeto para edição
          ),
    );
  }

  /// Abre o diálogo de confirmação para exclusão de projeto
  void _showDeleteProjectConfirmation(BuildContext context, dynamic project) {
    showDialog(
      context: context,
      builder:
          (context) =>
              ProjectDeleteDialog(controller: controller, project: project),
    );
  }
}
