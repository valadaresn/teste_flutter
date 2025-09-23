import 'package:flutter/material.dart';
import 'app_card.dart';

/// Exemplos de uso do AppCard para diferentes casos
class AppCardExamples {
  /// Exemplo para substituir TaskItem
  static Widget taskCard({
    required String title,
    required bool isCompleted,
    required VoidCallback onToggleComplete,
    required VoidCallback onTap,
    required Color listColor,
    bool isSelected = false,
    bool isImportant = false,
    String? description,
    DateTime? dueDate,
    int subtasksCount = 0,
    int completedSubtasks = 0,
    VoidCallback? onToggleImportant,
  }) {
    return AppCard(
      // Checkbox circular
      showCheckbox: true,
      isChecked: isCompleted,
      onCheckboxChanged: onToggleComplete,
      checkboxActiveColor: listColor,
      animateCheckbox: true,

      // Conteúdo principal
      title: title,
      strikethrough: isCompleted,
      textColorWhenDisabled: Colors.grey.shade500,

      // Informações secundárias
      secondaryInfo: _buildTaskSecondaryInfo(
        description: description,
        dueDate: dueDate,
        subtasksCount: subtasksCount,
        completedSubtasks: completedSubtasks,
      ),
      showSeparators: true,

      // Actions (estrela + menu)
      actions: [
        if (isImportant)
          GestureDetector(
            onTap: onToggleImportant,
            child: Icon(Icons.star, color: Colors.amber.shade600, size: 18),
          ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleTaskMenuAction(value, title),
          icon: Icon(Icons.more_horiz, size: 16, color: Colors.grey.shade400),
          itemBuilder: (context) => _buildTaskMenuItems(),
        ),
      ],

      // Visual e estado
      isSelected: isSelected,
      enableInstantSelection: true,
      showBorder: true,
      dynamicBorderColor: listColor,
      selectedBorderWidth: 2,
      unselectedBorderWidth: 1,

      // Hover
      enableHover: true,
      cursor: SystemMouseCursors.click,

      // Layout
      margin: const EdgeInsets.symmetric(vertical: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      // Interatividade
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  /// Exemplo para substituir NoteCard
  static Widget noteCard({
    required String title,
    required String content,
    required DateTime dateTime,
    required List<String> tags,
    required Color Function(String) getTagColor,
    bool isSelected = false,
    bool hasActiveFilters = false,
    required VoidCallback onTap,
  }) {
    return AppCard(
      // Borda lateral colorida
      leftBorderColor: tags.isNotEmpty ? getTagColor(tags.first) : null,
      leftBorderWidth: tags.isNotEmpty ? 5 : 0,

      // Header (título + data)
      title: title.isEmpty ? 'Sem título' : title,
      titleStyle: TextStyle(
        fontSize: 16,
        color: tags.contains('Importante') ? Colors.red.shade700 : Colors.black,
      ),

      // Data no trailing
      trailingText: '${dateTime.day}/${dateTime.month}/${dateTime.year}',

      // Conteúdo
      content: content,
      contentMaxLines: 1,
      contentOverflow: TextOverflow.ellipsis,
      contentStyle: const TextStyle(color: Colors.black87),

      // Tags como footer (só se não houver filtros ativos)
      children: hasActiveFilters ? null : _buildTagChips(tags, getTagColor),

      // Visual e estado
      isSelected: isSelected,
      selectedBackgroundColor: Colors.grey.shade200,

      // Layout
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      borderRadius: 8,
      elevation: 2,

      // Interatividade
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.grey.shade100,
    );
  }

  /// Exemplo para substituir HabitCard
  static Widget habitCard({
    required String title,
    required String emoji,
    required Color color,
    required bool isDoneToday,
    required VoidCallback onToggleCompletion,
    required VoidCallback onTap,
    bool isSelected = false,
    bool hasTimer = false,
    int? targetTime,
    bool isTimerRunning = false,
    VoidCallback? onStartTimer,
    VoidCallback? onStopTimer,
  }) {
    return AppCard(
      // Leading interativo (emoji → check)
      leadingText: isDoneToday ? null : emoji,
      leadingIcon: isDoneToday ? Icons.check : null,
      leadingIconColor: isDoneToday ? Colors.white : null,
      leadingBackgroundColor: isDoneToday ? color : color.withOpacity(0.15),
      onLeadingTap: onToggleCompletion,

      // Conteúdo principal
      title: title,
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),

      // Timer no trailing (se aplicável)
      trailing:
          hasTimer && targetTime != null
              ? _buildHabitTimerButton(
                isTimerRunning: isTimerRunning,
                targetTime: targetTime,
                color: color,
                onStart: onStartTimer,
                onStop: onStopTimer,
              )
              : null,

      // Visual e estado
      isSelected: isSelected,
      showBorder: true,
      selectedBackgroundColor: Colors.blue.shade50,

      // Layout
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      borderRadius: 16,
      elevation: 0,

      // Interatividade
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }

  // === MÉTODOS AUXILIARES ===

  static List<Widget>? _buildTaskSecondaryInfo({
    String? description,
    DateTime? dueDate,
    int subtasksCount = 0,
    int completedSubtasks = 0,
  }) {
    List<Widget> infoWidgets = [];

    if (description != null && description.isNotEmpty) {
      infoWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 12,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              'Anotação',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (dueDate != null) {
      infoWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              _formatDueDate(dueDate),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (subtasksCount > 0) {
      infoWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_list_bulleted,
              size: 12,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              '$completedSubtasks/$subtasksCount',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return infoWidgets.isEmpty ? null : infoWidgets;
  }

  static List<Widget> _buildTagChips(
    List<String> tags,
    Color Function(String) getTagColor,
  ) {
    return tags.map((tag) {
      final tagColor = getTagColor(tag);
      final contrastColor = _getContrastColor(tagColor);

      return Chip(
        label: Text(tag, style: TextStyle(fontSize: 10, color: contrastColor)),
        backgroundColor: tagColor,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      );
    }).toList();
  }

  static Widget _buildHabitTimerButton({
    required bool isTimerRunning,
    required int targetTime,
    required Color color,
    VoidCallback? onStart,
    VoidCallback? onStop,
  }) {
    return GestureDetector(
      onTap: isTimerRunning ? onStop : onStart,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTimerRunning ? color : color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTimerRunning ? Icons.stop : Icons.play_arrow,
              color: isTimerRunning ? Colors.white : color,
              size: 20,
            ),
          ),
          if (!isTimerRunning) ...[
            const SizedBox(height: 4),
            Text(
              _formatTargetTime(targetTime),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  static List<PopupMenuEntry<String>> _buildTaskMenuItems() {
    return [
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, size: 16),
            SizedBox(width: 8),
            Text('Editar'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'duplicate',
        child: Row(
          children: [
            Icon(Icons.copy, size: 16),
            SizedBox(width: 8),
            Text('Duplicar'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 16, color: Colors.red),
            SizedBox(width: 8),
            Text('Excluir', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  static void _handleTaskMenuAction(String action, String taskTitle) {
    switch (action) {
      case 'edit':
        print('✏️ Editar tarefa: $taskTitle');
        break;
      case 'duplicate':
        print('📋 Duplicar tarefa: $taskTitle');
        break;
      case 'delete':
        print('🗑️ Excluir tarefa: $taskTitle');
        break;
    }
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

  static String _formatTargetTime(int seconds) {
    if (seconds == 3) {
      return "3 seg";
    } else if (seconds < 60) {
      return "$seconds seg";
    } else {
      final minutes = seconds ~/ 60;
      return "$minutes min";
    }
  }

  static Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
