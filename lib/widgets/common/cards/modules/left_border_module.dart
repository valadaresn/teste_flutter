import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// 🌈 Módulo de border lateral colorida
class LeftBorderModule extends PositionableModule {
  final Color color;
  final double width;
  final bool enabled;

  LeftBorderModule({
    required String position,
    required this.color,
    this.width = 5.0,
    this.enabled = true,
  }) : super(position);

  @override
  String get moduleId => 'left_border_${color.value}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    // Este módulo não renderiza um widget visível
    // Ele serve para informar ao ModularBaseCard sobre a decoração
    return const SizedBox.shrink();
  }

  /// Retorna a decoração da border lateral para uso no card
  BoxDecoration getDecoration() {
    if (!enabled) return const BoxDecoration();

    return BoxDecoration(
      border: Border(left: BorderSide(color: color, width: width)),
    );
  }
}

/// 🎯 Factory para criar módulos de border lateral
class LeftBorderModuleFactory {
  /// Border lateral baseada na primeira tag
  static LeftBorderModule fromFirstTag({
    required List<String> tags,
    required Color Function(String) getTagColor,
    double width = 5.0,
  }) {
    final hasTag = tags.isNotEmpty;
    final color = hasTag ? getTagColor(tags.first) : Colors.transparent;

    return LeftBorderModule(
      position: 'decoration',
      color: color,
      width: width,
      enabled: hasTag,
    );
  }

  /// Border lateral com cor específica
  static LeftBorderModule colored({
    required Color color,
    double width = 5.0,
    bool enabled = true,
  }) {
    return LeftBorderModule(
      position: 'decoration',
      color: color,
      width: width,
      enabled: enabled,
    );
  }

  /// Border lateral baseada em prioridade
  static LeftBorderModule priority({
    required String priority, // 'high', 'medium', 'low'
    double width = 5.0,
  }) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
      case 'alta':
        color = Colors.red;
        break;
      case 'medium':
      case 'média':
        color = Colors.orange;
        break;
      case 'low':
      case 'baixa':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return LeftBorderModule(
      position: 'decoration',
      color: color,
      width: width,
      enabled: true,
    );
  }

  /// Border lateral baseada em status
  static LeftBorderModule status({
    required String status, // 'active', 'pending', 'completed', 'canceled'
    double width = 5.0,
  }) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
      case 'ativo':
        color = Colors.blue;
        break;
      case 'pending':
      case 'pendente':
        color = Colors.orange;
        break;
      case 'completed':
      case 'completo':
        color = Colors.green;
        break;
      case 'canceled':
      case 'cancelado':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return LeftBorderModule(
      position: 'decoration',
      color: color,
      width: width,
      enabled: true,
    );
  }
}
