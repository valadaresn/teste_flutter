import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// ⚡ **ActionModule** - Módulo de ações/botões para cards modulares
///
/// **FUNCIONALIDADE:**
/// - Múltiplas ações com diferentes estilos
/// - Botões de icon, button, filled, text, chip, fab
/// - Limite de ações com overflow
/// - Factory com ações pré-definidas (edit, delete, share, etc.)
///
/// **STATUS DE USO:**
/// ⚠️ SUBUTILIZADO - Usado apenas em CleanCardExamples
/// ⚠️ CONCORRE com ActionMenuModule (mais usado)
///
/// **DIFERENÇAS DO ActionMenuModule:**
/// - ActionModule: Botões visíveis lado a lado
/// - ActionMenuModule: Menu dropdown compacto (mais usado)
///
/// **RECOMENDAÇÃO:**
/// - Considere usar ActionMenuModule para simplicidade
/// - Use ActionModule quando precisar de ações sempre visíveis
///
/// **POSIÇÕES COMUNS:**
/// - `trailing`: Lado direito do card (padrão)
/// - `footer`: Rodapé do card (modo barra de ações)
/// - `header-trailing`: Direita do cabeçalho (modo compacto)
///
/// **EXEMPLO DE USO:**
/// ```dart
/// ActionModuleFactory.trailing(
///   actions: [
///     ActionDataFactory.edit(onPressed: editItem),
///     ActionDataFactory.delete(onPressed: deleteItem),
///   ],
///   style: ActionStyle.icon,
/// )
/// ```

/// ⚡ Módulo de Ações para cards
class ActionModule extends PositionableModule {
  final List<ActionData> actions;
  final ActionStyle style;
  final MainAxisAlignment alignment;
  final double spacing;
  final bool showLabels;
  final int maxActions;
  final VoidCallback? onOverflowTap;

  ActionModule({
    required String position,
    required this.actions,
    this.style = ActionStyle.icon,
    this.alignment = MainAxisAlignment.end,
    this.spacing = 8.0,
    this.showLabels = false,
    this.maxActions = 3,
    this.onOverflowTap,
  }) : super(position);

  @override
  String get moduleId => 'actions_${actions.length}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    final visibleActions = actions.take(maxActions).toList();
    final hasOverflow = actions.length > maxActions;

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleActions
            .map((action) => _buildAction(context, action))
            .expand((widget) => [widget, SizedBox(width: spacing)])
            .take(visibleActions.length * 2 - 1), // Remove último spacing
        // Overflow button
        if (hasOverflow) _buildOverflowAction(context),
      ],
    );
  }

  Widget _buildAction(BuildContext context, ActionData action) {
    final theme = Theme.of(context);

    switch (style) {
      case ActionStyle.icon:
        return IconButton(
          icon: Icon(action.icon),
          onPressed: action.onPressed,
          color: action.color ?? theme.colorScheme.onSurface,
          iconSize: 20,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
          tooltip: action.tooltip ?? action.label,
        );

      case ActionStyle.button:
        return OutlinedButton.icon(
          onPressed: action.onPressed,
          icon: Icon(action.icon, size: 16),
          label: Text(action.label),
          style: OutlinedButton.styleFrom(
            foregroundColor: action.color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(0, 32),
            visualDensity: VisualDensity.compact,
          ),
        );

      case ActionStyle.filled:
        return FilledButton.icon(
          onPressed: action.onPressed,
          icon: Icon(action.icon, size: 16),
          label: Text(action.label),
          style: FilledButton.styleFrom(
            backgroundColor: action.color ?? theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(0, 32),
            visualDensity: VisualDensity.compact,
          ),
        );

      case ActionStyle.text:
        return TextButton.icon(
          onPressed: action.onPressed,
          icon: Icon(action.icon, size: 16),
          label: Text(action.label),
          style: TextButton.styleFrom(
            foregroundColor: action.color,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(0, 28),
            visualDensity: VisualDensity.compact,
          ),
        );

      case ActionStyle.chip:
        return ActionChip(
          avatar: Icon(action.icon, size: 16),
          label: Text(action.label),
          onPressed: action.onPressed,
          backgroundColor: action.backgroundColor,
          labelStyle: TextStyle(color: action.color),
          visualDensity: VisualDensity.compact,
          tooltip: action.tooltip,
        );

      case ActionStyle.fab:
        return SizedBox(
          width: 32,
          height: 32,
          child: FloatingActionButton(
            onPressed: action.onPressed,
            mini: true,
            backgroundColor:
                action.backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: action.color ?? theme.colorScheme.onPrimary,
            elevation: 2,
            tooltip: action.tooltip ?? action.label,
            child: Icon(action.icon, size: 16),
          ),
        );
    }
  }

  Widget _buildOverflowAction(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_horiz),
      onPressed: onOverflowTap,
      color: Theme.of(context).colorScheme.onSurface,
      iconSize: 20,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      tooltip: 'Mais ações',
    );
  }
}

/// 🎬 Dados de uma ação
class ActionData {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  final bool isDestructive;

  const ActionData({
    required this.label,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.isDestructive = false,
  });
}

/// 🎨 Estilos de ação
enum ActionStyle {
  icon, // Apenas ícone
  button, // Botão com ícone e texto
  filled, // Botão preenchido
  text, // Botão de texto
  chip, // Action chip
  fab, // Mini FAB
}

/// 🎯 Factory para criar ações comuns
class ActionDataFactory {
  /// Ação de editar
  static ActionData edit({
    VoidCallback? onPressed,
    Color? color,
    String? tooltip,
  }) {
    return ActionData(
      label: 'Editar',
      icon: Icons.edit,
      onPressed: onPressed,
      color: color,
      tooltip: tooltip ?? 'Editar',
    );
  }

  /// Ação de deletar
  static ActionData delete({
    VoidCallback? onPressed,
    Color? color,
    String? tooltip,
  }) {
    return ActionData(
      label: 'Deletar',
      icon: Icons.delete,
      onPressed: onPressed,
      color: color ?? Colors.red,
      tooltip: tooltip ?? 'Deletar',
      isDestructive: true,
    );
  }

  /// Ação de compartilhar
  static ActionData share({
    VoidCallback? onPressed,
    Color? color,
    String? tooltip,
  }) {
    return ActionData(
      label: 'Compartilhar',
      icon: Icons.share,
      onPressed: onPressed,
      color: color,
      tooltip: tooltip ?? 'Compartilhar',
    );
  }

  /// Ação de favoritar
  static ActionData favorite({
    required bool isFavorite,
    VoidCallback? onPressed,
    Color? color,
    String? tooltip,
  }) {
    return ActionData(
      label: isFavorite ? 'Desfavoritar' : 'Favoritar',
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      onPressed: onPressed,
      color: color ?? (isFavorite ? Colors.red : null),
      tooltip:
          tooltip ??
          (isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos'),
    );
  }

  /// Ação de mais informações
  static ActionData info({
    VoidCallback? onPressed,
    Color? color,
    String? tooltip,
  }) {
    return ActionData(
      label: 'Info',
      icon: Icons.info_outline,
      onPressed: onPressed,
      color: color,
      tooltip: tooltip ?? 'Mais informações',
    );
  }

  /// Ação de play/pause
  static ActionData playPause({
    required bool isPlaying,
    VoidCallback? onPressed,
    Color? color,
    String? tooltip,
  }) {
    return ActionData(
      label: isPlaying ? 'Pausar' : 'Play',
      icon: isPlaying ? Icons.pause : Icons.play_arrow,
      onPressed: onPressed,
      color: color,
      tooltip: tooltip ?? (isPlaying ? 'Pausar' : 'Reproduzir'),
    );
  }

  /// Ação de configurações
  static ActionData settings({
    VoidCallback? onPressed,
    Color? color,
    String? tooltip,
  }) {
    return ActionData(
      label: 'Configurações',
      icon: Icons.settings,
      onPressed: onPressed,
      color: color,
      tooltip: tooltip ?? 'Configurações',
    );
  }

  /// Ação de copiar
  static ActionData copy({
    VoidCallback? onPressed,
    Color? color,
    String? tooltip,
  }) {
    return ActionData(
      label: 'Copiar',
      icon: Icons.copy,
      onPressed: onPressed,
      color: color,
      tooltip: tooltip ?? 'Copiar',
    );
  }
}

/// 🎯 Factory para criar módulos de ação em diferentes posições
class ActionModuleFactory {
  /// Ações no trailing (direita)
  static ActionModule trailing({
    required List<ActionData> actions,
    ActionStyle style = ActionStyle.icon,
    int maxActions = 3,
    VoidCallback? onOverflowTap,
  }) {
    return ActionModule(
      position: 'trailing',
      actions: actions,
      style: style,
      alignment: MainAxisAlignment.end,
      maxActions: maxActions,
      onOverflowTap: onOverflowTap,
    );
  }

  /// Ações no footer (embaixo)
  static ActionModule footer({
    required List<ActionData> actions,
    ActionStyle style = ActionStyle.button,
    MainAxisAlignment alignment = MainAxisAlignment.spaceEvenly,
    int maxActions = 4,
    VoidCallback? onOverflowTap,
  }) {
    return ActionModule(
      position: 'footer',
      actions: actions,
      style: style,
      alignment: alignment,
      maxActions: maxActions,
      onOverflowTap: onOverflowTap,
    );
  }

  /// Ações no header-trailing (direita do header)
  static ActionModule headerTrailing({
    required List<ActionData> actions,
    ActionStyle style = ActionStyle.icon,
    int maxActions = 2,
    VoidCallback? onOverflowTap,
  }) {
    return ActionModule(
      position: 'header-trailing',
      actions: actions,
      style: style,
      alignment: MainAxisAlignment.end,
      maxActions: maxActions,
      onOverflowTap: onOverflowTap,
      spacing: 4,
    );
  }
}
