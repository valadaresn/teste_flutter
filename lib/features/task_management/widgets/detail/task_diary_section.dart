import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../../../models/diary_entry.dart';
import 'task_diary_entry_form.dart';
import 'task_diary_entry_item.dart';

/// **TaskDiarySection** - Seção de diário da tarefa
///
/// Componente que gerencia entradas de diário relacionadas à tarefa
class TaskDiarySection extends StatelessWidget {
  final Task task;
  final List<DiaryEntry> diaryEntries;
  final bool isExpanded;
  final Function(String content, String mood) onAddEntry;
  final Function(DiaryEntry entry) onEditEntry;
  final Function(String entryId) onDeleteEntry;

  const TaskDiarySection({
    Key? key,
    required this.task,
    required this.diaryEntries,
    required this.isExpanded,
    required this.onAddEntry,
    required this.onEditEntry,
    required this.onDeleteEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Text(
            'Diário da Tarefa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 16),

          // Formulário para nova entrada
          TaskDiaryEntryForm(onSubmit: onAddEntry),

          if (diaryEntries.isNotEmpty) ...[
            const SizedBox(height: 16),

            // Lista de entradas existentes
            ...diaryEntries.map(
              (entry) => TaskDiaryEntryItem(
                entry: entry,
                onEdit: () => onEditEntry(entry),
                onDelete: () => onDeleteEntry(entry.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
