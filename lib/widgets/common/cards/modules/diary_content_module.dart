import 'package:flutter/material.dart';
import '../../../../tokens/module_pos.dart';
import '../modular_card_1.dart';

/// 📝 **DiaryContentModule** - Módulo de conteúdo para cards de diário
///
/// **FUNCIONALIDADE:**
/// - Exibe título ou conteúdo do diary
/// - Layout específico para diary (2 linhas, ellipsis)
/// - Estilo otimizado para leitura
/// - Fallback inteligente entre título e conteúdo
///
/// **USADO POR:**
/// - DiaryCard (posição content) - para mostrar texto principal
///
/// **POSIÇÕES COMUNS:**
/// - `content`: Área principal do card (padrão para diary)
///
/// **EXEMPLO DE USO:**
/// ```dart
/// DiaryContentModuleFactory.content(
///   title: "Título do diary",
///   content: "Conteúdo do diary...",
///   maxLines: 2,
/// )
/// ```
class DiaryContentModule extends PositionableModule {
  final String? title;
  final String content;
  final int maxLines;
  final TextOverflow overflow;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final EdgeInsets? padding;

  DiaryContentModule({
    required ModulePos position,
    this.title,
    required this.content,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.titleStyle,
    this.contentStyle,
    this.padding,
  }) : super(position);

  @override
  String get moduleId => 'diary_content_${title?.hashCode ?? content.hashCode}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    // Determinar qual texto exibir (título tem prioridade)
    final displayText = (title?.isNotEmpty == true) ? title! : content;

    // Estilo padrão para diary content
    final effectiveStyle =
        titleStyle ??
        contentStyle ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          height: 1.3,
        );

    final effectivePadding =
        padding ?? const EdgeInsets.only(top: 2.0, bottom: 2.0);

    return Padding(
      padding: effectivePadding,
      child: Text(
        displayText,
        maxLines: maxLines,
        overflow: overflow,
        style: effectiveStyle,
      ),
    );
  }
}

/// 🎯 Factory para criar módulos de conteúdo de diary
class DiaryContentModuleFactory {
  /// Conteúdo na posição content (área principal)
  static DiaryContentModule content({
    String? title,
    required String content,
    int maxLines = 2,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    EdgeInsets? padding,
  }) {
    return DiaryContentModule(
      position: ModulePos.content,
      title: title,
      content: content,
      maxLines: maxLines,
      overflow: overflow,
      titleStyle: titleStyle,
      contentStyle: contentStyle,
      padding: padding,
    );
  }

  /// Conteúdo compacto (1 linha)
  static DiaryContentModule compact({
    String? title,
    required String content,
    TextStyle? style,
    EdgeInsets? padding,
  }) {
    return DiaryContentModule(
      position: ModulePos.content,
      title: title,
      content: content,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      titleStyle: style,
      contentStyle: style,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 1.0),
    );
  }

  /// Conteúdo expandido (3+ linhas)
  static DiaryContentModule expanded({
    String? title,
    required String content,
    int maxLines = 4,
    TextStyle? style,
    EdgeInsets? padding,
  }) {
    return DiaryContentModule(
      position: ModulePos.content,
      title: title,
      content: content,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      titleStyle: style,
      contentStyle: style,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4.0),
    );
  }
}
