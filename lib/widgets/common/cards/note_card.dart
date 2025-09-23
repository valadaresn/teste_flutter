import 'package:flutter/material.dart';
import 'modular_card.dart';

/// 📝 **NoteCard** - Card simplificado para notas
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    this.title,
    required this.content,
    this.tags,
    this.createdAt,
    this.updatedAt,
    this.onTap, // Callback para tap no card inteiro
    this.onTagTap, // Callback para tap em uma tag
    this.isSelected = false, // Se o card está selecionado
    this.maxLines = 3,
    this.showBorder = true,
    this.getTagColor,
  });

  final String? title;
  final String content;
  final List<String>? tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VoidCallback? onTap;
  final Function(String)? onTagTap;
  final bool isSelected;
  final int maxLines;
  final bool showBorder;
  final Color Function(String)? getTagColor; // Função para cor da tag

  @override
  Widget build(BuildContext context) {
    final primaryTag = tags?.isNotEmpty == true ? tags!.first : null;
    final borderColor =
        primaryTag != null && getTagColor != null
            ? getTagColor!(primaryTag)
            : null;

    return ModularCard(
      onTap: onTap,
      backgroundColor: isSelected ? Colors.grey.shade50 : Colors.white,

      // 🏷️ Remover leading - agora usaremos a borda do card
      leading: null,

      // 📝 Título (se existir)
      title:
          title?.isNotEmpty == true
              ? Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              )
              : null,

      // 📄 Conteúdo principal
      content: Text(
        content,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          height: 1.3,
          color: Colors.grey.shade800,
        ),
      ),

      // 🏷️ Footer - removido (não aparece na imagem)
      footer: null,

      // 🎨 Customização da borda esquerda - prop de modular_card
      leftBorderColor: showBorder ? borderColor : null,
      leftBorderWidth: showBorder ? 5.0 : 0,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
        // Borda esquerda reta
      ),
    );
  }
}

// // /// 🏭 **Factory para casos específicos**
// // class NoteCardFactory {
// //   /// Card compacto (1 linha de conteúdo)
// //   static NoteCard compact({
// //     Key? key,
// //     String? title,
// //     required String content,
// //     List<String>? tags,
// //     DateTime? createdAt,
// //     DateTime? updatedAt,
// //     VoidCallback? onTap,
// //     Function(String)? onTagTap,
// //     bool isSelected = false,
// //     Color Function(String)? getTagColor,
// //   }) {
// //     return NoteCard(
// //       key: key,
// //       title: title,
// //       content: content,
// //       tags: tags,
// //       createdAt: createdAt,
// //       updatedAt: updatedAt,
// //       onTap: onTap,
// //       onTagTap: onTagTap,
// //       isSelected: isSelected,
// //       maxLines: 1,
// //       getTagColor: getTagColor,
// //     );
// //   }

// //   /// Card sem borda colorida
// //   static NoteCard simple({
// //     Key? key,
// //     String? title,
// //     required String content,
// //     List<String>? tags,
// //     DateTime? createdAt,
// //     DateTime? updatedAt,
// //     VoidCallback? onTap,
// //     Function(String)? onTagTap,
// //     bool isSelected = false,
// //     int maxLines = 3,
// //     Color Function(String)? getTagColor,
// //   }) {
// //     return NoteCard(
// //       key: key,
// //       title: title,
// //       content: content,
// //       tags: tags,
// //       createdAt: createdAt,
// //       updatedAt: updatedAt,
// //       onTap: onTap,
// //       onTagTap: onTagTap,
// //       isSelected: isSelected,
// //       maxLines: maxLines,
// //       showBorder: false,
// //       getTagColor: getTagColor,
// //     );
// //   }

// //   /// Card para preview (sem interações)
// //   static NoteCard preview({
// //     Key? key,
// //     String? title,
// //     required String content,
// //     List<String>? tags,
// //     DateTime? createdAt,
// //     int maxLines = 2,
// //     Color Function(String)? getTagColor,
// //   }) {
// //     return NoteCard(
// //       key: key,
// //       title: title,
// //       content: content,
// //       tags: tags,
// //       createdAt: createdAt,
// //       maxLines: maxLines,
// //       showBorder: true,
// //       getTagColor: getTagColor,
// //       // Sem onTap - não clicável
// //     );
// //   }
// }
