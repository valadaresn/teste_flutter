import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/project_model.dart';

class ProjectItem extends StatelessWidget {
  final Project project;
  final TaskController controller;
  final bool isSelected;
  final VoidCallback onTap;

  const ProjectItem({
    Key? key,
    required this.project,
    required this.controller,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Contar listas neste projeto
    final listsCount =
        controller.lists.where((list) => list.projectId == project.id).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: project.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(project.emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          project.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle:
            project.description.isNotEmpty
                ? Text(
                  project.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                : null,
        trailing:
            listsCount > 0
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: project.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    listsCount.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: project.color,
                    ),
                  ),
                )
                : null,
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: Theme.of(
          context,
        ).colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
