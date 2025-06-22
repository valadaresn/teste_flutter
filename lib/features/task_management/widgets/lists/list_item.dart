import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart';

class ListItem extends StatelessWidget {
  final TaskList list;
  final TaskController controller;
  final bool isSelected;
  final VoidCallback onTap;

  const ListItem({
    Key? key,
    required this.list,
    required this.controller,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pendingCount = controller.countPendingTasksInList(list.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: list.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              list.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          list.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        trailing: pendingCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: list.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pendingCount.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: list.color,
                  ),
                ),
              )
            : null,
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
