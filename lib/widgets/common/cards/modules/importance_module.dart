import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// ❗ Módulo para destacar importância no título
class ImportanceModule extends PositionableModule {
  final bool isImportant;
  final Color? importantColor;
  final Color? normalColor;
  final FontWeight? importantWeight;
  final FontWeight? normalWeight;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;

  ImportanceModule({
    required String position,
    required this.isImportant,
    this.importantColor,
    this.normalColor,
    this.importantWeight,
    this.normalWeight,
    this.fontSize,
    this.overflow,
    this.maxLines,
  }) : super(position);

  @override
  String get moduleId => 'importance_${isImportant ? 'important' : 'normal'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    // Este módulo não renderiza um widget visível
    // Ele serve para modificar o estilo do título
    return const SizedBox.shrink();
  }

  /// Retorna o estilo do texto baseado na importância
  TextStyle getTextStyle(BuildContext context, TextStyle? baseStyle) {
    final effectiveImportantColor = importantColor ?? Colors.red.shade700;
    final effectiveNormalColor = normalColor ?? Colors.black;
    final effectiveImportantWeight = importantWeight ?? FontWeight.w600;
    final effectiveNormalWeight = normalWeight ?? FontWeight.normal;

    return (baseStyle ?? const TextStyle()).copyWith(
      color: isImportant ? effectiveImportantColor : effectiveNormalColor,
      fontWeight:
          isImportant ? effectiveImportantWeight : effectiveNormalWeight,
      fontSize: fontSize,
    );
  }
}

/// 🎯 Factory para criar módulos de importância
class ImportanceModuleFactory {
  /// Importância baseada em tag
  static ImportanceModule fromTag({
    required List<String> tags,
    String importantTag = 'Importante',
    Color? importantColor,
    Color? normalColor,
    FontWeight? importantWeight,
    FontWeight? normalWeight,
  }) {
    final isImportant = tags.contains(importantTag);

    return ImportanceModule(
      position: 'title-style',
      isImportant: isImportant,
      importantColor: importantColor,
      normalColor: normalColor,
      importantWeight: importantWeight,
      normalWeight: normalWeight,
    );
  }

  /// Importância baseada em boolean
  static ImportanceModule fromBool({
    required bool isImportant,
    Color? importantColor,
    Color? normalColor,
    FontWeight? importantWeight,
    FontWeight? normalWeight,
  }) {
    return ImportanceModule(
      position: 'title-style',
      isImportant: isImportant,
      importantColor: importantColor,
      normalColor: normalColor,
      importantWeight: importantWeight,
      normalWeight: normalWeight,
    );
  }

  /// Importância baseada em prioridade
  static ImportanceModule fromPriority({
    required String priority, // 'high', 'medium', 'low'
    Color? highColor,
    Color? mediumColor,
    Color? lowColor,
    Color? normalColor,
  }) {
    final isImportant =
        priority.toLowerCase() == 'high' || priority.toLowerCase() == 'alta';
    Color? effectiveColor;

    switch (priority.toLowerCase()) {
      case 'high':
      case 'alta':
        effectiveColor = highColor ?? Colors.red.shade700;
        break;
      case 'medium':
      case 'média':
        effectiveColor = mediumColor ?? Colors.orange.shade700;
        break;
      case 'low':
      case 'baixa':
        effectiveColor = lowColor ?? Colors.green.shade700;
        break;
      default:
        effectiveColor = normalColor ?? Colors.black;
    }

    return ImportanceModule(
      position: 'title-style',
      isImportant: isImportant,
      importantColor: effectiveColor,
      normalColor: normalColor,
    );
  }
}
