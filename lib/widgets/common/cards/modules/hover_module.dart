import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modular_base_card.dart';

/// 🖱️ Módulo de hover e interatividade para cards
class HoverModule extends PositionableModule {
  final bool enableHover;
  final Color? hoverColor;
  final SystemMouseCursor cursor;
  final Duration hoverDuration;
  final Function(bool)? onHoverChanged;

  HoverModule({
    required String position,
    this.enableHover = true,
    this.hoverColor,
    this.cursor = SystemMouseCursors.click,
    this.hoverDuration = const Duration(milliseconds: 150),
    this.onHoverChanged,
  }) : super(position);

  @override
  String get moduleId => 'hover_${enableHover ? 'enabled' : 'disabled'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    // Este módulo não renderiza um widget visível
    // Ele serve para informar ao ModularBaseCard sobre os efeitos de hover
    return const SizedBox.shrink();
  }

  /// Aplica o wrapper de hover ao card
  Widget applyHover(
    Widget child,
    bool isHovered,
    VoidCallback onHoverEnter,
    VoidCallback onHoverExit,
  ) {
    if (!enableHover) return child;

    return MouseRegion(
      onEnter: (_) {
        onHoverEnter();
        onHoverChanged?.call(true);
      },
      onExit: (_) {
        onHoverExit();
        onHoverChanged?.call(false);
      },
      cursor: cursor,
      child: child,
    );
  }

  /// Retorna a cor de background para hover
  Color? getHoverBackgroundColor(BuildContext context, bool isHovered) {
    if (!enableHover || !isHovered) return null;

    return hoverColor ??
        Theme.of(context).colorScheme.onSurface.withOpacity(0.04);
  }
}

/// 🎯 Factory para criar módulos de hover
class HoverModuleFactory {
  /// Hover padrão para cards
  static HoverModule standard({
    bool enableHover = true,
    Color? hoverColor,
    SystemMouseCursor cursor = SystemMouseCursors.click,
    Function(bool)? onHoverChanged,
  }) {
    return HoverModule(
      position: 'decoration',
      enableHover: enableHover,
      hoverColor: hoverColor,
      cursor: cursor,
      onHoverChanged: onHoverChanged,
    );
  }

  /// Hover para tasks
  static HoverModule task({Function(bool)? onHoverChanged}) {
    return HoverModule(
      position: 'decoration',
      enableHover: true,
      cursor: SystemMouseCursors.click,
      onHoverChanged: onHoverChanged,
    );
  }

  /// Hover para hábitos
  static HoverModule habit({Function(bool)? onHoverChanged}) {
    return HoverModule(
      position: 'decoration',
      enableHover: true,
      cursor: SystemMouseCursors.click,
      onHoverChanged: onHoverChanged,
    );
  }

  /// Hover desabilitado
  static HoverModule disabled() {
    return HoverModule(position: 'decoration', enableHover: false);
  }
}
