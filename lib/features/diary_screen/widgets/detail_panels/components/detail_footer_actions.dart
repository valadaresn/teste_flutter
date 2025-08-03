import 'package:flutter/material.dart';
import '../../../../../screens/diary_screen/diary_styles.dart';
import '../utils/detail_panel_constants.dart';

/// **DetailFooterActions** - Rodapé com ações (emoji, favorito, exclusão)
///
/// Componente que centraliza todas as ações disponíveis para uma entrada:
/// - Seletor de emoji/mood
/// - Toggle de favorito
/// - Botão de exclusão
/// - Layout responsivo e configurável
class DetailFooterActions extends StatelessWidget {
  final String selectedMood;
  final bool isFavorite;
  final VoidCallback onEmojiTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onDeleteTap;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final MainAxisAlignment? alignment;
  final bool showLabels;

  const DetailFooterActions({
    Key? key,
    required this.selectedMood,
    required this.isFavorite,
    required this.onEmojiTap,
    required this.onFavoriteTap,
    required this.onDeleteTap,
    this.backgroundColor,
    this.padding,
    this.alignment,
    this.showLabels = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? DetailPanelConstants.contentBackgroundColor,
        borderRadius: BorderRadius.circular(DetailPanelConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: alignment ?? MainAxisAlignment.spaceEvenly,
        children: [
          _buildEmojiButton(),
          _buildFavoriteButton(),
          _buildDeleteButton(),
        ],
      ),
    );
  }

  /// 😊 Constrói botão de emoji/mood
  Widget _buildEmojiButton() {
    return GestureDetector(
      onTap: onEmojiTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DiaryStyles.getMoodColor(selectedMood),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Text(
              selectedMood,
              style: const TextStyle(fontSize: DetailPanelConstants.emojiSize),
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: 4),
            Text(
              'Humor',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  /// ⭐ Constrói botão de favorito
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: onFavoriteTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFavorite ? Colors.yellow.shade100 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isFavorite ? Colors.yellow.shade400 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.yellow.shade700 : Colors.grey.shade600,
              size: DetailPanelConstants.iconSize,
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: 4),
            Text(
              'Favorito',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  /// 🗑️ Constrói botão de exclusão
  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: onDeleteTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Colors.red.shade600,
              size: DetailPanelConstants.iconSize,
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: 4),
            Text(
              'Excluir',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

/// **DetailFooterActionsCompact** - Versão compacta das ações
///
/// Layout mais compacto para contextos com espaço limitado.
class DetailFooterActionsCompact extends StatelessWidget {
  final String selectedMood;
  final bool isFavorite;
  final VoidCallback onEmojiTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onDeleteTap;

  const DetailFooterActionsCompact({
    Key? key,
    required this.selectedMood,
    required this.isFavorite,
    required this.onEmojiTap,
    required this.onFavoriteTap,
    required this.onDeleteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailFooterActions(
      selectedMood: selectedMood,
      isFavorite: isFavorite,
      onEmojiTap: onEmojiTap,
      onFavoriteTap: onFavoriteTap,
      onDeleteTap: onDeleteTap,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      showLabels: false,
    );
  }
}

/// **DetailFooterActionsHorizontal** - Layout horizontal das ações
///
/// Para uso em headers ou outras áreas onde as ações devem ficar em linha.
class DetailFooterActionsHorizontal extends StatelessWidget {
  final String selectedMood;
  final bool isFavorite;
  final VoidCallback onEmojiTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onDeleteTap;

  const DetailFooterActionsHorizontal({
    Key? key,
    required this.selectedMood,
    required this.isFavorite,
    required this.onEmojiTap,
    required this.onFavoriteTap,
    required this.onDeleteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactButton(
          onTap: onEmojiTap,
          child: Text(selectedMood, style: const TextStyle(fontSize: 16)),
          backgroundColor: DiaryStyles.getMoodColor(selectedMood),
        ),
        const SizedBox(width: 8),
        _buildCompactButton(
          onTap: onFavoriteTap,
          child: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            size: 16,
            color: isFavorite ? Colors.yellow.shade700 : Colors.grey.shade600,
          ),
          backgroundColor: isFavorite ? Colors.yellow.shade100 : null,
        ),
        const SizedBox(width: 8),
        _buildCompactButton(
          onTap: onDeleteTap,
          child: Icon(
            Icons.delete_outline,
            size: 16,
            color: Colors.red.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactButton({
    required VoidCallback onTap,
    required Widget child,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: child,
      ),
    );
  }
}
