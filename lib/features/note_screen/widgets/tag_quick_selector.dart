import 'package:flutter/material.dart';
import '../notes_controller.dart';

/// Seletor de tags simplificado baseado no QuickListSelector
class TagQuickSelector extends StatelessWidget {
  final List<String> selectedTags;
  final NotesController controller;
  final Function(List<String>) onTagsChanged;
  final bool isNewNote;

  const TagQuickSelector({
    Key? key,
    required this.selectedTags,
    required this.controller,
    required this.onTagsChanged,
    this.isNewNote = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => _showTagSelector(context), // ✅ CORREÇÃO: Sempre permite abrir
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer,
            size: 16,
            color: isNewNote ? Colors.grey[400] : Colors.grey[600],
          ),
          if (selectedTags.isNotEmpty) ...[
            const SizedBox(width: 6),
            // Mostrar primeira tag + contador se houver mais
            Text(
              selectedTags.length == 1
                  ? selectedTags.first
                  : '${selectedTags.first} +${selectedTags.length - 1}',
              style: TextStyle(
                fontSize: 13,
                color: isNewNote ? Colors.grey[500] : Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ] else if (!isNewNote) ...[
            const SizedBox(width: 6),
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTagSelector(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    // Construir itens do menu
    final List<PopupMenuEntry<String>> menuItems = [];

    // Cabeçalho
    menuItems.add(
      PopupMenuItem<String>(
        enabled: false,
        child: Row(
          children: [
            Icon(Icons.label_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              'Selecionar Tags',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );

    // Adicionar opção "Remover todas as tags" se houver tags selecionadas
    if (selectedTags.isNotEmpty) {
      menuItems.add(
        PopupMenuItem<String>(
          value: '__REMOVE_ALL__',
          child: Row(
            children: [
              Icon(Icons.clear_all, size: 16, color: Colors.red.shade600),
              const SizedBox(width: 12),
              Text(
                'Remover todas as tags',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
      );

      // Adicionar divisor
      menuItems.add(const PopupMenuDivider());
    }

    // Adicionar cada tag disponível
    for (final tag in controller.suggestedTags) {
      final isSelected = selectedTags.contains(tag);
      final tagColor = controller.getTagColor(tag);

      menuItems.add(
        PopupMenuItem<String>(
          value: tag,
          child: Row(
            children: [
              // Ícone de tag com cor
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Nome da tag
              Expanded(
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color:
                        isSelected
                            ? Colors.grey.shade800
                            : Colors.grey.shade700,
                  ),
                ),
              ),

              // Ícone de selecionado
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check, size: 16, color: Colors.grey.shade600),
              ],
            ],
          ),
        ),
      );
    }

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - 200,
        position.dx + renderBox.size.width,
        position.dy,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 8,
      items: menuItems,
    ).then((selectedTag) {
      if (selectedTag != null) {
        if (selectedTag == '__REMOVE_ALL__') {
          // Remover todas as tags da nota atual
          onTagsChanged([]);
        } else {
          // Toggle tag individual
          _toggleTag(selectedTag);
        }
      }
    });
  }

  void _toggleTag(String tag) {
    final newTags = List<String>.from(selectedTags);

    if (newTags.contains(tag)) {
      // Se a tag já está selecionada, remove ela (desmarca)
      newTags.remove(tag);
    } else {
      // Seleção exclusiva: limpa todas as tags e adiciona apenas esta
      newTags.clear();
      newTags.add(tag);
    }

    onTagsChanged(newTags);
  }
}
