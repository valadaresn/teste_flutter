import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// ⭐ Módulo de estrela para marcar importância
class StarModule extends PositionableModule {
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final VoidCallback? onTap;
  final bool showOnlyWhenActive;

  StarModule({
    required String position,
    required this.isActive,
    this.activeColor,
    this.inactiveColor,
    this.size = 18,
    this.onTap,
    this.showOnlyWhenActive = true,
  }) : super(position);

  @override
  String get moduleId => 'star_${isActive ? 'active' : 'inactive'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    // Se showOnlyWhenActive for true e não estiver ativo, não mostra nada
    if (showOnlyWhenActive && !isActive) {
      return const SizedBox.shrink();
    }

    final effectiveActiveColor = activeColor ?? Colors.amber.shade600;
    final effectiveInactiveColor = inactiveColor ?? Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(
          isActive ? Icons.star : Icons.star_border,
          color: isActive ? effectiveActiveColor : effectiveInactiveColor,
          size: size,
        ),
      ),
    );
  }
}

/// 🎯 Factory para criar módulos de estrela
class StarModuleFactory {
  /// Estrela na posição trailing
  static StarModule trailing({
    required bool isActive,
    Color? activeColor,
    Color? inactiveColor,
    double size = 18,
    VoidCallback? onTap,
    bool showOnlyWhenActive = true,
  }) {
    return StarModule(
      position: 'trailing',
      isActive: isActive,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      onTap: onTap,
      showOnlyWhenActive: showOnlyWhenActive,
    );
  }

  /// Estrela na posição header-trailing
  static StarModule headerTrailing({
    required bool isActive,
    Color? activeColor,
    Color? inactiveColor,
    double size = 16,
    VoidCallback? onTap,
    bool showOnlyWhenActive = true,
  }) {
    return StarModule(
      position: 'header-trailing',
      isActive: isActive,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      onTap: onTap,
      showOnlyWhenActive: showOnlyWhenActive,
    );
  }
}
