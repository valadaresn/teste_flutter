import 'package:flutter/material.dart';
import '../modular_base_card.dart';

/// 📊 Módulo de informações secundárias para cards
class SecondaryInfoModule extends PositionableModule {
  final List<SecondaryInfoItem> items;
  final bool showSeparators;
  final Color? separatorColor;
  final double separatorWidth;
  final double separatorHeight;
  final double spacing;

  SecondaryInfoModule({
    required String position,
    required this.items,
    this.showSeparators = true,
    this.separatorColor,
    this.separatorWidth = 1,
    this.separatorHeight = 12,
    this.spacing = 8,
  }) : super(position);

  @override
  String get moduleId => 'secondary_info_${items.length}';

  @override
  Widget build(BuildContext context, Map<String, dynamic> config) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _buildInfoItem(context, items[i]),
          if (i < items.length - 1 && showSeparators) _buildSeparator(context),
        ],
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, SecondaryInfoItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: 12, color: item.color ?? Colors.grey.shade500),
          const SizedBox(width: 4),
        ],
        Text(
          item.text,
          style: TextStyle(
            fontSize: 12,
            color: item.color ?? Colors.grey.shade600,
            fontWeight: item.fontWeight,
          ),
          maxLines: item.maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Container(
        width: separatorWidth,
        height: separatorHeight,
        color: separatorColor ?? Colors.grey.shade300,
      ),
    );
  }
}

/// 📋 Item de informação secundária
class SecondaryInfoItem {
  final String text;
  final IconData? icon;
  final Color? color;
  final FontWeight? fontWeight;
  final int maxLines;

  const SecondaryInfoItem({
    required this.text,
    this.icon,
    this.color,
    this.fontWeight,
    this.maxLines = 1,
  });
}

/// 🎯 Factory para criar módulos de informação secundária
class SecondaryInfoModuleFactory {
  /// Módulo no content (dentro do conteúdo principal)
  static SecondaryInfoModule content({
    required List<SecondaryInfoItem> items,
    bool showSeparators = true,
    Color? separatorColor,
    double spacing = 8,
  }) {
    return SecondaryInfoModule(
      position: 'content',
      items: items,
      showSeparators: showSeparators,
      separatorColor: separatorColor,
      spacing: spacing,
    );
  }

  /// Módulo no footer
  static SecondaryInfoModule footer({
    required List<SecondaryInfoItem> items,
    bool showSeparators = false,
    Color? separatorColor,
    double spacing = 12,
  }) {
    return SecondaryInfoModule(
      position: 'footer',
      items: items,
      showSeparators: showSeparators,
      separatorColor: separatorColor,
      spacing: spacing,
    );
  }

  /// Cria item de descrição/anotação
  static SecondaryInfoItem description() {
    return const SecondaryInfoItem(
      text: 'Anotação',
      icon: Icons.sticky_note_2_outlined,
    );
  }

  /// Cria item de data de vencimento
  static SecondaryInfoItem dueDate(DateTime date, {bool isOverdue = false}) {
    return SecondaryInfoItem(
      text: _formatDueDate(date),
      icon: Icons.calendar_today,
      color: isOverdue ? Colors.red : null,
    );
  }

  /// Cria item de contador de subtarefas
  static SecondaryInfoItem subtasks(int completed, int total) {
    return SecondaryInfoItem(
      text: '$completed/$total',
      icon: Icons.format_list_bulleted,
    );
  }

  /// Cria item de timer ativo
  static SecondaryInfoItem timer(String timeText, Color color) {
    return SecondaryInfoItem(
      text: timeText,
      icon: Icons.timer,
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'hoje';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'amanhã';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'ontem';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
