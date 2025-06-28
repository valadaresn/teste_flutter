import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/list_model.dart';
import '../../themes/app_theme.dart'; // Para ListStyleConstants
import 'list_context_menu.dart';

class ListItem extends StatelessWidget {
  final TaskList list;
  final TaskController controller;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(TapUpDetails details)? onSecondaryTapUp;
  final VoidCallback? onLongPress;
  final bool useDecoratedStyle; // Novo parâmetro

  const ListItem({
    Key? key,
    required this.list,
    required this.controller,
    required this.isSelected,
    required this.onTap,
    this.onSecondaryTapUp,
    this.onLongPress,
    this.useDecoratedStyle = false, // Default é false (estilo atual)
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return useDecoratedStyle
        ? _buildDecoratedStyle(context)
        : _buildCompactStyle(context);
  }

  // Estilo atual (compacto) - código existente movido aqui
  Widget _buildCompactStyle(BuildContext context) {
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
          leading: Text(
            list.emoji,
            style: TextStyle(fontSize: ListStyleConstants.compactEmojiSize),
          ),
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

  // Novo estilo decorado - containers coloridos para emojis
  Widget _buildDecoratedStyle(BuildContext context) {
    final pendingCount = controller.countPendingTasksInList(list.id);

    // Usar cor da lista ou fallback para cor do tema
    final baseColor = list.color;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
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
          dense: ListStyleConstants.decoratedDense, // Usar constante
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: ListStyleConstants.decoratedEmojiContainerSize,
            height: ListStyleConstants.decoratedEmojiContainerSize,
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                ListStyleConstants.decoratedContainerRadius,
              ),
            ),
            child: Center(
              child: Text(
                list.emoji,
                style: TextStyle(
                  fontSize: ListStyleConstants.decoratedEmojiSize,
                ),
              ),
            ),
          ),
          title: Text(
            list.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          trailing:
              pendingCount > 0
                  ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pendingCount.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: baseColor,
                      ),
                    ),
                  )
                  : null,
          onTap: onTap,
          selected: isSelected,
          selectedTileColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
