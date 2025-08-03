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
      margin: const EdgeInsets.symmetric(vertical: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: IntrinsicHeight(
        // Força altura uniforme para todos elementos
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Estica elementos para altura total
          children: [
            // Emoji centralizado verticalmente ocupando altura total
            Container(
              width: 28, // Largura fixa para consistência
              decoration: BoxDecoration(
                color: DiaryStyles.getMoodColor(widget.entry.mood),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                // Centraliza o emoji dentro do container
                child: Text(
                  widget.entry.mood.isEmpty ? '📝' : widget.entry.mood,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Coluna com texto na parte superior e data na parte inferior
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween, // Distribui espaço entre topo e base
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.max, // Ocupa altura máxima disponível
                children: [
                  // Linha 1: Título/Conteúdo (parte superior com margem superior)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                    ), // Margem superior dobrada
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.entry.title ?? widget.entry.content,
                        maxLines: _isExpanded ? null : 1,
                        overflow:
                            _isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Linha 2: Data/hora (parte inferior com margem inferior)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4.0,
                    ), // Margem inferior dobrada
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        _formatDateTime(widget.entry.dateTime),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botões de ação alinhados com o texto superior
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Alinha com o texto principal
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão de expansão (apenas se conteúdo é longo)
                    if ((widget.entry.title ?? widget.entry.content).length >
                        50)
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                    // Menu de ações discreto
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 14,
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
                                  Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red,
                                  ),
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
              ],
            ),
          ],
        ),
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
