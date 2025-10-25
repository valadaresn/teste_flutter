import 'package:flutter/material.dart';

/// 📋 **ContextMenuModule** - Menu de contexto genérico e reutilizável
///
/// **FUNCIONALIDADE:**
/// - Menu de contexto para desktop (clique direito com posição específica)
/// - Bottom sheet para mobile (toque longo)
/// - Lista configurável de ações
/// - Suporte a ações destrutivas (vermelho)
/// - Suporte a dividers entre ações
///
/// **USADO POR:**
/// - SubtaskCard - menu edit/delete
/// - TaskCard - menu edit/delete/duplicate/move
/// - NoteCard - menu edit/delete/share
/// - Qualquer widget que precise de menu de contexto
///
/// **EXEMPLO DE USO:**
/// ```dart
/// // Usando factory editDelete (mais comum)
/// ContextMenuModule.editDelete(
///   onEdit: () => _showEditDialog(),
///   onDelete: () => _confirmDelete(),
///   child: MyWidget(),
/// )
///
/// // Usando factory custom (mais flexível)
/// ContextMenuModule.custom(
///   items: [
///     ContextMenuItem(value: 'edit', label: 'Editar', icon: Icons.edit),
///     ContextMenuItem.divider(),
///     ContextMenuItem(
///       value: 'delete',
///       label: 'Excluir',
///       icon: Icons.delete,
///       isDestructive: true,
///     ),
///   ],
///   onActionSelected: (action) {
///     if (action == 'edit') handleEdit();
///     if (action == 'delete') handleDelete();
///   },
///   child: MyWidget(),
/// )
/// ```
class ContextMenuModule extends StatelessWidget {
  final List<ContextMenuItem> items;
  final Function(String) onActionSelected;
  final Widget child;

  const ContextMenuModule({
    super.key,
    required this.items,
    required this.onActionSelected,
    required this.child,
  });

  /// Factory para menu edit/delete (caso mais comum)
  factory ContextMenuModule.editDelete({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required Widget child,
    String editLabel = 'Editar',
    String deleteLabel = 'Excluir',
  }) {
    return ContextMenuModule(
      items: [
        ContextMenuItem(
          value: 'edit',
          label: editLabel,
          icon: Icons.edit,
        ),
        ContextMenuItem.divider(),
        ContextMenuItem(
          value: 'delete',
          label: deleteLabel,
          icon: Icons.delete,
          isDestructive: true,
        ),
      ],
      onActionSelected: (action) {
        if (action == 'edit') onEdit();
        if (action == 'delete') onDelete();
      },
      child: child,
    );
  }

  /// Factory para menu customizado
  factory ContextMenuModule.custom({
    required List<ContextMenuItem> items,
    required Function(String) onActionSelected,
    required Widget child,
  }) {
    return ContextMenuModule(
      items: items,
      onActionSelected: onActionSelected,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Desktop: clique direito
      onSecondaryTapDown: (details) {
        _showDesktopMenu(context, details.globalPosition);
      },
      // Mobile: toque longo
      onLongPress: () {
        _showMobileMenu(context);
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  /// Menu contextual para desktop (clique direito)
  void _showDesktopMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items
          .where((item) => !item.isDivider)
          .map((item) => _buildPopupMenuItem(context, item))
          .toList(),
    ).then((action) {
      if (action != null) {
        onActionSelected(action);
      }
    });
  }

  /// Menu contextual para mobile (toque longo)
  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Itens do menu
            ...items.map((item) {
              if (item.isDivider) {
                return Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                );
              }

              return _buildListTile(context, item);
            }).toList(),

            // Espaçamento inferior
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Constrói um PopupMenuItem para desktop
  PopupMenuItem<String> _buildPopupMenuItem(
    BuildContext context,
    ContextMenuItem item,
  ) {
    final color = item.isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return PopupMenuItem<String>(
      value: item.value,
      enabled: item.enabled,
      child: Row(
        children: [
          if (item.icon != null)
            Icon(
              item.icon,
              size: 16,
              color: item.enabled ? color : Theme.of(context).disabledColor,
            ),
          if (item.icon != null) const SizedBox(width: 8),
          Text(
            item.label,
            style: TextStyle(
              color: item.enabled ? color : Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um ListTile para mobile
  Widget _buildListTile(BuildContext context, ContextMenuItem item) {
    final color = item.isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return ListTile(
      enabled: item.enabled,
      leading: item.icon != null
          ? Icon(
              item.icon,
              color: item.enabled ? color : Theme.of(context).disabledColor,
            )
          : null,
      title: Text(
        item.label,
        style: TextStyle(
          color: item.enabled ? color : Theme.of(context).disabledColor,
        ),
      ),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      onTap: item.enabled
          ? () {
              Navigator.pop(context);
              onActionSelected(item.value);
            }
          : null,
    );
  }
}

/// 📋 **ContextMenuItem** - Item individual do menu de contexto
class ContextMenuItem {
  final String value;
  final String label;
  final IconData? icon;
  final bool isDestructive;
  final bool enabled;
  final String? subtitle;
  final bool isDivider;

  const ContextMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.enabled = true,
    this.subtitle,
  }) : isDivider = false;

  /// Factory para criar um divider
  const ContextMenuItem.divider()
      : value = '',
        label = '',
        icon = null,
        isDestructive = false,
        enabled = true,
        subtitle = null,
        isDivider = true;
}
