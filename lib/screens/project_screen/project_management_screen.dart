import 'package:flutter/material.dart';
import '../../models/project.dart';
import 'project_edit_screen.dart';

class ProjectManagementScreen extends StatefulWidget {
  final List<Project> projects;
  final Function(Project) onAddProject;
  final Function(Project) onUpdateProject;
  final Function(String) onDeleteProject;

  const ProjectManagementScreen({
    super.key,
    required this.projects,
    required this.onAddProject,
    required this.onUpdateProject,
    required this.onDeleteProject,
  });

  @override
  State<ProjectManagementScreen> createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Projetos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProjectEditScreen(
                        onSave: widget.onAddProject,
                        onDelete: (_) {}, // Não usado para novo projeto
                      ),
                ),
              );
            },
            tooltip: 'Adicionar novo projeto',
          ),
        ],
      ),
      body:
          widget.projects.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum projeto criado',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clique no botão + para criar um novo projeto',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProjectEditScreen(
                                  onSave: widget.onAddProject,
                                  onDelete:
                                      (_) {}, // Não usado para novo projeto
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Projeto'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProjectEditScreen(
                                  project: project,
                                  onSave: widget.onUpdateProject,
                                  onDelete: widget.onDeleteProject,
                                ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: project.color.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                project.icon,
                                color: project.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${project.lists.length} ${project.lists.length == 1 ? 'lista' : 'listas'} • ${project.pendingTasks} ${project.pendingTasks == 1 ? 'tarefa pendente' : 'tarefas pendentes'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
