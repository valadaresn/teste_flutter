import 'package:flutter/material.dart';
import '../../../../../../models/diary_entry.dart';
import '../../../../models/task_model.dart';
import 'task_diary_entry_item.dart';
import 'task_diary_entry_form.dart';

/// **TaskDiarySection** - Seção de diário para tarefas
///
/// Componente que exibe entradas de diário relacionadas a uma tarefa específica
/// com funcionalidade de expandir/recolher e adicionar novas entradas
class TaskDiarySection extends StatefulWidget {
  final Task task;
  final List<DiaryEntry> diaryEntries;
  final Function(String content, String mood) onAddEntry;
  final Function(DiaryEntry) onEditEntry;
  final Function(String entryId) onDeleteEntry;
  final bool isExpanded;

  const TaskDiarySection({
    Key? key,
    required this.task,
    required this.diaryEntries,
    required this.onAddEntry,
    required this.onEditEntry,
    required this.onDeleteEntry,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<TaskDiarySection> createState() => _TaskDiarySectionState();
}

class _TaskDiarySectionState extends State<TaskDiarySection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conteúdo expansível baseado no estado externo
          if (widget.isExpanded) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da seção
                  Text(
                    'Diário (${widget.diaryEntries.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  // Lista de entradas existentes
                  ...widget.diaryEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: TaskDiaryEntryItem(
                        entry: entry,
                        onEdit: widget.onEditEntry,
                        onDelete: () => widget.onDeleteEntry(entry.id),
                      ),
                    ),
                  ),

                  // Formulário para nova entrada
                  const SizedBox(height: 8),
                  TaskDiaryEntryForm(onSubmit: widget.onAddEntry),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
