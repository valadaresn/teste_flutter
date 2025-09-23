import 'package:flutter/material.dart';
import '../modular_base_card.dart';
import 'tag_module.dart';

/// 🏷️ Módulo de tags condicionais (aparecem/somem baseado em filtros)
class ConditionalTagModule extends PositionableModule {
  final List<String> tags;
  final bool hasActiveFilters;
  final Color Function(String) getTagColor;
  final TagStyle style;
  final int maxTags;
  final bool showOverflow;
  final VoidCallback? onOverflowTap;
  final Function(String)? onTagTap;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  ConditionalTagModule({
    required String position,
    required this.tags,
    required this.hasActiveFilters,
    required this.getTagColor,
    this.style = TagStyle.chip,
    this.maxTags = 5,
    this.showOverflow = true,
    this.onOverflowTap,
    this.onTagTap,
    this.alignment = WrapAlignment.start,
    this.spacing = 4.0,
    this.runSpacing = 4.0,
  }) : super(position);

  @override
  String get moduleId =>
      'conditional_tags_${tags.length}_${hasActiveFilters ? 'filtered' : 'unfiltered'}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    // Se há filtros ativos e não devemos mostrar tags, retorna vazio
    if (hasActiveFilters || tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleTags = tags.take(maxTags).toList();
    final hiddenCount = tags.length - maxTags;
    final hasOverflowCount = hiddenCount > 0;

    return Column(
      children: [
        const SizedBox(height: 12),
        Wrap(
          alignment: alignment,
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            // Tags visíveis
            ...visibleTags.map((tag) => _buildTagChip(context, tag)),

            // Overflow indicator
            if (hasOverflowCount && showOverflow)
              _buildOverflowChip(context, hiddenCount),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    final tagColor = getTagColor(tag);
    final contrastColor = _getContrastColor(tagColor);

    return GestureDetector(
      onTap: onTagTap != null ? () => onTagTap!(tag) : null,
      child: Chip(
        label: Text(tag, style: TextStyle(fontSize: 10, color: contrastColor)),
        backgroundColor: tagColor,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildOverflowChip(BuildContext context, int count) {
    return GestureDetector(
      onTap: onOverflowTap,
      child: Chip(
        label: Text(
          '+$count',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        backgroundColor: Colors.grey.shade200,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// 🎯 Factory para criar módulos de tags condicionais
class ConditionalTagModuleFactory {
  /// Tags no footer que somem com filtros ativos
  static ConditionalTagModule footer({
    required List<String> tags,
    required bool hasActiveFilters,
    required Color Function(String) getTagColor,
    int maxTags = 5,
    bool showOverflow = true,
    VoidCallback? onOverflowTap,
    Function(String)? onTagTap,
  }) {
    return ConditionalTagModule(
      position: 'footer',
      tags: tags,
      hasActiveFilters: hasActiveFilters,
      getTagColor: getTagColor,
      maxTags: maxTags,
      showOverflow: showOverflow,
      onOverflowTap: onOverflowTap,
      onTagTap: onTagTap,
    );
  }

  /// Tags inline que somem com filtros ativos
  static ConditionalTagModule inline({
    required List<String> tags,
    required bool hasActiveFilters,
    required Color Function(String) getTagColor,
    int maxTags = 3,
    bool showOverflow = true,
    VoidCallback? onOverflowTap,
    Function(String)? onTagTap,
  }) {
    return ConditionalTagModule(
      position: 'content',
      tags: tags,
      hasActiveFilters: hasActiveFilters,
      getTagColor: getTagColor,
      maxTags: maxTags,
      showOverflow: showOverflow,
      onOverflowTap: onOverflowTap,
      onTagTap: onTagTap,
      spacing: 2,
      runSpacing: 2,
    );
  }
}
