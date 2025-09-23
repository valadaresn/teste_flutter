import 'package:flutter/material.dart';
import 'modular_card.dart';
import '../../../utils/widget_mods.dart';

/// 📝 **DiaryCard** - Card simplificado para entradas de diário
class DiaryCard extends StatelessWidget {
  const DiaryCard({
    super.key,
    this.title,
    required this.content,
    required this.mood, // Emoji do humor
    required this.dateTime,
    this.isFavorite = false,
    this.showFavorite = true,
    this.onTap, // Callback para tap no card inteiro
    this.onToggleFavorite, // Callback para toggle do favorito
    this.isSelected = false, // Se o card está selecionado
    this.maxLines = 2,
  });

  final String? title;
  final String content;
  final String mood;
  final DateTime dateTime;
  final bool isFavorite;
  final bool showFavorite;
  final VoidCallback? onTap;
  final Function(bool)? onToggleFavorite;
  final bool isSelected;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return ModularCard(
      onTap: onTap,
      backgroundColor: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
      crossAxisAlignment: CrossAxisAlignment.center, //verticalmente
      footerSpacing: 4, // ✅ Es    paçamento menor entre conteúdo e footer
      // 😊 Emoji com fundo colorido
      leading: Text(
        mood.isEmpty ? '📝' : mood,
        style: const TextStyle(fontSize: 18),
      ).center().container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _getMoodColor(mood),
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // 📝 Conteúdo principal (ao lado direito do emoji, na Row)
      content: Text(
        title?.isNotEmpty == true ? title! : content,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: title?.isNotEmpty == true ? 16 : 14,
          fontWeight:
              title?.isNotEmpty == true ? FontWeight.w600 : FontWeight.normal,
          height: 1.3,
        ),
      ),

      // 🕐 Rodapé com hora e favorito
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hora
          Text(
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.0,
            ),
          ),

          // Favorito
          if (showFavorite || isFavorite)
            Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: isFavorite ? Colors.red.shade600 : Colors.grey.shade400,
            ).when(
              onToggleFavorite != null,
              (icon) =>
                  icon.tappable(() => onToggleFavorite?.call(!isFavorite)),
            ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case '😊':
      case '😄':
      case '🙂':
      case '😁':
      case '🥰':
        return Colors.green.withOpacity(0.15);
      case '😢':
      case '😭':
      case '😞':
      case '😔':
      case '🥺':
        return Colors.blue.withOpacity(0.15);
      case '😡':
      case '😠':
      case '🤬':
      case '😤':
        return Colors.red.withOpacity(0.15);
      case '😴':
      case '😪':
      case '🥱':
      case '😑':
        return Colors.purple.withOpacity(0.15);
      case '😰':
      case '😥':
      case '😓':
      case '😵':
        return Colors.orange.withOpacity(0.15);
      case '😲':
      case '🤩':
      case '😍':
      case '🥳':
        return Colors.yellow.withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }
}
