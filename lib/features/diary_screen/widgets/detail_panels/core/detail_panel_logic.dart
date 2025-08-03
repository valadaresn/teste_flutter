import 'package:flutter/material.dart';
import '../../../../../screens/diary_screen/diary_styles.dart';
import '../utils/detail_panel_constants.dart';
import '../utils/detail_panel_helpers.dart';
import 'detail_panel_state.dart';

/// **DetailPanelLogicMixin** - Mixin para lógica de negócio dos painéis
///
/// Fornece métodos de lógica de negócio que não dependem do estado específico:
/// - Formatação de data/hora
/// - Exibição de popups e seletores
/// - Validação de dados
/// - Helpers para UI
mixin DetailPanelLogicMixin<T extends StatefulWidget>
    on State<T>, DetailPanelStateMixin<T> {
  /// 📅 Formata data e hora para exibição
  String formatDateTime(DateTime dateTime) {
    return DetailPanelHelpers.formatDateTime(dateTime);
  }

  /// 😊 Mostra popup seletor de emoji
  void showEmojiPopup() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - 200,
        position.dy - 250,
        position.dx,
        position.dy,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DetailPanelConstants.borderRadius),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 12,
      items:
          availableMoods.map((mood) {
            final isSelected = mood == selectedMood;
            return PopupMenuItem<String>(
              value: mood,
              child: _buildEmojiMenuItem(mood, isSelected),
            );
          }).toList(),
    ).then((selectedMoodValue) {
      if (selectedMoodValue != null) {
        changeMood(selectedMoodValue);
      }
    });
  }

  /// 🎨 Constrói item do menu de emoji
  Widget _buildEmojiMenuItem(String mood, bool isSelected) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? DiaryStyles.getMoodColor(mood)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? Border.all(color: Colors.blue.shade300, width: 2)
                    : null,
          ),
          child: Text(mood, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            DiaryStyles.getMoodName(mood),
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade800,
            ),
          ),
        ),
        if (isSelected)
          Icon(Icons.check_circle, size: 18, color: Colors.blue.shade600),
      ],
    );
  }

  /// 🎨 Obtém cor do mood selecionado
  Color getMoodColor(String mood) {
    return DiaryStyles.getMoodColor(mood);
  }

  /// 🏷️ Obtém nome do mood
  String getMoodName(String mood) {
    return DiaryStyles.getMoodName(mood);
  }

  /// 📝 Manipula mudanças no campo de texto
  void onContentChanged(String value) {
    debugPrint('📝 onContentChanged: "$value"');
    debugPrint('📝 hasUnsavedChanges: $hasUnsavedChanges');
    debugPrint('📝 originalContent: "$originalContent"');

    final contentChanged = DetailPanelHelpers.hasContentChanged(
      originalContent,
      value,
    );
    debugPrint('📝 contentChanged: $contentChanged');

    if (!hasUnsavedChanges && contentChanged) {
      debugPrint(
        '📝 Marcando como tendo mudanças não salvas via onContentChanged',
      );
      setState(() => hasUnsavedChanges = true);
    }
  }

  /// 🎯 Obtém cor do ícone de favorito
  Color getFavoriteIconColor(bool isFavorite) {
    return isFavorite ? Colors.yellow.shade700 : Colors.grey.shade600;
  }

  /// 🎨 Obtém cor de fundo do container de favorito
  Color getFavoriteBackgroundColor(bool isFavorite) {
    return isFavorite ? Colors.yellow.shade100 : Colors.transparent;
  }

  /// 🎯 Obtém cor da borda do container de favorito
  Color getFavoriteBorderColor(bool isFavorite) {
    return isFavorite ? Colors.yellow.shade400 : Colors.grey.shade300;
  }

  /// ⚡ Obtém ícone do favorito
  IconData getFavoriteIcon(bool isFavorite) {
    return isFavorite ? Icons.star : Icons.star_border;
  }

  /// 🔄 Obtém widget de indicador de status
  Widget getStatusIndicator() {
    if (isSaving) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        ),
      );
    } else if (hasUnsavedChanges) {
      return Icon(Icons.circle, size: 8, color: Colors.orange.shade600);
    }

    return const SizedBox.shrink();
  }

  /// 📏 Valida se o conteúdo é válido
  bool isContentValid() {
    return contentController.text.trim().isNotEmpty;
  }

  /// 🎭 Verifica se o mood é válido
  bool isMoodValid(String mood) {
    return availableMoods.contains(mood);
  }

  /// 🔧 Obtém decoração padrão para containers
  BoxDecoration getContainerDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? DetailPanelConstants.contentBackgroundColor,
      borderRadius: BorderRadius.circular(
        borderRadius ?? DetailPanelConstants.borderRadius,
      ),
      border: Border.all(color: borderColor ?? Colors.grey.shade200, width: 1),
    );
  }

  /// 📱 Verifica se está em modo mobile
  bool get isMobileMode => DetailPanelHelpers.isMobile(context);

  /// 🖥️ Verifica se está em modo desktop
  bool get isDesktopMode => DetailPanelHelpers.isDesktop(context);
}
