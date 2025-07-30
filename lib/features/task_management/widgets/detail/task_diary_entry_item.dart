import 'package:flutter/material.dart';
import '../../../../models/diary_entry.dart';

/// **TaskDiaryEntryItem** - Item individual de entrada de diário
///
/// Componente que exibe uma entrada de diário com opções de edição e exclusão
class TaskDiaryEntryItem extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskDiaryEntryItem({
    Key? key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com mood, data e ações
          Row(
            children: [
              // Mood
              Text(entry.mood, style: const TextStyle(fontSize: 16)),

              const SizedBox(width: 8),

              // Data e hora
              Text(
                _formatDate(entry.dateTime),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const Spacer(),

              // Botões de ação
              IconButton(
                icon: Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(width: 8),

              IconButton(
                icon: Icon(Icons.delete, size: 16, color: Colors.grey.shade600),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Conteúdo da entrada
          Text(entry.content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ontem ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
