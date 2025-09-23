import 'package:flutter/material.dart';
import 'simple_modular_base_card.dart';
import 'modules/simple_left_border_module.dart';

/// NoteCard - Card para notas usando sistema modular
class NoteCard extends StatelessWidget {
  final dynamic
  note; // Note object (aceita qualquer tipo com as propriedades necessárias)
  final VoidCallback onTap;
  final Color Function(String) getTagColor;
  final bool hasActiveFilters;
  final bool isSelected;
  final Function(String)? onTagTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.getTagColor,
    this.hasActiveFilters = false,
    this.isSelected = false,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 NoteCard com borda esquerda e configurações personalizadas
    return ModularBaseCard(
      title:
          note.title?.isEmpty == true
              ? 'Sem título'
              : (note.title ?? 'Sem título'),
      content: note.content,
      onTap: onTap,
      isSelected: isSelected,
      backgroundColor: isSelected ? Colors.grey.shade200 : Colors.white,

      // 🔧 NOVAS CONFIGURAÇÕES
      maxContentLines: 1, // Limitar conteúdo a 1 linha
      contentOverflow: TextOverflow.ellipsis, // Adicionar "..." no final
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ), // Bordas personalizadas

      modules: [
        // Borda esquerda com cor da primeira tag
        if (note.tags != null && note.tags.isNotEmpty)
          LeftBorderModuleFactory.fromFirstTag(
            tags: List<String>.from(note.tags),
            getTagColor: getTagColor,
            width: 5,
          ),
      ],
    );
  }
}
