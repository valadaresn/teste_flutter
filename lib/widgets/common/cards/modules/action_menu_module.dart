import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// 📋 Módulo de menu de ações popup
class ActionMenuModule extends PositionableModule {
  final List<ActionMenuItem> actions;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final Function(String)? onActionSelected;

  ActionMenuModule({
    required String position,
    required this.actions,
    this.icon = Icons.more_horiz,
    this.iconSize = 16,
    this.iconColor,
    this.onActionSelected,
  }) : super(position);

  @override
  String get moduleId => 'action_menu_${actions.length}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    return PopupMenuButton<String>(
      onSelected: onActionSelected,
      icon: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? Colors.grey.shade400,
      ),
      padding: EdgeInsets.zero,
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    List<PopupMenuEntry<String>> items = [];

    for (int i = 0; i < actions.length; i++) {
      final action = actions[i];

      if (action.isDivider) {
        items.add(const PopupMenuDivider());
      } else {
        items.add(
          PopupMenuItem(
            value: action.value,
            child: Row(
              children: [
                Icon(
                  action.icon,
                  size: 16,
                  color: action.isDestructive ? Colors.red : null,
                ),
                const SizedBox(width: 8),
                Text(
                  action.label,
                  style: TextStyle(
                    color: action.isDestructive ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return items;
  }
}

/// 📋 Item do menu de ações
class ActionMenuItem {
  final String value;
  final String label;
  final IconData icon;
  final bool isDestructive;
  final bool isDivider;

  const ActionMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.isDestructive = false,
    this.isDivider = false,
  });

  /// Cria um divisor
  const ActionMenuItem.divider()
    : value = '',
      label = '',
      icon = Icons.clear,
      isDestructive = false,
      isDivider = true;
}

/// 🎯 Factory para criar módulos de menu de ação
class ActionMenuModuleFactory {
  /// Menu na posição trailing
  static ActionMenuModule trailing({
    required List<ActionMenuItem> actions,
    IconData icon = Icons.more_horiz,
    double iconSize = 16,
    Color? iconColor,
    Function(String)? onActionSelected,
  }) {
    return ActionMenuModule(
      position: 'trailing',
      actions: actions,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
      onActionSelected: onActionSelected,
    );
  }

  /// Menu na posição header-trailing
  static ActionMenuModule headerTrailing({
    required List<ActionMenuItem> actions,
    IconData icon = Icons.more_vert,
    double iconSize = 18,
    Color? iconColor,
    Function(String)? onActionSelected,
  }) {
    return ActionMenuModule(
      position: 'header-trailing',
      actions: actions,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
      onActionSelected: onActionSelected,
    );
  }

  /// Ações padrão para tasks
  static List<ActionMenuItem> taskActions() {
    return [
      const ActionMenuItem(value: 'edit', label: 'Editar', icon: Icons.edit),
      const ActionMenuItem(
        value: 'duplicate',
        label: 'Duplicar',
        icon: Icons.copy,
      ),
      const ActionMenuItem.divider(),
      const ActionMenuItem(
        value: 'delete',
        label: 'Excluir',
        icon: Icons.delete,
        isDestructive: true,
      ),
    ];
  }

  /// Ações padrão para hábitos
  static List<ActionMenuItem> habitActions() {
    return [
      const ActionMenuItem(value: 'edit', label: 'Editar', icon: Icons.edit),
      const ActionMenuItem(
        value: 'stats',
        label: 'Estatísticas',
        icon: Icons.bar_chart,
      ),
      const ActionMenuItem(
        value: 'reset',
        label: 'Resetar sequência',
        icon: Icons.refresh,
      ),
      const ActionMenuItem.divider(),
      const ActionMenuItem(
        value: 'delete',
        label: 'Excluir',
        icon: Icons.delete,
        isDestructive: true,
      ),
    ];
  }

  /// Ações padrão para notas
  static List<ActionMenuItem> noteActions() {
    return [
      const ActionMenuItem(value: 'edit', label: 'Editar', icon: Icons.edit),
      const ActionMenuItem(
        value: 'share',
        label: 'Compartilhar',
        icon: Icons.share,
      ),
      const ActionMenuItem(value: 'copy', label: 'Copiar', icon: Icons.copy),
      const ActionMenuItem.divider(),
      const ActionMenuItem(
        value: 'delete',
        label: 'Excluir',
        icon: Icons.delete,
        isDestructive: true,
      ),
    ];
  }
}
