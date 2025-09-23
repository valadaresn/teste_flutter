import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// 🔲 Módulo de border dinâmica para cards
class DynamicBorderModule extends PositionableModule {
  final Color color;
  final bool isSelected;
  final double selectedWidth;
  final double unselectedWidth;
  final double opacity;
  final BorderRadius? borderRadius;

  DynamicBorderModule({
    required String position,
    required this.color,
    this.isSelected = false,
    this.selectedWidth = 2,
    this.unselectedWidth = 1,
    this.opacity = 1.0,
    this.borderRadius,
  }) : super(position);

  @override
  String get moduleId =>
      'dynamic_border_${isSelected ? 'selected' : 'unselected'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    // Este módulo não renderiza um widget visível
    // Ele serve para informar ao ModularBaseCard sobre a decoração
    return const SizedBox.shrink();
  }

  /// Retorna a decoração border para uso no card
  BoxDecoration getDecoration(BuildContext context) {
    final borderColor =
        isSelected
            ? color.withOpacity(opacity * 0.8)
            : Colors.grey.withOpacity(opacity * 0.2);

    final width = isSelected ? selectedWidth : unselectedWidth;

    return BoxDecoration(
      border: Border.all(color: borderColor, width: width),
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }
}

/// 🎯 Factory para criar módulos de border dinâmica
class DynamicBorderModuleFactory {
  /// Border para posição decoration (aplicada ao card todo)
  static DynamicBorderModule decoration({
    required Color color,
    bool isSelected = false,
    double selectedWidth = 2,
    double unselectedWidth = 1,
    double opacity = 1.0,
    BorderRadius? borderRadius,
  }) {
    return DynamicBorderModule(
      position: 'decoration',
      color: color,
      isSelected: isSelected,
      selectedWidth: selectedWidth,
      unselectedWidth: unselectedWidth,
      opacity: opacity,
      borderRadius: borderRadius,
    );
  }

  /// Border para tasks (baseada na cor da lista)
  static DynamicBorderModule taskBorder({
    required Color listColor,
    bool isSelected = false,
  }) {
    return DynamicBorderModule(
      position: 'decoration',
      color: listColor,
      isSelected: isSelected,
      selectedWidth: 2,
      unselectedWidth: 1,
      opacity: 0.8,
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Border para hábitos (baseada na cor do hábito)
  static DynamicBorderModule habitBorder({
    required Color habitColor,
    bool isSelected = false,
  }) {
    return DynamicBorderModule(
      position: 'decoration',
      color: habitColor,
      isSelected: isSelected,
      selectedWidth: 2,
      unselectedWidth: 0,
      opacity: 1.0,
      borderRadius: BorderRadius.circular(16),
    );
  }
}
