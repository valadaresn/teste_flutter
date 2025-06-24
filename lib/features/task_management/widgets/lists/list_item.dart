import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart';
import 'list_context_menu.dart';

class ListItem extends StatelessWidget {
  final TaskList list;
  final TaskController controller;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(TapUpDetails details)? onSecondaryTapUp;
  final VoidCallback? onLongPress;

  const ListItem({
    Key? key,
    required this.list,
    required this.controller,
    required this.isSelected,
    required this.onTap,
    this.onSecondaryTapUp,
    this.onLongPress,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pendingCount = controller.countPendingTasksInList(list.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border:
            isSelected
                ? Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                )
                : null,
      ),
      child: GestureDetector(
        // Clique direito (desktop)
        onSecondaryTapUp:
            onSecondaryTapUp ??
            (details) => ListContextMenu.show(
              context: context,
              controller: controller,
              list: list,
              position: details.globalPosition,
            ),
        // Toque longo (mobile)
        onLongPress:
            onLongPress ??
            () => ListContextMenu.show(
              context: context,
              controller: controller,
              list: list,
            ),
        child: ListTile(
          dense: true,
          leading: Text(list.emoji, style: const TextStyle(fontSize: 18)),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
            child: Text(list.name),
          ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : pendingCount > 0
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.outline.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : pendingCount > 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
              ),
              child: Text('$pendingCount'),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
