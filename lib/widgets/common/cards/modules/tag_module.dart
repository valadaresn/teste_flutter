import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// 🏷️ **TagModule** - Módulo de tags coloridas para cards modulares
///
/// **FUNCIONALIDADE:**
/// - Tags com cores customizáveis e estilos diversos
/// - Limite de tags exibidas com overflow
/// - Callback para tap em tags individuais
/// - Callback para remoção de tags
/// - Múltiplos estilos (chip, outlined, filled, text)
///
/// **STATUS DE USO:**
/// ⚠️ SUBUTILIZADO - Usado apenas em CleanCardExamples
///
/// **POTENCIAL DE USO:**
/// - NoteCard (footer) - para mostrar tags das notas
/// - TaskCard (footer) - para mostrar tags de projeto/contexto
/// - HabitCard (footer) - para mostrar categorias de hábitos
///
/// **POSIÇÕES COMUNS:**
/// - `footer`: Rodapé do card (padrão)
/// - `header-trailing`: Direita do cabeçalho (modo compacto)
/// - `content`: Dentro do conteúdo (modo inline)
///
/// **EXEMPLO DE USO:**
/// ```dart
/// TagModuleFactory.footer(
///   tags: [
///     TagData(label: 'Urgente', backgroundColor: Colors.red),
///     TagData(label: 'Trabalho', backgroundColor: Colors.blue),
///   ],
///   onTagTap: (tag) => filterByTag(tag.label),
/// )
/// ```

/// 🏷️ Módulo de Tags para cards
class TagModule extends PositionableModule {
  final List<TagData> tags;
  final TagStyle style;
  final int maxTags;
  final bool showOverflow;
  final VoidCallback? onOverflowTap;
  final Function(TagData)? onTagTap;
  final Function(TagData)? onTagRemove;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  TagModule({
    required String position,
    required this.tags,
    this.style = TagStyle.chip,
    this.maxTags = 3,
    this.showOverflow = true,
    this.onOverflowTap,
    this.onTagTap,
    this.onTagRemove,
    this.alignment = WrapAlignment.start,
    this.spacing = 4.0,
    this.runSpacing = 4.0,
  }) : super(position);

  @override
  String get moduleId => 'tags_${tags.length}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    final visibleTags = tags.take(maxTags).toList();
    final hiddenCount = tags.length - maxTags;
    final hasOverflow = hiddenCount > 0;

    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        // Tags visíveis
        ...visibleTags.map((tag) => _buildTag(context, tag)),

        // Overflow indicator
        if (hasOverflow && showOverflow)
          _buildOverflowTag(context, hiddenCount),
      ],
    );
  }

  Widget _buildTag(BuildContext context, TagData tag) {
    switch (style) {
      case TagStyle.chip:
        return Chip(
          label: Text(
            tag.label,
            style: TextStyle(
              fontSize: 12,
              color: tag.textColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor:
              tag.backgroundColor ?? Theme.of(context).colorScheme.surface,
          side:
              tag.borderColor != null
                  ? BorderSide(color: tag.borderColor!)
                  : null,
          deleteIcon:
              onTagRemove != null ? const Icon(Icons.close, size: 16) : null,
          onDeleted: onTagRemove != null ? () => onTagRemove!(tag) : null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );

      case TagStyle.outlined:
        return InkWell(
          onTap: onTagTap != null ? () => onTagTap!(tag) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: tag.borderColor ?? Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(16),
              color: tag.backgroundColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tag.icon != null) ...[
                  Icon(tag.icon, size: 12, color: tag.textColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  tag.label,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        tag.textColor ??
                        Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (onTagRemove != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => onTagRemove!(tag),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color:
                          tag.textColor ??
                          Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

      case TagStyle.filled:
        return InkWell(
          onTap: onTagTap != null ? () => onTagTap!(tag) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  tag.backgroundColor ?? Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tag.icon != null) ...[
                  Icon(
                    tag.icon,
                    size: 12,
                    color:
                        tag.textColor ??
                        Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  tag.label,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        tag.textColor ??
                        Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onTagRemove != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => onTagRemove!(tag),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color:
                          tag.textColor ??
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

      case TagStyle.text:
        return InkWell(
          onTap: onTagTap != null ? () => onTagTap!(tag) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tag.icon != null) ...[
                  Icon(
                    tag.icon,
                    size: 12,
                    color:
                        tag.textColor ?? Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  '#${tag.label}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        tag.textColor ?? Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildOverflowTag(BuildContext context, int count) {
    return InkWell(
      onTap: onOverflowTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '+$count',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// 🏷️ Dados de uma tag
class TagData {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final String? value; // Para uso programático

  const TagData({
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagData &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => label.hashCode ^ value.hashCode;
}

/// 🎨 Estilos de tag
enum TagStyle {
  chip, // Material Chip padrão
  outlined, // Contorno
  filled, // Preenchida
  text, // Apenas texto com #
}

/// 🎯 Factory para criar tags em diferentes posições
class TagModuleFactory {
  /// Tags no footer (embaixo)
  static TagModule footer({
    required List<TagData> tags,
    TagStyle style = TagStyle.chip,
    int maxTags = 5,
    bool showOverflow = true,
    VoidCallback? onOverflowTap,
    Function(TagData)? onTagTap,
    Function(TagData)? onTagRemove,
    WrapAlignment alignment = WrapAlignment.start,
  }) {
    return TagModule(
      position: 'footer',
      tags: tags,
      style: style,
      maxTags: maxTags,
      showOverflow: showOverflow,
      onOverflowTap: onOverflowTap,
      onTagTap: onTagTap,
      onTagRemove: onTagRemove,
      alignment: alignment,
    );
  }

  /// Tags no header-trailing (direita do header)
  static TagModule headerTrailing({
    required List<TagData> tags,
    TagStyle style = TagStyle.text,
    int maxTags = 2,
    bool showOverflow = true,
    VoidCallback? onOverflowTap,
    Function(TagData)? onTagTap,
    Function(TagData)? onTagRemove,
  }) {
    return TagModule(
      position: 'header-trailing',
      tags: tags,
      style: style,
      maxTags: maxTags,
      showOverflow: showOverflow,
      onOverflowTap: onOverflowTap,
      onTagTap: onTagTap,
      onTagRemove: onTagRemove,
      spacing: 2,
    );
  }

  /// Tags no content (dentro do conteúdo)
  static TagModule content({
    required List<TagData> tags,
    TagStyle style = TagStyle.filled,
    int maxTags = 3,
    bool showOverflow = true,
    VoidCallback? onOverflowTap,
    Function(TagData)? onTagTap,
    Function(TagData)? onTagRemove,
    WrapAlignment alignment = WrapAlignment.start,
  }) {
    return TagModule(
      position: 'content',
      tags: tags,
      style: style,
      maxTags: maxTags,
      showOverflow: showOverflow,
      onOverflowTap: onOverflowTap,
      onTagTap: onTagTap,
      onTagRemove: onTagRemove,
      alignment: alignment,
    );
  }
}
