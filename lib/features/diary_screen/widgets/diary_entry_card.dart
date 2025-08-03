import 'package:flutter/material.dart';
import '../../../models/diary_entry.dart';
import '../../../screens/diary_screen/diary_styles.dart';
import '../../../screens/diary_screen/diary_controller.dart';
import 'detail_panels/layouts/detail_panel_mobile.dart';
import 'detail_panels/layouts/detail_panel_desktop.dart';

/// **DiaryEntryCard** - Card otimizado para tela dedicada de diário
///
/// Diferenças do TaskDiaryEntryItem:
/// - Mostra apenas hora (não data completa)
/// - Fonte maior (14px vs 12px) para melhor legibilidade
/// - Botão de favorito visível
/// - Design otimizado para fundo rosado
/// - Mais espaçamento e padding
class DiaryEntryCard extends StatefulWidget {
  final DiaryEntry entry;
  final Function(DiaryEntry) onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggleFavorite;
  final bool isFavorite;
  final DiaryController? controller;

  const DiaryEntryCard({
    Key? key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
    this.isFavorite = false,
    this.controller,
  }) : super(key: key);

  @override
  State<DiaryEntryCard> createState() => _DiaryEntryCardState();
}

class _DiaryEntryCardState extends State<DiaryEntryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetailPanel(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7F7), // Fundo rosado suave
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emoji com fundo colorido
              Container(
                width: 32,
                decoration: BoxDecoration(
                  color: DiaryStyles.getMoodColor(widget.entry.mood),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    widget.entry.mood.isEmpty ? '📝' : widget.entry.mood,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Conteúdo principal
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título/Conteúdo
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        widget.entry.title ?? widget.entry.content,
                        maxLines: _isExpanded ? null : 2,
                        overflow:
                            _isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),

                    // Hora
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        _formatTime(widget.entry.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Ações - Favorito + Menu
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão de favorito
                      GestureDetector(
                        onTap:
                            () => widget.onToggleFavorite(!widget.isFavorite),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color:
                                widget.isFavorite
                                    ? Colors.red.shade400
                                    : Colors.grey.shade500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      // Botão de expansão para textos longos
                      if ((widget.entry.title ?? widget.entry.content).length >
                          80)
                        GestureDetector(
                          onTap:
                              () => setState(() => _isExpanded = !_isExpanded),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                      // Menu de ações
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
      ),
    );
  }

  /// Abre o painel de detalhes/edição da entrada (responsivo)
  void _openDetailPanel(BuildContext context) {
    if (widget.controller == null) {
      // Se não tem controller, usa o callback de edit antigo
      widget.onEdit(widget.entry);
      return;
    }

    // Detectar se é mobile ou desktop
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // Breakpoint para mobile

    debugPrint('📱 Screen width: $screenWidth, isMobile: $isMobile');

    if (isMobile) {
      // MOBILE: Navegação full-screen (comportamento atual)
      debugPrint('📱 Abrindo painel full-screen para mobile');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => DetailPanelMobile(
                entry: widget.entry,
                controller: widget.controller!,
                onDeleted: () {
                  Navigator.of(context).pop();
                  widget.onDelete();
                },
                onUpdated: () {
                  // Entrada foi atualizada, pode notificar parent se necessário
                },
              ),
        ),
      );
    } else {
      // DESKTOP: Painel lateral à direita
      debugPrint('🖥️ Abrindo painel lateral para desktop');
      _showSidePanel(context);
    }
  }

  /// Mostra painel lateral para desktop
  void _showSidePanel(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3), // Fundo semi-transparente
      builder: (context) {
        return Align(
          alignment: Alignment.centerRight,
          child: DetailPanelDesktop(
            entry: widget.entry,
            controller: widget.controller!,
            onDeleted: () {
              Navigator.of(context).pop();
              widget.onDelete();
            },
            onUpdated: () {
              // Entrada foi atualizada
            },
            onClose: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  /// Formata apenas a hora (HH:MM)
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
