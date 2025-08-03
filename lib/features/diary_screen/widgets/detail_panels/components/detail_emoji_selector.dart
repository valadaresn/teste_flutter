import 'package:flutter/material.dart';
import '../../../../../screens/diary_screen/diary_styles.dart';
import '../utils/detail_panel_constants.dart';

/// **DetailEmojiSelector** - Popup seletor de emoji
///
/// Componente responsável por exibir e gerenciar a seleção de emojis/moods:
/// - Menu popup com lista de emojis
/// - Indicação visual do emoji selecionado
/// - Nomes descritivos dos moods
/// - Animações e feedback visual
class DetailEmojiSelector {
  final List<String> availableMoods;
  final String currentMood;
  final ValueChanged<String> onMoodSelected;

  const DetailEmojiSelector({
    required this.availableMoods,
    required this.currentMood,
    required this.onMoodSelected,
  });

  /// 🎭 Mostra o popup seletor de emoji
  static Future<String?> show({
    required BuildContext context,
    required List<String> availableMoods,
    required String currentMood,
    Offset? position,
  }) {
    // Se não fornecida, calcula posição baseada no contexto
    final renderBox = context.findRenderObject() as RenderBox?;
    final calculatedPosition =
        position ?? (renderBox?.localToGlobal(Offset.zero) ?? Offset.zero);

    return showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        calculatedPosition.dx - 200,
        calculatedPosition.dy - 250,
        calculatedPosition.dx,
        calculatedPosition.dy,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DetailPanelConstants.borderRadius),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      elevation: 12,
      items:
          availableMoods.map((mood) {
            final isSelected = mood == currentMood;
            return PopupMenuItem<String>(
              value: mood,
              child: DetailEmojiSelectorItem(
                mood: mood,
                isSelected: isSelected,
              ),
            );
          }).toList(),
    );
  }

  /// 📱 Mostra o seletor como bottom sheet (para mobile)
  static Future<String?> showBottomSheet({
    required BuildContext context,
    required List<String> availableMoods,
    required String currentMood,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DetailEmojiBottomSheet(
            availableMoods: availableMoods,
            currentMood: currentMood,
          ),
    );
  }
}

/// **DetailEmojiSelectorItem** - Item individual do seletor
///
/// Representa um emoji individual no menu de seleção.
class DetailEmojiSelectorItem extends StatelessWidget {
  final String mood;
  final bool isSelected;
  final VoidCallback? onTap;

  const DetailEmojiSelectorItem({
    Key? key,
    required this.mood,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
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
                  color:
                      isSelected ? Colors.blue.shade700 : Colors.grey.shade800,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 18, color: Colors.blue.shade600),
          ],
        ),
      ),
    );
  }
}

/// **DetailEmojiBottomSheet** - Bottom sheet para seleção de emoji
///
/// Versão em bottom sheet para dispositivos móveis.
class DetailEmojiBottomSheet extends StatelessWidget {
  final List<String> availableMoods;
  final String currentMood;

  const DetailEmojiBottomSheet({
    Key? key,
    required this.availableMoods,
    required this.currentMood,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle do bottom sheet
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Selecione o humor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            // Lista de emojis
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: availableMoods.length,
                itemBuilder: (context, index) {
                  final mood = availableMoods[index];
                  final isSelected = mood == currentMood;

                  return DetailEmojiSelectorItem(
                    mood: mood,
                    isSelected: isSelected,
                    onTap: () => Navigator.of(context).pop(mood),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// **DetailEmojiGrid** - Grid de emojis para seleção
///
/// Layout em grid para exibir emojis quando há muitas opções.
class DetailEmojiGrid extends StatelessWidget {
  final List<String> availableMoods;
  final String currentMood;
  final ValueChanged<String> onMoodSelected;
  final int crossAxisCount;

  const DetailEmojiGrid({
    Key? key,
    required this.availableMoods,
    required this.currentMood,
    required this.onMoodSelected,
    this.crossAxisCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: availableMoods.length,
      itemBuilder: (context, index) {
        final mood = availableMoods[index];
        final isSelected = mood == currentMood;

        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? DiaryStyles.getMoodColor(mood)
                      : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(mood, style: const TextStyle(fontSize: 24)),
            ),
          ),
        );
      },
    );
  }
}
