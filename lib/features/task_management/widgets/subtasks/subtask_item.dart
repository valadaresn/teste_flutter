import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class SubtaskItem extends StatelessWidget {
  final Task subtask;
  final TaskController controller;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubtaskItem({
    Key? key,
    required this.subtask,
    required this.controller,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: subtask.isCompleted 
              ? Colors.green.withOpacity(0.3)
              : Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: subtask.isCompleted,
              onChanged: (_) => onToggleComplete(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  subtask.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: subtask.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                    color: subtask.isCompleted
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                        : null,
                  ),
                ),
                
                // Descrição (se houver)
                if (subtask.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtask.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      decoration: subtask.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Informações extras
                if (_hasExtraInfo()) ...[
                  const SizedBox(height: 4),
                  _buildExtraInfo(context),
                ],
              ],
            ),
          ),
          
          // Menu de ações
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: Icon(
              Icons.more_vert,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 14),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 14, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasExtraInfo() {
    return subtask.dueDate != null || 
           subtask.priority != TaskPriority.medium || 
           subtask.isImportant;
  }

  Widget _buildExtraInfo(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 2,
      children: [
        // Prioridade (se não for média)
        if (subtask.priority != TaskPriority.medium)
          _buildPriorityChip(context),
        
        // Data de prazo
        if (subtask.dueDate != null)
          _buildDueDateChip(context),
        
        // Importante
        if (subtask.isImportant)
          _buildImportantChip(context),
      ],
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: subtask.priorityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: subtask.priorityColor.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        subtask.priorityLabel,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: subtask.priorityColor,
        ),
      ),
    );
  }

  Widget _buildDueDateChip(BuildContext context) {
    final isOverdue = subtask.isOverdue;
    final isDueToday = subtask.isDueToday;
    
    Color chipColor;
    IconData icon;
    
    if (isOverdue) {
      chipColor = Colors.red;
      icon = Icons.schedule;
    } else if (isDueToday) {
      chipColor = Colors.orange;
      icon = Icons.today;
    } else {
      chipColor = Theme.of(context).colorScheme.primary;
      icon = Icons.calendar_today;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: chipColor.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: chipColor),
          const SizedBox(width: 2),
          Text(
            _formatDueDate(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 10, color: Colors.amber),
          SizedBox(width: 2),
          Text(
            'Importante',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDueDate() {
    if (subtask.dueDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(subtask.dueDate!.year, subtask.dueDate!.month, subtask.dueDate!.day);
    
    if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Amanhã';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else {
      return '${subtask.dueDate!.day}/${subtask.dueDate!.month}';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        onEdit();
        break;
      case 'delete':
        onDelete();
        break;
    }
  }
}
