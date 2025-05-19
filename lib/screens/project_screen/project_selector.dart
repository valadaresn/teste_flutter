import 'package:flutter/material.dart';
import '../../../models/project.dart';

class ProjectSelector extends StatefulWidget {
  final Project? selectedProject;
  final List<Project> projects;
  final Function(Project) onProjectSelected;
  final VoidCallback? onManageProjects;

  const ProjectSelector({
    super.key,
    this.selectedProject,
    required this.projects,
    required this.onProjectSelected,
    this.onManageProjects,
  });

  @override
  State<ProjectSelector> createState() => _ProjectSelectorState();
}

class _ProjectSelectorState extends State<ProjectSelector> {
  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _isSelecting ? null : _showSelector,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.selectedProject != null) ...[
            Icon(
              widget.selectedProject!.icon,
              color: widget.selectedProject!.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.selectedProject!.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ] else
            const Text(
              'Todos os Projetos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  void _showSelector() {
    if (widget.projects.isEmpty) return;

    setState(() => _isSelecting = true);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Selecionar Projeto',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (widget.onManageProjects != null)
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () {
                            Navigator.pop(context);
                            Future.microtask(() {
                              widget.onManageProjects?.call();
                            });
                          },
                          tooltip: 'Gerenciar projetos',
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.projects.length,
                    itemBuilder: (context, index) {
                      final project = widget.projects[index];
                      final isSelected =
                          widget.selectedProject?.id == project.id;

                      return ListTile(
                        leading: Icon(project.icon, color: project.color),
                        title: Text(project.name),
                        subtitle: Text('${project.pendingTasks} pendentes'),
                        selected: isSelected,
                        selectedTileColor: project.color.withOpacity(0.1),
                        onTap: () {
                          Navigator.pop(context);
                          Future.microtask(() {
                            widget.onProjectSelected(project);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    ).then((_) {
      if (mounted) {
        setState(() => _isSelecting = false);
      }
    });
  }
}
