import 'package:flutter/material.dart';
import '../../../../../../models/diary_entry.dart';
import '../../../../../../screens/diary_screen/diary_styles.dart';

/// **TaskDiaryEntryItem** - Item de entrada de diário compacto
///
/// Componente que exibe uma entrada individual de diário em formato clean:
/// - Linha 1: [Emoji envolvido] + Título/Conteúdo + Seta expansão + Menu ações
/// - Linha 2: Data/hora (indentada)
/// - Design compacto de 2 linhas, expansível quando necessário
class TaskDiaryEntryItem extends StatefulWidget {
  final DiaryEntry entry;
  final Function(DiaryEntry) onEdit;
  final VoidCallback onDelete;

  const TaskDiaryEntryItem({
    Key? key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<TaskDiaryEntryItem> createState() => _TaskDiaryEntryItemState();
}

class _TaskDiaryEntryItemState extends State<TaskDiaryEntryItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha 1: Emoji envolvido + Título/Conteúdo + Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emoji envolvido em fundo colorido
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: DiaryStyles.getMoodColor(widget.entry.mood),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.entry.mood.isEmpty ? '📝' : widget.entry.mood,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(width: 8),

              // Título ou conteúdo truncado
              Expanded(
                child: Text(
                  widget.entry.title ?? widget.entry.content,
                  maxLines: _isExpanded ? null : 1,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Botão de expansão (apenas se conteúdo é longo)
              if ((widget.entry.title ?? widget.entry.content).length > 50)
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

              // Menu de ações discreto
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                padding: EdgeInsets.zero,
                iconSize: 16,
                onSelected: (value) {
                  if (value == 'edit') {
                    widget.onEdit(widget.entry);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
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

          // Linha 2: Data/hora (indentada para alinhar com o texto)
          Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 1.0),
            child: Text(
              _formatDateTime(widget.entry.dateTime),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formata a data/hora em formato compacto:
  /// - Hoje: "14:30 • hoje"
  /// - Ontem: "09:15 • ontem"
  /// - Outros: "16:45 • 22 jul"
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(entryDate).inDays;

    // Formatação da hora
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final timeString = '$hour:$minute';

    if (difference == 0) {
      return '$timeString • hoje';
    } else if (difference == 1) {
      return '$timeString • ontem';
    } else {
      // Formato compacto "16:45 • 22 jul"
      final months = [
        '',
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ];
      final day = dateTime.day;
      final month = months[dateTime.month];

      return '$timeString • $day $month';
    }
  }

  /// Mostra confirmação antes de excluir
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir entrada'),
          content: const Text(
            'Tem certeza que deseja excluir esta entrada do diário?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
