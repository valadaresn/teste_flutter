// Arquivo renomeado de task_card.dart para task_item.dart para padronização com outros componentes do projeto.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../themes/theme_provider.dart';
import '../../themes/app_theme.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final TaskController controller;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleImportant;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.controller,
    required this.onToggleComplete,
    required this.onToggleImportant,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isSelected = controller.selectedTaskId == task.id;
    final selectedList =
        controller.selectedListId != null
            ? controller.getListById(controller.selectedListId!)
            : null;

    // Cor baseada na lista selecionada ou cor padrão
    final listColor = selectedList?.color ?? Theme.of(context).primaryColor;

    // Usar o ThemeProvider para obter configurações
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Determinar cor da borda e propriedades quando selecionado
    Color borderColor;
    if (isSelected && themeProvider.cardStyle == CardStyle.clean) {
      // Clean style: usar cor primary do tema quando selecionado
      borderColor = Theme.of(context).colorScheme.primary;
    } else {
      // Dynamic style: comportamento original
      borderColor = themeProvider.getCardBorderColor(isSelected, listColor);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.2),
      decoration: BoxDecoration(
        color:
            themeProvider.getCardGradient(isSelected) == null
                ? themeProvider.getCardColor(isSelected)
                : null,
        gradient: themeProvider.getCardGradient(isSelected),
        borderRadius: BorderRadius.circular(themeProvider.getBorderRadius()),
        border: Border.all(
          color: borderColor,
          width: themeProvider.getCardBorderWidth(isSelected),
        ),
        boxShadow: themeProvider.getCardShadow(isSelected),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(themeProvider.getBorderRadius()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox circular
              GestureDetector(
                onTap: onToggleComplete,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          task.isCompleted ? listColor : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: task.isCompleted ? listColor : Colors.transparent,
                  ),
                  child:
                      task.isCompleted
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          )
                          : null,
                ),
              ),

              const SizedBox(width: 12),

              // Conteúdo da tarefa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da tarefa (linha principal)
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color:
                            task.isCompleted
                                ? Colors.grey.shade500
                                : Colors.black87,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Informações secundárias (linha menor e discreta)
                    if (_hasSecondaryInfo()) ...[
                      const SizedBox(height: 2),
                      _buildSecondaryInfo(context),
                    ],
                  ],
                ),
              ),

              // Ícone de estrela (importante)
              if (task.isImportant)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: onToggleImportant,
                    child: Icon(
                      Icons.star,
                      color: Colors.amber.shade600,
                      size: 18,
                    ),
                  ),
                ),
              // Menu de ações (pequeno e discreto)
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                icon: Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                padding: EdgeInsets.zero,
                itemBuilder:
                    (context) => [
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
                            Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasSecondaryInfo() {
    return task.description.isNotEmpty ||
        task.dueDate != null ||
        controller.getSubtasks(task.id).isNotEmpty;
  }

  Widget _buildSecondaryInfo(BuildContext context) {
    final subtasks = controller.getSubtasks(task.id);
    final completedSubtasks = subtasks.where((s) => s.isCompleted).length;

    List<Widget> infoWidgets = [];

    // Descrição ou anotação
    if (task.description.isNotEmpty) {
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

    // Data de vencimento
    if (task.dueDate != null) {
      infoWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 12,
              color: task.isOverdue ? Colors.red : Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDueDate2(task.dueDate!),
              style: TextStyle(
                fontSize: 12,
                color: task.isOverdue ? Colors.red : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Subtarefas
    if (subtasks.isNotEmpty) {
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
              '$completedSubtasks/${subtasks.length}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < infoWidgets.length; i++) ...[
          infoWidgets[i],
          if (i < infoWidgets.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 1,
                height: 12,
                color: Colors.grey.shade300,
              ),
            ),
        ],
      ],
    );
  }

  String _formatDueDate2(DateTime date) {
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        onEdit();
        break;
      case 'duplicate':
        // TODO: Implementar duplicação
        print('📋 Duplicar tarefa: ${task.title}');
        break;
      case 'delete':
        onDelete();
        break;
    }
  }
}
