import 'package:flutter/material.dart';
import '../simple_modular_base_card.dart';

/// 🎨 Módulo de borda esquerda colorida
class LeftBorderModule extends PositionableModule {
  final Color color;
  final double width;

  LeftBorderModule({required this.color, this.width = 4.0})
    : super('decoration');

  @override
  String get moduleId => 'left_border_${color.value}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    final child = config['child'] as Widget;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8), // Mesmo borderRadius do card
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: width)),
        ),
        child: child,
      ),
    );
  }
}

/// 🎯 Factory para criar módulos de borda esquerda
class LeftBorderModuleFactory {
  /// Criar borda com base na primeira tag da lista
  static LeftBorderModule fromFirstTag({
    required List<String> tags,
    required Color Function(String) getTagColor,
    double width = 4.0,
  }) {
    final firstTag = tags.isNotEmpty ? tags.first : '';
    final color = tags.isNotEmpty ? getTagColor(firstTag) : Colors.grey;

    return LeftBorderModule(color: color, width: width);
  }

  /// Criar borda com cor específica
  static LeftBorderModule withColor({
    required Color color,
    double width = 4.0,
  }) {
    return LeftBorderModule(color: color, width: width);
  }
}
